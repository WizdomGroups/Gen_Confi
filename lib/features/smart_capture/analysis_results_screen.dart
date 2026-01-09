import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/config/api_config.dart';
import '../../core/models/analysis_models.dart';
import 'data/dummy_analysis_data.dart' as dummy;
import '../../services/saved_looks_store.dart';
import 'widgets/swipeable_hairstyle_cards.dart';
import '../../app/routes/app_routes.dart';

class AnalysisResultsScreen extends StatefulWidget {
  final String imagePath;
  final AnalysisResponse? analysisResponse; // API response data

  const AnalysisResultsScreen({
    Key? key,
    required this.imagePath,
    this.analysisResponse,
  }) : super(key: key);

  @override
  State<AnalysisResultsScreen> createState() => _AnalysisResultsScreenState();
}

class _AnalysisResultsScreenState extends State<AnalysisResultsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late dummy.AnalysisResults _results;
  final SavedLooksStore _savedLooksStore = SavedLooksStore();

  @override
  void initState() {
    super.initState();
    // Use API response if available, otherwise use dummy data
    if (widget.analysisResponse != null) {
      _results = _convertApiResponseToResults(widget.analysisResponse!);
    } else {
      _results = dummy.DummyAnalysisData.getDummyResults();
    }

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOut,
      ),
    );

    _fadeController.forward();
  }

  /// Convert API response to AnalysisResults format
  dummy.AnalysisResults _convertApiResponseToResults(AnalysisResponse response) {
    // Convert best_hairstyles from API to HairstyleRecommendation format
    final topHairstyles = response.styleRecommendations.bestHairstyles
        .map((h) => dummy.HairstyleRecommendation(
              name: h.name,
              description: h.description ?? 'Perfect match for your style',
              imageUrl: _getFullImageUrl(h.imageUrl),
              matchScore: h.confidenceScore ?? 0.85,
              features: [
                if (h.suitabilityReason != null) h.suitabilityReason!,
                'Matches your face shape',
                'Complements your style preferences',
              ],
            ))
        .toList();

    // If less than 3 hairstyles, pad with dummy data
    while (topHairstyles.length < 3) {
      final dummyHairstyle = dummy.DummyAnalysisData.getDummyResults().topHairstyles[topHairstyles.length];
      topHairstyles.add(dummyHairstyle);
    }

    // Convert face_matrix from API
    final faceMatrixData = response.faceAnalysis.faceMatrix ?? {};
    final faceMatrix = dummy.FaceMatrix(
      faceShapeScore: faceMatrixData['face_shape_score']?.toDouble() ?? 0.87,
      faceShape: response.faceAnalysis.faceShape ?? 'Oval',
      symmetryScore: faceMatrixData['symmetry_score']?.toDouble() ?? 
                     response.faceAnalysis.faceMetrics?['symmetry_score']?.toDouble() ?? 0.82,
      proportionScore: faceMatrixData['proportion_score']?.toDouble() ?? 0.79,
      measurements: {
        'Forehead Width': (faceMatrixData['forehead_width']?.toDouble() ?? 110.8) / 150.0,
        'Cheekbone Width': (faceMatrixData['cheekbone_width']?.toDouble() ?? 125.6) / 150.0,
        'Jawline Width': (faceMatrixData['jaw_width']?.toDouble() ?? 95.2) / 150.0,
        'Face Length': (faceMatrixData['face_length']?.toDouble() ?? 180.3) / 250.0,
        'Face Width': (faceMatrixData['face_width']?.toDouble() ?? 120.5) / 150.0,
      },
    );

    // Convert skin quality from API
    final skinQuality = response.faceAnalysis.skinQuality ?? 'Good';
    final skinHealth = dummy.SkinHealth(
      overallScore: _getSkinQualityScore(skinQuality),
      hydrationLevel: 0.68, // Will be populated by model later
      textureScore: 0.72, // Will be populated by model later
      toneScore: 0.80, // Will be populated by model later
      concerns: (response.chatAnswers['concerns'] as List<dynamic>?)?.cast<String>() ?? [],
      improvements: [
        'Maintain your current skincare routine',
        'Stay hydrated for better skin health',
        'Use sunscreen daily',
      ],
    );

    return dummy.AnalysisResults(
      topHairstyles: topHairstyles,
      faceMatrix: faceMatrix,
      skinHealth: skinHealth,
    );
  }

  /// Get full image URL from relative path
  String _getFullImageUrl(String url) {
    if (url.startsWith('http')) {
      return url;
    }
    // Convert relative URL to full URL
    final baseUrl = ApiConfig.baseUrl.replaceAll('/api/v1', '');
    return url.startsWith('/') ? '$baseUrl$url' : '$baseUrl/$url';
  }

  /// Convert skin quality string to score
  double _getSkinQualityScore(String quality) {
    switch (quality.toLowerCase()) {
      case 'excellent':
        return 0.95;
      case 'good':
        return 0.80;
      case 'fair':
        return 0.65;
      case 'poor':
        return 0.45;
      default:
        return 0.75;
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // Premium Background Aura
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gradientStart.withOpacity(isDark ? 0.15 : 0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gradientEnd.withOpacity(isDark ? 0.15 : 0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                          color: colorScheme.onSurface,
                        ),
                        Expanded(
                          child: Text(
                            'Your Analysis Results',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Top 3 Hairstyles Section
                    _buildSectionTitle('Best Hairstyles for You', isDark),
                    const SizedBox(height: 16),
                    SwipeableHairstyleCards(
                      hairstyles: _results.topHairstyles,
                      isDark: isDark,
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(height: 32),

                    // Face Matrix Section
                    _buildSectionTitle('Face Analysis Matrix', isDark),
                    const SizedBox(height: 16),
                    _buildFaceMatrixCard(
                      faceMatrix: _results.faceMatrix,
                      isDark: isDark,
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(height: 32),

                    // Skin Health Section
                    _buildSectionTitle('Skin Health Analysis', isDark),
                    const SizedBox(height: 16),
                    _buildSkinHealthCard(
                      skinHealth: _results.skinHealth,
                      isDark: isDark,
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(height: 32),

                    // Go Home Button
                    Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gradientStart
                                .withOpacity(isDark ? 0.2 : 0.15),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to home screen
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.clientShell,
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.home_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'GO HOME',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildHairstyleCard({
    required dummy.HairstyleRecommendation hairstyle,
    required int rank,
    required bool isDark,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Rank Badge
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hairstyle.name,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              // Match Score
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: dummy.DummyAnalysisData.getScoreColor(hairstyle.matchScore)
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(hairstyle.matchScore * 100).toInt()}% Match',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: dummy.DummyAnalysisData.getScoreColor(hairstyle.matchScore),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Save Button
              InkWell(
                onTap: () {
                  setState(() {
                    _savedLooksStore.toggleSave(hairstyle);
                  });
                  // Show snackbar feedback
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _savedLooksStore.isSaved(hairstyle)
                            ? '${hairstyle.name} saved to your looks'
                            : '${hairstyle.name} removed from saved looks',
                      ),
                      duration: const Duration(seconds: 2),
                      backgroundColor: isDark
                          ? AppColors.surfaceElevatedDark
                          : AppColors.surfaceElevatedLight,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _savedLooksStore.isSaved(hairstyle)
                        ? AppColors.gradientStart.withOpacity(0.2)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _savedLooksStore.isSaved(hairstyle)
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: _savedLooksStore.isSaved(hairstyle)
                        ? AppColors.gradientStart
                        : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight),
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            hairstyle.description,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          // Features
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: hairstyle.features.map((feature) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.gradientStart.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  feature,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.gradientStart,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFaceMatrixCard({
    required dummy.FaceMatrix faceMatrix,
    required bool isDark,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall Scores
          Row(
            children: [
              Expanded(
                child: _buildScoreItem(
                  label: 'Face Shape',
                  score: faceMatrix.faceShapeScore,
                  value: faceMatrix.faceShape,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildScoreItem(
                  label: 'Symmetry',
                  score: faceMatrix.symmetryScore,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildScoreItem(
            label: 'Proportion',
            score: faceMatrix.proportionScore,
            isDark: isDark,
          ),
          const SizedBox(height: 20),
          // Measurements
          Text(
            'Detailed Measurements',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...faceMatrix.measurements.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildMeasurementBar(
                label: entry.key,
                value: entry.value,
                isDark: isDark,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSkinHealthCard({
    required dummy.SkinHealth skinHealth,
    required bool isDark,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall Score
          _buildScoreItem(
            label: 'Overall Skin Health',
            score: skinHealth.overallScore,
            isDark: isDark,
          ),
          const SizedBox(height: 20),
          // Individual Scores
          Row(
            children: [
              Expanded(
                child: _buildScoreItem(
                  label: 'Hydration',
                  score: skinHealth.hydrationLevel,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildScoreItem(
                  label: 'Texture',
                  score: skinHealth.textureScore,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildScoreItem(
            label: 'Tone',
            score: skinHealth.toneScore,
            isDark: isDark,
          ),
          const SizedBox(height: 20),
          // Concerns
          if (skinHealth.concerns.isNotEmpty) ...[
            Text(
              'Current Concerns',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            ...skinHealth.concerns.map((concern) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        concern,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),
          ],
          // Improvements
          Text(
            'Recommendations for Improvement',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...skinHealth.improvements.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.gradientStart.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gradientStart,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildScoreItem({
    required String label,
    required double score,
    String? value,
    required bool isDark,
  }) {
    final scoreColor = dummy.DummyAnalysisData.getScoreColor(score);
    final scoreLabel = dummy.DummyAnalysisData.getScoreLabel(score);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scoreColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scoreColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${(score * 100).toInt()}%',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: score,
                  backgroundColor: scoreColor.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
          if (value != null) ...[
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: scoreColor,
              ),
            ),
          ] else ...[
            const SizedBox(height: 4),
            Text(
              scoreLabel,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: scoreColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMeasurementBar({
    required String label,
    required double value,
    required bool isDark,
  }) {
    final scoreColor = dummy.DummyAnalysisData.getScoreColor(value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: scoreColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: value,
          backgroundColor: scoreColor.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }
}

