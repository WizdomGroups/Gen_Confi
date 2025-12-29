import 'package:flutter/material.dart';

class AppColors {
  // Instagram Gradient Colors (#833AB4 → #FD1D1D → #F77737) - Same for both themes
  static const Color gradientStart = Color(0xFF833AB4); // Purple
  static const Color gradientMid = Color(0xFFFD1D1D); // Red
  static const Color gradientEnd = Color(0xFFF77737); // Orange

  // Primary brand gradient (use sparingly for CTAs, active states, splash)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [gradientStart, gradientMid, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Single color primary (for non-gradient use)
  static const Color primary = gradientStart; // Purple as base primary
  static const Color primaryLight = gradientEnd; // Orange as accent

  // Legacy alias for compatibility
  static const Color accent = primary;

  // Status Colors (Same for both themes)
  static const Color success = Color(0xFF2DBE7F);
  static const Color error = Color(0xFFE5484D);
  static const Color warning = Color(0xFFF4B740);
  static const Color white = Color(0xFFFFFFFF);

  // ========== DARK THEME COLORS ==========
  // Main background: Pure black
  static const Color backgroundDark = Color(0xFF000000); // #000000
  
  // Card background: Dark gray
  static const Color surfaceDark = Color(0xFF121212); // #121212
  
  // Surface elements: Slightly lighter dark gray
  static const Color surfaceElevatedDark = Color(0xFF1E1E1E); // #1E1E1E

  // Text Colors (High contrast for dark mode)
  static const Color textPrimaryDark = Color(0xFFFFFFFF); // White for primary text
  static const Color textSecondaryDark = Color(0xFFB3B3B3); // Light gray for secondary
  static const Color textMutedDark = Color(0xFF808080); // Medium gray for muted

  // Borders (Subtle for dark theme)
  static const Color borderDark = Color(0xFF2A2A2A); // Dark border
  static const Color dividerDark = Color(0xFF2A2A2A); // Dark divider

  // ========== LIGHT THEME COLORS ==========
  // Main background: White
  static const Color backgroundLight = Color(0xFFFFFFFF); // #FFFFFF
  
  // Card background: Light gray
  static const Color surfaceLight = Color(0xFFF5F5F5); // #F5F5F5
  
  // Surface elements: Slightly darker light gray
  static const Color surfaceElevatedLight = Color(0xFFE8E8E8); // #E8E8E8

  // Text Colors (High contrast for light mode)
  static const Color textPrimaryLight = Color(0xFF000000); // Black for primary text
  static const Color textSecondaryLight = Color(0xFF4A4A4A); // Dark gray for secondary
  static const Color textMutedLight = Color(0xFF808080); // Medium gray for muted

  // Borders (Subtle for light theme)
  static const Color borderLight = Color(0xFFE0E0E0); // Light border
  static const Color dividerLight = Color(0xFFE0E0E0); // Light divider

  // ========== BACKWARD COMPATIBILITY - Defaults to dark theme ==========
  // These constants are for legacy code compatibility
  // For theme-aware colors, use Theme.of(context) or the getColor methods below
  static const Color background = backgroundDark;
  static const Color surface = surfaceDark;
  static const Color surfaceElevated = surfaceElevatedDark;
  static const Color textPrimary = textPrimaryDark;
  static const Color textSecondary = textSecondaryDark;
  static const Color textMuted = textMutedDark;
  static const Color textInverse = Color(0xFF000000);
  static const Color border = borderDark;
  static const Color divider = dividerDark;

  // ========== THEME-AWARE METHODS ==========
  // These methods return the appropriate color based on theme
  // Use these when you need theme-aware colors
  static Color getBackground(bool isDark) => isDark ? backgroundDark : backgroundLight;
  static Color getSurface(bool isDark) => isDark ? surfaceDark : surfaceLight;
  static Color getSurfaceElevated(bool isDark) => isDark ? surfaceElevatedDark : surfaceElevatedLight;
  static Color getTextPrimary(bool isDark) => isDark ? textPrimaryDark : textPrimaryLight;
  static Color getTextSecondary(bool isDark) => isDark ? textSecondaryDark : textSecondaryLight;
  static Color getTextMuted(bool isDark) => isDark ? textMutedDark : textMutedLight;
  static Color getBorder(bool isDark) => isDark ? borderDark : borderLight;
  static Color getDivider(bool isDark) => isDark ? dividerDark : dividerLight;
}
