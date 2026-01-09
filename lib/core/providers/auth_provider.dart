import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_confi/core/models/user_model.dart';
import 'package:gen_confi/core/providers/api_providers.dart';
import 'package:gen_confi/core/services/auth_service.dart';
import 'package:gen_confi/core/storage/token_storage.dart';
import 'package:gen_confi/services/auth_store.dart';

// Auth State
class AuthState {
  final bool isAuthenticated;
  final UserModel? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.isAuthenticated = false,
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    UserModel? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState()) {
    _checkAuthStatus();
  }

  /// Check if user is already logged in
  Future<void> _checkAuthStatus() async {
    try {
      state = state.copyWith(isLoading: true);

      final isLoggedIn = await TokenStorage.isLoggedIn();
      if (isLoggedIn) {
        // 1. First, try to load from local storage for instant access
        final userJson = await TokenStorage.getUser();
        if (userJson != null) {
          try {
            final userData = jsonDecode(userJson);
            final storedUser = UserModel.fromJson(userData);

            print('📱 Loading cached user: ${storedUser.email}');

            // Sync legacy AuthStore
            AuthStore().signup(storedUser.email, "", _mapRole(storedUser.role));

            // Set state immediately with cached user to avoid login screen
            state = state.copyWith(
              isAuthenticated: true,
              user: storedUser,
              isLoading: true, // Still loading background refresh
            );
          } catch (e) {
            print('⚠️ Error parsing cached user: $e');
          }
        }

        // 2. Perform background refresh from API
        try {
          final user = await _authService.getCurrentUser();
          print('✅ Background Refresh Successful: ${user.email}');

          // Sync legacy AuthStore
          AuthStore().signup(user.email, "", _mapRole(user.role));

          state = state.copyWith(
            isAuthenticated: true,
            user: user,
            isLoading: false,
          );
        } catch (e) {
          // If it's a 401/Unauthorized, handle logout.
          // If it's just a network error, keep current state (don't logout).
          print('⚠️ Background Refresh Failed: $e');

          if (e.toString().contains('401') || e.toString().contains('403')) {
            print('🚫 Session expired or invalid token');
            await _authService.logout();
            AuthStore().logout(); // Sync legacy
            state = state.copyWith(
              isAuthenticated: false,
              user: null,
              isLoading: false,
            );
          } else {
            // Keep user logged in with cached data if it's just a connection issue or other non-auth error
            print(
              '📡 Continuing with cached session due to network/server issue',
            );
            state = state.copyWith(isLoading: false);
          }
        }
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  UserRole _mapRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'expert':
        return UserRole.expert;
      case 'client':
      default:
        return UserRole.client;
    }
  }

  /// Login
  Future<bool> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Check for dummy credentials first
      if (email.toLowerCase() == 'user@example.com' && password == 'User') {
        // Create dummy user for testing
        final dummyUser = UserModel(
          id: 1,
          email: 'user@example.com',
          name: 'Test User',
          phone: '1234567890',
          role: 'client',
          avatarUrl: null,
          gender: 'male',
        );

        // Save to token storage for persistence
        await TokenStorage.saveToken('dummy_token_for_testing');
        await TokenStorage.saveUser(jsonEncode(dummyUser.toJson()));
        await TokenStorage.markOnboardingComplete();

        // Sync legacy AuthStore
        AuthStore().signup(dummyUser.email, "", _mapRole(dummyUser.role));
        AuthStore().markOnboardingCompleteForCurrentRole();

        state = state.copyWith(
          isAuthenticated: true,
          user: dummyUser,
          isLoading: false,
        );

        print('✅ Dummy login successful: ${dummyUser.email}');
        return true;
      }

      // Regular API login
      final response = await _authService.login(email, password);

      // Sync legacy AuthStore
      AuthStore().signup(response.user.email, "", _mapRole(response.user.role));

      state = state.copyWith(
        isAuthenticated: true,
        user: response.user,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _formatError(e));
      return false;
    }
  }

  /// Signup
  Future<bool> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String gender,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _authService.signup(
        name: name,
        email: email,
        phone: phone,
        password: password,
        gender: gender,
      );

      // Sync legacy AuthStore
      AuthStore().signup(response.user.email, "", _mapRole(response.user.role));

      state = state.copyWith(
        isAuthenticated: true,
        user: response.user,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _formatError(e));
      return false;
    }
  }

  /// Forgot Password
  Future<bool> forgotPassword(String email) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _authService.forgotPassword(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _formatError(e));
      return false;
    }
  }

  /// Reset Password
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _authService.resetPassword(token, newPassword);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _formatError(e));
      return false;
    }
  }

  /// Update Profile
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final updatedUser = await _authService.updateProfile(data);

      // Sync legacy AuthStore if email or role changed (though usually they don't here)
      AuthStore().signup(updatedUser.email, "", _mapRole(updatedUser.role));

      state = state.copyWith(user: updatedUser, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _formatError(e));
      return false;
    }
  }

  /// Upload Avatar
  Future<bool> uploadAvatar(String filePath) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final updatedUser = await _authService.uploadAvatar(filePath);

      state = state.copyWith(user: updatedUser, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _formatError(e));
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    await _authService.logout();
    AuthStore().logout(); // Clear legacy state
    state = AuthState();
  }

  /// Refresh user data
  Future<void> refreshUser() async {
    try {
      final user = await _authService.getCurrentUser();
      print('♻️ User Data Refreshed: ${user.email}');
      state = state.copyWith(user: user);
    } catch (e) {
      // Don't set global error for background refresh, just log
      print('Failed to refresh user: $e');
    }
  }

  String _formatError(dynamic e) {
    // Simply return string, DioClient usually returns nice messages or we can parse here
    final msg = e.toString();
    if (msg.startsWith('Exception: ')) return msg.substring(11);
    return msg;
  }
}

// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

// Convenience providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});
