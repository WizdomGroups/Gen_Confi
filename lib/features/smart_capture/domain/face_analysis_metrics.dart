import 'dart:ui';
import 'package:flutter/material.dart';
import '../logic/face_capture_logic.dart';
import 'capture_thresholds.dart';

/// Comprehensive face analysis metrics for real-time display
class FaceAnalysisMetrics {
  // Detection
  final bool isFaceDetected;
  final double faceDetectionConfidence; // 0-100
  final int faceCount;
  
  // Positioning
  final double distanceScore; // 0-100 (0=too far, 50=perfect, 100=too close)
  final double centeringScore; // 0-100 (100=perfectly centered)
  final double centerOffsetX; // -1 to 1
  final double centerOffsetY; // -1 to 1
  final String distanceStatus; // "Too Close", "Perfect", "Too Far"
  final String centeringStatus; // "Centered", "Move Left", etc.
  
  // Image Quality
  final double brightnessScore; // 0-100
  final double sharpnessScore; // 0-100
  final String brightnessStatus; // "Good", "Low", "Too Bright"
  final String sharpnessStatus; // "Excellent", "Good", "Blurry"
  
  // Pose
  final double pitchDeg; // Head up/down
  final double yawDeg; // Head left/right
  final double rollDeg; // Head tilt
  final double poseScore; // 0-100 (100=perfect pose)
  final String poseStatus; // "Perfect", "Tilt Left", etc.
  
  // Face Features
  final bool bothEyesVisible;
  final bool mouthVisible;
  final double faceSymmetry; // 0-100
  final double faceCoverage; // Percentage of frame (0-100)
  
  // Overall
  final double overallQualityScore; // 0-100
  final bool isReadyForCapture;
  final double? stabilityScore; // 0.0 to 1.0 - how stable the face is
  final bool isStable; // Whether face is currently stable
  final List<String> recommendations; // What needs improvement
  
  // Visual Data
  final Rect? faceRect;
  final List<Offset>? landmarks;
  final FacePositionInfo? positionInfo;

  const FaceAnalysisMetrics({
    required this.isFaceDetected,
    this.faceDetectionConfidence = 0,
    this.faceCount = 0,
    this.distanceScore = 0,
    this.centeringScore = 0,
    this.centerOffsetX = 0,
    this.centerOffsetY = 0,
    this.distanceStatus = "Not Detected",
    this.centeringStatus = "Not Detected",
    this.brightnessScore = 0,
    this.sharpnessScore = 0,
    this.brightnessStatus = "Unknown",
    this.sharpnessStatus = "Unknown",
    this.pitchDeg = 0,
    this.yawDeg = 0,
    this.rollDeg = 0,
    this.poseScore = 0,
    this.poseStatus = "Unknown",
    this.bothEyesVisible = false,
    this.mouthVisible = false,
    this.faceSymmetry = 0,
    this.faceCoverage = 0,
    this.overallQualityScore = 0,
    this.isReadyForCapture = false,
    this.stabilityScore,
    this.isStable = false,
    this.recommendations = const [],
    this.faceRect,
    this.landmarks,
    this.positionInfo,
  });

  /// Get color for quality score
  Color getQualityColor(double score) {
    if (score >= 80) return const Color(0xFF00FF88); // Neon green
    if (score >= 60) return const Color(0xFFFFB800); // Amber
    return const Color(0xFFFF3366); // Coral red
  }

  /// Get status icon
  String getStatusIcon(String status) {
    if (status.toLowerCase().contains('perfect') || 
        status.toLowerCase().contains('good') ||
        status.toLowerCase().contains('excellent')) {
      return '✓';
    }
    if (status.toLowerCase().contains('low') ||
        status.toLowerCase().contains('blurry') ||
        status.toLowerCase().contains('tilt')) {
      return '⚠';
    }
    return '✗';
  }

