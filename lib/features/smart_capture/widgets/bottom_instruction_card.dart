import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gen_confi/core/constants/app_colors.dart';
import '../domain/face_analysis_metrics.dart';

/// Modern bottom instruction card with animations
class BottomInstructionCard extends StatefulWidget {
  final String instruction;
  final bool isReady;
  final double? progress; // 0.0 to 1.0 for stability progress
  final FaceAnalysisMetrics? metrics;
  final String? userName;

  const BottomInstructionCard({
    Key? key,
    required this.instruction,
    this.isReady = false,
    this.progress,
    this.metrics,
    this.userName,
  }) : super(key: key);

  @override
  State<BottomInstructionCard> createState() => _BottomInstructionCardState();
}

class _BottomInstructionCardState extends State<BottomInstructionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(BottomInstructionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isReady && !oldWidget.isReady) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isReady && oldWidget.isReady) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: _buildGlassCard(context),
    );
  }

  Widget _buildGlassCard(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isReady
                  ? [
                      AppColors.gradientStart.withOpacity(0.3),
                      AppColors.gradientMid.withOpacity(0.25),
                      AppColors.gradientEnd.withOpacity(0.2),
                    ]
                  : [
                      Colors.black.withOpacity(0.4),
                      Colors.black.withOpacity(0.35),
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isReady
                  ? AppColors.gradientStart.withOpacity(0.5)
                  : Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isReady
                    ? AppColors.gradientStart.withOpacity(0.3)
                    : Colors.black.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getFormattedMessage(),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.visible,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  height: 1.3,
                ),
              ),
              if (widget.progress != null && widget.isReady) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: widget.progress,
                    minHeight: 4,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getFormattedMessage() {
    final message = _getSingleLineMessage();
    if (widget.userName != null && widget.userName!.isNotEmpty) {
      // Capitalize first letter of name
      final capitalizedName = widget.userName![0].toUpperCase() + 
          (widget.userName!.length > 1 ? widget.userName!.substring(1) : '');
      // Integrate name naturally into the message
      return _integrateUserName(capitalizedName, message);
    }
    return message;
  }

  String _integrateUserName(String name, String message) {
    // Always include the name at the beginning of every message
    // Remove "Please" if present and add name instead
    final lowerMessage = message.toLowerCase();
    if (lowerMessage.startsWith('please')) {
      return '$name, ${message.substring(7).trim()}';
    } else {
      // Simply prepend the name to the message
      return '$name, $message';
    }
  }

  String _getSingleLineMessage() {
    final instruction = widget.instruction;
    
    // If ready, show friendly ready message
    if (widget.isReady) {
      return 'Perfect! Hold still for a moment while we capture your photo';
    }
    
    // Get the main instruction (first line only)
    String mainMessage = instruction.split('\n').first.trim();
    
    // Remove all emojis and icons - keep only text and punctuation
    // Remove specific emojis that might appear in messages
    mainMessage = mainMessage
        .replaceAll('📏', '')
        .replaceAll('🎯', '')
        .replaceAll('⬆️', '')
        .replaceAll('👀', '')
        .replaceAll('📐', '')
        .replaceAll('⏸️', '')
        .replaceAll('📸', '')
        .replaceAll('💡', '')
        .replaceAll('🤳', '')
        .replaceAll('📱', '')
        .replaceAll('🔄', '')
        .replaceAll('⚖️', '')
        .replaceAll('👤', '')
        .replaceAll('👈', '')
        .replaceAll('👉', '')
        .replaceAll('⬇️', '')
        .replaceAll('✨', '')
        .replaceAll('😊', '')
        .replaceAll('👥', '')
        .replaceAll('✅', '')
        .replaceAll('⚠️', '')
        .trim();
    
    // Simplify common instructions to friendly, meaningful messages
    final lowerMessage = mainMessage.toLowerCase();
    
    // Distance guidance
    if (lowerMessage.contains('closer') || lowerMessage.contains('too far') || lowerMessage.contains('far away') || lowerMessage.contains('fill more')) {
      if (lowerMessage.contains('bit closer') || lowerMessage.contains('fill 35')) {
        return 'Come a bit closer - For best results, fill 35-45% of the frame';
      }
      return 'Move closer to the camera for a better shot';
    } else if (lowerMessage.contains('step back') || lowerMessage.contains('back slightly') || lowerMessage.contains('too close') || lowerMessage.contains('fill 35')) {
      if (lowerMessage.contains('back slightly') || lowerMessage.contains('fill 35')) {
        return 'Step back slightly - For best results, fill 35-45% of the frame';
      }
      return 'Step back from the camera - Your face is too close';
    } 
    // Centering guidance
    else if (lowerMessage.contains('center') || lowerMessage.contains('align')) {
      if (lowerMessage.contains('move left')) {
        return 'Move your face slightly to the left';
      } else if (lowerMessage.contains('move right')) {
        return 'Move your face slightly to the right';
      } else if (lowerMessage.contains('move up')) {
        return 'Move your face up a little bit';
      } else if (lowerMessage.contains('move down')) {
        return 'Move your face down a little bit';
      } else {
        return 'Center your face in the frame for the best angle';
      }
    } 
    // Lighting guidance
    else if (lowerMessage.contains('light') || lowerMessage.contains('bright') || lowerMessage.contains('lighting')) {
      return 'Find better lighting for a clearer photo';
    } 
    // Stability guidance
    else if (lowerMessage.contains('still') || lowerMessage.contains('hold') || lowerMessage.contains('steady') || lowerMessage.contains('blurry')) {
      return 'Hold your device steady for a clear shot';
    } 
    // Pose guidance
    else if (lowerMessage.contains('straight') && lowerMessage.contains('camera')) {
      return 'Look straight at the camera';
    } else if (lowerMessage.contains('raise') || lowerMessage.contains('phone') || lowerMessage.contains('eye level')) {
      return 'Raise your phone to eye level';
    } else if (lowerMessage.contains('turn') || lowerMessage.contains('head') || lowerMessage.contains('face forward')) {
      return 'Turn your head to face forward';
    } else if (lowerMessage.contains('straighten') || lowerMessage.contains('level')) {
      return 'Keep your head level and straight';
    } 
    // Multiple faces
    else if (lowerMessage.contains('multiple') || lowerMessage.contains('only you') || lowerMessage.contains('visible')) {
      return 'Make sure only you are visible in the frame';
    } 
    // Position face
    else if (lowerMessage.contains('face') && (lowerMessage.contains('frame') || lowerMessage.contains('position'))) {
      return 'Position your face in the center of the frame';
    }
    
    // Clean and return the message (remove extra whitespace and newlines)
    mainMessage = mainMessage.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    // Make default message friendly
    if (mainMessage.isEmpty) {
      return 'Position your face in the center of the frame';
    }
    
    // Return the cleaned message as-is (don't add "Please" prefix)
    return mainMessage;
  }
}



