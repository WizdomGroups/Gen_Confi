import 'package:flutter/material.dart';
import 'package:gen_confi/core/constants/app_colors.dart';
import 'package:gen_confi/core/utils/theme_extensions.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double? width;
  final Color? borderColor;
  final Color? backgroundColor;
  final bool showShadow;

  const AppCard({
    super.key,
    required this.child,
    this.title,
    this.padding,
    this.onTap,
    this.width,
    this.borderColor,
    this.backgroundColor,
    this.showShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(
          16,
        ), // Increased for a more modern, friendly look
        border: Border.all(
          color: borderColor ?? context.themeBorder.withOpacity(0.8),
          width: 1.5,
        ),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: context.themeTextPrimary.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.primary.withValues(alpha: 0.05),
          highlightColor: Colors.transparent,
          child: Padding(
            padding:
                padding ??
                const EdgeInsets.all(
                  20.0,
                ), // Generous padding for a "airy" feel
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: 16, // Standardized for UI readability
                      fontWeight: FontWeight.w700,
                      color: context.themeTextPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
