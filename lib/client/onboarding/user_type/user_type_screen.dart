import 'package:flutter/material.dart';
import 'package:gen_confi/app/routes/app_routes.dart';
import 'package:gen_confi/core/constants/app_colors.dart';
import 'package:gen_confi/core/constants/app_spacing.dart';
import 'package:gen_confi/core/layout/base_scaffold.dart';
import 'package:gen_confi/core/widgets/app_button.dart';
import 'package:gen_confi/core/widgets/app_card.dart';
import 'package:gen_confi/services/onboarding_store.dart';

class UserTypeScreen extends StatefulWidget {
  const UserTypeScreen({super.key});

  @override
  State<UserTypeScreen> createState() => _UserTypeScreenState();
}

class _UserTypeScreenState extends State<UserTypeScreen> {
  String? _selectedType;

  final List<Map<String, dynamic>> _options = [
    {'label': 'Men', 'icon': Icons.man_rounded},
    {'label': 'Women', 'icon': Icons.woman_rounded},
    {'label': 'Kids', 'icon': Icons.child_care_rounded, 'subtext': 'For kids, we provide gentle & age-appropriate grooming tips.'},
  ];

  void _onContinue() {
    if (_selectedType == null) return;
    
    // Save selection
    if (_selectedType == 'Men') {
       OnboardingStore().updateDraft(gender: 'Male');
    } else if (_selectedType == 'Women') {
       OnboardingStore().updateDraft(gender: 'Female');
    } else {
       // Handle Kids logic or store as 'Kid'
       OnboardingStore().updateDraft(gender: 'Kid'); 
    }

    Navigator.pushNamed(context, AppRoutes.onboardingGoal);
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      showBackButton: true,
      useResponsiveContainer: true,
      title: "Who is this for?",
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Who is this grooming for?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            
            ..._options.map((option) => _buildOptionCard(option)),

            const SizedBox(height: AppSpacing.xxl),

            AppButton(
              text: "Continue",
              onPressed: _selectedType != null ? _onContinue : null,
              isDisabled: _selectedType == null,
              style: AppButtonStyle.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(Map<String, dynamic> option) {
    final isSelected = _selectedType == option['label'];
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        onTap: () => setState(() => _selectedType = option['label']),
        padding: const EdgeInsets.all(AppSpacing.lg),
        borderColor: isSelected ? AppColors.primary : AppColors.border,
        backgroundColor: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                option['icon'],
                color: isSelected ? AppColors.primary : Colors.grey,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option['label'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  if (option.containsKey('subtext')) ...[
                    const SizedBox(height: 4),
                    Text(
                      option['subtext'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
