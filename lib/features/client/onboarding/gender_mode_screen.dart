import 'package:flutter/material.dart';
import 'package:gen_confi/app/routes/app_routes.dart';
import 'package:gen_confi/core/constants/app_colors.dart';
import 'package:gen_confi/core/constants/app_spacing.dart';
import 'package:gen_confi/core/utils/navigation.dart';
import 'package:gen_confi/core/widgets/app_button.dart';
import 'package:gen_confi/core/widgets/section_title.dart';

class GenderModeScreen extends StatefulWidget {
  const GenderModeScreen({super.key});

  @override
  State<GenderModeScreen> createState() => _GenderModeScreenState();
}

class _GenderModeScreenState extends State<GenderModeScreen> {
  String? _selectedGender;
  String? _selectedMode;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<Map<String, String>> _modes = [
    {
      'title': 'AI Styling Only',
      'description': 'Automated recommendations based on your profile.',
    },
    {
      'title': 'AI + Expert Consultation',
      'description': 'Get personal advice from professional stylists.',
    },
  ];

  bool get _canContinue => _selectedGender != null && _selectedMode != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
        title: const Text(
          'Step 1 of 4',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: 0.25,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 4,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _HeaderDetails(),
                    const SizedBox(height: AppSpacing.xl),

                    const SectionTitle(title: 'I identify as...'),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.md,
                      children: _genders
                          .map(
                            (gender) => SizedBox(
                              width:
                                  (MediaQuery.of(context).size.width -
                                      48 -
                                      16) /
                                  2, // 2 columns approx
                              child: _SelectionCard(
                                title: gender,
                                isSelected: _selectedGender == gender,
                                centered: true,
                                onTap: () =>
                                    setState(() => _selectedGender = gender),
                              ),
                            ),
                          )
                          .toList(),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    const SectionTitle(title: 'My Goal'),
                    const SizedBox(height: AppSpacing.md),
                    ..._modes.map(
                      (mode) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _SelectionCard(
                          title: mode['title']!,
                          description: mode['description'],
                          isSelected: _selectedMode == mode['title'],
                          onTap: () =>
                              setState(() => _selectedMode = mode['title']),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: AppButton(
                text: 'Continue',
                onPressed: () {
                  AppNavigation.pushNamed(context, AppRoutes.bodyTypeSelection);
                },
                isDisabled: !_canContinue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderDetails extends StatelessWidget {
  const _HeaderDetails();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Let’s get to know you',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900, // Bold header
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          'Your identity helps us tailor the perfect style recommendations.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
        ),
      ],
    );
  }
}

class _SelectionCard extends StatelessWidget {
  final String title;
  final String? description;
  final bool isSelected;
  final bool centered;
  final VoidCallback onTap;

  const _SelectionCard({
    required this.title,
    this.description,
    required this.isSelected,
    this.centered = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.skyBlue.withValues(alpha: 0.5)
            : AppColors.surface,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(20), // Pill-like
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: centered
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: centered
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (description != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          description!,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.textPrimary.withOpacity(0.8)
                                : AppColors.textSecondary,
                            fontSize: 14,
                            height: 1.4,
                          ),
                          textAlign: centered
                              ? TextAlign.center
                              : TextAlign.start,
                        ),
                      ],
                    ],
                  ),
                ),
                if (isSelected && !centered)
                  const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Icon(Icons.check_circle, color: AppColors.primary),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