  /// Create from AnalysisResult
  factory FaceAnalysisMetrics.fromAnalysisResult(
    AnalysisResult result,
    FacePositionInfo? positionInfo,
  ) {
    if (result.status == CaptureStatus.noFace) {
      return const FaceAnalysisMetrics(
        isFaceDetected: false,
        recommendations: ['Position your face in the frame'],
      );
    }

    // Calculate scores (0-100)
    final distanceScore = _calculateDistanceScore(positionInfo?.distanceRatio ?? 0.5);
    final centeringScore = _calculateCenteringScore(
      positionInfo?.centerOffsetX ?? 0,
      positionInfo?.centerOffsetY ?? 0,
    );
    final brightnessScore = _calculateBrightnessScore(result.brightness ?? 0);
    final sharpnessScore = _calculateSharpnessScore(result.sharpness ?? 0);
    final poseScore = _calculatePoseScore(
      positionInfo?.rotationX ?? 0,
      positionInfo?.rotationY ?? 0,
      positionInfo?.rotationZ ?? 0,
    );

    // Overall quality (weighted average)
    final overallQuality = (
      distanceScore * 0.2 +
      centeringScore * 0.2 +
      brightnessScore * 0.15 +
      sharpnessScore * 0.2 +
      poseScore * 0.25
    );

    // Generate recommendations
    final recommendations = <String>[];
    if (distanceScore < 40) recommendations.add('Move closer to camera');
    if (distanceScore > 60) recommendations.add('Move back from camera');
    if (centeringScore < 80) recommendations.add('Center your face');
    if (brightnessScore < 60) recommendations.add('Move to better lighting');
    if (sharpnessScore < 60) recommendations.add('Hold still');
    if (poseScore < 80) recommendations.add('Look straight at camera');

    return FaceAnalysisMetrics(
      isFaceDetected: true,
      faceDetectionConfidence: result.status == CaptureStatus.ready ? 95 : 70,
      faceCount: result.status == CaptureStatus.multipleFaces ? 2 : 1,
      distanceScore: distanceScore,
      centeringScore: centeringScore,
      centerOffsetX: positionInfo?.centerOffsetX ?? 0,
      centerOffsetY: positionInfo?.centerOffsetY ?? 0,
      distanceStatus: _getDistanceStatus(positionInfo?.distanceRatio ?? 0.5),
      centeringStatus: _getCenteringStatus(
        positionInfo?.centerOffsetX ?? 0,
        positionInfo?.centerOffsetY ?? 0,
      ),
      brightnessScore: brightnessScore,
      sharpnessScore: sharpnessScore,
      brightnessStatus: _getBrightnessStatus(result.brightness ?? 0),
      sharpnessStatus: _getSharpnessStatus(result.sharpness ?? 0),
      pitchDeg: positionInfo?.rotationX ?? 0,
      yawDeg: positionInfo?.rotationY ?? 0,
      rollDeg: positionInfo?.rotationZ ?? 0,
      poseScore: poseScore,
      poseStatus: _getPoseStatus(
        positionInfo?.rotationX ?? 0,
        positionInfo?.rotationY ?? 0,
        positionInfo?.rotationZ ?? 0,
      ),
      bothEyesVisible: result.landmarks != null && result.landmarks!.length >= 2,
      mouthVisible: result.landmarks != null && result.landmarks!.length >= 5,
      faceSymmetry: 85.0, // Placeholder - would need landmark analysis
      faceCoverage: _calculateFaceCoverage(result.faceRect),
      overallQualityScore: overallQuality,
      isReadyForCapture: result.status == CaptureStatus.ready,
      recommendations: recommendations,
      faceRect: result.faceRect,
      landmarks: result.landmarks,
      positionInfo: positionInfo,
    );
  }

  static double _calculateDistanceScore(double distanceRatio) {
    // 0.5 is perfect, score decreases as we move away
    final distanceFromPerfect = (distanceRatio - 0.5).abs();
    return (1.0 - distanceFromPerfect * 2).clamp(0.0, 1.0) * 100;
  }

