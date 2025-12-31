import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../data/dummy_analysis_data.dart';
import '../../../services/saved_looks_store.dart';

class SwipeableHairstyleCards extends StatefulWidget {
  final List<HairstyleRecommendation> hairstyles;
  final bool isDark;
  final ColorScheme colorScheme;

  const SwipeableHairstyleCards({
    Key? key,
    required this.hairstyles,
    required this.isDark,
    required this.colorScheme,
  }) : super(key: key);

  @override
  State<SwipeableHairstyleCards> createState() => _SwipeableHairstyleCardsState();
}

class _SwipeableHairstyleCardsState extends State<SwipeableHairstyleCards> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentIndex = 0;
  final SavedLooksStore _savedLooksStore = SavedLooksStore();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 520,
      child: Stack(
        children: [
          // Background cards (stacked effect)
          ...List.generate(
            widget.hairstyles.length,
            (index) {
              if (index <= _currentIndex) return const SizedBox.shrink();
              final offset = (index - _currentIndex) * 8.0;
              return Positioned(
                top: offset,
                left: offset,
                right: -offset,
                bottom: -offset,
                child: Transform.scale(
                  scale: 1.0 - (index - _currentIndex) * 0.05,
                  child: Opacity(
                    opacity: 1.0 - (index - _currentIndex) * 0.3,
                    child: _buildCard(
                      widget.hairstyles[index],
                      index + 1,
                      false,
                    ),
                  ),
                ),
              );
            },
          ),
          // Main swipeable cards
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.hairstyles.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildCard(
                  widget.hairstyles[index],
                  index + 1,
                  true,
                ),
              );
            },
          ),
          // Page indicators
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.hairstyles.length,
                (index) => _buildPageIndicator(index == _currentIndex),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    HairstyleRecommendation hairstyle,
    int rank,
    bool isActive,
  ) {
    final isSaved = _savedLooksStore.isSaved(hairstyle);

    return Container(
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(widget.isDark ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image placeholder with gradient
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.gradientStart.withOpacity(0.8),
                      AppColors.gradientMid.withOpacity(0.6),
                      AppColors.gradientEnd.withOpacity(0.4),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Placeholder for image
                    Center(
                      child: Icon(
                        Icons.face,
                        size: 120,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    // Save button
                    Positioned(
                      top: 16,
                      right: 16,
                      child: InkWell(
                        onTap: () {
                          final wasSaved = _savedLooksStore.isSaved(hairstyle);
                          setState(() {
                            _savedLooksStore.toggleSave(hairstyle);
                          });
                          final isNowSaved = _savedLooksStore.isSaved(hairstyle);
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(
                                    isNowSaved ? Icons.check_circle : Icons.remove_circle,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      isNowSaved
                                          ? '${hairstyle.name} saved to your looks'
                                          : '${hairstyle.name} removed from saved looks',
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              duration: const Duration(seconds: 2),
                              backgroundColor: isNowSaved
                                  ? AppColors.success
                                  : AppColors.error,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            isSaved ? Icons.bookmark : Icons.bookmark_border,
                            color: isSaved
                                ? AppColors.gradientStart
                                : Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    // Rank badge
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '$rank',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content section
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hairstyle name and match score
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            hairstyle.name,
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: widget.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: DummyAnalysisData
                                .getScoreColor(hairstyle.matchScore)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${(hairstyle.matchScore * 100).toInt()}% Match',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: DummyAnalysisData.getScoreColor(
                                hairstyle.matchScore,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Description
                    Expanded(
                      child: Text(
                        hairstyle.description,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: widget.isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.gradientStart
            : (widget.isDark
                ? AppColors.borderDark
                : AppColors.borderLight),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

