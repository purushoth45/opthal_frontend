import 'dart:convert';
import 'package:ophthal_vivaedge/core/enums/user_role.dart';
import 'package:ophthal_vivaedge/models/user_model.dart';
import 'package:ophthal_vivaedge/services/api_client.dart';
import 'package:ophthal_vivaedge/services/secure_storage_service.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final SecureStorageService _storageService;

  AuthRepository({
    ApiClient? apiClient,
    SecureStorageService? storageService,
  })  : _apiClient = apiClient ?? ApiClient(),
        _storageService = storageService ?? SecureStorageService();

  Future<UserModel?> getSavedUserSession() async {
    try {
      final userJson = await _storageService.getUserData();
      if (userJson != null && userJson.isNotEmpty) {
        return UserModel.fromJson(jsonDecode(userJson));
      }
    } catch (_) {}
    return null;
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password are required.');
    }

    final response = await _apiClient.post(
      '/auth/login',
      body: {'email': email, 'password': password},
    );

    if (response != null && response is Map) {
      final token = response['token'] as String? ?? '';
      if (token.isEmpty) {
        throw Exception('Login failed: Token not found.');
      }

      await _storageService.saveToken(token);

      // Retrieve full user profile
      final profileResponse = await _apiClient.get('/users/profile');
      final user = UserModel.fromJson(profileResponse as Map<String, dynamic>);

      await _storageService.saveUserData(jsonEncode(user.toJson()));
      return user;
    }

    throw Exception('Login failed. Invalid credentials.');
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required String medicalCollege,
    required String mbbsYear,
  }) async {
    final response = await _apiClient.post(
      '/auth/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
        'confirmPassword': password,
        'phone': phoneNumber,
      },
    );

    if (response != null) {
      final resStr = response.toString();
      if (resStr.contains('already registered') || resStr.contains('Email already registered')) {
        throw Exception('Email is already registered.');
      }
      if (resStr.contains('Passwords do not match')) {
        throw Exception('Passwords do not match.');
      }

      // Auto login after successful registration
      return await login(email: email, password: password);
    }

    throw Exception('Registration failed.');
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    if (email.trim().isEmpty) {
      throw Exception('Please enter a valid email address.');
    }
    final response = await _apiClient.post(
      '/auth/forgot-password',
      body: {'email': email},
    );
    if (response != null && response is Map && response.containsKey('message')) {
      return true;
    }
    return true;
  }

  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    if (token.isEmpty || newPassword.isEmpty) {
      throw Exception('Token and new password are required.');
    }
    await _apiClient.post(
      '/auth/reset-password',
      body: {
        'token': token,
        'newPassword': newPassword,
      },
    );
    return true;
  }

  Future<UserModel> updateProfile({
    required String name,
    required String phoneNumber,
  }) async {
    final response = await _apiClient.put(
      '/users/profile',
      body: {
        'name': name,
        'phone': phoneNumber,
      },
    );
    if (response != null && response is Map) {
      final user = UserModel.fromJson(response as Map<String, dynamic>);
      await _storageService.saveUserData(jsonEncode(user.toJson()));
      return user;
    }
    throw Exception('Failed to update profile.');
  }

  Future<void> logout() async {
    await _storageService.clearAll();
  }
}
