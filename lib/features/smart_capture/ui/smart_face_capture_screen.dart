import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gen_confi/core/constants/app_colors.dart';
import 'package:gen_confi/core/layout/base_scaffold.dart';
import 'package:gen_confi/features/smart_capture/logic/quality_gate.dart';
import 'package:gen_confi/features/smart_capture/platform/mediapipe_capture_engine.dart';
import 'package:gen_confi/features/smart_capture/ui/camera_preview_widget.dart';
// import 'package:gen_confi/app/routes/app_routes.dart'; // Unused here unless we use pushReplacementNamed logic inside _performCapture which we changed to pop

import 'package:permission_handler/permission_handler.dart';

class SmartFaceCaptureScreen extends StatefulWidget {
  const SmartFaceCaptureScreen({super.key});

  @override
  State<SmartFaceCaptureScreen> createState() => _SmartFaceCaptureScreenState();
}

class _SmartFaceCaptureScreenState extends State<SmartFaceCaptureScreen>
    with WidgetsBindingObserver {
  final _engine = MediaPipeCaptureEngine();
  final _qualityGate = QualityGate();

  QualityStatus _status = QualityStatus.noFace;
  String _guidanceMessage = "Initializing...";
  bool _isCapturing = false;
  bool _hasPermission = false;

  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissionAndStart();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_hasPermission) {
      _checkPermissionAndStart();
    }
  }

  Future<void> _checkPermissionAndStart() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      if (!_hasPermission) {
        setState(() {
          _hasPermission = true;
        });
      }
      // Do NOT call _startCapture here. Wait for view creation.
    } else {
      setState(() {
        _hasPermission = false;
        _guidanceMessage = "Camera permission required";
      });
    }
  }

  Future<void> _startCapture() async {
    if (!_hasPermission) return;

    await _engine.initialize();
    await _engine.start();

    if (!mounted) return;

    _subscription = _engine.qualityStream.listen((meta) {
      final newStatus = _qualityGate.evaluate(meta);
      // ... same logic ...
      if (newStatus != _status || _qualityGate.isStable) {
        if (!mounted) return;
        setState(() {
          _status = newStatus;
          _guidanceMessage = _qualityGate.getGuidanceMessage(newStatus);
        });

        // Auto-capture logic
        if (_status == QualityStatus.optimal &&
            _qualityGate.isStable &&
            !_isCapturing) {
          _performCapture();
        }
      }
    });
  }

  Future<void> _performCapture() async {
    setState(() {
      _isCapturing = true;
      _guidanceMessage = "Capturing...";
    });

    final result = await _engine.capture();

    if (!mounted) return;

    if (result != null) {
      // Success! Navigate to Hub or processing
      print("Captured image at: ${result.imagePath}");
      // Here we would typically return the result to the previous screen or navigate forward
      Navigator.pop(context, result);
    } else {
      setState(() {
        _isCapturing = false;
        _guidanceMessage = "Capture failed, try again.";
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _engine.stop();
    _engine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isError = _status != QualityStatus.optimal;
    // UI Feedback Colors
    final borderColor = isError ? Colors.redAccent : AppColors.primary;
    final statusColor = isError
        ? Colors.red.withOpacity(0.8)
        : Colors.green.withOpacity(0.8);

    return BaseScaffold(
      title: 'Smart Face Capture',
      showBackButton: true,
      useResponsiveContainer: false, // Full screen for camera
      body: Stack(
        children: [
          // 1. Camera Preview
          if (_hasPermission)
            Positioned.fill(
              child: CameraPreviewWidget(
                onViewCreated: _startCapture,
              ),
            )
          else
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Camera Access Needed",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: openAppSettings,
                        child: const Text("Grant Permission"),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 2. Face Guide Overlay (Oval)
          if (_hasPermission)
            Center(
              child: Container(
                width: 280,
                height: 380,
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: 4),
                  borderRadius: BorderRadius.circular(140), // Oval
                ),
              ),
            ),

          // 3. Guidance Banner
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: _buildGuidanceBanner(statusColor),
          ),

          // 4. Manual Capture Button (Optional / Fallback)
          if (_hasPermission)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _status == QualityStatus.optimal && !_isCapturing
                      ? _performCapture
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 5),
                      color: _isCapturing
                          ? Colors.white
                          : (_status == QualityStatus.optimal
                                ? Colors.white.withOpacity(0.3)
                                : Colors.transparent),
                    ),
                    child: _isCapturing
                        ? const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGuidanceBanner(Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        _guidanceMessage,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
