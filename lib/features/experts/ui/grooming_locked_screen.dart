// FILE: lib/features/experts/ui/grooming_locked_screen.dart

import 'package:flutter/material.dart';
import 'package:gen_confi/app/routes/app_routes.dart';
import 'package:gen_confi/core/constants/app_colors.dart';
import 'package:gen_confi/core/layout/responsive_container.dart';
import 'package:gen_confi/core/utils/theme_extensions.dart';
import 'package:gen_confi/core/widgets/gradient_button.dart';
import 'package:google_fonts/google_fonts.dart';

class GroomingLockedScreen extends StatelessWidget {
  const GroomingLockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gradientStart.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                "Start Your Grooming Journey",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: context.themeTextPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Analyze your face to get personalized insights and match with experts tailored for YOU.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: context.themeTextSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              GradientButton(
                text: "Start Face Scan",
                icon: Icons.camera_alt_rounded,
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.smartFaceCapture);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
