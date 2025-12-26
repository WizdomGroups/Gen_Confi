// FILE: lib/features/smart_capture/logic/quality_gate.dart

import 'package:gen_confi/features/smart_capture/domain/capture_thresholds.dart';
import 'package:gen_confi/features/smart_capture/domain/quality_models.dart';

enum QualityStatus {
  noFace,
  multipleFaces,
  centerFace,
  moveCloser,
  moveFarther,
  lookStraight, // Yaw
  eyeLevel, // Pitch
  headStraight, // Roll
  lowBrightness,
  blurry,
  optimal,
}

class QualityGate {
  DateTime? _stableSince;
  bool _isStable = false;

  QualityStatus evaluate(QualityMeta meta) {
    if (!meta.hasFace) {
      _resetStability();
      return QualityStatus.noFace;
    }

    if (meta.faceCount > 1) {
      _resetStability();
      return QualityStatus.multipleFaces;
    }

    // 1. Centering
    if (meta.faceCenterDx.abs() > CaptureThresholds.maxCenterOffset ||
        meta.faceCenterDy.abs() > CaptureThresholds.maxCenterOffset) {
      _resetStability();
      return QualityStatus.centerFace;
    }

    // 2. Distance
    if (meta.faceAreaRatio < CaptureThresholds.minFaceAreaRatio) {
      _resetStability();
      return QualityStatus.moveCloser;
    }
    if (meta.faceAreaRatio > CaptureThresholds.maxFaceAreaRatio) {
      _resetStability();
      return QualityStatus.moveFarther;
    }

    // 3. Pose
    if (meta.yawDeg.abs() > CaptureThresholds.maxYawDeg) {
      _resetStability();
      return QualityStatus.lookStraight;
    }
    if (meta.pitchDeg.abs() > CaptureThresholds.maxPitchDeg) {
      _resetStability();
      return QualityStatus.eyeLevel;
    }
    if (meta.rollDeg.abs() > CaptureThresholds.maxRollDeg) {
      _resetStability();
      return QualityStatus.headStraight;
    }

    // 4. Image Quality
    if (meta.brightness < CaptureThresholds.minBrightness) {
      _resetStability();
      return QualityStatus.lowBrightness;
    }
    if (meta.sharpness < CaptureThresholds.minSharpness) {
      _resetStability();
      return QualityStatus.blurry;
    }

    // All Good - Check Stability
    if (_stableSince == null) {
      _stableSince = DateTime.now();
    } else {
      final duration = DateTime.now().difference(_stableSince!);
      if (duration.inMilliseconds >= CaptureThresholds.stableDurationMs) {
        _isStable = true;
      }
    }

    return QualityStatus.optimal;
  }

  bool get isStable => _isStable;

  void _resetStability() {
    _stableSince = null;
    _isStable = false;
  }

  String getGuidanceMessage(QualityStatus status) {
    switch (status) {
      case QualityStatus.noFace:
        return "Position your face in the oval";
      case QualityStatus.multipleFaces:
        return "Just you, please! 👤";
      case QualityStatus.centerFace:
        return "Center your face inside the oval";
      case QualityStatus.moveCloser:
        return "Come a bit closer 📷";
      case QualityStatus.moveFarther:
        return "Step back a little";
      case QualityStatus.lookStraight:
        return "Look directly at the camera 👀";
      case QualityStatus.eyeLevel:
        return "Raise phone to eye level ⬆️";
      case QualityStatus.headStraight:
        return "Tilt head straight 😐";
      case QualityStatus.lowBrightness:
        return "It's dark here! Find better light 💡";
      case QualityStatus.blurry:
        return "Hold still for a moment...";
      case QualityStatus.optimal:
        return _isStable ? "Perfect! Stay still..." : "Hold steady...";
    }
  }
}
