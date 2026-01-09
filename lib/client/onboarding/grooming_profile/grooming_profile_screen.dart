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
  // Common
  String? _skinType;
  String? _hairType;
  List<String> _groomingConcerns = [];

  // Gender Specific
  String? _beardPreference; // Male
  String? _makeupFrequency; // Female
  String? _hairGoal;
  String? _skinGoal;

  // Options - Common
  final List<String> _skinTypeOptions = [
    'Normal',
    'Oily',
    'Dry',
    'Combination',
  ];
  final List<String> _hairTypeOptions = ['Straight', 'Wavy', 'Curly', 'Coily'];
  final List<String> _concernsOptions = [
    'Acne',
    'Dullness',
    'Pigmentation',
    'Hairfall',
    'Dandruff',
    'Frizz',
    'Dryness',
  ];

  // Options - Male
  final List<String> _beardOptions = ['Clean', 'Light', 'Medium', 'Heavy'];
  final List<String> _maleHairGoals = [
    'Volume',
    'Hairfall control',
    'Anti-dandruff',
    'Natural look',
    'Styling hold',
  ];
  final List<String> _maleSkinGoals = [
    'Acne care',
    'Brightening',
    'Oil control',
    'Glow',
  ];

  // Options - Female
  final List<String> _makeupOptions = ['None', 'Occasional', 'Daily'];
  final List<String> _femaleHairGoals = [
    'Frizz control',
    'Shine',
    'Volume',
    'Hairfall control',
    'Curl definition',
  ];
  final List<String> _femaleSkinGoals = [
    'Glow',
    'Acne care',
    'Brightening',
    'Pigmentation',
    'Hydration',
  ];

  @override
  void initState() {
    super.initState();
    final draft = OnboardingStore().draft;
    _skinType = draft.skinType;
    _hairType = draft.hairType;
    _groomingConcerns = List.from(draft.groomingConcerns);
    _beardPreference = draft.beardPreference;
    _makeupFrequency = draft.makeupFrequency;
    _hairGoal = draft.hairGoal;
    _skinGoal = draft.skinGoal;
  }

  bool get _isMaleMode {
    final draft = OnboardingStore().draft;
    return draft.gender == 'Male';
  }

  void _handleContinue() {
    final currentDraft = OnboardingStore().draft;
    OnboardingStore().update(
      currentDraft.copyWith(
        skinType: _skinType,
        hairType: _hairType,
        groomingConcerns: _groomingConcerns,
        beardPreference: _isMaleMode ? _beardPreference : null,
        makeupFrequency: !_isMaleMode ? _makeupFrequency : null,
        hairGoal: _hairGoal,
        skinGoal: _skinGoal,
      ),
    );
    Navigator.pushNamed(context, AppRoutes.onboardingSelfie);
  }

  void _handleSkip() {
    final currentDraft = OnboardingStore().draft;
    OnboardingStore().update(
      currentDraft.copyWith(
        skinType: 'Normal',
        hairType: 'Straight',
        groomingConcerns: [], // Empty defaults
        beardPreference: _isMaleMode ? 'Clean' : null,
        makeupFrequency: !_isMaleMode ? 'None' : null,
        hairGoal: _isMaleMode ? 'Natural look' : 'Shine',
        skinGoal: 'Glow',
      ),
    );
    Navigator.pushNamed(context, AppRoutes.onboardingSelfie);
  }

  bool get _canContinue {
    final commonSet =
        _skinType != null &&
        _hairType != null &&
        _hairGoal != null &&
        _skinGoal != null;
    if (_isMaleMode) {
      return commonSet && _beardPreference != null;
    } else {
      return commonSet && _makeupFrequency != null;
    }
  }

  void _toggleConcern(String concern) {
    setState(() {
      if (_groomingConcerns.contains(concern)) {
        _groomingConcerns.remove(concern);
      } else {
        if (_groomingConcerns.length < 3) {
          _groomingConcerns.add(concern);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Select up to 3 concerns only'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return OnboardingShell(
      stepIndex: 2,
      totalSteps: 2,
      title: 'Your grooming profile',
      subtitle: 'A few quick picks so we can personalize your routine.',
      primaryCtaText: 'Continue',
      primaryEnabled: _canContinue,
      onPrimaryPressed: _handleContinue,
      onSkip: _handleSkip,
      showSkip: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A) Skin Type
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

          // B) Hair Type
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

          // C) Concerns (Multi-select)
          _buildSectionTitle('Grooming concerns (Optional)'),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _concernsOptions.map((concern) {
              return SelectableChip(
                label: concern,
                isSelected: _groomingConcerns.contains(concern),
                onTap: () => _toggleConcern(concern),
              );
            }).toList(),
          ),

          const SizedBox(height: AppSpacing.xl),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppSpacing.xl),

          // D) Gender Specific Preference
          if (_isMaleMode) ...[
            _buildSectionTitle('Beard preference'),
            const SizedBox(height: AppSpacing.sm),
            _buildGridOptions(
              options: _beardOptions,
              selected: _beardPreference,
              onSelect: (val) => setState(() => _beardPreference = val),
              isDesktop: isDesktop,
            ),
          ] else ...[
            _buildSectionTitle('Makeup frequency'),
            const SizedBox(height: AppSpacing.sm),
            _buildGridOptions(
              options: _makeupOptions,
              selected: _makeupFrequency,
              onSelect: (val) => setState(() => _makeupFrequency = val),
              isDesktop: isDesktop,
            ),
          ],

          const SizedBox(height: AppSpacing.xl),

          // E) Hair Goal
          _buildSectionTitle('Hair goal'),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: (_isMaleMode ? _maleHairGoals : _femaleHairGoals).map((
              goal,
            ) {
              return SelectableChip(
                label: goal,
                isSelected: _hairGoal == goal,
                onTap: () => setState(() => _hairGoal = goal),
              );
            }).toList(),
          ),

          const SizedBox(height: AppSpacing.xl),

          // F) Skin Goal
          _buildSectionTitle('Skin goal'),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: (_isMaleMode ? _maleSkinGoals : _femaleSkinGoals).map((
              goal,
            ) {
              return SelectableChip(
                label: goal,
                isSelected: _skinGoal == goal,
                onTap: () => setState(() => _skinGoal = goal),
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
    if (isDesktop) {
      return Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.md,
        children: options.map((opt) {
          return SizedBox(
            width: 140,
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
            childAspectRatio: 2.5, // Shorter cards as requested (was 1.8)
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
