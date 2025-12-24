import 'package:flutter/material.dart';
import 'package:gen_confi/app/routes/app_routes.dart';
import 'package:gen_confi/client/onboarding/widgets/onboarding_shell.dart';
import 'package:gen_confi/core/constants/app_colors.dart';
import 'package:gen_confi/core/constants/app_spacing.dart';
import 'package:gen_confi/core/widgets/selectable_card.dart';
import 'package:gen_confi/core/widgets/selectable_chip.dart';
import 'package:gen_confi/services/onboarding_store.dart';

class StylePreferencesScreen extends StatefulWidget {
  const StylePreferencesScreen({super.key});

  @override
  State<StylePreferencesScreen> createState() => _StylePreferencesScreenState();
}

class _StylePreferencesScreenState extends State<StylePreferencesScreen> {
  // State
  List<String> _selectedTags = [];
  String _selectedFit = 'Regular';
  List<String> _selectedColors = [];

  // Data
  final List<String> _styleTags = [
    "Casual",
    "Minimal",
    "Street",
    "Formal",
    "Traditional",
    "Sporty",
    "Party",
    "Classic",
    "Smart-casual",
    "Ethnic",
  ];

  final List<String> _fitOptions = ["Slim", "Regular", "Relaxed"];

  final Map<String, Color> _colorOptions = {
    "Black": Colors.black,
    "White": Colors.white,
    "Blue": Colors.blue,
    "Navy": const Color(0xFF000080),
    "Grey": Colors.grey,
    "Beige": const Color(0xFFF5F5DC),
    "Olive": const Color(0xFF808000),
    "Brown": Colors.brown,
    "Red": Colors.red,
    "Pastel": const Color(0xFFFFD1DC),
  };

  @override
  void initState() {
    super.initState();
    final draft = OnboardingStore().draft;
    _selectedTags = List.from(draft.styleTags);
    if (draft.fitPreference != null) {
      _selectedFit = draft.fitPreference!;
    }
    _selectedColors = List.from(draft.colorPrefs);
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        if (_selectedTags.length < 5) {
          _selectedTags.add(tag);
        } else {
          _showSnackBar("You can select up to 5 styles");
        }
      }
    });
  }

  void _selectFit(String fit) {
    setState(() {
      _selectedFit = fit;
    });
  }

  void _toggleColor(String colorName) {
    setState(() {
      if (_selectedColors.contains(colorName)) {
        _selectedColors.remove(colorName);
      } else {
        if (_selectedColors.length < 3) {
          _selectedColors.add(colorName);
        } else {
          _showSnackBar("You can select up to 3 colors");
        }
      }
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleContinue() {
    final currentDraft = OnboardingStore().draft;
    OnboardingStore().update(
      currentDraft.copyWith(
        styleTags: _selectedTags,
        fitPreference: _selectedFit,
        colorPrefs: _selectedColors,
      ),
    );
    Navigator.pushNamed(context, AppRoutes.clientOnboardingGroomingProfile);
  }

  void _handleSkip() {
    final currentDraft = OnboardingStore().draft;
    // Save defaults: Empty lists and Regular fit
    OnboardingStore().update(
      currentDraft.copyWith(
        styleTags: [],
        fitPreference: 'Regular',
        colorPrefs: [],
      ),
    );
    Navigator.pushNamed(context, AppRoutes.clientOnboardingGroomingProfile);
  }

  bool get _canContinue =>
      _selectedTags.isNotEmpty ||
      _selectedColors.isNotEmpty ||
      _selectedFit.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return OnboardingShell(
      stepIndex: 3,
      totalSteps: 4,
      title: "Your style preferences",
      subtitle: "Pick what you like. This helps personalize your outfits.",
      primaryCtaText: "Continue",
      primaryEnabled: _canContinue,
      onPrimaryPressed: _handleContinue,
      onSkip: _handleSkip,
      showSkip: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section A: Style Tags
          _buildSectionTitle("Choose styles (up to 5)"),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _styleTags.map((tag) {
              return SelectableChip(
                label: tag,
                isSelected: _selectedTags.contains(tag),
                onTap: () => _toggleTag(tag),
              );
            }).toList(),
          ),

          const SizedBox(height: AppSpacing.xl),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppSpacing.xl),

          // Section B: Fit Preference
          _buildSectionTitle("Fit preference"),
          const SizedBox(height: AppSpacing.sm),
          isDesktop
              ? Row(
                  children: _fitOptions
                      .map(
                        (fit) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: AppSpacing.md,
                            ),
                            child: SelectableCard(
                              title: fit,
                              isSelected: _selectedFit == fit,
                              onTap: () => _selectFit(fit),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                )
              : Column(
                  children: _fitOptions
                      .map(
                        (fit) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: SelectableCard(
                            title: fit,
                            isSelected: _selectedFit == fit,
                            onTap: () => _selectFit(fit),
                          ),
                        ),
                      )
                      .toList(),
                ),

          const SizedBox(height: AppSpacing.xl),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppSpacing.xl),

          // Section C: Color Preferences
          _buildSectionTitle("Colors you wear most (up to 3)"),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _colorOptions.entries.map((entry) {
              return SelectableChip(
                label: entry.key,
                isSelected: _selectedColors.contains(entry.key),
                colorDot: entry.value,
                onTap: () => _toggleColor(entry.key),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}
