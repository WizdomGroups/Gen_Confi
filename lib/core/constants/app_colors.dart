import 'package:flutter/material.dart';

class AppColors {
  // Fitness App Inspired Palette
  static const Color background = Color(0xFFFFFFFF); // White
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color white = Color(0xFFFFFFFF);

  // Teal Blue Gradient (#0085A1 to #00BCD4)
  static const Color primary = Color(0xFF0085A1); // Base Teal Blue
  static const Color primaryLight = Color(0xFF00BCD4); // Lighter Cyan-Teal

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0085A1), Color(0xFF00BCD4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color skyBlue = Color(0xFFE0F7FA); // Soft Sky Blue Accent

  // Legacy alias for compatibility
  static const Color accent = primary;

  // Pastel Support Colors (Limited use)
  static const Color lavender = Color(0xFFDCD2FF);
  static const Color mint = Color(0xFF7ED9A7);
  static const Color lime = Color(0xFFC7F35A);
  static const Color cream = Color(0xFFF4EBDD);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF6B7280); // Slate 500
  static const Color textMuted = Color(0xFF9CA3AF); // Slate 400
  static const Color textInverse = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF2DBE7F);
  static const Color error = Color(0xFFE5484D);
  static const Color warning = Color(0xFFF4B740);

  // Borders
  static const Color border = Color(0xFFE5E7EB); // Slate 200
  static const Color divider = Color(0xFFF3F4F6);
}
