// FILE: lib/features/smart_capture/domain/capture_thresholds.dart

class CaptureThresholds {
  // Positioning
  static const double maxCenterOffset = 0.12;
  static const double minFaceAreaRatio = 0.10; // Too far
  static const double maxFaceAreaRatio = 0.28; // Too close (strict)

  // Pose (Degrees)
  static const double maxYawDeg = 12.0;
  static const double maxPitchDeg = 10.0;
  static const double maxRollDeg = 10.0;

  // Image Quality
  static const double minBrightness = 0.35;
  static const double minSharpness = 0.45;

  // Timing
  static const int stableDurationMs = 650;
  static const int cooldownDurationMs = 2000;
}
