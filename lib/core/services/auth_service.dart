import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:gen_confi/core/api/api_endpoints.dart';
import 'package:gen_confi/core/api/dio_client.dart';
import 'package:gen_confi/core/models/auth_models.dart';
import 'package:gen_confi/core/models/user_model.dart';
import 'package:gen_confi/core/storage/token_storage.dart';

class AuthService {
  final DioClient _dioClient;

  AuthService(this._dioClient);

  /// Login user
  Future<LoginResponse> login(String email, String password) async {
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _dioClient.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );

      final loginResponse = LoginResponse.fromJson(response.data);

      // Save token and user data
      await TokenStorage.saveToken(loginResponse.accessToken);
      await TokenStorage.saveUser(jsonEncode(loginResponse.user.toJson()));

      print(
        '✅ Login Successful: ${loginResponse.user.email} (ID: ${loginResponse.user.id})',
      );
      return loginResponse;
    } catch (e) {
      rethrow;
    }
  }

  /// Signup new user
  Future<LoginResponse> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String gender,
  }) async {
    try {
      final request = SignupRequest(
        name: name,
        email: email,
        phone: phone,
        password: password,
        gender: gender,
      );

      final response = await _dioClient.post(
        ApiEndpoints.signup,
        data: request.toJson(),
      );

      final loginResponse = LoginResponse.fromJson(response.data);

      // Save token and user data
      await TokenStorage.saveToken(loginResponse.accessToken);
      await TokenStorage.saveUser(jsonEncode(loginResponse.user.toJson()));

      print(
        '✅ Signup Successful: ${loginResponse.user.email} (ID: ${loginResponse.user.id})',
      );
      return loginResponse;
    } catch (e) {
      rethrow;
    }
  }

  /// Get current user
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.me);
      final user = UserModel.fromJson(response.data);
      // Sync local storage
      await TokenStorage.saveUser(jsonEncode(user.toJson()));
      return user;
    } catch (e) {
      rethrow;
    }
  }

  /// Update Profile
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.put(ApiEndpoints.updateMe, data: data);
      final user = UserModel.fromJson(response.data);
      // Sync local storage
      await TokenStorage.saveUser(jsonEncode(user.toJson()));
      return user;
    } catch (e) {
      rethrow;
    }
  }

  /// Upload Avatar
  Future<UserModel> uploadAvatar(String filePath) async {
    try {
      String fileName = filePath.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _dioClient.post(
        ApiEndpoints.uploadAvatar,
        data: formData,
      );
      final user = UserModel.fromJson(response.data);
      // Sync local storage
      await TokenStorage.saveUser(jsonEncode(user.toJson()));
      return user;
    } catch (e) {
      rethrow;
    }
  }

  /// Forgot Password
  Future<void> forgotPassword(String email) async {
    try {
      await _dioClient.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Reset Password
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await _dioClient.post(
        ApiEndpoints.resetPassword,
        data: {'token': token, 'new_password': newPassword},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Logout user
  Future<void> logout() async {
    await TokenStorage.clearAll();
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await TokenStorage.isLoggedIn();
  }
}
