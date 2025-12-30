import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import '../logic/face_capture_logic.dart';

class SmartCaptureOverlay extends StatelessWidget {
  final String instruction;
  final bool isReady;
  final Rect? faceRect;
  final Size imageSize;
  final FacePositionInfo? positionInfo;
  final List<Offset>? landmarks;

  const SmartCaptureOverlay({
    Key? key,
    required this.instruction,
    this.isReady = false,
    this.faceRect,
    required this.imageSize,
    this.positionInfo,
    this.landmarks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: _OverlayPainter(
            isReady: isReady,
            faceRect: faceRect,
            imageSize: imageSize,
            screenSize: screenSize,
            positionInfo: positionInfo,
            landmarks: landmarks,
          ),
        ),
        // Instruction Card with better design
        Positioned(
          bottom: 100,
          left: 20,
          right: 20,
          child: _buildInstructionCard(),
        ),
        // Status indicator at top
        if (isReady)
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: _buildStatusIndicator(),
          ),
      ],
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: isReady 
          ? Colors.green.withOpacity(0.9)
          : Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isReady ? Colors.greenAccent : Colors.white.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            instruction,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          if (isReady) ...[
            const SizedBox(height: 8),
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            "Ready to capture",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final bool isReady;
  final Rect? faceRect;
  final Size imageSize;
  final Size screenSize;
  final FacePositionInfo? positionInfo;
  final List<Offset>? landmarks;

  _OverlayPainter({
    required this.isReady,
    this.faceRect,
    required this.imageSize,
    required this.screenSize,
    this.positionInfo,
    this.landmarks,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final center = Offset(width / 2, height / 2 - 40);
    
    // Color scheme based on status
    final primaryColor = isReady ? Colors.greenAccent : Colors.cyanAccent;
    final warningColor = Colors.orangeAccent;
    final errorColor = Colors.redAccent;
    final gridColor = Colors.cyan.withOpacity(0.1);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw subtle grid background
    paint.color = gridColor;
    double gridSize = 40.0;
    
    for (double x = 0; x < width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, height), paint);
    }
    for (double y = 0; y < height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(width, y), paint);
    }

    // Draw target guide frame (ideal position)
    final guideWidth = width * 0.7;
    final guideHeight = guideWidth * 1.3;
    final guideRect = Rect.fromCenter(center: center, width: guideWidth, height: guideHeight);

    // Draw actual face bounding box if available
    if (faceRect != null && positionInfo != null) {
      // Convert face rect from image coordinates to screen coordinates
      final scaleX = width / imageSize.width;
      final scaleY = height / imageSize.height;
      final scale = scaleX < scaleY ? scaleX : scaleY;
      
      final scaledRect = Rect.fromLTWH(
        (faceRect!.left * scale) + (width - imageSize.width * scale) / 2,
        (faceRect!.top * scale) + (height - imageSize.height * scale) / 2,
        faceRect!.width * scale,
        faceRect!.height * scale,
      );

      // Determine status color
      Color statusColor = primaryColor;
      if (!isReady) {
        if (positionInfo!.centerOffsetX.abs() > 0.2 || 
            positionInfo!.centerOffsetY.abs() > 0.2 ||
            positionInfo!.distanceRatio < 0.3 || 
            positionInfo!.distanceRatio > 0.7) {
          statusColor = errorColor;
        } else {
          statusColor = warningColor;
        }
      }

      // Draw face bounding box with status color
      paint.color = statusColor;
      paint.strokeWidth = 3.0;
      paint.style = PaintingStyle.stroke;
      canvas.drawRect(scaledRect, paint);

      // Draw corner brackets on face rect
      paint.strokeWidth = 4.0;
      double cornerLen = 25.0;
      double cornerGap = 8.0;

      // Top Left
      canvas.drawLine(
        scaledRect.topLeft + Offset(-cornerGap, cornerLen),
        scaledRect.topLeft + Offset(-cornerGap, -cornerGap),
        paint,
      );
      canvas.drawLine(
        scaledRect.topLeft + Offset(-cornerGap, -cornerGap),
        scaledRect.topLeft + Offset(cornerLen, -cornerGap),
        paint,
      );

      // Top Right
      canvas.drawLine(
        scaledRect.topRight + Offset(cornerGap, cornerLen),
        scaledRect.topRight + Offset(cornerGap, -cornerGap),
        paint,
      );
      canvas.drawLine(
        scaledRect.topRight + Offset(cornerGap, -cornerGap),
        scaledRect.topRight + Offset(-cornerLen, -cornerGap),
        paint,
      );

      // Bottom Left
      canvas.drawLine(
        scaledRect.bottomLeft + Offset(-cornerGap, -cornerLen),
        scaledRect.bottomLeft + Offset(-cornerGap, cornerGap),
        paint,
      );
      canvas.drawLine(
        scaledRect.bottomLeft + Offset(-cornerGap, cornerGap),
        scaledRect.bottomLeft + Offset(cornerLen, cornerGap),
        paint,
      );

      // Bottom Right
      canvas.drawLine(
        scaledRect.bottomRight + Offset(cornerGap, -cornerLen),
        scaledRect.bottomRight + Offset(cornerGap, cornerGap),
        paint,
      );
      canvas.drawLine(
        scaledRect.bottomRight + Offset(cornerGap, cornerGap),
        scaledRect.bottomRight + Offset(-cornerLen, cornerGap),
        paint,
      );

      // Draw face mesh/landmarks (like the image style)
      if (landmarks != null && landmarks!.isNotEmpty) {
        _drawFaceMesh(canvas, scaledRect, landmarks!, imageSize, screenSize.width, screenSize.height, statusColor);
      }

      // Draw center point
      final centerPaint = Paint()
        ..color = statusColor.withOpacity(0.8)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(scaledRect.center, 5.0, centerPaint);

      // Draw directional arrows if face is not centered
      if (!isReady) {
        _drawDirectionalArrows(canvas, scaledRect, guideRect, positionInfo!, statusColor);
      }

      // Draw distance indicator
      _drawDistanceIndicator(canvas, scaledRect, positionInfo!, statusColor);

      // Draw guide frame (ideal position) with transparency
      paint.color = statusColor.withOpacity(0.2);
      paint.strokeWidth = 2.0;
      paint.style = PaintingStyle.stroke;
      canvas.drawRect(guideRect, paint);
    } else {
      // No face detected - show guide frame only
      paint.color = errorColor.withOpacity(0.5);
      paint.strokeWidth = 2.0;
      paint.style = PaintingStyle.stroke;
      canvas.drawRect(guideRect, paint);

      // Draw corner brackets on guide frame
      paint.color = errorColor;
      paint.strokeWidth = 3.0;
      double cornerLen = 30.0;
      double cornerGap = 10.0;

      // Top Left
      canvas.drawLine(
        guideRect.topLeft + Offset(-cornerGap, cornerLen),
        guideRect.topLeft + Offset(-cornerGap, -cornerGap),
        paint,
      );
      canvas.drawLine(
        guideRect.topLeft + Offset(-cornerGap, -cornerGap),
        guideRect.topLeft + Offset(cornerLen, -cornerGap),
        paint,
      );

      // Top Right
      canvas.drawLine(
        guideRect.topRight + Offset(cornerGap, cornerLen),
        guideRect.topRight + Offset(cornerGap, -cornerGap),
        paint,
      );
      canvas.drawLine(
        guideRect.topRight + Offset(cornerGap, -cornerGap),
        guideRect.topRight + Offset(-cornerLen, -cornerGap),
        paint,
      );

      // Bottom Left
      canvas.drawLine(
        guideRect.bottomLeft + Offset(-cornerGap, -cornerLen),
        guideRect.bottomLeft + Offset(-cornerGap, cornerGap),
        paint,
      );
      canvas.drawLine(
        guideRect.bottomLeft + Offset(-cornerGap, cornerGap),
        guideRect.bottomLeft + Offset(cornerLen, cornerGap),
        paint,
      );

      // Bottom Right
      canvas.drawLine(
        guideRect.bottomRight + Offset(cornerGap, -cornerLen),
        guideRect.bottomRight + Offset(cornerGap, cornerGap),
        paint,
      );
      canvas.drawLine(
        guideRect.bottomRight + Offset(cornerGap, cornerGap),
        guideRect.bottomRight + Offset(-cornerLen, cornerGap),
        paint,
      );
    }

    // Draw scanning animation dots
    if (faceRect != null) {
      _drawScanningDots(canvas, center, primaryColor);
    }
  }

  void _drawDirectionalArrows(
    Canvas canvas,
    Rect faceRect,
    Rect guideRect,
    FacePositionInfo positionInfo,
    Color color,
  ) {
    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 3.0;

    // Horizontal arrow (left/right)
    if (positionInfo.centerOffsetX.abs() > 0.1) {
      final arrowX = positionInfo.centerOffsetX > 0 
        ? faceRect.left - 40  // Face is right of center, arrow points left
        : faceRect.right + 40; // Face is left of center, arrow points right
      final arrowY = faceRect.center.dy;
      
      _drawArrow(canvas, Offset(arrowX, arrowY), 
        positionInfo.centerOffsetX > 0 ? 180 : 0, color);
    }

    // Vertical arrow (up/down)
    if (positionInfo.centerOffsetY.abs() > 0.1) {
      final arrowX = faceRect.center.dx;
      final arrowY = positionInfo.centerOffsetY > 0 
        ? faceRect.top - 40  // Face is below center, arrow points up
        : faceRect.bottom + 40; // Face is above center, arrow points down
      
      _drawArrow(canvas, Offset(arrowX, arrowY), 
        positionInfo.centerOffsetY > 0 ? 270 : 90, color);
    }
  }

  void _drawArrow(Canvas canvas, Offset position, double angle, Color color) {
    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(angle * 3.14159 / 180);

    final path = Path()
      ..moveTo(0, -15)
      ..lineTo(-8, 5)
      ..lineTo(0, 0)
      ..lineTo(8, 5)
      ..close();

    canvas.drawPath(path, arrowPaint);
    canvas.restore();
  }

  void _drawDistanceIndicator(
    Canvas canvas,
    Rect faceRect,
    FacePositionInfo positionInfo,
    Color color,
  ) {
    // Draw distance indicator on the side
    final indicatorX = faceRect.right + 20;
    final indicatorY = faceRect.center.dy;
    final indicatorHeight = 100.0;
    final indicatorWidth = 8.0;

    // Background
    final bgPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(indicatorX, indicatorY),
          width: indicatorWidth,
          height: indicatorHeight,
        ),
        const Radius.circular(4),
      ),
      bgPaint,
    );

    // Distance bar
    final distanceRatio = positionInfo.distanceRatio.clamp(0.0, 1.0);
    final barHeight = indicatorHeight * distanceRatio;
    final barPaint = Paint()
      ..color = distanceRatio < 0.3 || distanceRatio > 0.7 
        ? Colors.red 
        : distanceRatio < 0.4 || distanceRatio > 0.6
          ? Colors.orange
          : Colors.green
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          indicatorX - indicatorWidth / 2,
          indicatorY - indicatorHeight / 2,
          indicatorWidth,
          barHeight,
        ),
        const Radius.circular(4),
      ),
      barPaint,
    );

    // Center marker (ideal distance)
    final markerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawLine(
      Offset(indicatorX - indicatorWidth / 2 - 5, indicatorY),
      Offset(indicatorX + indicatorWidth / 2 + 5, indicatorY),
      markerPaint,
    );
  }

  /// Draw face mesh with white dots and lines (like the image style)
  void _drawFaceMesh(
    Canvas canvas,
    Rect faceRect,
    List<Offset> landmarks,
    Size imageSize,
    double screenWidth,
    double screenHeight,
    Color baseColor,
  ) {
    // Convert landmarks from image coordinates to screen coordinates
    final scaleX = screenWidth / imageSize.width;
    final scaleY = screenHeight / imageSize.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;
    
    final scaledLandmarks = landmarks.map((landmark) {
      return Offset(
        (landmark.dx * scale) + (screenWidth - imageSize.width * scale) / 2,
        (landmark.dy * scale) + (screenHeight - imageSize.height * scale) / 2,
      );
    }).toList();

    // White color for mesh (like the image)
    final whiteColor = Colors.white;
    
    // Draw connecting lines between key points
    final linePaint = Paint()
      ..color = whiteColor.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Connect landmarks in a mesh pattern
    if (scaledLandmarks.length >= 5) {
      // Connect eyes to nose
      if (scaledLandmarks.length >= 3) {
        canvas.drawLine(scaledLandmarks[0], scaledLandmarks[2], linePaint); // left eye to nose
        canvas.drawLine(scaledLandmarks[1], scaledLandmarks[2], linePaint); // right eye to nose
      }
      
      // Connect nose to mouth
      if (scaledLandmarks.length >= 5) {
        canvas.drawLine(scaledLandmarks[2], scaledLandmarks[3], linePaint); // nose to left mouth
        canvas.drawLine(scaledLandmarks[2], scaledLandmarks[4], linePaint); // nose to right mouth
      }
      
      // Connect eyes
      if (scaledLandmarks.length >= 2) {
        canvas.drawLine(scaledLandmarks[0], scaledLandmarks[1], linePaint);
      }
      
      // Connect mouth corners
      if (scaledLandmarks.length >= 5) {
        canvas.drawLine(scaledLandmarks[3], scaledLandmarks[4], linePaint);
      }
      
      // Connect to cheeks if available
      if (scaledLandmarks.length >= 7) {
        canvas.drawLine(scaledLandmarks[0], scaledLandmarks[5], linePaint); // left eye to left cheek
        canvas.drawLine(scaledLandmarks[1], scaledLandmarks[6], linePaint); // right eye to right cheek
      }
      
      // Connect to forehead and chin if available
      if (scaledLandmarks.length >= 9) {
        canvas.drawLine(scaledLandmarks[2], scaledLandmarks[7], linePaint); // nose to forehead
        canvas.drawLine(scaledLandmarks[2], scaledLandmarks[8], linePaint); // nose to chin
      }
    }

    // Draw white dots at landmark positions
    final dotPaint = Paint()
      ..color = whiteColor
      ..style = PaintingStyle.fill;

    for (final landmark in scaledLandmarks) {
      canvas.drawCircle(landmark, 3.0, dotPaint);
      // Add subtle glow
      final glowPaint = Paint()
        ..color = whiteColor.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(landmark, 5.0, glowPaint);
    }
  }

  void _drawScanningDots(Canvas canvas, Offset center, Color color) {
    final dotPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    // Draw pulsing dots around center
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * 3.14159 / 180;
      final radius = 30.0 + (sin(time * 2 + i) * 10);
      final x = center.dx + cos(angle) * radius;
      final y = center.dy + sin(angle) * radius;
      final opacity = 0.3 + (sin(time * 2 + i) * 0.3);
      
      dotPaint.color = color.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), 3.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter oldDelegate) {
    return oldDelegate.isReady != isReady || 
           oldDelegate.faceRect != faceRect ||
           oldDelegate.positionInfo != positionInfo ||
           oldDelegate.landmarks != landmarks;
  }
}
