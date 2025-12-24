import 'package:flutter/material.dart';
import 'package:gen_confi/app/routes/app_routes.dart';
import 'package:gen_confi/core/constants/app_colors.dart';

import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _startAnimation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnimationSequence();
    });
  }

  void _startAnimationSequence() async {
    // Initial reveal delay
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() => _startAnimation = true);
    }

    // Extended 10-second wait before navigation
    await Future.delayed(const Duration(seconds: 10));
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Cinematic Background Image with Zoom Effect
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 1.0, end: 1.15),
            duration: const Duration(
              seconds: 12,
            ), // Slightly longer than stay time
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: AnimatedOpacity(
                  opacity: _startAnimation ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 2000),
                  curve: Curves.easeInOut,
                  child: Image.asset(
                    'assets/images/splash.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: Colors.black),
                  ),
                ),
              );
            },
          ),

          // 2. Professional Dual-Branded Gradient Overlay
          // This applies the primary color at both top and bottom for a unified look
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.6), // Top Brand Layer
                  Colors.transparent,
                  Colors.transparent,
                  AppColors.primary.withValues(
                    alpha: 0.9,
                  ), // Bottom Brand Layer
                ],
                stops: const [0.0, 0.3, 0.6, 1.0],
              ),
            ),
          ),

          // 3. Content Overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSlide(
                    offset: _startAnimation
                        ? Offset.zero
                        : const Offset(0, 0.1),
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.easeOutCubic,
                    child: AnimatedOpacity(
                      opacity: _startAnimation ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 1200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GEN\nCONFI',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 64,
                              height: 0.9,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -1.0,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Premium Accent Line
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'YOUR PERSONAL STYLIST &\nGROOMING PARTNER',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 2.0, // High-end spacing
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Subtle Loading Indicator (Optional but Professional for 10s wait)
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
