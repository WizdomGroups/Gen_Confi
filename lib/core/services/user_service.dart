import 'package:gen_confi/core/api/dio_client.dart';
import 'package:gen_confi/core/config/api_config.dart';
import 'package:gen_confi/core/models/user_model.dart';

class UserService {
  final DioClient _dioClient;

  UserService(this._dioClient);

  /// Get all users with pagination
  Future<List<UserModel>> getUsers({
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiConfig.users,
        queryParameters: {
          'skip': skip,
          'limit': limit,
        },
      );

      final List<dynamic> data = response.data;
      return data.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get user by ID
  Future<UserModel> getUserById(int id) async {
    try {
      final response = await _dioClient.get(ApiConfig.userById(id));
      return UserModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update user
  Future<UserModel> updateUser(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.put(
        ApiConfig.userById(id),
        data: data,
      );
      return UserModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete user
  Future<void> deleteUser(int id) async {
    try {
      await _dioClient.delete(ApiConfig.userById(id));
    } catch (e) {
      rethrow;
    }
  }
}

