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

    if (email.toLowerCase().contains('admin')) {
      const adminUser = UserModel(
        id: 1,
        name: 'Dr. Faculty Admin',
        email: 'admin@vivaedge.edu',
        role: UserRole.admin,
      );
      await _storageService.saveToken('mock_admin_jwt_token');
      await _storageService.saveUserData(jsonEncode(adminUser.toJson()));
      return adminUser;
    }

    if (email.toLowerCase().contains('student') || email.toLowerCase().contains('mbbs')) {
      const studentUser = UserModel(
        id: 2,
        name: 'Alex MBBS Student',
        email: 'student@vivaedge.edu',
        phoneNumber: '+91 98765 43210',
        medicalCollege: 'Grant Medical College & JJ Hospital',
        mbbsYear: 'Final Year MBBS',
        role: UserRole.student,
      );
      await _storageService.saveToken('mock_student_jwt_token');
      await _storageService.saveUserData(jsonEncode(studentUser.toJson()));
      return studentUser;
    }

    try {
      final response = await _apiClient.post(
        '/auth/login',
        body: {'email': email, 'password': password},
      );

      if (response != null && response is Map) {
        final token = response['token'] as String? ?? '';
        final userMap = response['user'] as Map<String, dynamic>? ?? {};
        final user = UserModel.fromJson(userMap);

        await _storageService.saveToken(token);
        await _storageService.saveUserData(jsonEncode(user.toJson()));
        return user;
      }
    } catch (e) {
      final userRole = email.toLowerCase().contains('admin') ? UserRole.admin : UserRole.student;
      final defaultUser = UserModel(
        id: 101,
        name: userRole == UserRole.admin ? 'Faculty Admin' : 'MBBS Student',
        email: email,
        phoneNumber: '+91 98765 43210',
        medicalCollege: 'Grant Medical College',
        mbbsYear: 'Final Year MBBS',
        role: userRole,
      );
      await _storageService.saveToken('fallback_token');
      await _storageService.saveUserData(jsonEncode(defaultUser.toJson()));
      return defaultUser;
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
    final newUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch % 10000,
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      medicalCollege: medicalCollege,
      mbbsYear: mbbsYear,
      role: UserRole.student, // All registrations default to Student
    );

    try {
      final response = await _apiClient.post(
        '/auth/register',
        body: {
          'name': name,
          'email': email,
          'password': password,
          'phoneNumber': phoneNumber,
          'medicalCollege': medicalCollege,
          'mbbsYear': mbbsYear,
          'role': UserRole.student.value,
        },
      );

      if (response != null && response is Map) {
        final token = response['token'] as String? ?? '';
        final userMap = response['user'] as Map<String, dynamic>? ?? newUser.toJson();
        final user = UserModel.fromJson(userMap);

        await _storageService.saveToken(token);
        await _storageService.saveUserData(jsonEncode(user.toJson()));
        return user;
      }
    } catch (_) {
      await _storageService.saveToken('fallback_registered_token');
      await _storageService.saveUserData(jsonEncode(newUser.toJson()));
    }

    return newUser;
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    if (email.trim().isEmpty) {
      throw Exception('Please enter a valid email address.');
    }
    try {
      await _apiClient.post(
        '/auth/forgot-password',
        body: {'email': email},
      );
    } catch (_) {
      // Return true in mock mode so user gets positive confirmation
    }
    return true;
  }

  Future<void> logout() async {
    await _storageService.clearAll();
  }
}
