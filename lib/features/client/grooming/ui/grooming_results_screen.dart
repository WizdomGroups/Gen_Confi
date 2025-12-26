// FILE: lib/features/client/grooming/ui/grooming_results_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gen_confi/app/routes/app_routes.dart';
import 'package:gen_confi/core/constants/app_colors.dart';
import 'package:gen_confi/core/constants/app_spacing.dart';
import 'package:gen_confi/core/layout/base_scaffold.dart';
import 'package:gen_confi/core/widgets/app_button.dart';
import 'package:gen_confi/services/auth_store.dart';
import 'package:google_fonts/google_fonts.dart';

class GroomingResultsScreen extends StatelessWidget {
  final String imagePath;
  final Map<String, dynamic>? metaData;

  final bool isTabMode;

  const GroomingResultsScreen({
    super.key,
    required this.imagePath,
    this.metaData,
    this.isTabMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Your Grooming Profile',
      showBackButton: !isTabMode,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Captured Image Review
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                height: 300,
                width: double.infinity,
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. AI Analysis Insights (Mock Data)
            _buildSectionHeader("AI Detected Attributes"),
            const SizedBox(height: 12),
            _buildInsightCard("Face Shape", "Oval", "Balanced proportions, versatile for styling."),
            _buildInsightCard("Skin Tone", "Medium-Neutral", "Earthy tones and pastels work great."),
            const SizedBox(height: 24),

            _buildSectionHeader("Recommendations"),
            const SizedBox(height: 12),
            _buildRecommendationCard(
              "Suggested Hairstyle",
              "Textured Crop with Fade",
              Icons.content_cut_rounded,
              Colors.orange,
            ),
            _buildRecommendationCard(
              "Eyewear",
              "Rectangular or Aviator Frames",
              Icons.remove_red_eye_rounded,
              Colors.blue,
            ),
            _buildRecommendationCard(
              "Skin Routine",
              "Hydration & SPF Focus",
              Icons.water_drop_rounded,
              Colors.teal,
            ),
            const SizedBox(height: 32),

            // 3. CTA to Experts
            AppButton(
              text: "Connect with Experts",
              onPressed: () {
                // Mark grooming as complete
                AuthStore().setGroomingCompleted(true);
                
                // Navigate to Shell (which displays Home).
                // Ideally, we want to go specific tab, but routing to shell and letting user tap is fine,
                // OR we can pass an argument to Shell to switch tabs.
                // For now, let's pop until we are at home, or replace logic.
                // Simpler: Just pop to Home, user sees "Experts" unlocked.
                
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.clientShell,
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildInsightCard(String label, String value, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
