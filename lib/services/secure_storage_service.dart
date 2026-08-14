import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'user_data';
  static const String _keyOnboarding = 'completed_onboarding';
  static const String _keyTtsRate = 'tts_speech_rate';
  static const String _keyAutoRead = 'auto_read_question';
  static const String _keyThemeMode = 'app_theme_mode';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  Future<void> saveUserData(String userJson) async {
    await _storage.write(key: _keyUser, value: userJson);
  }

  Future<String?> getUserData() async {
    return await _storage.read(key: _keyUser);
  }

  Future<void> setCompletedOnboarding(bool completed) async {
    await _storage.write(key: _keyOnboarding, value: completed.toString());
  }

  Future<bool> hasCompletedOnboarding() async {
    final val = await _storage.read(key: _keyOnboarding);
    return val == 'true';
  }

  Future<void> saveTtsSpeechRate(double rate) async {
    await _storage.write(key: _keyTtsRate, value: rate.toString());
  }

  Future<double> getTtsSpeechRate() async {
    final val = await _storage.read(key: _keyTtsRate);
    if (val != null) return double.tryParse(val) ?? 0.48;
    return 0.48;
  }

  Future<void> saveAutoReadQuestion(bool autoRead) async {
    await _storage.write(key: _keyAutoRead, value: autoRead.toString());
  }

  Future<bool> getAutoReadQuestion() async {
    final val = await _storage.read(key: _keyAutoRead);
    return val == 'true';
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    await _storage.write(key: _keyThemeMode, value: mode.name);
  }

  Future<ThemeMode> getThemeMode() async {
    final val = await _storage.read(key: _keyThemeMode);
    if (val == 'dark') return ThemeMode.dark;
    if (val == 'light') return ThemeMode.light;
    return ThemeMode.system;
  }

  Future<void> clearAll() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyUser);
  }
}
