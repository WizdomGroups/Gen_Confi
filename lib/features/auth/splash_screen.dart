import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gen_confi/app/routes/app_routes.dart';
import 'package:gen_confi/core/constants/app_colors.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:gen_confi/services/auth_store.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  bool _startAnimation = false;
  String _displayedText = "";
  final String _fullText1 = "GEN";
  final String _fullText2 = "CONFI";
  bool _showSecondWord = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnimationSequence();
    });
  }

  void _startAnimationSequence() async {
    // 1. Initial Delay
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _startAnimation = true);

    // 2. Typewriter Effect for "GEN"
    for (int i = 0; i < _fullText1.length; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
      setState(() {
        _displayedText = _fullText1.substring(0, i + 1);
      });
    }

    // 3. Pause
    await Future.delayed(const Duration(milliseconds: 200));

    // 4. Typewriter Effect for "CONFI" (New line or next to it)
    // We will render them separately to control layout, but animate state
    setState(() => _showSecondWord = true); 
    
    // 5. Total wait time to match 6 seconds (approx)
    // We have consumed ~1s so far. Wait ~4.5s more.
    await Future.delayed(const Duration(seconds: 4, milliseconds: 500));
    
    if (mounted) {
      if (AuthStore().isLoggedIn) {
        Navigator.pushReplacementNamed(context, AppRoutes.clientShell);
      } else {
        // Not Logged In -> Go to Login
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
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
              seconds: 6, 
            ), 
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
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.6), 
                  Colors.transparent,
                  Colors.transparent,
                  AppColors.primary.withValues(
                    alpha: 0.9,
                  ), 
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
                   Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // "GEN"
                      Text(
                        _displayedText,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 64,
                          height: 0.9,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1.0,
                        ),
                      ),
                      // "CONFI" - Typewrites in
                      if (_showSecondWord)
                         _TypewriterText(
                           text: _fullText2, 
                           style: GoogleFonts.playfairDisplay(
                              fontSize: 64,
                              height: 0.9,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -1.0,
                            ),
                            startDelay: const Duration(milliseconds: 100),
                         ),
                      
                      const SizedBox(height: 24),
                      // Premium Accent Line
                      AnimatedContainer(
                        duration: const Duration(seconds: 1),
                        width: _startAnimation ? 40 : 0,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 24),
                      AnimatedOpacity(
                        duration: const Duration(seconds: 2),
                        opacity: _showSecondWord ? 1.0 : 0.0,
                        child: Text(
                          'YOUR PERSONAL STYLIST &\nGROOMING PARTNER',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 2.0, 
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration startDelay;

  const _TypewriterText({required this.text, required this.style, this.startDelay = Duration.zero});

  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText> {
  String _currentText = "";

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() async {
    await Future.delayed(widget.startDelay);
    for (int i = 0; i < widget.text.length; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
      setState(() {
        _currentText = widget.text.substring(0, i + 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _currentText,
      style: widget.style,
    );
  }
}
