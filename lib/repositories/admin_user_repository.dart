import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophthal_vivaedge/models/user_model.dart';
import 'package:ophthal_vivaedge/services/api_client.dart';

class AdminUserRepository {
  final ApiClient _apiClient;

  AdminUserRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<UserModel>> getAllUsers() async {
    final response = await _apiClient.get('/admin/users');
    if (response is List) {
      return response
          .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<UserModel> getUserById(int id) async {
    final response = await _apiClient.get('/admin/users/$id');
    return UserModel.fromJson(response as Map<String, dynamic>);
  }

  Future<UserModel> updateUser(
    int id, {
    required String name,
    required String phone,
    required String role,
  }) async {
    final response = await _apiClient.put(
      '/admin/users/$id',
      body: {
        'name': name.trim(),
        'phone': phone.trim(),
        'role': role.trim().toUpperCase(),
      },
    );
    return UserModel.fromJson(response as Map<String, dynamic>);
  }

  Future<UserModel> updateUserRole(
    int id, {
    required String role,
  }) async {
    final response = await _apiClient.put(
      '/admin/users/$id/role',
      body: {
        'role': role.trim().toUpperCase(),
      },
    );
    return UserModel.fromJson(response as Map<String, dynamic>);
  }

  Future<void> deleteUser(int id) async {
    await _apiClient.delete('/admin/users/$id');
  }
}

final adminUserRepositoryProvider = Provider<AdminUserRepository>((ref) {
  return AdminUserRepository();
});
