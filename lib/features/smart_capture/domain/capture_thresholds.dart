// FILE: lib/features/smart_capture/domain/capture_thresholds.dart

/// Centralized thresholds for face capture validation
/// All face capture logic should use these constants for consistency
class CaptureThresholds {
  // Positioning
  static const double maxCenterOffset = 0.15; // 15% deviation from center (X & Y)
  static const double minFaceAreaRatio = 0.35; // Minimum face size (35% of image)
  static const double maxFaceAreaRatio = 0.60; // Maximum face size (60% of image)

  // Pose (Degrees)
  static const double maxYawDeg = 12.0; // Left/right head rotation
  static const double maxPitchDeg = 12.0; // Up/down head rotation
  static const double maxRollDeg = 12.0; // Tilt head rotation

  // Image Quality
  static const double minBrightness = 80.0; // Minimum brightness (0-255 scale)
  static const double minBrightnessNormalized = 0.35; // Normalized brightness (0-1)
  static const double minSharpness = 60.0; // Laplacian variance threshold for sharpness (relaxed from 100)
  static const double minSharpnessNormalized = 0.35; // Normalized sharpness (0-1)

  // Motion Detection
  static const double maxFaceDisplacement = 0.08; // Max face center movement between frames (8% of image, relaxed from 5%)
  static const int motionDetectionFrames = 3; // Number of frames to track for motion

  // Timing
  static const int stableDurationMs = 600; // Required stability duration before capture (reduced from 800ms)
  static const int cooldownDurationMs = 2000; // Cooldown after capture to prevent rapid captures
  static const int frameSkipCount = 3; // Process every Nth frame for performance

  // Performance
  static const int maxBufferSize = 5; // Maximum frames to keep in buffer
}
