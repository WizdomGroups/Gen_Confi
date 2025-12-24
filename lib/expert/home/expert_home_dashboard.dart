import 'package:flutter/material.dart';
import 'package:gen_confi/app/routes/app_routes.dart';
import 'package:gen_confi/core/constants/app_colors.dart';
import 'package:gen_confi/core/layout/base_scaffold.dart';
import 'package:gen_confi/services/auth_store.dart';

class ExpertHomeDashboard extends StatelessWidget {
  const ExpertHomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Expert Dashboard',
      showBackButton: false,
      useResponsiveContainer: true,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.psychology, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text(
              "Welcome, Expert!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("Manage your clients here (Placeholder)"),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () {
                AuthStore().logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
