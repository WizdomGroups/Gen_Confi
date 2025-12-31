import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/onboarding_store.dart';
import '../../core/constants/app_colors.dart';
import 'analyzing_features_screen.dart';

class StyleLifestyleScreen extends StatefulWidget {
  final String imagePath;

  const StyleLifestyleScreen({
    Key? key,
    required this.imagePath,
  }) : super(key: key);

  @override
  State<StyleLifestyleScreen> createState() => _StyleLifestyleScreenState();
}

class _StyleLifestyleScreenState extends State<StyleLifestyleScreen> {
  // Section 1: Daily Routine (single select)
  String? _selectedDailyRoutine;

  // Section 2: Styling Preference (single select)
  String? _selectedStylingPreference;

  // Section 3: Occasions (multi-select)
  final Set<String> _selectedOccasions = {};

  // Section 4: Hair & Scalp Concerns (multi-select)
  final Set<String> _selectedConcerns = {};

  // Section 5: Personal Style (multi-select)
  final Set<String> _selectedStyles = {};

  void _handleContinue() {
    // Save preferences to OnboardingStore
    final store = OnboardingStore();
    
    // Combine all preferences into styleTags
    final allStyleTags = <String>[];
    if (_selectedDailyRoutine != null) allStyleTags.add(_selectedDailyRoutine!);
    if (_selectedStylingPreference != null) allStyleTags.add(_selectedStylingPreference!);
    allStyleTags.addAll(_selectedOccasions);
    allStyleTags.addAll(_selectedStyles);
    
    // Update draft with style tags and concerns
    final currentDraft = store.draft;
    store.update(
      currentDraft.copyWith(
        styleTags: allStyleTags,
        groomingConcerns: _selectedConcerns.toList(),
      ),
    );

    // Navigate to analyzing features screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => AnalyzingFeaturesScreen(
          imagePath: widget.imagePath,
        ),
      ),
    ).then((result) {
      // When analysis completes, return to previous screen with image path
      if (result != null && mounted) {
        Navigator.pop(context, result);
      }
    });
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
          // Premium Background Aura (matching login screen)
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
            bottom: -150,
            left: -150,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gradientEnd.withOpacity(isDark ? 0.1 : 0.08),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: colorScheme.onSurface,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      // Progress indicator
                      Text(
                        "Almost done",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Progress dots
                      Row(
                        children: List.generate(3, (index) {
                          return Container(
                            margin: const EdgeInsets.only(left: 4),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index == 2
                                  ? AppColors.gradientStart
                                  : (isDark
                                      ? AppColors.borderDark
                                      : AppColors.borderLight),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      // Voice indicator icon
                      Icon(
                        Icons.volume_up_outlined,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                        size: 20,
                      ),
                    ],
                  ),
                ),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        // Title
                        Text(
                          "Help me personalize your style",
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Subtitle
                        Text(
                          "These details help me recommend styles that actually fit your lifestyle.",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // SECTION 1: Daily Routine
                        _buildSection(
                          title: "How would you describe your daily routine?",
                          child: _buildChipSelector(
                            options: const [
                              "Mostly indoors",
                              "Office / Corporate",
                              "College / Student",
                              "Outdoor / Field work",
                              "Very active lifestyle",
                            ],
                            selected: _selectedDailyRoutine,
                            onSelect: (value) {
                              setState(() {
                                _selectedDailyRoutine = value;
                              });
                            },
                            isMultiSelect: false,
                            isDark: isDark,
                            colorScheme: colorScheme,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // SECTION 2: Styling Preference
                        _buildSection(
                          title: "How much effort do you prefer for hair styling?",
                          child: _buildCardSelector(
                            options: const [
                              "Low maintenance (quick & simple)",
                              "Medium (a few times a week)",
                              "High (daily styling is okay)",
                            ],
                            selected: _selectedStylingPreference,
                            onSelect: (value) {
                              setState(() {
                                _selectedStylingPreference = value;
                              });
                            },
                            isDark: isDark,
                            colorScheme: colorScheme,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // SECTION 3: Occasions
                        _buildSection(
                          title: "What occasions do you usually style for?",
                          child: _buildChipSelector(
                            options: const [
                              "Everyday / Office",
                              "College",
                              "Weddings & functions",
                              "Festivals / traditional wear",
                              "Dates & social outings",
                              "Interviews / professional meetings",
                            ],
                            selected: _selectedOccasions,
                            onSelect: (value) {
                              setState(() {
                                if (_selectedOccasions.contains(value)) {
                                  _selectedOccasions.remove(value);
                                } else {
                                  _selectedOccasions.add(value);
                                }
                              });
                            },
                            isMultiSelect: true,
                            isDark: isDark,
                            colorScheme: colorScheme,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // SECTION 4: Hair & Scalp Concerns
                        _buildSection(
                          title: "Are you facing any hair or scalp concerns?",
                          child: _buildChipSelector(
                            options: const [
                              "Hair fall",
                              "Dandruff",
                              "Thinning hair",
                              "Dry scalp",
                              "Oily scalp",
                              "Frizzy hair",
                              "None",
                            ],
                            selected: _selectedConcerns,
                            onSelect: (value) {
                              setState(() {
                                if (value == "None") {
                                  _selectedConcerns.clear();
                                  _selectedConcerns.add("None");
                                } else {
                                  _selectedConcerns.remove("None");
                                  if (_selectedConcerns.contains(value)) {
                                    _selectedConcerns.remove(value);
                                  } else {
                                    _selectedConcerns.add(value);
                                  }
                                }
                              });
                            },
                            isMultiSelect: true,
                            showIcons: true,
                            isDark: isDark,
                            colorScheme: colorScheme,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // SECTION 5: Personal Style
                        _buildSection(
                          title: "What kind of style do you usually like?",
                          child: _buildChipSelector(
                            options: const [
                              "Clean & professional",
                              "Trendy / modern",
                              "Natural / minimal",
                              "Bold & experimental",
                              "Traditional",
                            ],
                            selected: _selectedStyles,
                            onSelect: (value) {
                              setState(() {
                                if (_selectedStyles.contains(value)) {
                                  _selectedStyles.remove(value);
                                } else {
                                  _selectedStyles.add(value);
                                }
                              });
                            },
                            isMultiSelect: true,
                            isDark: isDark,
                            colorScheme: colorScheme,
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                // Bottom CTA (matching login screen style)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Primary CTA Button (gradient like login)
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
                          onPressed: _handleContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'CONTINUE',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Skip option
                      TextButton(
                        onPressed: () => Navigator.pop(context, widget.imagePath),
                        child: Text(
                          "Skip for now",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildChipSelector({
    required List<String> options,
    required dynamic selected,
    required Function(String) onSelect,
    required bool isMultiSelect,
    required bool isDark,
    required ColorScheme colorScheme,
    bool showIcons = false,
  }) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: options.map((option) {
        final isSelected = isMultiSelect
            ? (selected as Set<String>).contains(option)
            : (selected as String?) == option;

        return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 64, // Account for padding
          ),
          child: ChoiceChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showIcons) ...[
                  Icon(
                    _getIconForConcern(option),
                    size: 18,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight),
                  ),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    option,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    softWrap: true,
                  ),
                ),
              ],
            ),
            selected: isSelected,
            onSelected: (selected) => onSelect(option),
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            selectedColor: AppColors.gradientStart,
            labelStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : colorScheme.onSurface,
            ),
            side: BorderSide(
              color: isSelected
                  ? AppColors.gradientStart
                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
              width: 1,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCardSelector({
    required List<String> options,
    required String? selected,
    required Function(String) onSelect,
    required bool isDark,
    required ColorScheme colorScheme,
  }) {
    return Column(
      children: options.map((option) {
        final isSelected = selected == option;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => onSelect(option),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.gradientStart
                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      option,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      softWrap: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (isSelected)
                    Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.gradientStart,
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getIconForConcern(String concern) {
    switch (concern.toLowerCase()) {
      case 'hair fall':
        return Icons.water_drop_outlined;
      case 'dandruff':
        return Icons.medical_services_outlined;
      case 'thinning hair':
        return Icons.visibility_outlined;
      case 'dry scalp':
        return Icons.wb_sunny_outlined;
      case 'oily scalp':
        return Icons.opacity_outlined;
      case 'frizzy hair':
        return Icons.waves_outlined;
      case 'none':
        return Icons.check_circle_outline;
      default:
        return Icons.info_outline;
    }
  }
}
