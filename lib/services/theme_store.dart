import 'package:flutter/material.dart';

class ThemeStore {
  // Singleton pattern
  static final ThemeStore _instance = ThemeStore._internal();
  factory ThemeStore() => _instance;
  ThemeStore._internal();

  // Theme mode state
  bool _isDarkMode = true; // Default to dark mode
  final ValueNotifier<bool> _themeNotifier = ValueNotifier<bool>(true);

  // Getters
  bool get isDarkMode => _isDarkMode;
  ValueNotifier<bool> get themeNotifier => _themeNotifier;

  // Toggle theme
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _themeNotifier.value = _isDarkMode;
    // TODO: Persist theme preference to local storage (SharedPreferences)
  }

  // Set theme explicitly
  void setTheme(bool isDark) {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      _themeNotifier.value = _isDarkMode;
    }
  }

  // Load theme from storage (for future implementation)
  Future<void> loadTheme() async {
    // TODO: Load from SharedPreferences
    // For now, default to dark mode
    _isDarkMode = true;
    _themeNotifier.value = _isDarkMode;
  }

  // Save theme to storage (for future implementation)
  Future<void> saveTheme() async {
    // TODO: Save to SharedPreferences
  }
}

