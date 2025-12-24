import 'package:flutter/material.dart';

import 'package:gen_confi/core/constants/app_spacing.dart';
import 'package:gen_confi/core/widgets/app_button.dart';

class OnboardingShell extends StatelessWidget {
  final int stepIndex;
  final int totalSteps;
  final String title;
  final String subtitle;
  final Widget child;
  final String primaryCtaText;
  final bool primaryEnabled;
  final VoidCallback onPrimaryPressed;
  final VoidCallback? onSkip;
  final bool showSkip;

  const OnboardingShell({
    super.key,
    required this.stepIndex,
    required this.totalSteps,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.primaryCtaText,
    required this.primaryEnabled,
    required this.onPrimaryPressed,
    this.onSkip,
    this.showSkip = false,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate progress
    final double progress = (stepIndex / totalSteps).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFF0D9488), // Teal-600
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Section (Teal)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Navigation Row
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const Spacer(),
                      Column(
                        children: [
                          Text(
                            'Step $stepIndex of $totalSteps',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Progress Bar inside header
                          SizedBox(
                            width: 80,
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.black12,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              minHeight: 2,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Skip Button or Placeholder
                      if (showSkip && onSkip != null)
                        TextButton(
                          onPressed: onSkip,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white70,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Skip',
                            style: TextStyle(fontSize: 14),
                          ),
                        )
                      else
                        const SizedBox(width: 20),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Header Texts
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),

            // Bottom Section (White Card)
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  child: Column(
                    children: [
                      // Content Area
                      Expanded(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 720),
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.xl,
                              ),
                              child: child,
                            ),
                          ),
                        ),
                      ),
                      // Sticky Bottom Bar
                      Container(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(
                              color: Colors.grey.withOpacity(0.1),
                            ),
                          ),
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 720),
                            child: AppButton(
                              text: primaryCtaText,
                              onPressed: onPrimaryPressed,
                              isDisabled: !primaryEnabled,
                              width: double.infinity,
                              style: AppButtonStyle.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
