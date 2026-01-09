import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:gen_confi/app/routes/app_routes.dart';
import 'package:gen_confi/core/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_confi/core/providers/auth_provider.dart';
import 'package:gen_confi/core/storage/token_storage.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _particleController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  late AudioPlayer _audioPlayer;

  String _displayedText = "";
  final String _fullText = "GENCONFI";
  int _currentIndex = 0;
  Timer? _typewriterTimer;

  bool get isDarkTheme => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();

    _audioPlayer = AudioPlayer();

    // Main animation controller
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Particle animation controller (continuous)
    _particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // Pulse animation controller (continuous)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );

    _startAnimationSequence();
  }

  Future<void> _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    // Play splash audio
    try {
      await _audioPlayer.play(AssetSource('audio/splash_audio.wav'));
    } catch (e) {
      debugPrint('Error playing splash audio: $e');
    }

    // Start main animations
    _mainController.forward();

    // Start typewriter effect
    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 150), (
      timer,
    ) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_currentIndex < _fullText.length) {
        setState(() {
          _currentIndex++;
          _displayedText = _fullText.substring(0, _currentIndex);
        });
      } else {
        timer.cancel();
      }
    });

    // Wait for minimum duration and ensure auth check is complete
    await Future.delayed(const Duration(milliseconds: 3500));

    if (!mounted) return;

    // Check auth state using Riverpod
    final authState = ref.read(authProvider);

    if (authState.isAuthenticated && authState.user != null) {
      final role = authState.user!.role.toLowerCase();
      print('🔄 Auto-login successful: ${authState.user!.email} (Role: $role)');

      // Check if onboarding is complete
      final isOnboardingComplete = await TokenStorage.isOnboardingComplete();

      switch (role) {
        case 'admin':
          Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
          break;
        case 'expert':
          if (isOnboardingComplete) {
            Navigator.pushReplacementNamed(context, AppRoutes.expertHome);
          } else {
            Navigator.pushReplacementNamed(context, AppRoutes.expertOnboarding);
          }
          break;
        case 'client':
        default:
          if (isOnboardingComplete) {
            Navigator.pushReplacementNamed(context, AppRoutes.clientShell);
          } else {
            print('📋 Onboarding incomplete, redirecting to onboarding');
            Navigator.pushReplacementNamed(context, AppRoutes.genderModeSelection);
          }
          break;
      }
    } else {
      print('🚪 No active session found, navigating to login');
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    _mainController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDarkTheme ? Colors.black : Colors.white;
    final textColor = isDarkTheme ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Animated gradient particles background
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlePainter(
                  animation: _particleController.value,
                  isDark: isDarkTheme,
                ),
                size: Size.infinite,
              );
            },
          ),

          // Radial gradient glow effect
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      AppColors.gradientStart.withOpacity(
                        0.15 * _glowAnimation.value,
                      ),
                      backgroundColor.withOpacity(0.0),
                    ],
                  ),
                ),
              );
            },
          ),

          // Main content
          Center(
            child: AnimatedBuilder(
              animation: _mainController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Pulsing gradient circle behind text
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            final pulseScale =
                                1.0 + (_pulseController.value * 0.1);
                            return Transform.scale(
                              scale: pulseScale,
                              child: Container(
                                width: 220,
                                height: 220,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      AppColors.gradientStart.withOpacity(0.2),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        // Logo text with typewriter effect
                        Transform.translate(
                          offset: const Offset(0, -110),
                          child: Column(
                            children: [
                              // Main text with gradient and glow
                              Stack(
                                children: [
                                  // Glow effect
                                  ShaderMask(
                                    shaderCallback: (bounds) {
                                      return AppColors.primaryGradient
                                          .createShader(
                                            Rect.fromLTWH(
                                              0,
                                              0,
                                              bounds.width,
                                              bounds.height,
                                            ),
                                          );
                                    },
                                    child: Text(
                                      _displayedText,
                                      style: GoogleFonts.inter(
                                        fontSize: 56,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 2.0,
                                        shadows: [
                                          Shadow(
                                            color: AppColors.gradientStart
                                                .withOpacity(
                                                  0.5 * _glowAnimation.value,
                                                ),
                                            blurRadius: 30,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Animated gradient underline
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                width: _displayedText.length * 6.0,
                                height: 4,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.gradientStart
                                          .withOpacity(0.5),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Tagline with fade-in
                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 800),
                                opacity: _currentIndex >= _fullText.length
                                    ? 1.0
                                    : 0.0,
                                child: Column(
                                  children: [
                                    Text(
                                      'YOUR PERSONAL STYLIST &',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: textColor.withOpacity(0.7),
                                        letterSpacing: 2.0,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'GROOMING PARTNER',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: textColor.withOpacity(0.7),
                                        letterSpacing: 2.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Shimmer effect overlay
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return Opacity(
                opacity: 0.3 * _glowAnimation.value,
                child: CustomPaint(
                  painter: ShimmerPainter(
                    animation: _particleController.value,
                    isDark: isDarkTheme,
                  ),
                  size: Size.infinite,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Particle animation painter
class ParticlePainter extends CustomPainter {
  final double animation;
  final bool isDark;

  ParticlePainter({required this.animation, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Create floating particles
    for (int i = 0; i < 20; i++) {
      final seed = i * 123.456;
      final x =
          (math.sin(seed + animation * 2 * math.pi) * 0.3 + 0.5) * size.width;
      final y = ((seed % 1000) / 1000 + animation) % 1.0 * size.height;
      final radius = 2.0 + (seed % 3);

      final colors = [
        const Color(0xFF833AB4),
        const Color(0xFFFD1D1D),
        const Color(0xFFF77737),
      ];

      paint.color = colors[i % 3].withOpacity(0.15);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}

// Shimmer effect painter
class ShimmerPainter extends CustomPainter {
  final double animation;
  final bool isDark;

  ShimmerPainter({required this.animation, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.transparent,
          (isDark ? Colors.white : Colors.black).withOpacity(0.05),
          Colors.transparent,
        ],
        stops: [animation - 0.3, animation, animation + 0.3],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(ShimmerPainter oldDelegate) => true;
}
