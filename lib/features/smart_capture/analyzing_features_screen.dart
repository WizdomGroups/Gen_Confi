import 'dart:async';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import 'analysis_results_screen.dart';

class AnalyzingFeaturesScreen extends StatefulWidget {
  final String imagePath;

  const AnalyzingFeaturesScreen({
    Key? key,
    required this.imagePath,
  }) : super(key: key);

  @override
  State<AnalyzingFeaturesScreen> createState() => _AnalyzingFeaturesScreenState();
}

class _AnalyzingFeaturesScreenState extends State<AnalyzingFeaturesScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _fadeController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;

  int _currentStep = 0;
  final List<AnalysisStep> _steps = [
    AnalysisStep(title: "Detecting face shape...", completed: false),
    AnalysisStep(title: "Analyzing skin tone...", completed: false),
    AnalysisStep(title: "Identifying undertone...", completed: false),
    AnalysisStep(title: "Evaluating hair texture...", completed: false),
    AnalysisStep(title: "Finalizing results...", completed: false),
  ];

  Timer? _stepTimer;
  final Map<int, AnimationController> _stepControllers = {};

  @override
  void initState() {
    super.initState();

    // Progress animation controller
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );

    // Pulse animation controller
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Rotation animation controller (continuous rotation)
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Fade animation controller
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _rotationController,
        curve: Curves.linear,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOut,
      ),
    );

    // Initialize step controllers for individual step animations
    for (int i = 0; i < _steps.length; i++) {
      _stepControllers[i] = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
    }

    // Start animations
    _progressController.forward();
    _startStepAnimation();

    // Navigate after completion
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Complete all steps
        setState(() {
          for (var step in _steps) {
            step.completed = true;
          }
        });
        // Navigate to results screen after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (ctx) => AnalysisResultsScreen(imagePath: widget.imagePath),
              ),
            );
          }
        });
      }
    });
  }

  void _startStepAnimation() {
    // Complete steps over 30 seconds (approximately every 6 seconds)
    _stepTimer = Timer.periodic(const Duration(milliseconds: 6000), (timer) {
      if (mounted && _currentStep < _steps.length) {
        // Animate step completion
        _stepControllers[_currentStep]?.forward();
        setState(() {
          _steps[_currentStep].completed = true;
          _currentStep++;
        });
        if (_currentStep >= _steps.length) {
          timer.cancel();
        }
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _fadeController.dispose();
    for (var controller in _stepControllers.values) {
      controller.dispose();
    }
    _stepTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // Premium Background Aura
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gradientStart.withOpacity(isDark ? 0.15 : 0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -150,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gradientEnd.withOpacity(isDark ? 0.1 : 0.08),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    "Analyzing your features",
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 60),

                  // Circular Loading Graphic with rotation and glow
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: AnimatedBuilder(
                      animation: Listenable.merge([
                        _progressAnimation,
                        _pulseAnimation,
                        _rotationAnimation,
                      ]),
                      builder: (context, child) {
                        return Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gradientStart.withOpacity(0.2 * _pulseAnimation.value),
                                blurRadius: 30 * _pulseAnimation.value,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Transform.rotate(
                              angle: _rotationAnimation.value,
                              child: CustomPaint(
                                painter: GradientCircularProgressPainter(
                                  progress: _progressAnimation.value,
                                  isDark: isDark,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Analysis Steps
                  Column(
                    children: _steps.asMap().entries.map((entry) {
                      final index = entry.key;
                      final step = entry.value;
                      return _buildStepItem(
                        step: step,
                        index: index,
                        isDark: isDark,
                        colorScheme: colorScheme,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required AnalysisStep step,
    required int index,
    required bool isDark,
    required ColorScheme colorScheme,
  }) {
    final stepController = _stepControllers[index];
    
    // If step is not completed, show immediately without animation
    if (!step.completed || stepController == null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          children: [
            // Status Indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: step.completed
                    ? AppColors.gradientStart
                    : Colors.transparent,
                border: Border.all(
                  color: step.completed
                      ? AppColors.gradientStart
                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                  width: 2,
                ),
              ),
              child: step.completed
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            // Step Text
            Expanded(
              child: Text(
                step.title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: step.completed
                      ? colorScheme.onSurface
                      : (isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight),
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    final scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: stepController,
        curve: Curves.elasticOut,
      ),
    );
    
    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: stepController,
        curve: Curves.easeOut,
      ),
    );

    return FadeTransition(
      opacity: fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          children: [
            // Status Indicator with scale animation
            ScaleTransition(
              scale: scaleAnimation,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutBack,
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: step.completed
                      ? AppColors.gradientStart
                      : Colors.transparent,
                  border: Border.all(
                    color: step.completed
                        ? AppColors.gradientStart
                        : (isDark ? AppColors.borderDark : AppColors.borderLight),
                    width: 2,
                  ),
                  boxShadow: step.completed
                      ? [
                          BoxShadow(
                            color: AppColors.gradientStart.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: step.completed
                    ? Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            // Step Text with animated color transition
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 400),
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: step.completed
                      ? colorScheme.onSurface
                      : (isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight),
                ),
                child: Text(step.title),
              ),
            ),
            // Active indicator with animation
            if (index == _currentStep - 1 && step.completed)
              ScaleTransition(
                scale: scaleAnimation,
                child: Icon(
                  Icons.check_circle,
                  size: 20,
                  color: AppColors.gradientMid,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AnalysisStep {
  String title;
  bool completed;

  AnalysisStep({required this.title, required this.completed});
}

class GradientCircularProgressPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  GradientCircularProgressPainter({
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background circle
    final backgroundPaint = Paint()
      ..color = isDark ? AppColors.borderDark : AppColors.borderLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw wavy dotted progress arc
    final sweepAngle = 2 * math.pi * progress;
    const numDots = 60; // More dots for smoother effect
    
    final dotPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i <= (numDots * progress).round(); i++) {
      final angle = (sweepAngle / numDots) * i - (math.pi / 2); // Start from top
      
      // Create wavy effect with sine wave
      final waveOffset = math.sin(i * 0.3) * 3.0; // Wavy effect
      final currentRadius = radius + waveOffset;
      
      final x = center.dx + currentRadius * math.cos(angle);
      final y = center.dy + currentRadius * math.sin(angle);

      // Gradient color based on position (blue -> purple -> magenta)
      Color dotColor;
      final progressRatio = i / numDots;
      if (progressRatio < 0.33) {
        // Blue to purple transition
        final t = progressRatio / 0.33;
        dotColor = Color.lerp(
          const Color(0xFF2196F3), // Blue
          const Color(0xFF9C27B0), // Purple
          t,
        )!;
      } else if (progressRatio < 0.66) {
        // Purple to magenta transition
        final t = (progressRatio - 0.33) / 0.33;
        dotColor = Color.lerp(
          const Color(0xFF9C27B0), // Purple
          const Color(0xFFE91E63), // Magenta
          t,
        )!;
      } else {
        // Magenta
        dotColor = const Color(0xFFE91E63);
      }

      dotPaint.color = dotColor;
      canvas.drawCircle(Offset(x, y), 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


