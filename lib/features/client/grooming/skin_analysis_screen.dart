import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gen_confi/core/constants/app_colors.dart';
import 'package:gen_confi/core/layout/base_scaffold.dart';
import 'package:gen_confi/app/routes/app_routes.dart';
import 'package:gen_confi/services/auth_store.dart';

class SkinAnalysisScreen extends StatefulWidget {
  final String? imagePath;
  const SkinAnalysisScreen({super.key, this.imagePath});

  @override
  State<SkinAnalysisScreen> createState() => _SkinAnalysisScreenState();
}

class _SkinAnalysisScreenState extends State<SkinAnalysisScreen> {
  bool _isAnalyzing = false;
  String _statusMessage = 'Face Detected. Ready for analysis.';
  double _scanProgress = 0.0;
  Timer? _analysisTimer;

  @override
  void initState() {
    super.initState();
    // Auto-start analysis if an image is provided
    if (widget.imagePath != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startAnalysis();
      });
    }
  }

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
    _analysisTimer = Timer.periodic(const Duration(milliseconds: 1000), (
      timer,
    ) {
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
          _onAnalysisComplete();
        }
      });
    });
  }

  void _onAnalysisComplete() async {
    // Save to AuthStore (legacy for now)
    if (widget.imagePath != null) {
      AuthStore().setGroomingCompleted(true, imagePath: widget.imagePath);
    }

    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    // After analysis, we usually go to the results or back to home
    // The user said "once signup is successfull it should go to the home screen and with their user profile should be need analyse and make this"
    // So after analysis we should probably go back to the home shell which will now show the results
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.clientShell,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get image path from arguments if not provided in constructor
    final String? imagePath =
        widget.imagePath ??
        (ModalRoute.of(context)?.settings.arguments
            as Map<String, dynamic>?)?['imagePath'];

    return BaseScaffold(
      title: 'AI Analysis',
      showBackButton: true,
      body: Stack(
        children: [
          // 1. Captured Image Background
          Positioned.fill(
            child: Container(
              color: Colors.black,
              child: imagePath != null
                  ? Image.file(File(imagePath), fit: BoxFit.cover)
                  : const Center(
                      child: Icon(
                        Icons.face_retouching_natural,
                        size: 120,
                        color: Colors.white24,
                      ),
                    ),
            ),
          ),

          // Dark overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),

          // 2. Overlay Frame & Scanner
          Center(
            child: Container(
              width: 300,
              height: 420,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isAnalyzing
                      ? AppColors.primary
                      : Colors.white.withOpacity(0.5),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(32),
              ),
              child: _isAnalyzing
                  ? Stack(
                      children: [
                        // Scanning Line Animation
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 100),
                          top: 420 * (_scanProgress > 1 ? 1 : _scanProgress),
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.8),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
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
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isAnalyzing && _scanProgress < 1.0)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                      if (_isAnalyzing && _scanProgress < 1.0)
                        const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          _statusMessage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                // Manual Trigger if not started
                if (!_isAnalyzing)
                  ElevatedButton(
                    onPressed: _startAnalysis,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "START ANALYSIS",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
