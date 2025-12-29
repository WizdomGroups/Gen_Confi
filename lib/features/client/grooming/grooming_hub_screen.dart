// FILE: lib/features/client/grooming/grooming_hub_screen.dart

import 'package:flutter/material.dart';
import 'package:gen_confi/core/constants/app_colors.dart';
import 'package:gen_confi/core/layout/base_scaffold.dart';
import 'package:gen_confi/core/layout/responsive_container.dart';
import 'package:gen_confi/services/onboarding_store.dart';

class GroomingHubScreen extends StatefulWidget {
  const GroomingHubScreen({super.key});

  @override
  State<GroomingHubScreen> createState() => _GroomingHubScreenState();
}

class _GroomingHubScreenState extends State<GroomingHubScreen> {
  bool _isAm = true; // Toggle state for AM/PM

  @override
  Widget build(BuildContext context) {
    // Get personal data
    final goal = OnboardingStore().draft.skinGoal ?? 'Look your best';
    final gender = OnboardingStore().draft.gender ?? 'Male';
    final isMale = gender == 'Male';

    return BaseScaffold(
      title: 'Grooming',
      body: SingleChildScrollView(
        child: ResponsiveContainer(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Your routine for today',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),

                // Today's Routine Card
                _buildRoutineCard(goal),

                const SizedBox(height: 32),

                // Quick Tiles Grid
                // Using Wrap or LayoutBuilder for responsiveness if not using GridView
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 600;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: isWide ? 4 : 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.1,
                      children: [
                        _buildQuickTile(
                          'Skin',
                          Icons.face,
                          AppColors.primary,
                          () => Navigator.pushNamed(
                            context,
                            '/client/grooming/skin',
                          ),
                        ),
                        _buildQuickTile(
                          'Hair',
                          Icons.content_cut,
                          Colors.purple,
                          () {
                            // TODO: Navigate to Hair flow
                          },
                        ),
                        _buildQuickTile(
                          isMale ? 'Beard' : 'Makeup',
                          isMale ? Icons.face_retouching_natural : Icons.brush,
                          Colors.orange,
                          () {
                            // TODO: Navigate to Beard/Makeup flow
                          },
                        ),
                        _buildQuickTile(
                          'History',
                          Icons.history,
                          Colors.grey,
                          () => Navigator.pushNamed(
                            context,
                            '/client/grooming/history',
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoutineCard(String goal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header with AM/PM toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isAm ? 'Morning Routine' : 'Evening Routine',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Goal: $goal',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _buildToggleBtn(
                      'AM',
                      _isAm,
                      () => setState(() => _isAm = true),
                    ),
                    _buildToggleBtn(
                      'PM',
                      !_isAm,
                      () => setState(() => _isAm = false),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to routine player with correct key based on selection
                // Defaulting to 'skin_am_quick' for demo if AM, 'skin_pm_quick' if PM
                final key = _isAm ? 'skin_am_quick' : 'skin_pm_quick';
                Navigator.pushNamed(
                  context,
                  '/client/grooming/routine',
                  arguments: {'routineKey': key},
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Start Routine',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleBtn(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.primary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickTile(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
