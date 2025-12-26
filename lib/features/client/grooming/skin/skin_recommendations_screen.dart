// FILE: lib/features/client/grooming/skin/skin_recommendations_screen.dart

import 'package:flutter/material.dart';
import 'package:gen_confi/core/constants/app_colors.dart';
import 'package:gen_confi/core/layout/base_scaffold.dart';
import 'package:gen_confi/core/layout/responsive_container.dart';
import 'package:gen_confi/services/onboarding_store.dart';

class SkinRecommendationsScreen extends StatelessWidget {
  const SkinRecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final draft = OnboardingStore().draft;
    final skinType = draft.skinType ?? 'Normal';
    final goal = draft.skinGoal ?? 'Improve Skin Health';

    return BaseScaffold(
      title: 'Skin Care',
      showBackButton: true,
      body: SingleChildScrollView(
        child: ResponsiveContainer(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInfoCard(skinType, goal),
                const SizedBox(height: 32),
                const Text(
                  'Recommended Routines',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildRoutineOption(
                  context,
                  title: 'Quick Routine',
                  description: 'Essentials only. Good for busy mornings.',
                  duration: '2 min',
                  icon: Icons.flash_on_rounded,
                  color: Colors.orange,
                  routineKeyPrefix:
                      'skin_am_quick', // AM/PM logic could be expanded
                ),
                const SizedBox(height: 16),
                _buildRoutineOption(
                  context,
                  title: 'Balanced Routine',
                  description: 'The sweet spot for daily maintenance.',
                  duration: '5 min',
                  icon: Icons.balance,
                  color: AppColors.primary,
                  routineKeyPrefix: 'skin_am_balanced',
                ),
                const SizedBox(height: 16),
                _buildRoutineOption(
                  context,
                  title: 'Full Routine',
                  description: 'Advanced care for maximum results.',
                  duration: '8 min',
                  icon: Icons.spa,
                  color: Colors.purple,
                  routineKeyPrefix: 'skin_am_full',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String skinType, String goal) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.face, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  skinType,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Goal: $goal',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineOption(
    BuildContext context, {
    required String title,
    required String description,
    required String duration,
    required IconData icon,
    required Color color,
    required String routineKeyPrefix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // For simplicity, passing the exact prefix as key,
            // but in real app we'd determine AM/PM context or ask user
            Navigator.pushNamed(
              context,
              '/client/grooming/routine',
              arguments: {'routineKey': routineKeyPrefix},
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.divider,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              duration,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
