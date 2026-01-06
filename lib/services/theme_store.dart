import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeStore {
  // Singleton pattern
  static final ThemeStore _instance = ThemeStore._internal();
  factory ThemeStore() => _instance;
  ThemeStore._internal();

  static const String _themeKey = 'is_dark_mode';

  // Theme mode state
  bool _isDarkMode = true; // Default to dark mode
  final ValueNotifier<bool> _themeNotifier = ValueNotifier<bool>(true);

  // Getters
  bool get isDarkMode => _isDarkMode;
  ValueNotifier<bool> get themeNotifier => _themeNotifier;

  /// Toggle theme and persist
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    _themeNotifier.value = _isDarkMode;
    await _saveTheme();
  }

  /// Set theme explicitly and persist
  Future<void> setTheme(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      _themeNotifier.value = _isDarkMode;
      await _saveTheme();
    }
  }

  /// Load theme from local storage
  Future<void> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Default to true (Dark Mode) if not set
      _isDarkMode = prefs.getBool(_themeKey) ?? true;
      _themeNotifier.value = _isDarkMode;
      debugPrint('🎨 Theme loaded: ${_isDarkMode ? "Dark" : "Light"}');
    } catch (e) {
      debugPrint('⚠️ Error loading theme: $e');
    }
  }

  /// Private helper to save theme
  Future<void> _saveTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isDarkMode);
    } catch (e) {
      debugPrint('⚠️ Error saving theme: $e');
    }
  }
}
