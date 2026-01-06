import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_confi/core/models/user_model.dart';
import 'package:gen_confi/core/providers/api_providers.dart';

// Users List Provider
final usersListProvider = FutureProvider.family<List<UserModel>, ({
  int skip,
  int limit,
})>((ref, params) async {
  final userService = ref.watch(userServiceProvider);
  return await userService.getUsers(
    skip: params.skip,
    limit: params.limit,
  );
});

// User by ID Provider
final userByIdProvider = FutureProvider.family<UserModel, int>((ref, id) async {
  final userService = ref.watch(userServiceProvider);
  return await userService.getUserById(id);
});

// User Update Notifier
class UserUpdateNotifier extends StateNotifier<AsyncValue<UserModel>> {
  final UserService _userService;
  final int _userId;

  UserUpdateNotifier(this._userService, this._userId)
      : super(const AsyncValue.loading()) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await _userService.getUserById(_userId);
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateUser(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      final user = await _userService.updateUser(_userId, data);
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteUser() async {
    state = const AsyncValue.loading();
    try {
      await _userService.deleteUser(_userId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final userUpdateProvider = StateNotifierProvider.family<
    UserUpdateNotifier, AsyncValue<UserModel>, int>((ref, userId) {
  final userService = ref.watch(userServiceProvider);
  return UserUpdateNotifier(userService, userId);
});

