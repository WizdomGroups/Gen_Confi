import 'dart:io';
import 'package:flutter/material.dart';

import 'package:gen_confi/core/layout/base_scaffold.dart';
import 'package:gen_confi/core/widgets/app_button.dart';
import 'package:gen_confi/features/client/grooming/ui/grooming_results_screen.dart';
import 'package:gen_confi/features/smart_capture/domain/quality_models.dart';
import 'package:gen_confi/features/smart_capture/logic/analysis_pipeline.dart';
import 'package:gen_confi/services/auth_store.dart';

class GroomingPreviewScreen extends StatefulWidget {
  final CaptureResult captureResult;

  const GroomingPreviewScreen({super.key, required this.captureResult});

  @override
  State<GroomingPreviewScreen> createState() => _GroomingPreviewScreenState();
}

class _GroomingPreviewScreenState extends State<GroomingPreviewScreen> {
  bool _isAnalyzing = false;

  void _onRetake() {
    Navigator.of(context).pop(null);
  }

  Future<void> _onSubmit() async {
    setState(() {
      _isAnalyzing = true;
    });

    try {
      // Run analysis
      final pipeline = AnalysisPipeline();
      final result = await pipeline.analyze(widget.captureResult);

      if (!mounted) return;

      // Save completion state
      AuthStore().setGroomingCompleted(
        true,
        imagePath: widget.captureResult.imagePath,
      );

      // Navigate to Results Screen
      // Ideally we should pass the full 'result' object to GroomingResultsScreen.
      // But GroomingResultsScreen expects 'metaData' map.
      // We will pass result.toJson() as metaData.

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => GroomingResultsScreen(
            imagePath: widget.captureResult.imagePath,
            metaData: result.toJson(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Analysis failed: $e')));
      setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Preview Captured Photo',
      showBackButton: true,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.file(
                      File(widget.captureResult.imagePath),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: "Retake",
                        style: AppButtonStyle.outline,
                        onPressed: _isAnalyzing ? null : _onRetake,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppButton(
                        text: "Continue",
                        onPressed: _isAnalyzing ? null : _onSubmit,
                        isLoading: _isAnalyzing,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Loading Overlay (optional, as button has loading state, but let's block UI)
          if (_isAnalyzing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(), // Buttons handle visual loading
              ),
            ),
        ],
      ),
    );
  }
}
