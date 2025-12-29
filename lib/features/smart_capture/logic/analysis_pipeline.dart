import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img; // Need 'image' package in pubspec
import 'package:gen_confi/features/smart_capture/domain/analysis_models.dart';
import 'package:gen_confi/features/smart_capture/domain/quality_models.dart';

class AnalysisPipeline {
  Future<AnalysisResult> analyze(CaptureResult capture) async {
    final landmarks = capture.landmarks;
    final imagePath = capture.imagePath;

    // 1. Face Geometry (from Landmarks)
    final geom = _computeGeometry(landmarks);

    // 2. Pixel Analysis (Beard + Skin)
    // Loading full image might be heavy; ideally we rescale or sample.
    // For now, we simulate or attempt basic analysis if package:image is available.
    BeardMetrics beard = BeardMetrics(density: 0, patchiness: 0, symmetry: 0);
    SkinToneMetrics skinTone = SkinToneMetrics(
      toneLevel: "Unknown",
      undertone: "Unknown",
      confidence: 0,
      evenness: 0,
    );
    SkinConcerns skinConcerns = SkinConcerns(
      oiliness: 0,
      redness: 0,
      darkCircles: 0,
      texture: 0,
    );

    try {
      final bytes = await File(imagePath).readAsBytes();
      final image = img.decodeImage(bytes);
      if (image != null) {
        // Perform pixel analysis
        beard = _analyzeBeard(image, landmarks);
        skinTone = _analyzeSkinTone(image, landmarks);
        skinConcerns = _analyzeSkinConcerns(image, landmarks);
      }
    } catch (e) {
      print("Analysis failed to load image: $e");
    }

    return AnalysisResult(
      imagePath: imagePath,
      quality: capture.meta,
      faceGeometry: geom,
      beard: beard,
      skinTone: skinTone,
      skinConcerns: skinConcerns,
    );
  }

  FaceGeometry _computeGeometry(List<Map<String, double>> landmarks) {
    if (landmarks.isEmpty) {
      return _emptyGeometry();
    }

    // Helper to get point
    Point3d p(int index) {
      if (index >= landmarks.length) return const Point3d(0, 0, 0);
      final l = landmarks[index];
      return Point3d(l['x'] ?? 0, l['y'] ?? 0, l['z'] ?? 0);
    }

    // MediaPipe 468 mesh indices (Approximate)
    // Top: 10, Bottom: 152
    // Left Cheek: 234, Right Cheek: 454
    // Forehead Width: 103 - 332
    // Cheekbone Width: 205 - 425 (or use 123-352)
    // Jaw Width: 172 - 397 (Gonions)
    // Chin Width: 18 - 20 (approx)

    final faceLength = _dist(p(10), p(152));
    final faceWidth = _dist(p(234), p(454));
    final foreheadWidth = _dist(p(103), p(332));
    final cheekboneWidth = _dist(p(205), p(425));
    final jawWidth = _dist(p(172), p(397));
    final chinWidth = _dist(p(57), p(287)); // Mouth corners/chin approx

    // Ratios
    final widthToLength = faceLength > 0 ? faceWidth / faceLength : 0.0;
    final foreheadToJaw = jawWidth > 0 ? foreheadWidth / jawWidth : 0.0;
    final cheekboneToJaw = jawWidth > 0 ? cheekboneWidth / jawWidth : 0.0;

    // Jaw Sharpness (Angle at Gonion)
    // Simple heuristic: distance ratio or curvature.
    // Let's use a dummy value based on jawWidth ratio for now.
    final jawSharpness = (jawWidth / faceWidth).clamp(0.0, 1.0);

    // Face Shape Classifier (Rule-based)
    final shape = _classifyFaceShape(
      widthToLength,
      foreheadToJaw,
      cheekboneToJaw,
      jawWidth,
      foreheadWidth,
    );

    return FaceGeometry(
      faceLength: faceLength,
      faceWidth: faceWidth,
      foreheadWidth: foreheadWidth,
      cheekboneWidth: cheekboneWidth,
      jawWidth: jawWidth,
      chinWidth: chinWidth,
      ratios: FaceRatios(
        widthToLength: widthToLength,
        foreheadToJaw: foreheadToJaw,
        cheekboneToJaw: cheekboneToJaw,
      ),
      jawSharpness: jawSharpness,
      faceShape: shape,
    );
  }

  FaceShape _classifyFaceShape(
    double w2l,
    double f2j,
    double c2j,
    double jawW,
    double foreW,
  ) {
    if (w2l > 0.9) {
      return FaceShape(label: "Round", confidence: 0.85);
    } else if (w2l < 0.70) {
      return FaceShape(label: "Oblong", confidence: 0.85);
    } else if (jawW > foreW * 0.95) {
      return FaceShape(label: "Square", confidence: 0.80);
    } else if (c2j > 1.2 && w2l < 0.85) {
      return FaceShape(label: "Diamond", confidence: 0.75);
    } else if (f2j > 1.4) {
      return FaceShape(label: "Heart", confidence: 0.80);
    }
    return FaceShape(label: "Oval", confidence: 0.90);
  }

  BeardMetrics _analyzeBeard(
    img.Image image,
    List<Map<String, double>> landmarks,
  ) {
    // Placeholder: Need pixel processing on ROI (chin, cheeks, upper lip)
    // Return dummy data for now as full pixel proc is complex
    return BeardMetrics(density: 0.65, patchiness: 0.2, symmetry: 0.9);
  }

  SkinToneMetrics _analyzeSkinTone(
    img.Image image,
    List<Map<String, double>> landmarks,
  ) {
    // Placeholder
    return SkinToneMetrics(
      toneLevel: "Type III",
      undertone: "Neutral",
      confidence: 0.88,
      evenness: 0.75,
    );
  }

  SkinConcerns _analyzeSkinConcerns(
    img.Image image,
    List<Map<String, double>> landmarks,
  ) {
    // Placeholder
    return SkinConcerns(
      oiliness: 0.3,
      redness: 0.1,
      darkCircles: 0.2,
      texture: 0.4,
    );
  }

  double _dist(Point3d p1, Point3d p2) {
    return sqrt(
      pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2) + pow(p1.z - p2.z, 2),
    );
  }

  FaceGeometry _emptyGeometry() {
    return FaceGeometry(
      faceLength: 0,
      faceWidth: 0,
      foreheadWidth: 0,
      cheekboneWidth: 0,
      jawWidth: 0,
      chinWidth: 0,
      ratios: FaceRatios(widthToLength: 0, foreheadToJaw: 0, cheekboneToJaw: 0),
      jawSharpness: 0,
      faceShape: FaceShape(label: "Unknown", confidence: 0),
    );
  }
}

class Point3d {
  final double x, y, z;
  const Point3d(this.x, this.y, this.z);
}
