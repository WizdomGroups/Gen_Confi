import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter/foundation.dart';
import '../utils/camera_utils.dart';
import '../domain/capture_thresholds.dart';
import '../domain/face_analysis_metrics.dart';

enum CaptureStatus {
  noFace,
  multipleFaces,
  tooClose,
  tooFar,
  notCentered,
  lowLight,
  moving,
  ready,
  capturing
}

class AnalysisResult {
  final CaptureStatus status;
  final String instruction;
  final Rect? faceRect;
  final double? sharpness;
  final double? brightness;
  final FacePositionInfo? positionInfo;
  final List<Offset>? landmarks;

  AnalysisResult({
    required this.status,
    required this.instruction,
    this.faceRect,
    this.sharpness,
    this.brightness,
    this.positionInfo,
    this.landmarks,
  });
}

/// Face position information for visual guidance
class FacePositionInfo {
  final double centerOffsetX; // -1 to 1, negative = left, positive = right
  final double centerOffsetY; // -1 to 1, negative = up, positive = down
  final double distanceRatio; // 0-1, how close/far (0 = too far, 1 = too close, 0.5 = perfect)
  final double rotationX; // Pitch in degrees
  final double rotationY; // Yaw in degrees
  final double rotationZ; // Roll in degrees

  FacePositionInfo({
    required this.centerOffsetX,
    required this.centerOffsetY,
    required this.distanceRatio,
    required this.rotationX,
    required this.rotationY,
    required this.rotationZ,
  });
}

class FaceCaptureLogic {
  final FaceDetector _faceDetector;
  
  // Enhanced motion tracking with multi-frame history
  final List<Map<String, double>> _motionHistory = []; // Store recent face positions
  static const int _maxMotionHistorySize = 5; // Track last 5 frames for smoother detection
  Rect? _previousFaceRect;
  double? _previousFaceCenterX;
  double? _previousFaceCenterY;
  int _frameCount = 0;
  
  // Dynamic stability scoring (0.0 to 1.0)
  double _stabilityScore = 0.0;
  int _consecutiveStableFrames = 0;
  
  // Adaptive thresholds based on conditions
  double _adaptiveMotionThreshold = CaptureThresholds.maxFaceDisplacement;
  double _adaptiveSharpnessThreshold = CaptureThresholds.minSharpness;
  
  // Store last result for overlay access
  AnalysisResult? lastResult;
  
  // Store comprehensive metrics
  FaceAnalysisMetrics? _currentMetrics;
  
  // Processing lock to prevent concurrent analysis
  bool _isAnalyzing = false;
  
