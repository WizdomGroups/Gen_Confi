import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Simple face status for corner guide colors
enum SimpleFaceStatus {
  noFace,      // No overlay shown
  detected,    // Blue corner guides
  aligned,     // Green corner guides
  captured,    // Emerald with glow
}

/// Simple Face Tracking Overlay with Corner Guides Only
/// 
/// This is a minimal, clean implementation that:
/// - Shows only 4 L-shaped corner guides (no full rectangle)
/// - Tracks face bounding box smoothly
/// - Changes color based on face status
/// - No landmarks, no mesh, no complex logic
class SimpleFaceTrackingOverlay extends StatefulWidget {
  /// Face bounding box from SDK (in camera coordinates)
  /// If null, no overlay is shown
  final Rect? faceRect;
  
  /// Face status for color state
  final SimpleFaceStatus status;
  
  /// Camera preview size (for coordinate mapping)
  final Size cameraSize;
  
  /// Screen size (for coordinate mapping)
  final Size screenSize;
  
  /// Animation duration for smooth movement (default: 250ms)
  final Duration animationDuration;
  
  /// Corner guide length (default: 24.0)
  final double cornerLength;
  
  /// Stroke width (default: 3.0)
  final double strokeWidth;

  const SimpleFaceTrackingOverlay({
    Key? key,
    this.faceRect,
    this.status = SimpleFaceStatus.noFace,
    required this.cameraSize,
    required this.screenSize,
    this.animationDuration = const Duration(milliseconds: 250),
    this.cornerLength = 24.0,
    this.strokeWidth = 3.0,
  }) : super(key: key);

  @override
  State<SimpleFaceTrackingOverlay> createState() => _SimpleFaceTrackingOverlayState();
}

class _SimpleFaceTrackingOverlayState extends State<SimpleFaceTrackingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Rect?> _animatedRect;
  late Animation<Color?> _animatedColor;
  
  Rect? _previousRect;
  SimpleFaceStatus _previousStatus = SimpleFaceStatus.noFace;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    // Initialize with current values
    _animatedRect = AlwaysStoppedAnimation<Rect?>(null);
    _animatedColor = AlwaysStoppedAnimation<Color?>(_getColorForStatus(widget.status));
    
    // Start animation if face is already detected
    if (widget.faceRect != null) {
      _updateAnimation(widget.faceRect, widget.status);
    }
  }

  @override
  void didUpdateWidget(SimpleFaceTrackingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update animation when face rect or status changes
    if (widget.faceRect != oldWidget.faceRect || widget.status != oldWidget.status) {
      _updateAnimation(widget.faceRect, widget.status);
    }
  }

  void _updateAnimation(Rect? newRect, SimpleFaceStatus newStatus) {
    // Map camera coordinates to screen coordinates
    final screenRect = newRect != null ? _mapCameraToScreen(newRect) : null;
    
    // Create rect animation
    if (screenRect != null && _previousRect != null) {
      // Smooth transition from previous to new rect
      _animatedRect = RectTween(
        begin: _previousRect,
        end: screenRect,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ));
    } else {
      // Instant transition for first appearance or disappearance
      _animatedRect = Tween<Rect?>(
        begin: _previousRect,
        end: screenRect,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ));
    }
    
    // Create color animation
    _animatedColor = ColorTween(
      begin: _getColorForStatus(_previousStatus),
      end: _getColorForStatus(newStatus),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Update previous values
    _previousRect = screenRect;
    _previousStatus = newStatus;
    
    // Start animation
    _animationController.forward(from: 0.0);
  }

  /// Map camera coordinates to screen coordinates
  /// Handles aspect ratio differences (letterboxing/pillarboxing)
  Rect _mapCameraToScreen(Rect cameraRect) {
    try {
      // Validate inputs to prevent exceptions
      if (widget.cameraSize.width <= 0 || widget.cameraSize.height <= 0 ||
          widget.screenSize.width <= 0 || widget.screenSize.height <= 0 ||
          cameraRect.width <= 0 || cameraRect.height <= 0) {
        return cameraRect;
      }
      
      final cameraAspect = widget.cameraSize.width / widget.cameraSize.height;
      final screenAspect = widget.screenSize.width / widget.screenSize.height;
      
      // Prevent division by zero
      if (cameraAspect <= 0 || screenAspect <= 0) {
        return cameraRect;
      }
      
      double scale;
      double offsetX = 0;
      double offsetY = 0;
      
      if (cameraAspect > screenAspect) {
        // Camera is wider - letterbox (black bars top/bottom)
        scale = widget.screenSize.width / widget.cameraSize.width;
        if (scale <= 0 || !scale.isFinite) {
          return cameraRect;
        }
        final scaledHeight = widget.cameraSize.height * scale;
        offsetY = (widget.screenSize.height - scaledHeight) / 2;
      } else {
        // Camera is taller - pillarbox (black bars left/right)
        scale = widget.screenSize.height / widget.cameraSize.height;
        if (scale <= 0 || !scale.isFinite) {
          return cameraRect;
        }
        final scaledWidth = widget.cameraSize.width * scale;
        offsetX = (widget.screenSize.width - scaledWidth) / 2;
      }
      
      // Validate calculated values
      final left = cameraRect.left * scale + offsetX;
      final top = cameraRect.top * scale + offsetY;
      final width = cameraRect.width * scale;
      final height = cameraRect.height * scale;
      
      if (!left.isFinite || !top.isFinite || !width.isFinite || !height.isFinite ||
          width <= 0 || height <= 0) {
        return cameraRect;
      }
      
      return Rect.fromLTWH(left, top, width, height);
    } catch (e) {
      debugPrint("_mapCameraToScreen error: $e");
      // Return original rect on error to prevent crash
      return cameraRect;
    }
  }

  /// Get color for face status
  Color _getColorForStatus(SimpleFaceStatus status) {
    switch (status) {
      case SimpleFaceStatus.noFace:
        return Colors.transparent;
      case SimpleFaceStatus.detected:
        return const Color(0xFF3B82F6); // Blue-500
      case SimpleFaceStatus.aligned:
        return const Color(0xFF10B981); // Green-500
      case SimpleFaceStatus.captured:
        return const Color(0xFF10B981); // Emerald-500
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      // Don't show overlay if no face or status is noFace
      if (widget.faceRect == null || widget.status == SimpleFaceStatus.noFace) {
        return const SizedBox.shrink();
      }

      // Validate screen size
      if (widget.screenSize.width <= 0 || widget.screenSize.height <= 0) {
        return const SizedBox.shrink();
      }

      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          try {
            final currentRect = _animatedRect.value;
            final currentColor = _animatedColor.value ?? _getColorForStatus(widget.status);
            
            if (currentRect == null) {
              return const SizedBox.shrink();
            }
            
            // Validate rect values
            if (!currentRect.width.isFinite || !currentRect.height.isFinite ||
                currentRect.width <= 0 || currentRect.height <= 0) {
              return const SizedBox.shrink();
            }
            
            return CustomPaint(
              painter: CornerGuidePainter(
                faceRect: currentRect,
                color: currentColor,
                status: widget.status,
                cornerLength: widget.cornerLength,
                strokeWidth: widget.strokeWidth,
              ),
              size: widget.screenSize,
            );
          } catch (e) {
            debugPrint("AnimatedBuilder error: $e");
            return const SizedBox.shrink();
          }
        },
      );
    } catch (e) {
      debugPrint("SimpleFaceTrackingOverlay build error: $e");
      return const SizedBox.shrink();
    }
  }
}

