import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_confi/core/api/dio_client.dart';
import 'package:gen_confi/core/services/auth_service.dart';
import 'package:gen_confi/core/services/user_service.dart';

// Dio Client Provider
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

