import 'package:json_annotation/json_annotation.dart';

part 'analysis_models.g.dart';

@JsonSerializable()
class ChatAnswers {
  final String? dailyRoutine;
  final String? stylingPreference;
  final List<String>? occasions;
  final List<String>? concerns;
  final List<String>? personalStyle;

  ChatAnswers({
    this.dailyRoutine,
    this.stylingPreference,
    this.occasions,
    this.concerns,
    this.personalStyle,
  });

  factory ChatAnswers.fromJson(Map<String, dynamic> json) =>
      _$ChatAnswersFromJson(json);

  Map<String, dynamic> toJson() => _$ChatAnswersToJson(this);
}

@JsonSerializable()
class FaceAnalysis {
  final String? faceShape;
  final String? skinTone;
  @JsonKey(name: 'skin_quality')
  final String? skinQuality;
  @JsonKey(name: 'face_matrix')
  final Map<String, dynamic>? faceMatrix;
  @JsonKey(name: 'face_metrics')
  final Map<String, dynamic>? faceMetrics;
  final String status;

  FaceAnalysis({
    this.faceShape,
    this.skinTone,
    this.skinQuality,
    this.faceMatrix,
    this.faceMetrics,
    this.status = 'pending',
  });

  factory FaceAnalysis.fromJson(Map<String, dynamic> json) =>
      _$FaceAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$FaceAnalysisToJson(this);
}

@JsonSerializable()
class HairstyleRecommendation {
  final int id;
  final String name;
  @JsonKey(name: 'image_url')
  final String imageUrl;
  final String? description;
  @JsonKey(name: 'confidence_score')
  final double? confidenceScore;
  @JsonKey(name: 'suitability_reason')
  final String? suitabilityReason;

  HairstyleRecommendation({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.description,
    this.confidenceScore,
    this.suitabilityReason,
  });

  factory HairstyleRecommendation.fromJson(Map<String, dynamic> json) =>
      _$HairstyleRecommendationFromJson(json);

  Map<String, dynamic> toJson() => _$HairstyleRecommendationToJson(this);
}

@JsonSerializable()
class StyleRecommendations {
  @JsonKey(name: 'best_hairstyles')
  final List<HairstyleRecommendation> bestHairstyles;
  final List<Map<String, dynamic>> hairstyles;
  final List<Map<String, dynamic>> products;
  final List<Map<String, dynamic>> routines;
  final String status;

  StyleRecommendations({
    this.bestHairstyles = const [],
    this.hairstyles = const [],
    this.products = const [],
    this.routines = const [],
    this.status = 'pending',
  });

  factory StyleRecommendations.fromJson(Map<String, dynamic> json) =>
      _$StyleRecommendationsFromJson(json);

  Map<String, dynamic> toJson() => _$StyleRecommendationsToJson(this);
}

@JsonSerializable()
class PersonalizedInsights {
  final List<String> bestStyles;
  final List<String> avoidStyles;
  final List<String> tips;
  final String status;

  PersonalizedInsights({
    this.bestStyles = const [],
    this.avoidStyles = const [],
    this.tips = const [],
    this.status = 'pending',
  });

  factory PersonalizedInsights.fromJson(Map<String, dynamic> json) =>
      _$PersonalizedInsightsFromJson(json);

  Map<String, dynamic> toJson() => _$PersonalizedInsightsToJson(this);
}

@JsonSerializable()
class AnalysisResponse {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'image_url')
  final String imageUrl;
  @JsonKey(name: 'chat_answers')
  final Map<String, dynamic> chatAnswers;
  @JsonKey(name: 'face_analysis')
  final FaceAnalysis faceAnalysis;
  @JsonKey(name: 'style_recommendations')
  final StyleRecommendations styleRecommendations;
  @JsonKey(name: 'personalized_insights')
  final PersonalizedInsights personalizedInsights;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  AnalysisResponse({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.chatAnswers,
    required this.faceAnalysis,
    required this.styleRecommendations,
    required this.personalizedInsights,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AnalysisResponse.fromJson(Map<String, dynamic> json) =>
      _$AnalysisResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AnalysisResponseToJson(this);
}

