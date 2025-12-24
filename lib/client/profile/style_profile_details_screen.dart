import 'package:flutter/material.dart';
import 'package:gen_confi/core/constants/app_colors.dart';
import 'package:gen_confi/core/constants/app_spacing.dart';
import 'package:gen_confi/core/layout/base_scaffold.dart';
import 'package:gen_confi/core/widgets/app_card.dart';
import 'package:gen_confi/services/onboarding_store.dart';

class StyleProfileDetailsScreen extends StatelessWidget {
  const StyleProfileDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final draft = OnboardingStore().draft;
    final isMale = draft.gender == "Male";

    return BaseScaffold(
      title: "Style & Grooming",
      showBackButton: true,
      useResponsiveContainer: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // Intro
            const Text(
              "Your personalized preferences helping us curate your style.",
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Body Stats
            _buildSection("Body & Fit", [
              _buildInfoRow("Body Type", draft.bodyType ?? "Not selected"),
              _buildInfoRow("Preferred Fit", draft.fitPreference ?? "Regular"),
            ]),
            const SizedBox(height: AppSpacing.lg),

            // Grooming
            _buildSection("Grooming Profile", [
              _buildInfoRow("Skin Type", draft.skinType ?? "Unknown"),
              _buildInfoRow("Hair Type", draft.hairType ?? "Unknown"),
              if (isMale)
                _buildInfoRow(
                  "Beard Preference",
                  draft.beardPreference ?? "None",
                )
              else
                _buildInfoRow(
                  "Makeup Frequency",
                  draft.makeupFrequency ?? "None",
                ),

              const SizedBox(height: 12),
              const Text(
                "Goals",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (draft.hairGoal != null)
                    _buildChip(draft.hairGoal!, Icons.face),
                  if (draft.skinGoal != null)
                    _buildChip(draft.skinGoal!, Icons.wb_sunny_outlined),
                ],
              ),
            ]),
            const SizedBox(height: AppSpacing.lg),

            // Style & Colors
            _buildSection("Style & Colors", [
              const Text(
                "Style Tribes",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: draft.styleTags
                    .map((t) => _buildChip(t, Icons.check))
                    .toList(),
              ),

              if (draft.colorPrefs.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  "Preferred Colors",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: draft.colorPrefs
                      .map((c) => _buildChip(c, Icons.palette_outlined))
                      .toList(),
                ),
              ],
            ]),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
