// FILE: lib/features/smart_capture/domain/quality_models.dart

class QualityMeta {
  final bool hasFace;
  final int faceCount;
  final double faceCenterDx;
  final double faceCenterDy;
  final double faceAreaRatio;
  final double yawDeg;
  final double pitchDeg;
  final double rollDeg;
  final double brightness;
  final double sharpness;
  final List<String> reasons;

  const QualityMeta({
    required this.hasFace,
    required this.faceCount,
    required this.faceCenterDx,
    required this.faceCenterDy,
    required this.faceAreaRatio,
    required this.yawDeg,
    required this.pitchDeg,
    required this.rollDeg,
    required this.brightness,
    required this.sharpness,
    this.reasons = const [],
  });

  factory QualityMeta.fromMap(Map<dynamic, dynamic> map) {
    return QualityMeta(
      hasFace: map['hasFace'] as bool? ?? false,
      faceCount: map['faceCount'] as int? ?? 0,
      faceCenterDx: (map['faceCenterDx'] as num? ?? 0.0).toDouble(),
      faceCenterDy: (map['faceCenterDy'] as num? ?? 0.0).toDouble(),
      faceAreaRatio: (map['faceAreaRatio'] as num? ?? 0.0).toDouble(),
      yawDeg: (map['yawDeg'] as num? ?? 0.0).toDouble(),
      pitchDeg: (map['pitchDeg'] as num? ?? 0.0).toDouble(),
      rollDeg: (map['rollDeg'] as num? ?? 0.0).toDouble(),
      brightness: (map['brightness'] as num? ?? 0.0).toDouble(),
      sharpness: (map['sharpness'] as num? ?? 0.0).toDouble(),
      reasons:
          (map['reasons'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hasFace': hasFace,
      'faceCount': faceCount,
      'faceCenterDx': faceCenterDx,
      'faceCenterDy': faceCenterDy,
      'faceAreaRatio': faceAreaRatio,
      'yawDeg': yawDeg,
      'pitchDeg': pitchDeg,
      'rollDeg': rollDeg,
      'brightness': brightness,
      'sharpness': sharpness,
      'reasons': reasons,
    };
  }

  @override
  String toString() {
    return 'QualityMeta(face: $hasFace, count: $faceCount, center: ($faceCenterDx, $faceCenterDy), area: $faceAreaRatio, pose: ($yawDeg, $pitchDeg, $rollDeg), reasons: $reasons)';
  }
}

class CaptureResult {
  final String imagePath;
  final QualityMeta meta;
  final List<Map<String, double>> landmarks; // x, y, z normalized

  const CaptureResult({
    required this.imagePath,
    required this.meta,
    this.landmarks = const [],
  });

  factory CaptureResult.fromMap(Map<dynamic, dynamic> map) {
    return CaptureResult(
      imagePath: map['imagePath'] as String? ?? '',
      meta: QualityMeta.fromMap(map['meta'] as Map<dynamic, dynamic>? ?? {}),
      landmarks:
          (map['landmarks'] as List<dynamic>?)
              ?.map((e) => Map<String, double>.from(e as Map))
              .toList() ??
          [],
    );
  }
}
