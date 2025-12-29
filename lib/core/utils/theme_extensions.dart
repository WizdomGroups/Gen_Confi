import 'package:flutter/material.dart';
import 'package:gen_confi/core/constants/app_colors.dart';

/// Extension to easily get theme-aware colors from context
/// Uses Theme.of(context).brightness for reactivity
extension ThemeColors on BuildContext {
  /// Get current theme mode from Theme
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Theme-aware background color
  Color get themeBackground => AppColors.getBackground(isDarkMode);

  /// Theme-aware surface color
  Color get themeSurface => AppColors.getSurface(isDarkMode);

  /// Theme-aware elevated surface color
  Color get themeSurfaceElevated => AppColors.getSurfaceElevated(isDarkMode);

  /// Theme-aware primary text color
  Color get themeTextPrimary => AppColors.getTextPrimary(isDarkMode);

  /// Theme-aware secondary text color
  Color get themeTextSecondary => AppColors.getTextSecondary(isDarkMode);

  /// Theme-aware muted text color
  Color get themeTextMuted => AppColors.getTextMuted(isDarkMode);

  /// Theme-aware border color
  Color get themeBorder => AppColors.getBorder(isDarkMode);

  /// Theme-aware divider color
  Color get themeDivider => AppColors.getDivider(isDarkMode);
}

