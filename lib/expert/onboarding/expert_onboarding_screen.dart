import 'package:flutter/material.dart';
import 'package:gen_confi/app/routes/app_routes.dart';
import 'package:gen_confi/core/layout/base_scaffold.dart';
import 'package:gen_confi/services/auth_store.dart';
import 'package:gen_confi/core/widgets/app_button.dart';
import 'package:gen_confi/core/constants/app_spacing.dart';

class ExpertOnboardingScreen extends StatelessWidget {
  const ExpertOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Expert Profile',
      useResponsiveContainer: true,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Complete your expert profile"),
            const SizedBox(height: AppSpacing.xl),
            // Placeholder content
            const TextField(
              decoration: InputDecoration(labelText: "Specialization"),
            ),
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: "Complete Setup",
                onPressed: () {
                  AuthStore().markOnboardingCompleteForCurrentRole();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.expertHome,
                    (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
