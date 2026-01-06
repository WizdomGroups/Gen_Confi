import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_confi/core/models/user_model.dart';
import 'package:gen_confi/core/providers/api_providers.dart';
import 'package:gen_confi/core/services/auth_service.dart';
import 'package:gen_confi/core/storage/token_storage.dart';

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
        // Try to get current user to verify token is valid
        try {
          final user = await _authService.getCurrentUser();

          // Also check stored user data
          // final userJson = await TokenStorage.getUser();
          // UserModel? storedUser;
          // if (userJson != null) {
          //   final userData = jsonDecode(userJson);
          //   storedUser = UserModel.fromJson(userData);
          // }

          print('✅ Auto-Login Successful: ${user.email} (${user.role})');

          state = state.copyWith(
            isAuthenticated: true,
            user: user, // Prefer fetched user over stored
            isLoading: false,
          );
        } catch (e) {
          // Token invalid, clear and logout
          print('⚠️ Auto-Login Failed (Token Invalid): $e');
          await _authService.logout();
          state = state.copyWith(
            isAuthenticated: false,
            user: null,
            isLoading: false,
          );
        }
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Login
  Future<bool> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _authService.login(email, password);

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
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _authService.signup(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

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

  /// Logout
  Future<void> logout() async {
    await _authService.logout();
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