  static double _calculateCenteringScore(double offsetX, double offsetY) {
    final maxOffset = 0.15; // From CaptureThresholds
    final offsetXAbs = offsetX.abs();
    final offsetYAbs = offsetY.abs();
    final maxOffsetAbs = offsetXAbs > offsetYAbs ? offsetXAbs : offsetYAbs;
    return (1.0 - (maxOffsetAbs / maxOffset)).clamp(0.0, 1.0) * 100;
  }

  static double _calculateBrightnessScore(double brightness) {
    final minBrightness = CaptureThresholds.minBrightness;
    if (brightness < minBrightness) {
      return (brightness / minBrightness) * 60; // 0-60 for low light
    }
    return 60 + ((brightness - minBrightness) / (255 - minBrightness)) * 40; // 60-100
  }

  static double _calculateSharpnessScore(double sharpness) {
    final minSharpness = CaptureThresholds.minSharpness;
    if (sharpness < minSharpness) {
      return (sharpness / minSharpness) * 60;
    }
    return 60 + ((sharpness - minSharpness) / (minSharpness * 2)) * 40;
  }

  static double _calculatePoseScore(double pitch, double yaw, double roll) {
    final maxPitch = CaptureThresholds.maxPitchDeg;
    final maxYaw = CaptureThresholds.maxYawDeg;
    final maxRoll = CaptureThresholds.maxRollDeg;
    
    final pitchScore = 1.0 - (pitch.abs() / maxPitch).clamp(0.0, 1.0);
    final yawScore = 1.0 - (yaw.abs() / maxYaw).clamp(0.0, 1.0);
    final rollScore = 1.0 - (roll.abs() / maxRoll).clamp(0.0, 1.0);
    
    return ((pitchScore + yawScore + rollScore) / 3) * 100;
  }

  static String _getDistanceStatus(double distanceRatio) {
    if (distanceRatio < 0.3) return 'Too Far';
    if (distanceRatio > 0.7) return 'Too Close';
    if (distanceRatio > 0.4 && distanceRatio < 0.6) return 'Perfect';
    return 'Good';
  }

  static String _getCenteringStatus(double offsetX, double offsetY) {
    final maxOffset = 0.15;
    if (offsetX.abs() < maxOffset && offsetY.abs() < maxOffset) {
      return 'Centered';
    }
    if (offsetX.abs() > offsetY.abs()) {
      return offsetX > 0 ? 'Move Left' : 'Move Right';
    }
    return offsetY > 0 ? 'Move Up' : 'Move Down';
  }

  static String _getBrightnessStatus(double brightness) {
    if (brightness < CaptureThresholds.minBrightness) return 'Low';
    if (brightness > 200) return 'Too Bright';
    return 'Good';
  }

  static String _getSharpnessStatus(double sharpness) {
    if (sharpness < CaptureThresholds.minSharpness * 0.7) return 'Blurry';
    if (sharpness < CaptureThresholds.minSharpness) return 'Good';
    return 'Excellent';
  }

  static String _getPoseStatus(double pitch, double yaw, double roll) {
    final maxPitch = CaptureThresholds.maxPitchDeg;
    final maxYaw = CaptureThresholds.maxYawDeg;
    final maxRoll = CaptureThresholds.maxRollDeg;
    
    if (pitch.abs() < maxPitch && yaw.abs() < maxYaw && roll.abs() < maxRoll) {
      return 'Perfect';
    }
    if (pitch.abs() > maxPitch) return pitch > 0 ? 'Tilt Down' : 'Tilt Up';
    if (yaw.abs() > maxYaw) return yaw > 0 ? 'Turn Right' : 'Turn Left';
    if (roll.abs() > maxRoll) return roll > 0 ? 'Tilt Right' : 'Tilt Left';
    return 'Good';
  }

  static double _calculateFaceCoverage(Rect? faceRect) {
    if (faceRect == null) return 0;
    // This would need image dimensions - placeholder
    return 45.0; // Placeholder percentage
  }
}
