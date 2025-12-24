import 'package:flutter/material.dart';
import 'package:gen_confi/services/auth_store.dart';
import 'package:gen_confi/app/routes/app_routes.dart';
import 'package:gen_confi/core/constants/app_colors.dart';
import 'package:gen_confi/core/constants/app_spacing.dart';
import 'package:gen_confi/core/layout/base_scaffold.dart';
import 'package:gen_confi/core/widgets/app_button.dart';
import 'package:gen_confi/services/onboarding_store.dart';

class FinishScreen extends StatelessWidget {
  const FinishScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final draft = OnboardingStore().draft;

    // Collect summary items for chips
    final summaryItems = <String>[];
    if (draft.bodyType != null) summaryItems.add(draft.bodyType!);
    // if (draft.fitPreference != null) summaryItems.add(draft.fitPreference!); // Fit pref used to be there? Checking model.. yes it is.
    summaryItems.addAll(
      draft.styleTags.take(2),
    ); // Reduce style tags to make room

    // Gender specific
    if (draft.beardPreference != null) summaryItems.add(draft.beardPreference!);
    if (draft.makeupFrequency != null && draft.makeupFrequency != 'None') {
      summaryItems.add('Makeup: ${draft.makeupFrequency}');
    }

    if (draft.hairGoal != null) summaryItems.add(draft.hairGoal!);
    if (draft.skinGoal != null) summaryItems.add(draft.skinGoal!);

    return BaseScaffold(
      // Clean slate, no back button to encourage moving forward
      showBackButton: false,
      useResponsiveContainer: true,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                size: 64,
                color: AppColors.accent,
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text(
                "You're set!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                "We’ve personalized Gen Confi for you.",
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Summary Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Your Profile Snapshot',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      alignment: WrapAlignment.center,
                      children: summaryItems.map((item) {
                        return Chip(
                          label: Text(item),
                          backgroundColor: AppColors.surface,
                          side: const BorderSide(color: AppColors.border),
                          labelStyle: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // CTA
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: 'Go to Home',
                  onPressed: () {
                    AuthStore().markOnboardingCompleteForCurrentRole();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.clientHome,
                      (route) => false,
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to Edit Profile flow
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Edit profile feature coming soon"),
                    ),
                  );
                },
                child: const Text(
                  'Edit preferences',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
