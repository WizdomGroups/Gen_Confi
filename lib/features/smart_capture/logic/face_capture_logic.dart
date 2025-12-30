import 'dart:math';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter/foundation.dart';
import '../utils/camera_utils.dart';
import '../domain/capture_thresholds.dart';

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
  final List<Offset>? landmarks; // Face landmarks for mesh visualization

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
  
  // Motion tracking
  Rect? _previousFaceRect;
  double? _previousFaceCenterX;
  double? _previousFaceCenterY;
  int _frameCount = 0;
  final List<CameraImage> _frameBuffer = [];
  
  // Store last result for overlay access
  AnalysisResult? lastResult;
  
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
    _frameBuffer.clear();
  }

  Future<AnalysisResult> analyze(
    CameraImage frame, 
    CameraDescription camera, 
    DeviceOrientation orientation
  ) async {
    _frameCount++;
    
    // Process every frame for active face tracking
    // No frame skipping - we need real-time guidance updates

    // Manage frame buffer
    _frameBuffer.add(frame);
    if (_frameBuffer.length > CaptureThresholds.maxBufferSize) {
      _frameBuffer.removeAt(0);
    }

    // 1. Convert to InputImage
    final inputImage = CameraUtils.convertCameraImage(frame, camera, orientation);
    if (inputImage == null) {
      return AnalysisResult(
        status: CaptureStatus.noFace, 
        instruction: "Initializing camera...",
      );
    }

    // 2. Improved Brightness Check
    final double brightness = _calculateImprovedBrightness(frame);
    if (brightness < CaptureThresholds.minBrightness) {
      return AnalysisResult(
        status: CaptureStatus.lowLight, 
        instruction: "💡 Move to a brighter area\nYour face needs more light",
        brightness: brightness,
      );
    }

    // 3. Face Detection
    List<Face> faces;
    try {
      faces = await _faceDetector.processImage(inputImage);
    } catch (e) {
      debugPrint("Face detection error: $e");
      return AnalysisResult(
        status: CaptureStatus.noFace, 
        instruction: "👤 Position your face in the center\nLook directly at the camera",
      );
    }

    // 4. Basic Validation
    if (faces.isEmpty) {
      return AnalysisResult(
        status: CaptureStatus.noFace, 
        instruction: "👤 Position your face in the frame\nMake sure your entire face is visible",
      );
    }
    if (faces.length > 1) {
      return AnalysisResult(
        status: CaptureStatus.multipleFaces, 
        instruction: "👥 Only one person, please!\nMove others out of the frame",
      );
    }

    final face = faces.first;
    final Rect faceRect = face.boundingBox;
    
    // Extract landmarks for mesh visualization
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
      landmarks.add(Offset(faceRect.center.dx, faceRect.top + faceRect.height * 0.15));
      // Add chin point
      landmarks.add(Offset(faceRect.center.dx, faceRect.bottom - faceRect.height * 0.1));
    } catch (e) {
      debugPrint("Landmark extraction error: $e");
    }
    
    // Calculate image dimensions
    double imageWidth = frame.width.toDouble();
    double imageHeight = frame.height.toDouble();
    
    if (camera.sensorOrientation == 90 || camera.sensorOrientation == 270) {
      double temp = imageWidth;
      imageWidth = imageHeight;
      imageHeight = temp;
    }
    
    double faceArea = faceRect.width * faceRect.height;
    double imageArea = imageWidth * imageHeight;
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
    double distanceRatio = 0.5;
    if (faceFillRatio < CaptureThresholds.minFaceAreaRatio) {
      distanceRatio = faceFillRatio / CaptureThresholds.minFaceAreaRatio * 0.5;
    } else if (faceFillRatio > CaptureThresholds.maxFaceAreaRatio) {
      distanceRatio = 0.5 + ((faceFillRatio - CaptureThresholds.minFaceAreaRatio) / 
                             (CaptureThresholds.maxFaceAreaRatio - CaptureThresholds.minFaceAreaRatio)) * 0.5;
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
      String direction = rotX > 0 ? "down" : "up";
      _resetMotionTracking();
      return AnalysisResult(
        status: CaptureStatus.noFace, 
        instruction: "⬆️ Raise phone to eye level\nLook straight at the camera",
        faceRect: faceRect,
        positionInfo: positionInfo,
        landmarks: landmarks,
      );
    }
    if (rotY.abs() > CaptureThresholds.maxYawDeg) {
      String direction = rotY > 0 ? "right" : "left";
      _resetMotionTracking();
      return AnalysisResult(
        status: CaptureStatus.noFace, 
        instruction: "👀 Look directly at the camera\nTurn your head to face forward",
        faceRect: faceRect,
        positionInfo: positionInfo,
        landmarks: landmarks,
      );
    }
    if (rotZ.abs() > CaptureThresholds.maxRollDeg) {
      _resetMotionTracking();
      return AnalysisResult(
        status: CaptureStatus.noFace, 
        instruction: "📐 Straighten your head\nKeep your head level",
        faceRect: faceRect,
        positionInfo: positionInfo,
        landmarks: landmarks,
      );
    }
    
    // 6. Face Size Validation with distance guidance
    if (faceFillRatio < CaptureThresholds.minFaceAreaRatio) {
      _resetMotionTracking();
      double percentTooFar = ((CaptureThresholds.minFaceAreaRatio - faceFillRatio) / CaptureThresholds.minFaceAreaRatio * 100).roundToDouble();
      return AnalysisResult(
        status: CaptureStatus.tooFar, 
        instruction: "📏 Move closer to the camera\nYour face is too far away",
        faceRect: faceRect,
        positionInfo: positionInfo,
        landmarks: landmarks,
      );
    }
    if (faceFillRatio > CaptureThresholds.maxFaceAreaRatio) {
      _resetMotionTracking();
      return AnalysisResult(
        status: CaptureStatus.tooClose, 
        instruction: "📏 Move back a little\nYour face is too close",
        faceRect: faceRect,
        positionInfo: positionInfo,
        landmarks: landmarks,
      );
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
      
      return AnalysisResult(
        status: CaptureStatus.notCentered, 
        instruction: instruction,
        faceRect: faceRect,
        positionInfo: positionInfo,
        landmarks: landmarks,
      );
    }

    // 8. Motion Detection (only check if significant movement)
    if (_previousFaceRect != null && 
        _previousFaceCenterX != null && 
        _previousFaceCenterY != null) {
      double displacementX = (faceCenterX - _previousFaceCenterX!).abs() / imageWidth;
      double displacementY = (faceCenterY - _previousFaceCenterY!).abs() / imageHeight;
      double totalDisplacement = sqrt(displacementX * displacementX + displacementY * displacementY);
      
      // Only fail if movement is significant (allow small natural movements)
      if (totalDisplacement > CaptureThresholds.maxFaceDisplacement) {
        _updateMotionTracking(faceRect, faceCenterX, faceCenterY);
        return AnalysisResult(
          status: CaptureStatus.moving, 
          instruction: "⏸️ Hold still...\nKeep your head steady",
          faceRect: faceRect,
          positionInfo: positionInfo,
          landmarks: landmarks,
        );
      }
    }

    // 9. Sharpness/Blur Detection (relaxed - only fail if very blurry)
    double sharpness = _calculateSharpness(frame, faceRect);
    // Only fail if significantly blurry, allow some tolerance
    if (sharpness < CaptureThresholds.minSharpness * 0.7) {
      _updateMotionTracking(faceRect, faceCenterX, faceCenterY);
      return AnalysisResult(
        status: CaptureStatus.moving, 
        instruction: "📸 Hold still for a moment\nImage is blurry",
        faceRect: faceRect,
        sharpness: sharpness,
        positionInfo: positionInfo,
        landmarks: landmarks,
      );
    }

    // All validations passed
    _updateMotionTracking(faceRect, faceCenterX, faceCenterY);
    final result = AnalysisResult(
      status: CaptureStatus.ready, 
      instruction: "✅ Perfect! Hold still...\nPhoto will be taken automatically",
      faceRect: faceRect,
      sharpness: sharpness,
      brightness: brightness,
      positionInfo: positionInfo,
      landmarks: landmarks,
    );
    lastResult = result;
    return result;
  }

  double _calculateImprovedBrightness(CameraImage image) {
    final plane = image.planes[0];
    final bytes = plane.bytes;
    final width = image.width;
    final height = image.height;
    
    int total = 0;
    int samples = 0;
    int step = 50;
    
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
          if (distFromCenter < 0.3) {
            weight = 2.0;
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
      
      int step = 5;
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
  }
}
