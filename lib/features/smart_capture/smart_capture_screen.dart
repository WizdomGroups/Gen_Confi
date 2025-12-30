import 'dart:async';
import 'package:camera/camera.dart';
import 'dart:io' show Platform, File;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import 'logic/face_capture_logic.dart';
import 'widgets/bottom_instruction_card.dart';
import 'widgets/simple_face_tracking_overlay.dart';
import 'widgets/simple_face_tracking_helper.dart';
import 'preview_screen.dart';
import 'domain/capture_thresholds.dart';
import 'domain/face_analysis_metrics.dart';
import 'package:gen_confi/core/constants/app_colors.dart';
import 'package:gen_confi/services/auth_store.dart';

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
  bool _isDisposed = false; // Track disposal state to prevent using disposed controller
  bool _isCapturing = false; // Prevent concurrent captures
  
  // State
  String _instruction = "Initializing...";
  bool _isStable = false;
  Timer? _stabilityTimer;
  Rect? _currentFaceRect;
  FaceAnalysisMetrics? _currentMetrics;
  double _stabilityProgress = 0.0;
  CaptureStatus _currentCaptureStatus = CaptureStatus.noFace; // Track capture status for overlay
  DateTime? _lastCaptureTime; // For cooldown mechanism

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    _isDisposed = true; // Mark as disposed first
    WidgetsBinding.instance.removeObserver(this);
    _stabilityTimer?.cancel();
    _stopStream();
    // Dispose controller after stopping stream
    final controller = _controller;
    _controller = null; // Clear reference before disposal
    controller?.dispose();
    _logic?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isDisposed) return;
    
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    
    if (state == AppLifecycleState.inactive) {
      _stopStream();
      final controllerToDispose = _controller;
      _controller = null; // Clear reference before disposal
      _isCameraInitialized = false;
      controllerToDispose?.dispose();
    } else if (state == AppLifecycleState.resumed && !_isDisposed && mounted) {
      _initializeCamera(); 
    }
  }

  Future<void> _initializeCamera() async {
    try {
      // 1. Permissions
      final status = await Permission.camera.request();
      if (status != PermissionStatus.granted) {
      if (mounted) {
        final navigator = Navigator.of(context);
        _showErrorDialog(
          "Camera Permission Required",
          "Please grant camera permission to use face capture.",
          () => navigator.pop(),
        );
      }
        return;
      }

      // 2. Select Front Camera
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
      if (mounted) {
        final navigator = Navigator.of(context);
        _showErrorDialog(
          "No Camera Available",
          "No camera found on this device.",
          () => navigator.pop(),
        );
      }
        return;
      }
      
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

      // Initialize with error handling
      try {
        await _controller!.initialize();
        // Check if still mounted and not disposed after async operation
        if (!mounted || _isDisposed) {
          _controller?.dispose();
          _controller = null;
          return;
        }
        await _controller!.lockCaptureOrientation(DeviceOrientation.portraitUp);
      } catch (e) {
        debugPrint("Camera initialization error: $e");
        if (mounted && !_isDisposed) {
          _controller?.dispose();
          _controller = null;
          final navigator = Navigator.of(context);
          _showErrorDialog(
            "Camera Error",
            "Failed to initialize camera. Please try again.",
            () => navigator.pop(),
          );
        }
        return;
      }
      
      // Final check before proceeding
      if (!mounted || _isDisposed || _controller == null || !_controller!.value.isInitialized) {
        return;
      }
      
      _logic = FaceCaptureLogic();
      
      if (mounted && !_isDisposed) {
        setState(() {
          _isCameraInitialized = true;
          _instruction = "Position your face in the frame";
        });
        _startStream();
      }
    } on CameraException catch (e) {
      debugPrint("Camera exception: ${e.code} - ${e.description}");
      if (mounted && !_isDisposed) {
        _controller?.dispose();
        _controller = null;
        final navigator = Navigator.of(context);
        _showErrorDialog(
          "Camera Error",
          "Failed to initialize camera: ${e.description ?? e.code}",
          () => navigator.pop(),
          showRetry: true,
        );
      }
    } catch (e) {
      debugPrint("Camera init error: $e");
      if (mounted) {
        final navigator = Navigator.of(context);
        _showErrorDialog(
          "Camera Error",
          "An unexpected error occurred: ${e.toString()}",
          () => navigator.pop(),
          showRetry: true,
        );
      }
    }
  }
  
  void _showErrorDialog(String title, String message, VoidCallback onClose, {bool showRetry = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          if (showRetry)
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _initializeCamera(); // Retry
              },
              child: const Text("Retry"),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              onClose(); // Close screen
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _startStream() {
    if (_isDisposed) return;
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    try {
      if (!controller.value.isStreamingImages) {
        controller.startImageStream(_processCameraImage);
      }
    } catch (e) {
      debugPrint("Error starting image stream: $e");
    }
  }
  
  void _stopStream() {
    if (_isDisposed) return;
    final controller = _controller;
    if (controller == null) return;
    try {
      if (controller.value.isStreamingImages) {
        controller.stopImageStream();
      }
    } catch (e) {
      debugPrint("Error stopping image stream: $e");
    }
  }

  // Frame skipping is handled in FaceCaptureLogic, no need for double skipping

  String? _getUserName() {
    final authStore = AuthStore();
    final userEmail = authStore.userEmail;
    
    if (userEmail != null && userEmail.isNotEmpty) {
      // Extract name from email (part before @)
      final name = userEmail.split('@')[0];
      if (name.isNotEmpty) {
        // Capitalize first letter
        return name[0].toUpperCase() + (name.length > 1 ? name.substring(1) : '');
      }
    }
    
    // Return null if no user email found
    return null;
  }

  void _processCameraImage(CameraImage image) async {
    // Prevent concurrent processing - use lock from logic class
    // Also check if controller is still valid
    if (_isProcessing || _isDisposed || !mounted || _isCapturing) {
      return;
    }
    
    // Get local reference to controller to avoid using disposed controller
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _logic == null) {
      return;
    }
    
    _isProcessing = true;

    try {
      final camera = controller.description;
      final orientation = controller.value.deviceOrientation;
      
      AnalysisResult result;
      try {
        result = await _logic!.analyze(image, camera, orientation)
            .timeout(
              const Duration(seconds: 5),
              onTimeout: () {
                debugPrint("Analysis timeout");
                return AnalysisResult(
                  status: CaptureStatus.noFace,
                  instruction: "Processing timeout\nPlease try again",
                );
              },
            );
      } catch (e, stackTrace) {
        debugPrint("Face analysis exception: $e");
        debugPrint("Stack trace: $stackTrace");
        // Return safe default result instead of crashing
        result = AnalysisResult(
          status: CaptureStatus.noFace,
          instruction: "Position your face in the frame",
        );
      }
      
      if (!mounted || _isDisposed) return;

      // Update analysis metrics - check logic is still valid
      if (_logic != null && !_isDisposed) {
        _currentMetrics = _logic!.getAnalysisMetrics();
      }
      
      // DEBUG: Log face detection data
      debugPrint('Face Detection - Status: ${result.status}, Instruction: ${result.instruction}');
      
      // Always update capture status for overlay
      _currentCaptureStatus = result.status;
      
      // Always update instruction messages to provide proper guidance
      // Update State / Logic
      if (result.status == CaptureStatus.ready) {
          if (!_isStable) {
            // Just became stable - start timer
            if (mounted && !_isDisposed) {
              setState(() {
                 _isStable = true;
                 _instruction = result.instruction;
                 _currentFaceRect = result.faceRect;
                 if (_logic != null) {
                   _currentMetrics = _logic!.getAnalysisMetrics();
                 }
                 _stabilityProgress = 0.0;
              });
              if (!_isDisposed) {
                _startStabilityTimer();
              }
            }
          } else {
            // Update while stable - keep face rect updated but don't reset timer
            // This allows timer to continue even with minor updates
            if (mounted && !_isDisposed) {
              setState(() {
                _instruction = result.instruction;
                _currentFaceRect = result.faceRect;
                if (_logic != null) {
                  _currentMetrics = _logic!.getAnalysisMetrics();
                }
              });
              // Only restart timer if it was actually cancelled (not just inactive)
              // Don't restart if timer is already running
              if (!_isDisposed && _stabilityTimer == null) {
                _startStabilityTimer();
              }
            }
          }
        } else {
          // Not stable/ready - reset timer for any non-ready status
          // This includes moving, tooClose, tooFar, notCentered, etc.
          if (_isStable) {
            // Reset timer for any status that's not ready
            _resetStabilityTimer();
            if (mounted && !_isDisposed) {
              setState(() {
                _isStable = false;
                _instruction = result.instruction;
                _currentFaceRect = result.faceRect;
                if (_logic != null) {
                  _currentMetrics = _logic!.getAnalysisMetrics();
                }
                _stabilityProgress = 0.0;
              });
            }
          } else if (!_isStable) {
            // Always update to show active guidance
            if (mounted && !_isDisposed) {
              setState(() {
                _instruction = result.instruction;
                _currentFaceRect = result.faceRect;
                if (_logic != null) {
                  _currentMetrics = _logic!.getAnalysisMetrics();
                }
              });
            }
          }
        }
      
      // Always update face rect if available, even if status didn't change
      if (result.faceRect != null && mounted && !_isDisposed) {
        // Only update face rect if instruction wasn't already updated above
        if (_currentFaceRect != result.faceRect) {
          setState(() {
            _currentFaceRect = result.faceRect;
          });
        }
      }
    } catch (e, stackTrace) {
      debugPrint("Analysis error: $e");
      debugPrint("Stack trace: $stackTrace");
      // Silently handle errors - don't show red error messages
      // Just reset to initial state
      if (mounted && !_isDisposed) {
        setState(() {
          _instruction = "Position your face in the frame";
          _currentFaceRect = null;
          _currentCaptureStatus = CaptureStatus.noFace;
        });
      }
    } finally {
      _isProcessing = false;
    }
  }

  void _startStabilityTimer() {
    _stabilityTimer?.cancel();
    
    // Update progress during timer
    final startTime = DateTime.now();
    _stabilityTimer = Timer.periodic(
      const Duration(milliseconds: 50),
      (timer) {
        if (!mounted || _isDisposed) {
          timer.cancel();
          return;
        }
        
        final elapsed = DateTime.now().difference(startTime).inMilliseconds;
        final progress = (elapsed / CaptureThresholds.stableDurationMs).clamp(0.0, 1.0);
        
        if (mounted && !_isDisposed) {
          setState(() {
            _stabilityProgress = progress;
          });
        }
        
        if (elapsed >= CaptureThresholds.stableDurationMs) {
          timer.cancel();
          if (!_isDisposed && mounted) {
            _capturePhoto();
          }
        }
      },
    );
  }

  void _resetStabilityTimer() {
    _stabilityTimer?.cancel();
    _stabilityTimer = null;
  }

  Future<void> _capturePhoto() async {
    if (!mounted || _isDisposed || _isCapturing) return;
    
    // Check cooldown period
    if (_lastCaptureTime != null) {
      final timeSinceLastCapture = DateTime.now().difference(_lastCaptureTime!);
      if (timeSinceLastCapture.inMilliseconds < CaptureThresholds.cooldownDurationMs) {
        debugPrint("Capture cooldown active, skipping");
        return;
      }
    }
    
    // Get local reference to controller
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    
    // Safety checks - verify face is still stable and ready
    if (!_isStable || _currentCaptureStatus != CaptureStatus.ready) {
      debugPrint("Face not stable or ready, aborting capture");
      return;
    }

    // Set capturing flag to prevent concurrent captures
    _isCapturing = true;
    _resetStabilityTimer(); // Cancel timer to prevent multiple triggers

    try {
      _stopStream(); // Stop analysis logic
      
      // Double check after stopping stream
      if (_isDisposed || !mounted) {
        return; // finally block will reset _isCapturing
      }
      
      // Haptics/Sound
      HapticFeedback.mediumImpact();
      
      // Use local reference to avoid using disposed controller
      // Add timeout to prevent hanging
      final XFile originalImage = await controller.takePicture()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException("Camera capture timed out after 10 seconds");
            },
          );
      
      if (!mounted) return;

      // Flip image horizontally to match preview (front camera shows mirror view)
      // The preview shows a mirrored view, but captured image is not mirrored
      // We need to flip it to match what user sees in preview
      String flippedImagePath = await _flipImageHorizontally(originalImage.path);
      
      // Navigate to Preview with flipped image
      final confirmed = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => SmartCapturePreviewScreen(
            imagePath: flippedImagePath,
            onRetake: () {
               Navigator.pop(ctx, false);
            },
            onConfirm: (path) {
               Navigator.pop(ctx, true);
            },
          ),
        ),
      );

      // Update last capture time for cooldown
      _lastCaptureTime = DateTime.now();
      
      if (confirmed == true) {
         // Return result to parent with flipped image path
         if (widget.onCaptureComplete != null) {
           widget.onCaptureComplete!(flippedImagePath);
         } else {
           Navigator.pop(context, flippedImagePath);
         }
      } else {
        // Resume Camera only if not disposed
        if (!_isDisposed && mounted) {
          _startStream();
          setState(() {
            _isStable = false;
            _instruction = "Position your face in the frame";
            _currentFaceRect = null;
            _stabilityProgress = 0.0;
          });
        }
      }
      
    } catch (e, stackTrace) {
      debugPrint("Capture error: $e");
      debugPrint("Stack trace: $stackTrace");
      
      // Cancel timer if still running
      _resetStabilityTimer();
      
      if (mounted && !_isDisposed) {
        // Show user-friendly error message (not red SnackBar)
        // Update instruction instead of showing error SnackBar
        setState(() {
          _isStable = false;
          _instruction = "Unable to capture photo\nPlease try again";
          _stabilityProgress = 0.0;
        });
        
        // Resume stream automatically only if not disposed
        if (!_isDisposed) {
          _startStream();
        }
      }
    } finally {
      // Always reset capturing flag
      _isCapturing = false;
    }
  }

  /// Flip image horizontally to match the mirror preview view
  /// Front camera preview shows mirrored view, but captured image is not mirrored
  Future<String> _flipImageHorizontally(String imagePath) async {
    try {
      // Read the image file
      final imageBytes = await File(imagePath).readAsBytes();
      
      // Decode the image
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) {
        debugPrint("Failed to decode image, returning original path");
        return imagePath;
      }
      
      // Flip horizontally
      img.Image flippedImage = img.flipHorizontal(image);
      
      // Get temporary directory for saving flipped image
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final flippedPath = '${directory.path}/flipped_capture_$timestamp.jpg';
      
      // Encode and save the flipped image
      final flippedBytes = img.encodeJpg(flippedImage, quality: 95);
      await File(flippedPath).writeAsBytes(flippedBytes);
      
      // Delete original image to save space (optional)
      try {
        await File(imagePath).delete();
      } catch (e) {
        debugPrint("Could not delete original image: $e");
      }
      
      return flippedPath;
    } catch (e, stackTrace) {
      debugPrint("Error flipping image: $e");
      debugPrint("Stack trace: $stackTrace");
      // Return original path if flipping fails
      return imagePath;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wrap entire build in error boundary to prevent red screen
    try {
      // Get local reference to controller to avoid using disposed controller
      final controller = _controller;
      
      // Check if controller is valid and initialized before building preview
      if (_isDisposed || !_isCameraInitialized || controller == null) {
        return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator(color: Colors.white)),
        );
      }

      // Additional safety check - verify controller is still initialized
      if (!controller.value.isInitialized) {
        return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator(color: Colors.white)),
        );
      }

      // Check preview size is available
      final previewSize = controller.value.previewSize;
      if (previewSize == null || previewSize.width <= 0 || previewSize.height <= 0) {
        return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator(color: Colors.white)),
        );
      }

      // Final check - ensure controller is still valid before building preview
      if (_isDisposed || controller != _controller) {
        return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator(color: Colors.white)),
        );
      }

      // Get screen size safely
      final screenSize = MediaQuery.of(context).size;
      if (screenSize.width <= 0 || screenSize.height <= 0) {
        return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator(color: Colors.white)),
        );
      }

      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Camera Preview - Fill complete screen
            // Wrap in error boundary
            _buildCameraPreview(controller, previewSize),
            
            // Simple Face Tracking Overlay - Corner Guides Only
            // Wrap in error boundary to prevent crashes
            _buildFaceTrackingOverlay(previewSize, screenSize),
            
            // Bottom Instruction Card (Only UI element - no guides/overlays)
            // Wrap in error boundary
            _buildBottomCard(),
            
            // Back Button with app colors
            _buildBackButton(),
          ],
        ),
      );
    } catch (e, stackTrace) {
      debugPrint("Build error: $e");
      debugPrint("Stack trace: $stackTrace");
      // Return safe fallback UI instead of crashing
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                "Initializing camera...",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildCameraPreview(CameraController controller, Size previewSize) {
    try {
      return Positioned.fill(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: previewSize.height,
            height: previewSize.width,
            child: CameraPreview(controller),
          ),
        ),
      );
    } catch (e) {
      debugPrint("CameraPreview build error: $e");
      return const SizedBox.shrink();
    }
  }

  Widget _buildFaceTrackingOverlay(Size previewSize, Size screenSize) {
    try {
      // Validate sizes before creating overlay
      if (previewSize.width <= 0 || previewSize.height <= 0 ||
          screenSize.width <= 0 || screenSize.height <= 0) {
        return const SizedBox.shrink();
      }

      return SimpleFaceTrackingOverlay(
        faceRect: _currentFaceRect,
        status: SimpleFaceTrackingHelper.statusFromCaptureStatus(_currentCaptureStatus),
        cameraSize: Size(
          previewSize.height, // Swapped for rotated preview
          previewSize.width,
        ),
        screenSize: screenSize,
        animationDuration: const Duration(milliseconds: 250),
        cornerLength: 24.0,
        strokeWidth: 3.0,
      );
    } catch (e) {
      debugPrint("FaceTrackingOverlay build error: $e");
      return const SizedBox.shrink();
    }
  }

  Widget _buildBottomCard() {
    try {
      return BottomInstructionCard(
        instruction: _instruction,
        isReady: _isStable,
        progress: _isStable ? _stabilityProgress : null,
        metrics: _currentMetrics,
        userName: _getUserName(),
      );
    } catch (e) {
      debugPrint("BottomCard build error: $e");
      return const SizedBox.shrink();
    }
  }

  Widget _buildBackButton() {
    try {
      return Positioned(
        top: 0,
        left: 0,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gradientStart.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  if (mounted && !_isDisposed) {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint("BackButton build error: $e");
      return const SizedBox.shrink();
    }
  }
}
