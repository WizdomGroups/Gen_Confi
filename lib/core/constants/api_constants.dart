import 'package:flutter/foundation.dart' show kIsWeb;

// Conditional import - uses dart:io on mobile, stub on web
// ignore: avoid_relative_lib_imports
import 'dart:io'
    if (dart.library.html) 'package:gen_confi/core/utils/platform_stub.dart'
    as io;

class ApiConstants {
  // Base URL - Automatically detects platform
  // For Flutter Web: http://localhost:8000/api/v1
  // For Android Emulator: http://10.0.2.2:8000/api/v1
  // For iOS Simulator: http://localhost:8000/api/v1
  // For Physical Device: Use your computer's IP (e.g., http://192.168.x.x:8000/api/v1)

  static String get baseUrl {
    // Flutter Web - MUST use localhost (10.0.2.2 doesn't work in browsers)
    if (kIsWeb) {
      final url = 'http://localhost:8000/api/v1';
      // print('🌐 [ApiConstants] Flutter Web detected - Using: $url');
      return url;
    }

    // Mobile platforms - check if Android
    // On mobile, io will be dart:io, so Platform.isAndroid will work
    if (io.Platform.isAndroid) {
      // Use computer's IP for physical device
      final url = 'http://10.20.190.66:8000/api/v1';
      // final url = 'http://10.0.2.2:8000/api/v1'; // Emulator
      // print('📱 [ApiConstants] Android detected - Using: $url');
      return url;
    }

    // iOS or other - use localhost
    final url = 'http://localhost:8000/api/v1';
    // print('📱 [ApiConstants] iOS/Other detected - Using: $url');
    return url;
  }

  // Auth endpoints
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String me = '/auth/me';

  // User endpoints
  static const String users = '/users';
  static String userById(int id) => '/users/$id';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
