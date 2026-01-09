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
import 'package:gen_confi/core/storage/token_storage.dart';
import 'package:gen_confi/core/models/user_model.dart';
import 'package:gen_confi/app/routes/app_routes.dart';
import 'dart:convert';

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
  
  // Manual capture timer - enable button after 20 seconds
  Timer? _manualCaptureTimer;
  bool _showManualCaptureButton = false;
  DateTime? _screenStartTime;
  
  // User name for guidance messages
  String? _userName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _screenStartTime = DateTime.now();
    _startManualCaptureTimer();
    _loadUserName();
    _initializeCamera();
  }
  
  Future<void> _loadUserName() async {
    try {
      // Get user data from storage
      final userJson = await TokenStorage.getUser();
      if (userJson != null && userJson.isNotEmpty) {
        final userData = jsonDecode(userJson);
        final user = UserModel.fromJson(userData);
        
        // Store the user's actual name (use first name only)
        if (mounted && !_isDisposed && user.name.isNotEmpty) {
          setState(() {
            // Extract first name (first word) and capitalize first letter
            final firstName = user.name.split(' ').first;
            _userName = firstName[0].toUpperCase() + 
                       (firstName.length > 1 ? firstName.substring(1) : '');
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading user name: $e");
    }
  }
  
  void _startManualCaptureTimer() {
    _manualCaptureTimer?.cancel();
    _manualCaptureTimer = Timer(const Duration(seconds: 20), () {
      if (mounted && !_isDisposed && !_isCapturing) {
        setState(() {
          _showManualCaptureButton = true;
          // Update instruction to inform user about manual button
          if (!_isStable) {
            _instruction = "Tap the button below to capture manually";
          }
        });
        debugPrint("Manual capture button enabled after 20 seconds");
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true; // Mark as disposed first
    WidgetsBinding.instance.removeObserver(this);
    _stabilityTimer?.cancel();
    _manualCaptureTimer?.cancel();
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
    
    switch (state) {
      case AppLifecycleState.inactive:
        // App is transitioning (e.g., incoming call, notification)
        // Just pause the stream, don't dispose camera yet
        if (controller != null && controller.value.isInitialized) {
          _stopStream();
        }
        break;
        
      case AppLifecycleState.paused:
        // App is in background - stop stream and dispose camera to free resources
        if (controller != null && controller.value.isInitialized) {
          _stopStream();
          final controllerToDispose = _controller;
          _controller = null; // Clear reference before disposal
          _isCameraInitialized = false;
          controllerToDispose?.dispose();
        }
        break;
        
      case AppLifecycleState.resumed:
        // App is back in foreground - reinitialize camera if needed
        if (!_isDisposed && mounted && (controller == null || !controller.value.isInitialized)) {
          _initializeCamera();
        } else if (controller != null && controller.value.isInitialized) {
          // Camera still valid, just restart stream
          _startStream();
        }
        break;
        
      case AppLifecycleState.detached:
        // App is being terminated - handled by dispose()
        break;
        
      case AppLifecycleState.hidden:
        // App is hidden - pause stream
        if (controller != null && controller.value.isInitialized) {
          _stopStream();
        }
        break;
    }
  }

  Future<void> _initializeCamera() async {
    try {
      // 1. Check current permission status first
      final currentStatus = await Permission.camera.status;
      
      // If permission was previously denied, request again
      if (currentStatus.isDenied) {
        final status = await Permission.camera.request();
        if (status.isDenied || status.isPermanentlyDenied) {
          // User denied permission - navigate back to home
          if (mounted) {
            _navigateBackToHome();
          }
          return;
        }
      } else if (currentStatus.isPermanentlyDenied) {
        // Permission is permanently denied - show dialog and navigate back
        if (mounted) {
          _showPermissionDeniedDialog();
        }
        return;
      } else if (!currentStatus.isGranted) {
        // Request permission if not granted
        final status = await Permission.camera.request();
        if (status.isDenied || status.isPermanentlyDenied) {
          // User denied permission - navigate back to home
          if (mounted) {
            _navigateBackToHome();
          }
          return;
        }
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
  
  void _navigateBackToHome() {
    // Navigate back to home screen (client shell)
    if (mounted && !_isDisposed) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.clientShell,
        (route) => false,
      );
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Camera Permission Denied"),
        content: const Text(
          "Camera permission is required to use face capture. "
          "Please enable it in your device settings if you want to use this feature.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _navigateBackToHome(); // Navigate to home
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
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
    
    // Adaptive timer duration based on quality
    // Higher quality = faster capture, lower quality = wait longer
    int timerDuration = CaptureThresholds.stableDurationMs;
    if (_logic != null) {
      // Adjust based on how stable the face is
      final stabilityScore = _logic!.stabilityScore;
      final consecutiveStable = _logic!.consecutiveStableFrames;
      
      if (stabilityScore > 0.9 && consecutiveStable >= 3) {
        // Very stable - capture faster (30% faster)
        timerDuration = (CaptureThresholds.stableDurationMs * 0.7).round();
      } else if (stabilityScore < 0.7 || consecutiveStable < 2) {
        // Less stable - wait longer (30% longer)
        timerDuration = (CaptureThresholds.stableDurationMs * 1.3).round();
      }
    }
    
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
        final progress = (elapsed / timerDuration).clamp(0.0, 1.0);
        
        if (mounted && !_isDisposed) {
          setState(() {
            _stabilityProgress = progress;
          });
        }
        
        if (elapsed >= timerDuration) {
          timer.cancel();
          if (!_isDisposed && mounted) {
            // Hide manual button when auto-capture triggers
            if (_showManualCaptureButton) {
              setState(() {
                _showManualCaptureButton = false;
              });
            }
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

  Future<void> _capturePhoto({bool isManual = false}) async {
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
    
    // For manual capture, allow even if not perfectly stable
    // For auto capture, require face to be stable and ready
    if (!isManual) {
      if (!_isStable || _currentCaptureStatus != CaptureStatus.ready) {
        debugPrint("Face not stable or ready, aborting auto capture");
        return;
      }
    } else {
      // Manual capture - only require face to be detected (not necessarily perfect)
      if (_currentCaptureStatus == CaptureStatus.noFace || 
          _currentFaceRect == null) {
        debugPrint("No face detected, cannot capture manually");
        if (mounted && !_isDisposed) {
          setState(() {
            _instruction = "Please position your face in the frame";
          });
        }
        return;
      }
      debugPrint("Manual capture triggered - capturing even if not perfect");
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
          // Reset manual capture timer when retaking
          _showManualCaptureButton = false;
          _startManualCaptureTimer();
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
            
            // Manual Capture Button (appears after 20 seconds)
            if (_showManualCaptureButton) _buildManualCaptureButton(),
            
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
        userName: _userName,
      );
    } catch (e) {
      debugPrint("BottomCard build error: $e");
      return const SizedBox.shrink();
    }
  }

  Widget _buildManualCaptureButton() {
    try {
      return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 120.0, left: 24.0, right: 24.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Hint text
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Tap to capture manually",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Capture button
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gradientStart.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isCapturing ? null : () => _capturePhoto(isManual: true),
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 3,
                            ),
                          ),
                          child: _isCapturing
                              ? const Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint("ManualCaptureButton build error: $e");
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