/// Custom painter for corner guides only
/// 
/// Draws 4 L-shaped corner guides at the corners of the face rect
/// No full rectangle, no landmarks, no mesh - just clean corner guides
class CornerGuidePainter extends CustomPainter {
  final Rect faceRect;
  final Color color;
  final SimpleFaceStatus status;
  final double cornerLength;
  final double strokeWidth;

  CornerGuidePainter({
    required this.faceRect,
    required this.color,
    required this.status,
    required this.cornerLength,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw glow effect for captured state
    if (status == SimpleFaceStatus.captured) {
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 6.0
        ..color = color.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);
      
      _drawCornerGuides(canvas, glowPaint);
    }
    
    // Draw main corner guides
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    
    _drawCornerGuides(canvas, paint);
  }

  /// Draw 4 L-shaped corner guides
  void _drawCornerGuides(Canvas canvas, Paint paint) {
    final gap = 4.0; // Small gap from corner for cleaner look
    
    // Top-left corner (L-shape pointing inward)
    canvas.drawLine(
      Offset(faceRect.left + gap, faceRect.top),
      Offset(faceRect.left + gap + cornerLength, faceRect.top),
      paint,
    );
    canvas.drawLine(
      Offset(faceRect.left, faceRect.top + gap),
      Offset(faceRect.left, faceRect.top + gap + cornerLength),
      paint,
    );
    
    // Top-right corner
    canvas.drawLine(
      Offset(faceRect.right - gap, faceRect.top),
      Offset(faceRect.right - gap - cornerLength, faceRect.top),
      paint,
    );
    canvas.drawLine(
      Offset(faceRect.right, faceRect.top + gap),
      Offset(faceRect.right, faceRect.top + gap + cornerLength),
      paint,
    );
    
    // Bottom-left corner
    canvas.drawLine(
      Offset(faceRect.left + gap, faceRect.bottom),
      Offset(faceRect.left + gap + cornerLength, faceRect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(faceRect.left, faceRect.bottom - gap),
      Offset(faceRect.left, faceRect.bottom - gap - cornerLength),
      paint,
    );
    
    // Bottom-right corner
    canvas.drawLine(
      Offset(faceRect.right - gap, faceRect.bottom),
      Offset(faceRect.right - gap - cornerLength, faceRect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(faceRect.right, faceRect.bottom - gap),
      Offset(faceRect.right, faceRect.bottom - gap - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(CornerGuidePainter oldDelegate) {
    // Only repaint if face rect, color, or status changed
    return oldDelegate.faceRect != faceRect ||
        oldDelegate.color != color ||
        oldDelegate.status != status;
  }
}

