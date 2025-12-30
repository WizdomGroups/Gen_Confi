import '../logic/face_capture_logic.dart';
import 'simple_face_tracking_overlay.dart';

/// Helper to convert SDK capture status to simple face status
class SimpleFaceTrackingHelper {
  /// Convert CaptureStatus to SimpleFaceStatus for overlay colors
  static SimpleFaceStatus statusFromCaptureStatus(CaptureStatus captureStatus) {
    switch (captureStatus) {
      case CaptureStatus.noFace:
      case CaptureStatus.multipleFaces:
        return SimpleFaceStatus.noFace;
      
      case CaptureStatus.ready:
        return SimpleFaceStatus.aligned;
      
      case CaptureStatus.capturing:
        return SimpleFaceStatus.captured;
      
      // All other states (tooClose, tooFar, notCentered, lowLight, moving)
      // indicate face is detected but not ready
      default:
        return SimpleFaceStatus.detected;
    }
  }
}

