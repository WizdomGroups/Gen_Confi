import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' if (dart.library.html) 'package:gen_confi/core/utils/platform_stub.dart' as io;

/// API Environment Configuration
/// 
/// This file centralizes all API endpoint configurations for different environments.
/// Change the [currentEnvironment] to switch between environments.
enum ApiEnvironment {
  /// For Android Emulator - uses 10.0.2.2 to access host machine
  emulator,
  
  /// For USB-connected physical device - uses 127.0.0.1 with ADB port forwarding
  local,
  
  /// Development server (e.g., staging server)
  development,
  
  /// Production server
  production,
}

class ApiConfig {
  // ============================================
  // ENVIRONMENT CONFIGURATION
  // ============================================
  
  /// Change this to switch between environments
  /// 
  /// Options:
  /// - [ApiEnvironment.emulator] - For Android Emulator
  /// - [ApiEnvironment.local] - For USB-connected device (requires ADB port forwarding)
  /// - [ApiEnvironment.development] - Development/staging server
  /// - [ApiEnvironment.production] - Production server
  static const ApiEnvironment currentEnvironment = ApiEnvironment.local;
  
  // ============================================
  // BASE URL CONFIGURATIONS
  // ============================================
  
  /// Emulator base URL (Android Emulator)
  /// Uses 10.0.2.2 which maps to host machine's localhost
  static const String emulatorBaseUrl = 'http://10.0.2.2:8000/api/v1';
  
  /// Local base URL (USB-connected device with ADB port forwarding)
  /// Uses 127.0.0.1 which requires ADB port forwarding: adb reverse tcp:8000 tcp:8000
  /// For WiFi-connected devices on same network, use your computer's IP instead
  /// To find your IP: Windows (ipconfig | findstr IPv4) or Linux/Mac (ifconfig | grep inet)
  static const String localBaseUrl = 'http://127.0.0.1:8000/api/v1';
  
  /// Development base URL (staging server)
  /// Update this with your development server URL
  static const String developmentBaseUrl = 'http://dev.example.com:8000/api/v1';
  
  /// Production base URL
  /// Update this with your production server URL
  static const String productionBaseUrl = 'https://api.genconfi.com/api/v1';
  
  // ============================================
  // DYNAMIC BASE URL GETTER
  // ============================================
  
  /// Gets the base URL based on current environment and platform
  static String get baseUrl {
    // Flutter Web - always use localhost (10.0.2.2 doesn't work in browsers)
    if (kIsWeb) {
      return _getWebBaseUrl();
    }
    
    // Mobile platforms
    if (io.Platform.isAndroid || io.Platform.isIOS) {
      return _getMobileBaseUrl();
    }
    
    // Desktop platforms (Windows, macOS, Linux)
    return _getDesktopBaseUrl();
  }
  
  /// Get base URL for Flutter Web
  static String _getWebBaseUrl() {
    switch (currentEnvironment) {
      case ApiEnvironment.emulator:
      case ApiEnvironment.local:
        return 'http://localhost:8000/api/v1';
      case ApiEnvironment.development:
        return developmentBaseUrl;
      case ApiEnvironment.production:
        return productionBaseUrl;
    }
  }
  
  /// Get base URL for mobile platforms (Android/iOS)
  static String _getMobileBaseUrl() {
    switch (currentEnvironment) {
      case ApiEnvironment.emulator:
        return emulatorBaseUrl;
      case ApiEnvironment.local:
        return localBaseUrl;
      case ApiEnvironment.development:
        return developmentBaseUrl;
      case ApiEnvironment.production:
        return productionBaseUrl;
    }
  }
  
  /// Get base URL for desktop platforms
  static String _getDesktopBaseUrl() {
    switch (currentEnvironment) {
      case ApiEnvironment.emulator:
      case ApiEnvironment.local:
        return 'http://localhost:8000/api/v1';
      case ApiEnvironment.development:
        return developmentBaseUrl;
      case ApiEnvironment.production:
        return productionBaseUrl;
    }
  }
  
  // ============================================
  // API ENDPOINTS
  // ============================================
  
  /// Authentication endpoints
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String me = '/auth/me';
  
  /// User endpoints
  static const String users = '/users';
  static String userById(int id) => '/users/$id';
  static const String updateMe = '/users/me';
  static const String uploadAvatar = '/users/me/avatar';
  
      /// Static files
      static const String uploads = '/uploads';

      // ============================================
      // ANALYSIS ENDPOINTS
      // ============================================
      static const String completeAnalysis = '/analysis/complete-analysis';
      static String getAnalysis(int id) => '/analysis/$id';
      static const String getUserAnalyses = '/analysis/';

      // ============================================
      // CONNECTION SETTINGS
      // ============================================
  
  /// Connection timeout duration
  static const Duration connectTimeout = Duration(seconds: 30);
  
  /// Receive timeout duration
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // ============================================
  // UTILITY METHODS
  // ============================================
  
  /// Get full URL for an endpoint
  static String getFullUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
  
  /// Print current configuration (for debugging)
  static void printConfig() {
    print('🔧 [ApiConfig] Current Environment: $currentEnvironment');
    print('🔧 [ApiConfig] Base URL: $baseUrl');
    print('🔧 [ApiConfig] Platform: ${kIsWeb ? "Web" : io.Platform.operatingSystem}');
  }
  
  /// Check if running in production
  static bool get isProduction => currentEnvironment == ApiEnvironment.production;
  
  /// Check if running in development
  static bool get isDevelopment => 
      currentEnvironment == ApiEnvironment.development ||
      currentEnvironment == ApiEnvironment.local ||
      currentEnvironment == ApiEnvironment.emulator;
}

