import 'dart:math';
import 'dart:ui'; // Required for Rect
import 'package:camera/camera.dart';
import 'package:flutter/services.dart'; // Required for DeviceOrientation
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter/foundation.dart';
import '../utils/camera_utils.dart';

enum CaptureStatus {
  noFace,
  multipleFaces,
  tooClose,
  tooFar,
  notCentered,
  lowLight,
  moving, // implying blur/motion
  ready,
  capturing
}

class AnalysisResult {
  final CaptureStatus status;
  final String instruction;
  final Rect? faceRect;

  AnalysisResult({required this.status, required this.instruction, this.faceRect});
}

class FaceCaptureLogic {
  final FaceDetector _faceDetector;
  
  // Tuning Parameters
  static const double _minFacePercent = 0.35;
  static const double _maxFacePercent = 0.60;
  static const double _maxRotation = 12.0;
  static const double _centerToleranceX = 0.15; // 15% deviation
  static const double _centerToleranceY = 0.15;
  static const int _minBrightness = 80;

  FaceCaptureLogic() : _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate, // Key change: mode -> performanceMode
      enableContours: false,
      enableLandmarks: true,
      enableClassification: true, 
    )
  );

  void dispose() {
    _faceDetector.close();
  }

   Future<AnalysisResult> analyze(CameraImage frame, CameraDescription camera, DeviceOrientation orientation) async {
    // 1. Convert to InputImage
    final inputImage = CameraUtils.convertCameraImage(frame, camera, orientation);
    if (inputImage == null) {
       return AnalysisResult(status: CaptureStatus.noFace, instruction: "Initializing...");
    }

    // 2. Brightness Check (Fast, on Y plane)
    final double brightness = _calculateAverageBrightness(frame);
    if (brightness < _minBrightness) {
       return AnalysisResult(status: CaptureStatus.lowLight, instruction: "More light needed");
    }

    // 3. Face Detection
    List<Face> faces;
    try {
      faces = await _faceDetector.processImage(inputImage);
    } catch (e) {
      return AnalysisResult(status: CaptureStatus.noFace, instruction: "Position your face in the frame");
    }

    // 4. Validation
    if (faces.isEmpty) {
      return AnalysisResult(status: CaptureStatus.noFace, instruction: "Position your face in the frame");
    }
    if (faces.length > 1) {
      return AnalysisResult(status: CaptureStatus.multipleFaces, instruction: "Only one face in the frame");
    }

    final face = faces.first;
    final Rect faceRect = face.boundingBox;
    
    // Calculate metrics relative to image size
    // ML Kit returns coordinates based on the ROTATED image if we pass correct rotation metadata.
    // So if the image is 1280x720 but rotation is 90, ML Kit sees 720x1280.
    // However, we used InputImage.fromBytes which might behave differently depending on version.
    // Standard behavior: coordinates are within the unrotated buffer unless we simply rely on relative.
    
    // Let's assume ML Kit respects the rotation we pass in metadata.
    bool runsDeepAnalysis = true; // Placeholder if we need to toggle
    
    // Determine "Logical" width/height of the analyzed space
    double imageWidth = frame.width.toDouble();
    double imageHeight = frame.height.toDouble();
    
    // If rotation is 90 or 270, swap dimensions for logic check
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
    
    if (rotX.abs() > _maxRotation || rotY.abs() > _maxRotation || rotZ.abs() > _maxRotation) {
      return AnalysisResult(status: CaptureStatus.noFace, instruction: "Look straight ahead", faceRect: faceRect);
    }
    
    // Face Size
    if (faceFillRatio < _minFacePercent) {
      return AnalysisResult(status: CaptureStatus.tooFar, instruction: "Move closer", faceRect: faceRect);
    }
    if (faceFillRatio > _maxFacePercent) {
      return AnalysisResult(status: CaptureStatus.tooClose, instruction: "Move farther away", faceRect: faceRect);
    }

    // Centering
    double faceCenterX = faceRect.center.dx;
    double faceCenterY = faceRect.center.dy;
    
    // Normalized centers
    double normCloudX = faceCenterX / imageWidth;
    double normCloudY = faceCenterY / imageHeight;
    
    if ((normCloudX - 0.5).abs() > _centerToleranceX || (normCloudY - 0.5).abs() > _centerToleranceY) {
       return AnalysisResult(status: CaptureStatus.notCentered, instruction: "Center your face", faceRect: faceRect);
    }

    return AnalysisResult(status: CaptureStatus.ready, instruction: "Perfect — hold still", faceRect: faceRect);
  }

  double _calculateAverageBrightness(CameraImage image) {
    // Y Plane is index 0
    final plane = image.planes[0];
    final bytes = plane.bytes;
    int total = 0;
    // Sample every 100th pixel for speed
    int step = 100;
    int samples = 0;
    for (int i = 0; i < bytes.length; i += step) {
      total += bytes[i];
      samples++;
    }
    if (samples == 0) return 0;
    return total / samples;
  }
}
