// FILE: lib/features/smart_capture/domain/analysis_models.dart

import 'package:gen_confi/features/smart_capture/domain/quality_models.dart';

class AnalysisResult {
  final String imagePath;
  final QualityMeta quality;
  final FaceGeometry faceGeometry;
  final BeardMetrics beard;
  final SkinToneMetrics skinTone;
  final SkinConcerns skinConcerns;

  AnalysisResult({
    required this.imagePath,
    required this.quality,
    required this.faceGeometry,
    required this.beard,
    required this.skinTone,
    required this.skinConcerns,
  });

  Map<String, dynamic> toJson() {
    return {
      'imagePath': imagePath,
      'quality': quality.toMap(),
      'faceGeometry': faceGeometry.toJson(),
      'beard': beard.toJson(),
      'skinTone': skinTone.toJson(),
      'skinConcerns': skinConcerns.toJson(),
    };
  }
}

class FaceGeometry {
  final double faceLength;
  final double faceWidth;
  final double foreheadWidth;
  final double cheekboneWidth;
  final double jawWidth;
  final double chinWidth;
  final FaceRatios ratios;
  final double jawSharpness;
  final FaceShape faceShape;

  FaceGeometry({
    required this.faceLength,
    required this.faceWidth,
    required this.foreheadWidth,
    required this.cheekboneWidth,
    required this.jawWidth,
    required this.chinWidth,
    required this.ratios,
    required this.jawSharpness,
    required this.faceShape,
  });

  Map<String, dynamic> toJson() => {
    'faceLength': faceLength,
    'faceWidth': faceWidth,
    'foreheadWidth': foreheadWidth,
    'cheekboneWidth': cheekboneWidth,
    'jawWidth': jawWidth,
    'chinWidth': chinWidth,
    'ratios': ratios.toJson(),
    'jawSharpness': jawSharpness,
    'faceShape': faceShape.toJson(),
  };
}

class FaceRatios {
  final double widthToLength;
  final double foreheadToJaw;
  final double cheekboneToJaw;

  FaceRatios({
    required this.widthToLength,
    required this.foreheadToJaw,
    required this.cheekboneToJaw,
  });

  Map<String, dynamic> toJson() => {
    'widthToLength': widthToLength,
    'foreheadToJaw': foreheadToJaw,
    'cheekboneToJaw': cheekboneToJaw,
  };
}

class FaceShape {
  final String label;
  final double confidence;

  FaceShape({required this.label, required this.confidence});

  Map<String, dynamic> toJson() => {'label': label, 'confidence': confidence};
}

class BeardMetrics {
  final double density;
  final double patchiness;
  final double symmetry;

  BeardMetrics({
    required this.density,
    required this.patchiness,
    required this.symmetry,
  });

  Map<String, dynamic> toJson() => {
    'density': density,
    'patchiness': patchiness,
    'symmetry': symmetry,
  };
}

class SkinToneMetrics {
  final String toneLevel;
  final String undertone;
  final double confidence;
  final double evenness;

  SkinToneMetrics({
    required this.toneLevel,
    required this.undertone,
    required this.confidence,
    required this.evenness,
  });

  Map<String, dynamic> toJson() => {
    'toneLevel': toneLevel,
    'undertone': undertone,
    'confidence': confidence,
    'evenness': evenness,
  };
}

class SkinConcerns {
  final double oiliness;
  final double redness;
  final double darkCircles;
  final double texture;

  SkinConcerns({
    required this.oiliness,
    required this.redness,
    required this.darkCircles,
    required this.texture,
  });

  Map<String, dynamic> toJson() => {
    'oiliness': oiliness,
    'redness': redness,
    'darkCircles': darkCircles,
    'texture': texture,
  };
}
