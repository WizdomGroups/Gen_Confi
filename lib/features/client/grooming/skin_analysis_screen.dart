// FILE: lib/features/client/grooming/skin_analysis_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gen_confi/core/constants/app_colors.dart';
import 'package:gen_confi/core/layout/base_scaffold.dart';
import 'package:gen_confi/app/routes/app_routes.dart';

class SkinAnalysisScreen extends StatefulWidget {
  const SkinAnalysisScreen({super.key});

  @override
  State<SkinAnalysisScreen> createState() => _SkinAnalysisScreenState();
}

class _SkinAnalysisScreenState extends State<SkinAnalysisScreen> {
  bool _isAnalyzing = false;
  String _statusMessage = 'Align your face within the frame';
  double _scanProgress = 0.0;
  Timer? _analysisTimer;

  @override
  void dispose() {
    _analysisTimer?.cancel();
    super.dispose();
  }

  void _startAnalysis() {
    setState(() {
      _isAnalyzing = true;
      _statusMessage = 'Analyzing skin texture...';
    });

    // Simulate analysis steps
    int step = 0;
    _analysisTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (!mounted) return;

      setState(() {
        step++;
        _scanProgress += 0.25;

        if (step == 1)
          _statusMessage = 'Checking hydration levels...';
        else if (step == 2)
          _statusMessage = 'Detecting impurities...';
        else if (step == 3)
          _statusMessage = 'Evaluating skin tone...';
        else if (step >= 4) {
          _statusMessage = 'Analysis Complete!';
          timer.cancel();
          _navigateToHub();
        }
      });
    });
  }

  void _navigateToHub() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    Navigator.pushReplacementNamed(context, AppRoutes.clientGroomingHub);
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Skin Analysis',
      showBackButton: true,
      body: Stack(
        children: [
          // 1. Camera Viewfinder Simulation (Background)
          Container(
            color: Colors.black,
            child: Center(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.face_retouching_natural,
                  size: 120,
                  color: Colors.white24,
                ),
              ),
            ),
          ),

          // 2. Overlay Frame
          Center(
            child: Container(
              width: 300,
              height: 400,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isAnalyzing
                      ? AppColors.primary
                      : Colors.white.withOpacity(0.5),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: _isAnalyzing
                  ? Stack(
                      children: [
                        // Scanning Line Animation
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 800),
                          margin: EdgeInsets.only(
                            top:
                                (400 *
                                    (_scanProgress > 1 ? 1 : _scanProgress)) -
                                2,
                          ),
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
          ),

          // 3. UI Controls
          SafeArea(
            child: Column(
              children: [
                const Spacer(),

                // Status Text
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    _statusMessage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Capture Button
                if (!_isAnalyzing)
                  GestureDetector(
                    onTap: _startAnalysis,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(
                    height: 80,
                  ), // Placeholder to keep layout stable

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
