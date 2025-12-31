/// Dummy data for analysis results
/// This file contains sample data for hairstyles, face matrix, and skin health

import 'package:flutter/material.dart';

class HairstyleRecommendation {
  final String name;
  final String description;
  final String imageUrl; // Placeholder URL or asset path
  final double matchScore; // 0.0 to 1.0
  final List<String> features; // Key features of this hairstyle

  const HairstyleRecommendation({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.matchScore,
    required this.features,
  });
}

class FaceMatrix {
  final double faceShapeScore; // 0.0 to 1.0
  final String faceShape; // e.g., "Oval", "Round", "Square", etc.
  final double symmetryScore; // 0.0 to 1.0
  final double proportionScore; // 0.0 to 1.0
  final Map<String, double> measurements; // Various face measurements

  const FaceMatrix({
    required this.faceShapeScore,
    required this.faceShape,
    required this.symmetryScore,
    required this.proportionScore,
    required this.measurements,
  });
}

class SkinHealth {
  final double overallScore; // 0.0 to 1.0
  final double hydrationLevel; // 0.0 to 1.0
  final double textureScore; // 0.0 to 1.0
  final double toneScore; // 0.0 to 1.0
  final List<String> concerns; // e.g., ["Dryness", "Uneven tone"]
  final List<String> improvements; // Recommendations

  const SkinHealth({
    required this.overallScore,
    required this.hydrationLevel,
    required this.textureScore,
    required this.toneScore,
    required this.concerns,
    required this.improvements,
  });
}

class AnalysisResults {
  final List<HairstyleRecommendation> topHairstyles;
  final FaceMatrix faceMatrix;
  final SkinHealth skinHealth;

  const AnalysisResults({
    required this.topHairstyles,
    required this.faceMatrix,
    required this.skinHealth,
  });
}

/// Dummy data generator
class DummyAnalysisData {
  /// Get dummy analysis results
  static AnalysisResults getDummyResults() {
    return AnalysisResults(
      topHairstyles: _getTopHairstyles(),
      faceMatrix: _getFaceMatrix(),
      skinHealth: _getSkinHealth(),
    );
  }

  static List<HairstyleRecommendation> _getTopHairstyles() {
    return [
      HairstyleRecommendation(
        name: "Textured Crop",
        description: "A modern, low-maintenance style that adds volume and definition. Perfect for your face shape and hair type.",
        imageUrl: "https://example.com/hairstyle1.jpg",
        matchScore: 0.92,
        features: [
          "Adds volume to crown",
          "Easy to maintain",
          "Works with your hair texture",
          "Professional yet trendy",
        ],
      ),
      HairstyleRecommendation(
        name: "Classic Side Part",
        description: "Timeless elegance that complements your facial structure. Versatile for both formal and casual occasions.",
        imageUrl: "https://example.com/hairstyle2.jpg",
        matchScore: 0.88,
        features: [
          "Balances face proportions",
          "Professional appearance",
          "Suitable for all occasions",
          "Easy styling routine",
        ],
      ),
      HairstyleRecommendation(
        name: "Modern Pompadour",
        description: "Bold and confident style that enhances your features. Great for special events and making a statement.",
        imageUrl: "https://example.com/hairstyle3.jpg",
        matchScore: 0.85,
        features: [
          "Adds height and presence",
          "High impact style",
          "Best for special occasions",
          "Requires regular styling",
        ],
      ),
    ];
  }

  static FaceMatrix _getFaceMatrix() {
    return FaceMatrix(
      faceShapeScore: 0.87,
      faceShape: "Oval",
      symmetryScore: 0.82,
      proportionScore: 0.79,
      measurements: {
        "Forehead Width": 0.75,
        "Cheekbone Width": 0.80,
        "Jawline Width": 0.72,
        "Face Length": 0.78,
        "Eye Distance": 0.85,
        "Nose Width": 0.70,
      },
    );
  }

  static SkinHealth _getSkinHealth() {
    return SkinHealth(
      overallScore: 0.75,
      hydrationLevel: 0.68,
      textureScore: 0.72,
      toneScore: 0.80,
      concerns: [
        "Slight dryness in T-zone",
        "Minor uneven skin tone",
        "Some texture irregularities",
      ],
      improvements: [
        "Increase daily hydration with a lightweight moisturizer",
        "Use a gentle exfoliant 2-3 times per week",
        "Apply sunscreen daily to even out skin tone",
        "Consider a vitamin C serum for brightness",
        "Drink more water to improve overall hydration",
      ],
    );
  }

  /// Get score color based on value (0.0 to 1.0)
  static Color getScoreColor(double score) {
    if (score >= 0.8) return const Color(0xFF2DBE7F); // Green - Excellent
    if (score >= 0.6) return const Color(0xFFF4B740); // Yellow - Good
    return const Color(0xFFE5484D); // Red - Needs improvement
  }

  /// Get score label
  static String getScoreLabel(double score) {
    if (score >= 0.8) return "Excellent";
    if (score >= 0.6) return "Good";
    if (score >= 0.4) return "Fair";
    return "Needs Improvement";
  }
}

