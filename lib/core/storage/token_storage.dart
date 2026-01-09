import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _tokenKey = 'access_token';
  static const String _userKey = 'user_data';
  static const String _onboardingCompleteKey = 'onboarding_complete';

  /// Save access token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Get stored access token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Save user data
  static Future<void> saveUser(String userJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, userJson);
  }

  /// Get stored user data
  static Future<String?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKey);
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Check if onboarding is complete
  static Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompleteKey) ?? false;
  }

  /// Mark onboarding as complete
  static Future<void> markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, true);
  }

  /// Clear onboarding status (for testing or re-onboarding)
  static Future<void> clearOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingCompleteKey);
  }

  /// Clear all stored data (logout)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_onboardingCompleteKey);
  }

  /// Clear only token
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}