  FaceCaptureLogic() : _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableContours: false,
      enableLandmarks: true,
      enableClassification: true, 
    )
  );

  void dispose() {
    _faceDetector.close();
    _isAnalyzing = false;
  }

  /// Get current analysis metrics
  FaceAnalysisMetrics? getAnalysisMetrics() {
    return _currentMetrics;
  }
  
  /// Get current stability score (0.0 to 1.0)
  double get stabilityScore => _stabilityScore;
  
  /// Get consecutive stable frames count
  int get consecutiveStableFrames => _consecutiveStableFrames;

  Future<AnalysisResult> analyze(
    CameraImage frame, 
    CameraDescription camera, 
    DeviceOrientation orientation
  ) async {
    // Prevent concurrent analysis
    if (_isAnalyzing) {
      return lastResult ?? AnalysisResult(
        status: CaptureStatus.noFace,
        instruction: "Processing...",
      );
    }
    
    _frameCount++;
    
    // Frame skipping for performance - process every Nth frame
    // Still provide real-time feedback but reduce CPU load
    if (_frameCount % CaptureThresholds.frameSkipCount != 0) {
      // Return last result for smooth UI updates
      return lastResult ?? AnalysisResult(
        status: CaptureStatus.noFace,
        instruction: "Position your face in the frame",
      );
    }
    
    _isAnalyzing = true;
    
    try {
      // 1. Convert to InputImage
      final inputImage = CameraUtils.convertCameraImage(frame, camera, orientation);
      if (inputImage == null) {
      final result = AnalysisResult(
        status: CaptureStatus.noFace, 
        instruction: "Initializing camera...",
      );
      lastResult = result;
      _currentMetrics = FaceAnalysisMetrics.fromAnalysisResult(result, null);
      _isAnalyzing = false;
      return result;
    }

    // 2. Improved Brightness Check
    final double brightness = _calculateImprovedBrightness(frame);
    if (brightness < CaptureThresholds.minBrightness) {
      final result = AnalysisResult(
        status: CaptureStatus.lowLight, 
        instruction: "Move to a brighter area\nYour face needs more light",
        brightness: brightness,
      );
      lastResult = result;
      _currentMetrics = FaceAnalysisMetrics.fromAnalysisResult(result, null);
      _isAnalyzing = false;
      return result;
    }

    // 3. Face Detection with timeout
    List<Face> faces;
    try {
      faces = await _faceDetector.processImage(inputImage)
          .timeout(
            CaptureThresholds.faceDetectionTimeout,
            onTimeout: () {
              debugPrint("Face detection timeout");
              return <Face>[];
            },
          );
    } catch (e) {
      debugPrint("Face detection error: $e");
      _isAnalyzing = false;
      return AnalysisResult(
        status: CaptureStatus.noFace, 
        instruction: "Detection error\nPlease try again",
      );
    }

    // 4. Basic Validation
    if (faces.isEmpty) {
      final result = AnalysisResult(
        status: CaptureStatus.noFace, 
        instruction: "Position your face in the frame\nMake sure your entire face is visible",
      );
      lastResult = result;
      _currentMetrics = FaceAnalysisMetrics.fromAnalysisResult(result, null);
      _isAnalyzing = false;
      return result;
    }
    
    // Calculate image dimensions first (needed for face filtering and size validation)
    double imageWidth = frame.width.toDouble();
    double imageHeight = frame.height.toDouble();
    
    if (camera.sensorOrientation == 90 || camera.sensorOrientation == 270) {
      double temp = imageWidth;
      imageWidth = imageHeight;
      imageHeight = temp;
    }
    
    // Filter out false positive faces (very small faces are likely reflections or shadows)
    // Calculate image area for size comparison
    double imageArea = imageWidth * imageHeight;
    
    // Filter faces by size - ignore very small faces (likely false positives)
    final validFaces = faces.where((face) {
      final faceArea = face.boundingBox.width * face.boundingBox.height;
      final faceRatio = faceArea / imageArea;
      return faceRatio >= CaptureThresholds.minFaceSizeForMultipleDetection;
    }).toList();
    
    if (validFaces.isEmpty) {
      final result = AnalysisResult(
        status: CaptureStatus.noFace, 
        instruction: "Position your face in the frame\nMake sure your entire face is visible",
      );
      lastResult = result;
      _currentMetrics = FaceAnalysisMetrics.fromAnalysisResult(result, null);
      _isAnalyzing = false;
      return result;
    }
    
    // Check for multiple valid faces
    if (validFaces.length > 1) {
      // Find the largest face (primary face)
      validFaces.sort((a, b) {
        final areaA = a.boundingBox.width * a.boundingBox.height;
        final areaB = b.boundingBox.width * b.boundingBox.height;
        return areaB.compareTo(areaA); // Sort descending
      });
      
      // If the second largest face is significantly smaller, ignore it
      final primaryArea = validFaces[0].boundingBox.width * validFaces[0].boundingBox.height;
      final secondaryArea = validFaces[1].boundingBox.width * validFaces[1].boundingBox.height;
      
      // If secondary face is less than 30% of primary, ignore it (likely false positive)
      if (secondaryArea / primaryArea < 0.30) {
        // Use only the primary face
        final face = validFaces[0];
        // Continue with single face processing below
      } else {
        // Two significant faces detected - show multiple faces message
        final result = AnalysisResult(
          status: CaptureStatus.multipleFaces, 
          instruction: "Make sure only you are visible\nMove others out of the frame",
        );
        lastResult = result;
        _currentMetrics = FaceAnalysisMetrics.fromAnalysisResult(result, null);
        _isAnalyzing = false;
        return result;
      }
    }

    // Use the primary (largest) face
    final face = validFaces[0];
    final Rect faceRect = face.boundingBox;
    
    // Extract landmarks for overlay display
    List<Offset> landmarks = [];
    try {
      // ML Kit provides landmarks through face.landmarks
      // Key landmarks: leftEye, rightEye, noseBase, leftMouth, rightMouth, etc.
      final leftEye = face.landmarks[FaceLandmarkType.leftEye];
      final rightEye = face.landmarks[FaceLandmarkType.rightEye];
      final noseBase = face.landmarks[FaceLandmarkType.noseBase];
      final leftMouth = face.landmarks[FaceLandmarkType.leftMouth];
      final rightMouth = face.landmarks[FaceLandmarkType.rightMouth];
      final leftCheek = face.landmarks[FaceLandmarkType.leftCheek];
      final rightCheek = face.landmarks[FaceLandmarkType.rightCheek];
      
      // Add key landmarks if available (convert int to double for Offset)
      if (leftEye != null) landmarks.add(Offset(leftEye.position.x.toDouble(), leftEye.position.y.toDouble()));
      if (rightEye != null) landmarks.add(Offset(rightEye.position.x.toDouble(), rightEye.position.y.toDouble()));
      if (noseBase != null) landmarks.add(Offset(noseBase.position.x.toDouble(), noseBase.position.y.toDouble()));
      if (leftMouth != null) landmarks.add(Offset(leftMouth.position.x.toDouble(), leftMouth.position.y.toDouble()));
      if (rightMouth != null) landmarks.add(Offset(rightMouth.position.x.toDouble(), rightMouth.position.y.toDouble()));
      if (leftCheek != null) landmarks.add(Offset(leftCheek.position.x.toDouble(), leftCheek.position.y.toDouble()));
      if (rightCheek != null) landmarks.add(Offset(rightCheek.position.x.toDouble(), rightCheek.position.y.toDouble()));
      
      // Add forehead point (estimated from face rect)
      landmarks.add(Offset(faceRect.center.dx, faceRect.top + faceRect.height * CaptureThresholds.foreheadEstimateOffset));
      // Add chin point
      landmarks.add(Offset(faceRect.center.dx, faceRect.bottom - faceRect.height * CaptureThresholds.chinEstimateOffset));
    } catch (e) {
      debugPrint("Landmark extraction error: $e");
    }
    
    // Calculate face fill ratio (image dimensions already calculated above)
    double faceArea = faceRect.width * faceRect.height;
    double faceFillRatio = faceArea / imageArea;

    // Head Pose
    final double rotX = face.headEulerAngleX ?? 0; // Pitch
    final double rotY = face.headEulerAngleY ?? 0; // Yaw
    final double rotZ = face.headEulerAngleZ ?? 0; // Roll
    
    // Calculate position info for visual guidance
    double faceCenterX = faceRect.center.dx;
    double faceCenterY = faceRect.center.dy;
    double normCenterX = faceCenterX / imageWidth;
    double normCenterY = faceCenterY / imageHeight;
    double centerOffsetX = (normCenterX - 0.5) * 2; // Normalize to -1 to 1
    double centerOffsetY = (normCenterY - 0.5) * 2;
    
    // Distance ratio: 0 = too far, 0.5 = perfect, 1 = too close
    double distanceRatio = CaptureThresholds.perfectDistanceRatio;
    if (faceFillRatio < CaptureThresholds.minFaceAreaRatio) {
      distanceRatio = faceFillRatio / CaptureThresholds.minFaceAreaRatio * CaptureThresholds.perfectDistanceRatio;
    } else if (faceFillRatio > CaptureThresholds.maxFaceAreaRatio) {
      distanceRatio = CaptureThresholds.perfectDistanceRatio + ((faceFillRatio - CaptureThresholds.minFaceAreaRatio) / 
                             (CaptureThresholds.maxFaceAreaRatio - CaptureThresholds.minFaceAreaRatio)) * CaptureThresholds.perfectDistanceRatio;
    }
    
    final positionInfo = FacePositionInfo(
      centerOffsetX: centerOffsetX,
      centerOffsetY: centerOffsetY,
      distanceRatio: distanceRatio,
      rotationX: rotX,
      rotationY: rotY,
      rotationZ: rotZ,
    );

    // 5. Head Pose Validation with detailed messages
    if (rotX.abs() > CaptureThresholds.maxPitchDeg) {
      _resetMotionTracking();
      final result = AnalysisResult(
        status: CaptureStatus.noFace, 
        instruction: "Raise phone to eye level\nLook straight at the camera",
        faceRect: faceRect,
        positionInfo: positionInfo,
        landmarks: landmarks,
      );
      lastResult = result;
      // Update metrics
      _currentMetrics = FaceAnalysisMetrics.fromAnalysisResult(result, positionInfo);
      _isAnalyzing = false;
      return result;
    }
    if (rotY.abs() > CaptureThresholds.maxYawDeg) {
      _resetMotionTracking();
      final result = AnalysisResult(
        status: CaptureStatus.noFace, 
        instruction: "Look directly at the camera\nTurn your head to face forward",
        faceRect: faceRect,
        positionInfo: positionInfo,
        landmarks: landmarks,
      );
      lastResult = result;
      // Update metrics
      _currentMetrics = FaceAnalysisMetrics.fromAnalysisResult(result, positionInfo);
      _isAnalyzing = false;
      return result;
    }
    if (rotZ.abs() > CaptureThresholds.maxRollDeg) {
      _resetMotionTracking();
      final result = AnalysisResult(
        status: CaptureStatus.noFace, 
        instruction: "Straighten your head\nKeep your head level",
        faceRect: faceRect,
        positionInfo: positionInfo,
        landmarks: landmarks,
      );
      lastResult = result;
      // Update metrics
      _currentMetrics = FaceAnalysisMetrics.fromAnalysisResult(result, positionInfo);
      _isAnalyzing = false;
      return result;
    }
    
    // 6. Face Size Validation with distance guidance
    // First check if face is too small (too far)
    if (faceFillRatio < CaptureThresholds.minFaceAreaRatio) {
      _resetMotionTracking();
      final result = AnalysisResult(
        status: CaptureStatus.tooFar, 
        instruction: "Move closer to the camera\nYour face needs to fill more of the frame",
        faceRect: faceRect,
        positionInfo: positionInfo,
        landmarks: landmarks,
      );
      lastResult = result;
      // Update metrics
      _currentMetrics = FaceAnalysisMetrics.fromAnalysisResult(result, positionInfo);
      _isAnalyzing = false;
      return result;
    }
    
    // Check if face is too large (too close) - stricter for model processing
    if (faceFillRatio > CaptureThresholds.maxFaceAreaRatio) {
      _resetMotionTracking();
      final result = AnalysisResult(
        status: CaptureStatus.tooClose, 
        instruction: "Step back from the camera\nYour face is too close for processing",
        faceRect: faceRect,
        positionInfo: positionInfo,
        landmarks: landmarks,
      );
      lastResult = result;
      // Update metrics
      _currentMetrics = FaceAnalysisMetrics.fromAnalysisResult(result, positionInfo);
      _isAnalyzing = false;
      return result;
    }

    // 7. Centering Validation with directional guidance
    double centerOffsetXAbs = centerOffsetX.abs();
    double centerOffsetYAbs = centerOffsetY.abs();
    
    if (centerOffsetXAbs > CaptureThresholds.maxCenterOffset || 
        centerOffsetYAbs > CaptureThresholds.maxCenterOffset) {
      _resetMotionTracking();
      String horizontal = centerOffsetXAbs > CaptureThresholds.maxCenterOffset
          ? (centerOffsetX > 0 ? "Move left" : "Move right")
          : "";
      String vertical = centerOffsetYAbs > CaptureThresholds.maxCenterOffset
          ? (centerOffsetY > 0 ? "Move up" : "Move down")
          : "";
      
      String instruction = "🎯 Center your face\n";
      if (horizontal.isNotEmpty && vertical.isNotEmpty) {
        instruction += "$horizontal and $vertical";
      } else if (horizontal.isNotEmpty) {
        instruction += horizontal;
      } else if (vertical.isNotEmpty) {
        instruction += vertical;
      }
      
      final result = AnalysisResult(
        status: CaptureStatus.notCentered, 
        instruction: instruction,
        faceRect: faceRect,
        positionInfo: positionInfo,
        landmarks: landmarks,
      );
      lastResult = result;
      // Update metrics
      _currentMetrics = FaceAnalysisMetrics.fromAnalysisResult(result, positionInfo);
      _isAnalyzing = false;
      return result;
    }

    // 8. Enhanced Motion Detection with multi-frame analysis
    double motionScore = _calculateMotionScore(faceCenterX, faceCenterY, imageWidth, imageHeight);
    
    // Update motion history
    _motionHistory.add({
      'x': faceCenterX / imageWidth,
      'y': faceCenterY / imageHeight,
      'timestamp': DateTime.now().millisecondsSinceEpoch.toDouble(),
    });
    
    // Keep only recent history
    if (_motionHistory.length > _maxMotionHistorySize) {
      _motionHistory.removeAt(0);
    }
    
    // Adaptive motion threshold based on face size (larger faces = stricter)
    double adaptiveThreshold = _adaptiveMotionThreshold;
    if (faceFillRatio > CaptureThresholds.optimalMaxFaceAreaRatio) {
      // Face is close - be more strict
      adaptiveThreshold = CaptureThresholds.maxFaceDisplacement * 0.7;
    } else if (faceFillRatio < CaptureThresholds.optimalMinFaceAreaRatio) {
      // Face is far - be more lenient
      adaptiveThreshold = CaptureThresholds.maxFaceDisplacement * 1.3;
    }
    
    // Calculate stability score (0.0 = moving, 1.0 = perfectly still)
    _stabilityScore = 1.0 - (motionScore / adaptiveThreshold).clamp(0.0, 1.0);
    
    // Only fail if movement is significant and consistent
    if (motionScore > adaptiveThreshold && _motionHistory.length >= 3) {
      // Check if motion is consistent (not just a single frame glitch)
      bool isConsistentMotion = _isConsistentMotion();
      if (isConsistentMotion) {
        _updateMotionTracking(faceRect, faceCenterX, faceCenterY);
        _consecutiveStableFrames = 0;
        final result = AnalysisResult(
          status: CaptureStatus.moving, 
          instruction: "Hold still\nKeep your head steady",
          faceRect: faceRect,
          positionInfo: positionInfo,
          landmarks: landmarks,
        );
        lastResult = result;
        _currentMetrics = FaceAnalysisMetrics.fromAnalysisResult(result, positionInfo);
        _isAnalyzing = false;
        return result;
      }
    } else if (motionScore <= adaptiveThreshold) {
      _consecutiveStableFrames++;
    }

    // 9. Enhanced Sharpness/Blur Detection with adaptive threshold
    double sharpness = _calculateSharpness(frame, faceRect);
    
    // Adaptive sharpness threshold based on face size and brightness
    double adaptiveSharpnessThreshold = _adaptiveSharpnessThreshold;
    if (brightness < CaptureThresholds.minBrightness) {
      // Low light - be more lenient with sharpness
      adaptiveSharpnessThreshold = CaptureThresholds.minSharpness * 0.6;
    } else if (brightness > 200) {
      // Very bright - can be stricter
      adaptiveSharpnessThreshold = CaptureThresholds.minSharpness * 1.2;
    }
    
    // Progressive sharpness validation (warn before failing)
    double sharpnessRatio = sharpness / adaptiveSharpnessThreshold;
    if (sharpnessRatio < 0.5) {
      // Very blurry - fail immediately
      _updateMotionTracking(faceRect, faceCenterX, faceCenterY);
      _consecutiveStableFrames = 0;
      final result = AnalysisResult(
        status: CaptureStatus.moving, 
        instruction: "Hold still for a moment\nImage is blurry",
        faceRect: faceRect,
        sharpness: sharpness,
        positionInfo: positionInfo,
        landmarks: landmarks,
      );
      lastResult = result;
      // Update metrics
      _currentMetrics = FaceAnalysisMetrics.fromAnalysisResult(result, positionInfo);
      _isAnalyzing = false;
      return result;
    } else if (sharpnessRatio < 0.8 && _stabilityScore < 0.7) {
      // Slightly blurry and moving - warn but don't fail yet
      // Continue to ready state but with lower confidence
    }

    // All validations passed - face is in optimal range for model processing
    // Update motion tracking
    _updateMotionTracking(faceRect, faceCenterX, faceCenterY);
    _consecutiveStableFrames++;
    
    // Calculate overall quality score (0.0 to 1.0)
    double qualityScore = _calculateQualityScore(
      faceFillRatio,
      centerOffsetXAbs,
      centerOffsetYAbs,
      sharpness,
      brightness,
      _stabilityScore,
    );
    
    // Only mark as ready if quality score is high enough
    // This ensures we only capture when everything is truly optimal
    if (qualityScore >= 0.75 && _consecutiveStableFrames >= 2) {
      final result = AnalysisResult(
        status: CaptureStatus.ready, 
        instruction: "Perfect! Hold still\nPhoto will be taken automatically",
        faceRect: faceRect,
        sharpness: sharpness,
        brightness: brightness,
        positionInfo: positionInfo,
        landmarks: landmarks,
      );
      lastResult = result;
      // Update metrics
      _currentMetrics = FaceAnalysisMetrics.fromAnalysisResult(result, positionInfo);
      _isAnalyzing = false;
      return result;
    } else {
      // Almost ready - provide encouraging feedback
      String instruction = "Almost there! ";
      if (qualityScore < 0.6) {
        instruction += "Adjust your position slightly";
      } else if (_stabilityScore < 0.8) {
        instruction += "Hold still a bit longer";
      } else {
        instruction += "Keep holding still";
      }
      
      final result = AnalysisResult(
        status: CaptureStatus.moving, 
        instruction: instruction,
        faceRect: faceRect,
        sharpness: sharpness,
        brightness: brightness,
        positionInfo: positionInfo,
        landmarks: landmarks,
      );
      lastResult = result;
      // Update metrics
      _currentMetrics = FaceAnalysisMetrics.fromAnalysisResult(result, positionInfo);
      _isAnalyzing = false;
      return result;
    }
    } catch (e, stackTrace) {
      // Handle any unexpected errors
      debugPrint("Unexpected error in analyze: $e");
      debugPrint("Stack trace: $stackTrace");
      final errorResult = AnalysisResult(
        status: CaptureStatus.noFace,
        instruction: "Detection error\nPlease try again",
      );
      lastResult = errorResult;
      _currentMetrics = FaceAnalysisMetrics.fromAnalysisResult(errorResult, null);
      _isAnalyzing = false;
      return errorResult;
    } finally {
      // Ensure lock is released even if error occurs
      _isAnalyzing = false;
    }
  }

  double _calculateImprovedBrightness(CameraImage image) {
    final plane = image.planes[0];
    final bytes = plane.bytes;
    final width = image.width;
    final height = image.height;
    
    int total = 0;
    int samples = 0;
    final int step = CaptureThresholds.brightnessSamplingStep.toInt();
    
    for (int y = 0; y < height; y += step) {
      for (int x = 0; x < width; x += step) {
        int index = y * width + x;
        if (index < bytes.length) {
          double weight = 1.0;
          double centerX = width / 2.0;
          double centerY = height / 2.0;
          double distFromCenter = sqrt(
            pow((x - centerX) / width, 2) + pow((y - centerY) / height, 2)
          );
          if (distFromCenter < CaptureThresholds.centerRegionRadius) {
            weight = CaptureThresholds.centerWeightMultiplier;
          }
          
          total += (bytes[index] * weight).round();
          samples += weight.round();
        }
      }
    }
    
    if (samples == 0) return 0;
    return total / samples;
  }

  double _calculateSharpness(CameraImage image, Rect faceRegion) {
    try {
      final plane = image.planes[0];
      final bytes = plane.bytes;
      final width = image.width;
      final height = image.height;
      
      int faceLeft = faceRegion.left.toInt().clamp(0, width - 1);
      int faceTop = faceRegion.top.toInt().clamp(0, height - 1);
      int faceRight = faceRegion.right.toInt().clamp(0, width - 1);
      int faceBottom = faceRegion.bottom.toInt().clamp(0, height - 1);
      
      double variance = 0.0;
      double mean = 0.0;
      int count = 0;
      
      final int step = CaptureThresholds.sharpnessSamplingStep.toInt();
      for (int y = faceTop; y < faceBottom; y += step) {
        for (int x = faceLeft; x < faceRight; x += step) {
          int index = y * width + x;
          if (index >= 0 && index < bytes.length) {
            int center = bytes[index];
            int right = (x + 1 < width) ? bytes[y * width + (x + 1)] : center;
            int bottom = (y + 1 < height) ? bytes[(y + 1) * width + x] : center;
            
            double laplacian = (center * 2 - right - bottom).abs().toDouble();
            mean += laplacian;
            count++;
          }
        }
      }
      
      if (count == 0) return 0.0;
      mean /= count;
      
      for (int y = faceTop; y < faceBottom; y += step) {
        for (int x = faceLeft; x < faceRight; x += step) {
          int index = y * width + x;
          if (index >= 0 && index < bytes.length) {
            int center = bytes[index];
            int right = (x + 1 < width) ? bytes[y * width + (x + 1)] : center;
            int bottom = (y + 1 < height) ? bytes[(y + 1) * width + x] : center;
            
            double laplacian = (center * 2 - right - bottom).abs().toDouble();
            variance += pow(laplacian - mean, 2);
          }
        }
      }
      
      return count > 0 ? variance / count : 0.0;
    } catch (e) {
      debugPrint("Sharpness calculation error: $e");
      return 0.0;
    }
  }

  void _updateMotionTracking(Rect faceRect, double centerX, double centerY) {
    _previousFaceRect = faceRect;
    _previousFaceCenterX = centerX;
    _previousFaceCenterY = centerY;
  }

  void _resetMotionTracking() {
    _previousFaceRect = null;
    _previousFaceCenterX = null;
    _previousFaceCenterY = null;
    _motionHistory.clear();
    _consecutiveStableFrames = 0;
    _stabilityScore = 0.0;
  }
  
  /// Calculate motion score based on multi-frame history
  double _calculateMotionScore(double centerX, double centerY, double imageWidth, double imageHeight) {
    if (_motionHistory.isEmpty || _previousFaceCenterX == null || _previousFaceCenterY == null) {
      return 0.0;
    }
    
    // Calculate displacement from previous frame
    double displacementX = (centerX - _previousFaceCenterX!) / imageWidth;
    double displacementY = (centerY - _previousFaceCenterY!) / imageHeight;
    double instantDisplacement = sqrt(displacementX * displacementX + displacementY * displacementY);
    
    // Calculate average displacement over history (smoother detection)
    if (_motionHistory.length >= 2) {
      double totalDisplacement = 0.0;
      for (int i = 1; i < _motionHistory.length; i++) {
        double dx = (_motionHistory[i]['x']! - _motionHistory[i-1]['x']!).abs();
        double dy = (_motionHistory[i]['y']! - _motionHistory[i-1]['y']!).abs();
        totalDisplacement += sqrt(dx * dx + dy * dy);
      }
      double avgDisplacement = totalDisplacement / (_motionHistory.length - 1);
      
      // Use weighted average: 70% instant, 30% average (responds quickly but smooth)
      return instantDisplacement * 0.7 + avgDisplacement * 0.3;
    }
    
    return instantDisplacement;
  }
  
  /// Check if motion is consistent (not just a single frame glitch)
  bool _isConsistentMotion() {
    if (_motionHistory.length < 3) return false;
    
    // Check if last 3 frames show consistent movement
    int movingFrames = 0;
    for (int i = _motionHistory.length - 3; i < _motionHistory.length - 1; i++) {
      double dx = (_motionHistory[i+1]['x']! - _motionHistory[i]['x']!).abs();
      double dy = (_motionHistory[i+1]['y']! - _motionHistory[i]['y']!).abs();
      double displacement = sqrt(dx * dx + dy * dy);
      
      if (displacement > _adaptiveMotionThreshold * 0.8) {
        movingFrames++;
      }
    }
    
    // Motion is consistent if at least 2 out of 3 frames show movement
    return movingFrames >= 2;
  }
  
  /// Calculate overall quality score (0.0 to 1.0)
  double _calculateQualityScore(
    double faceFillRatio,
    double centerOffsetX,
    double centerOffsetY,
    double sharpness,
    double brightness,
    double stabilityScore,
  ) {
    // Distance score (0.0 to 1.0) - optimal range gets 1.0
    double distanceScore = 1.0;
    if (faceFillRatio < CaptureThresholds.optimalMinFaceAreaRatio) {
      distanceScore = faceFillRatio / CaptureThresholds.optimalMinFaceAreaRatio;
    } else if (faceFillRatio > CaptureThresholds.optimalMaxFaceAreaRatio) {
      distanceScore = 1.0 - ((faceFillRatio - CaptureThresholds.optimalMaxFaceAreaRatio) / 
                             (CaptureThresholds.maxFaceAreaRatio - CaptureThresholds.optimalMaxFaceAreaRatio));
    }
    
    // Centering score (0.0 to 1.0) - perfectly centered gets 1.0
    double maxOffset = max(centerOffsetX, centerOffsetY);
    double centeringScore = 1.0 - (maxOffset / CaptureThresholds.maxCenterOffset).clamp(0.0, 1.0);
    
    // Sharpness score (0.0 to 1.0)
    double sharpnessScore = (sharpness / _adaptiveSharpnessThreshold).clamp(0.0, 1.0);
    
    // Brightness score (0.0 to 1.0) - optimal around 150-200
    double brightnessScore = 1.0;
    if (brightness < CaptureThresholds.minBrightness) {
      brightnessScore = brightness / CaptureThresholds.minBrightness;
    } else if (brightness > 220) {
      brightnessScore = 1.0 - ((brightness - 220) / 35).clamp(0.0, 1.0);
    }
    
    // Weighted combination (stability is most important)
    double qualityScore = (
      distanceScore * 0.20 +
      centeringScore * 0.15 +
      sharpnessScore * 0.20 +
      brightnessScore * 0.15 +
      stabilityScore * 0.30
    );
    
    return qualityScore.clamp(0.0, 1.0);
  }
  
}
