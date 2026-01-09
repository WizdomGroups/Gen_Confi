import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_confi/core/api/dio_client.dart';
import 'package:gen_confi/core/services/auth_service.dart';
import 'package:gen_confi/core/services/user_service.dart';
import 'package:gen_confi/core/services/analysis_service.dart';

// Dio Client Provider
// Note: This provider is cached. To refresh after changing baseUrl,
// you MUST do a HOT RESTART (press 'R' in Flutter terminal), not hot reload.
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthService(dioClient);
});

// User Service Provider
final userServiceProvider = Provider<UserService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return UserService(dioClient);
});

// Analysis Service Provider
final analysisServiceProvider = Provider<AnalysisService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AnalysisService(dioClient);
});

