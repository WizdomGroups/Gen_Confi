import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'logic/face_capture_logic.dart';
import 'widgets/smart_capture_overlay.dart';
import 'preview_screen.dart';
import 'domain/capture_thresholds.dart';

class SmartCaptureScreen extends StatefulWidget {
  final Function(String path)? onCaptureComplete;

  const SmartCaptureScreen({Key? key, this.onCaptureComplete}) : super(key: key);

  @override
  State<SmartCaptureScreen> createState() => _SmartCaptureScreenState();
}

class _SmartCaptureScreenState extends State<SmartCaptureScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  FaceCaptureLogic? _logic; // logic engine
  
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  
  // State
  String _instruction = "Initializing...";
  bool _isStable = false;
  Timer? _stabilityTimer;
  Rect? _currentFaceRect;
  FacePositionInfo? _positionInfo;
  List<Offset>? _landmarks;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopStream();
    _controller?.dispose();
    _logic?.dispose();
    _stabilityTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    
    if (state == AppLifecycleState.inactive) {
      _stopStream();
      _controller?.dispose(); 
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera(); 
    }
  }

  Future<void> _initializeCamera() async {
    // 1. Permissions
    final status = await Permission.camera.request();
    if (status != PermissionStatus.granted) { 
      if (mounted) Navigator.pop(context); // Or show error
      return; 
    }

    // 2. Select Front Camera
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    // 3. Controller
    // Resolution: medium is usually enough for CV, but we want High Res capture.
    // We can stream at low res or same res. High/Max is risky for stream perf.
    // Let's try ResolutionPreset.veryHigh and see. If laggy, we might need 2 streams or assume modern phone.
    // The prompt says "Validation logic on preview frames... Final capture at full camera resolution".
    // Flutter camera plugin ties preview and capture resolution mostly. 
    // We'll use ResolutionPreset.high (720p/1080p).
    
    _controller = CameraController(
      frontCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );

    try {
      await _controller!.initialize();
      await _controller!.lockCaptureOrientation(DeviceOrientation.portraitUp);
      
      _logic = FaceCaptureLogic();
      
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _instruction = "Position your face in the frame";
        });
        _startStream();
      }
    } catch (e) {
      debugPrint("Camera init error: $e");
    }
  }

  void _startStream() {
    if (_controller == null) return;
    _controller!.startImageStream(_processCameraImage);
  }
  
  void _stopStream() {
    if (_controller?.value.isStreamingImages == true) {
      _controller!.stopImageStream();
    }
  }

  void _processCameraImage(CameraImage image) async {
    if (_isProcessing || _logic == null || !mounted) return;
    _isProcessing = true;

    try {
      final camera = _controller!.description;
      final orientation = _controller!.value.deviceOrientation;
      
      final result = await _logic!.analyze(image, camera, orientation);
      
      if (!mounted) return;

      // Always update UI with latest result for active tracking
      // Only skip updates if it's a "scanning" message and we already have face data
      bool shouldUpdate = true;
      if (result.status == CaptureStatus.noFace && 
          result.instruction.contains("Scanning") && 
          _currentFaceRect != null) {
        // Don't overwrite good tracking with scanning message
        shouldUpdate = false;
      }

      if (shouldUpdate) {
        // Update State / Logic
        if (result.status == CaptureStatus.ready) {
          if (!_isStable) {
            // Just became stable - start timer
            setState(() {
               _isStable = true;
               _instruction = result.instruction;
               _currentFaceRect = result.faceRect;
               _positionInfo = result.positionInfo;
               _landmarks = result.landmarks;
            });
            _startStabilityTimer();
          } else {
            // Update while stable - keep face rect updated but don't reset timer
            // This allows timer to continue even with minor updates
            setState(() {
              _instruction = result.instruction;
              _currentFaceRect = result.faceRect;
              _positionInfo = result.positionInfo;
              _landmarks = result.landmarks;
            });
            // Restart timer if it was cancelled (safety check)
            if (_stabilityTimer == null || !_stabilityTimer!.isActive) {
              _startStabilityTimer();
            }
          }
        } else {
          // Not stable/ready - only reset if status changed significantly
          // Allow brief interruptions without resetting timer
          if (_isStable && result.status != CaptureStatus.moving) {
            // Only reset for significant issues, not minor movements
            _resetStabilityTimer();
            setState(() {
              _isStable = false;
              _instruction = result.instruction;
              _currentFaceRect = result.faceRect;
              _positionInfo = result.positionInfo;
              _landmarks = result.landmarks;
            });
          } else if (!_isStable) {
            // Always update to show active guidance
            setState(() {
              _instruction = result.instruction;
              _currentFaceRect = result.faceRect;
              _positionInfo = result.positionInfo;
              _landmarks = result.landmarks;
            });
          }
        }
      } else if (result.faceRect != null) {
        // Update face rect even if we skip instruction update
        setState(() {
          _currentFaceRect = result.faceRect;
          _landmarks = result.landmarks;
        });
      }
    } catch (e) {
      debugPrint("Analysis error: $e");
    } finally {
      _isProcessing = false;
    }
  }

  void _startStabilityTimer() {
    _stabilityTimer?.cancel();
    _stabilityTimer = Timer(
      const Duration(milliseconds: CaptureThresholds.stableDurationMs), 
      _capturePhoto
    );
  }

  void _resetStabilityTimer() {
    _stabilityTimer?.cancel();
    _stabilityTimer = null;
  }

  Future<void> _capturePhoto() async {
    if (!mounted || _controller == null) return;
    
    // Safety check
    if (!_isStable) return;

    try {
      _stopStream(); // Stop analysis logic
      
      // Haptics/Sound
      HapticFeedback.mediumImpact();
      
      final XFile image = await _controller!.takePicture();
      
      if (!mounted) return;

      // Navigate to Preview
      // Use pushReplacement or push? If prompt says "Module", push so we can pop later.
      // But we probably want to stay in this route flow.
      
      final confirmed = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => SmartCapturePreviewScreen(
            imagePath: image.path,
            onRetake: () {
               Navigator.pop(ctx, false);
            },
            onConfirm: (path) {
               Navigator.pop(ctx, true);
            },
          ),
        ),
      );

      if (confirmed == true) {
         // Return result to parent
         if (widget.onCaptureComplete != null) {
           widget.onCaptureComplete!(image.path);
         } else {
           Navigator.pop(context, image.path);
         }
      } else {
        // Resume Camera
        _startStream();
        setState(() {
          _isStable = false;
          _instruction = "Position your face in the frame";
          _currentFaceRect = null;
          _positionInfo = null;
        });
      }
      
    } catch (e) {
      debugPrint("Capture error: $e");
      // Resume
      _startStream();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    
    // Scale Preview to Cover
    final size = MediaQuery.of(context).size;
    final scale = 1 / (_controller!.value.aspectRatio * size.aspectRatio);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview (Center Cropped / Cover)
          // Transform.scale to cover full screen if needed, 
          // or use CameraPreview directly if AspectRatio widget is consistent.
          // Usually CameraPreview respects aspect ratio, leading to letterboxing.
          // To cover, we wrap in SizedBox.expand and FittedBox
          SizedBox.expand(
            child: FittedBox(
               fit: BoxFit.cover,
               child: SizedBox(
                 width: _controller!.value.previewSize!.height, // Swapped for portrait
                 height: _controller!.value.previewSize!.width,
                 child: CameraPreview(_controller!),
               ),
            ),
          ),
          
          // Overlay
          SmartCaptureOverlay(
            instruction: _instruction,
            isReady: _isStable,
            faceRect: _currentFaceRect,
            imageSize: _controller!.value.previewSize ?? const Size(720, 1280),
            positionInfo: _positionInfo,
            landmarks: _landmarks,
          ),
          
          // Back Button
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
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
