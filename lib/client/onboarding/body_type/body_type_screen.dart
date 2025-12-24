import 'package:flutter/material.dart';
import 'package:gen_confi/app/routes/app_routes.dart';
import 'package:gen_confi/client/onboarding/widgets/onboarding_shell.dart';
import 'package:gen_confi/core/constants/app_spacing.dart';
import 'package:gen_confi/core/widgets/selectable_card.dart';
import 'package:gen_confi/services/onboarding_store.dart';

class BodyTypeScreen extends StatefulWidget {
  const BodyTypeScreen({super.key});

  @override
  State<BodyTypeScreen> createState() => _BodyTypeScreenState();
}

class _BodyTypeScreenState extends State<BodyTypeScreen> {
  String? _selectedBodyType;

  final List<Map<String, String>> _options = [
    {'label': 'Slim', 'helper': 'Lean build'},
    {'label': 'Athletic', 'helper': 'Defined shoulders'},
    {'label': 'Average', 'helper': 'Balanced proportions'},
    {'label': 'Broad', 'helper': 'Wider frame'},
    {'label': 'Plus', 'helper': 'Fuller figure'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedBodyType = OnboardingStore().draft.bodyType;
  }

  void _onOptionSelected(String value) {
    setState(() {
      _selectedBodyType = value;
    });
  }

  void _handleContinue() {
    if (_selectedBodyType != null) {
      final currentDraft = OnboardingStore().draft;
      OnboardingStore().update(
        currentDraft.copyWith(bodyType: _selectedBodyType),
      );
      Navigator.pushNamed(context, AppRoutes.clientOnboardingStylePreferences);
    }
  }

  void _handleSkip() {
    final currentDraft = OnboardingStore().draft;
    // Default to 'Average' on skip
    OnboardingStore().update(currentDraft.copyWith(bodyType: 'Average'));
    Navigator.pushNamed(context, AppRoutes.clientOnboardingStylePreferences);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return OnboardingShell(
      stepIndex: 2,
      totalSteps: 4,
      title: 'Your body type',
      subtitle:
          'This helps us recommend better fits. You can change this later.',
      primaryCtaText: 'Continue',
      primaryEnabled: _selectedBodyType != null,
      onPrimaryPressed: _handleContinue,
      onSkip: _handleSkip,
      showSkip: true,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 3 : 2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: isDesktop ? 1.4 : 1.1,
        ),
        itemCount: _options.length,
        itemBuilder: (context, index) {
          final option = _options[index];
          final value = option['label']!;
          final isSelected = _selectedBodyType == value;

          return SelectableCard(
            title: value,
            subtitle: option['helper'],
            isSelected: isSelected,
            onTap: () => _onOptionSelected(value),
          );
        },
      ),
    );
  }
}
