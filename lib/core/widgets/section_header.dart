import 'package:flutter/material.dart';
import 'package:gen_confi/core/constants/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool centerAlign;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.centerAlign = false, // Added flexibility for different screen types
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: centerAlign
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          textAlign: centerAlign ? TextAlign.center : TextAlign.start,
          style: const TextStyle(
            fontSize: 26, // Slightly reduced from 28 for better mobile scaling
            fontWeight: FontWeight.w800, // Extra bold for the primary anchor
            color: AppColors.textPrimary,
            letterSpacing:
                -0.5, // Tighter tracking for a high-end editorial feel
            height: 1.2,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 12), // Consistent spacing
          Text(
            subtitle!,
            textAlign: centerAlign ? TextAlign.center : TextAlign.start,
            style: const TextStyle(
              fontSize:
                  15, // 15px is the "sweet spot" for readability in modern UI
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.6, // Increased line-height for better eye tracking
              letterSpacing: 0.1,
            ),
          ),
        ],
      ],
    );
  }
}
