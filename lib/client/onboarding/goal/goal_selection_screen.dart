import 'package:flutter/material.dart';
import 'package:gen_confi/app/routes/app_routes.dart';
import 'package:gen_confi/core/constants/app_colors.dart';
import 'package:gen_confi/core/constants/app_spacing.dart';
import 'package:gen_confi/core/layout/base_scaffold.dart';
import 'package:gen_confi/core/widgets/app_button.dart';
import 'package:gen_confi/services/auth_store.dart';
import 'package:gen_confi/services/onboarding_store.dart';

class GoalSelectionScreen extends StatefulWidget {
  const GoalSelectionScreen({super.key});

  @override
  State<GoalSelectionScreen> createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends State<GoalSelectionScreen> {
  String? _selectedGoal;

  final List<String> _goals = [
    "Everyday clean look",
    "Professional / Office look",
    "Glow-up / Style change",
    "Wedding / Special event",
    "Low maintenance",
    "For my child",
  ];

  void _onContinue() {
    if (_selectedGoal == null) return;
    
    // Save selection
    OnboardingStore().updateDraft(skinGoal: _selectedGoal); // Reusing skinGoal field for generic goal for now
    AuthStore().markOnboardingCompleteForCurrentRole();

    // Navigate to Home Shell
    Navigator.pushNamedAndRemoveUntil(
      context, 
      AppRoutes.clientShell,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      showBackButton: true,
      useResponsiveContainer: true,
      title: "Set Your Goal",
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "What’s your goal?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
             const Text(
              "We'll tailor your recommendations based on this goal.",
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _goals.map((goal) => _buildChoiceChip(goal)).toList(),
            ),

            const SizedBox(height: AppSpacing.xxl),

            AppButton(
              text: "Continue",
              onPressed: _selectedGoal != null ? _onContinue : null,
              isDisabled: _selectedGoal == null,
              style: AppButtonStyle.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChip(String label) {
    final isSelected = _selectedGoal == label;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedGoal = selected ? label : null;
        });
      },
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.transparent : AppColors.border,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
