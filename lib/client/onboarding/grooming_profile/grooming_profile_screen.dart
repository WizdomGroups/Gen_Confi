import 'package:flutter/material.dart';
import 'package:gen_confi/app/routes/app_routes.dart';
import 'package:gen_confi/client/onboarding/widgets/onboarding_shell.dart';
import 'package:gen_confi/core/constants/app_colors.dart';
import 'package:gen_confi/core/constants/app_spacing.dart';
import 'package:gen_confi/core/widgets/selectable_card.dart';
import 'package:gen_confi/core/widgets/selectable_chip.dart';
import 'package:gen_confi/services/onboarding_store.dart';

class GroomingProfileScreen extends StatefulWidget {
  const GroomingProfileScreen({super.key});

  @override
  State<GroomingProfileScreen> createState() => _GroomingProfileScreenState();
}

class _GroomingProfileScreenState extends State<GroomingProfileScreen> {
  String? _skinType;
  String? _hairType;
  String? _facialPreference; // Beard or Makeup
  String? _groomingGoal;

  final List<String> _skinTypeOptions = [
    'Normal',
    'Oily',
    'Dry',
    'Combination',
  ];
  final List<String> _hairTypeOptions = ['Straight', 'Wavy', 'Curly', 'Coily'];
  final List<String> _goalOptions = [
    'Acne care',
    'Brightening',
    'Hairfall control',
    'Dandruff care',
    'Beard growth',
    'Glow',
  ];

  @override
  void initState() {
    super.initState();
    final draft = OnboardingStore().draft;
    _skinType = draft.skinType;
    _hairType = draft.hairType;
    _facialPreference = draft.facialPreference;
    _groomingGoal = draft.groomingGoal;
  }

  bool get _isMaleMode {
    final draft = OnboardingStore().draft;
    // Simple check, can be expanded based on exact Mode values
    return draft.gender == 'Male' || (draft.mode?.contains('Men') ?? false);
  }

  List<String> get _facialOptions {
    if (_isMaleMode) {
      return ['Clean', 'Light', 'Medium', 'Heavy'];
    }
    return ['None', 'Occasional', 'Daily'];
  }

  String get _facialLabel =>
      _isMaleMode ? 'Beard preference' : 'Makeup preference';

  void _handleContinue() {
    final currentDraft = OnboardingStore().draft;
    OnboardingStore().update(
      currentDraft.copyWith(
        skinType: _skinType,
        hairType: _hairType,
        facialPreference: _facialPreference,
        groomingGoal: _groomingGoal,
      ),
    );
    Navigator.pushNamed(context, AppRoutes.clientOnboardingFinish);
  }

  void _handleSkip() {
    final currentDraft = OnboardingStore().draft;
    OnboardingStore().update(
      currentDraft.copyWith(
        skinType: 'Normal',
        hairType: 'Straight',
        facialPreference: _isMaleMode ? 'Clean' : 'None',
        groomingGoal: 'Glow',
      ),
    );
    Navigator.pushNamed(context, AppRoutes.clientOnboardingFinish);
  }

  bool get _canContinue =>
      _skinType != null &&
      _hairType != null &&
      _facialPreference != null &&
      _groomingGoal != null;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return OnboardingShell(
      stepIndex: 4,
      totalSteps: 4,
      title: 'Your grooming profile',
      subtitle: 'So we can tailor routines and recommendations.',
      primaryCtaText: 'Continue',
      primaryEnabled: _canContinue,
      onPrimaryPressed: _handleContinue,
      onSkip: _handleSkip,
      showSkip: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Skin type'),
          const SizedBox(height: AppSpacing.sm),
          _buildGridOptions(
            options: _skinTypeOptions,
            selected: _skinType,
            onSelect: (val) => setState(() => _skinType = val),
            isDesktop: isDesktop,
          ),
          const SizedBox(height: AppSpacing.xl),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionTitle('Hair type'),
          const SizedBox(height: AppSpacing.sm),
          _buildGridOptions(
            options: _hairTypeOptions,
            selected: _hairType,
            onSelect: (val) => setState(() => _hairType = val),
            isDesktop: isDesktop,
          ),
          const SizedBox(height: AppSpacing.xl),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionTitle(_facialLabel),
          const SizedBox(height: AppSpacing.sm),
          _buildGridOptions(
            options: _facialOptions,
            selected: _facialPreference,
            onSelect: (val) => setState(() => _facialPreference = val),
            isDesktop: isDesktop,
          ),
          const SizedBox(height: AppSpacing.xl),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionTitle('Primary grooming goal'),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _goalOptions.map((goal) {
              return SelectableChip(
                label: goal,
                isSelected: _groomingGoal == goal,
                onTap: () => setState(() => _groomingGoal = goal),
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

  Widget _buildGridOptions({
    required List<String> options,
    required String? selected,
    required Function(String) onSelect,
    required bool isDesktop,
  }) {
    // Desktop: Row (ALL in one row if possible, or wrap).
    // Mobile: Grid 2 cols for better touch targets.
    if (isDesktop) {
      return Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.md,
        children: options.map((opt) {
          return SizedBox(
            width: 140, // Fixed width for consistent look on web
            child: SelectableCard(
              title: opt,
              isSelected: selected == opt,
              onTap: () => onSelect(opt),
            ),
          );
        }).toList(),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            childAspectRatio: 1.8,
          ),
          itemCount: options.length,
          itemBuilder: (context, index) {
            final opt = options[index];
            return SelectableCard(
              title: opt,
              isSelected: selected == opt,
              onTap: () => onSelect(opt),
            );
          },
        );
      },
    );
  }
}
