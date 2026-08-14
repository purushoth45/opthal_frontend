import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophthal_vivaedge/services/secure_storage_service.dart';

class SettingsState {
  final double speechRate;
  final bool autoReadQuestion;
  final bool highContrastTables;
  final ThemeMode themeMode;
  final bool isLoading;

  const SettingsState({
    this.speechRate = 0.48,
    this.autoReadQuestion = false,
    this.highContrastTables = true,
    this.themeMode = ThemeMode.system,
    this.isLoading = false,
  });

  SettingsState copyWith({
    double? speechRate,
    bool? autoReadQuestion,
    bool? highContrastTables,
    ThemeMode? themeMode,
    bool? isLoading,
  }) {
    return SettingsState(
      speechRate: speechRate ?? this.speechRate,
      autoReadQuestion: autoReadQuestion ?? this.autoReadQuestion,
      highContrastTables: highContrastTables ?? this.highContrastTables,
      themeMode: themeMode ?? this.themeMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SettingsViewModel extends StateNotifier<SettingsState> {
  final SecureStorageService _storage;

  SettingsViewModel({SecureStorageService? storage})
      : _storage = storage ?? SecureStorageService(),
        super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final rate = await _storage.getTtsSpeechRate();
    final autoRead = await _storage.getAutoReadQuestion();
    final mode = await _storage.getThemeMode();
    state = state.copyWith(
      speechRate: rate,
      autoReadQuestion: autoRead,
      themeMode: mode,
    );
  }

  Future<void> setSpeechRate(double rate) async {
    state = state.copyWith(speechRate: rate);
    await _storage.saveTtsSpeechRate(rate);
  }

  Future<void> setAutoReadQuestion(bool val) async {
    state = state.copyWith(autoReadQuestion: val);
    await _storage.saveAutoReadQuestion(val);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _storage.saveThemeMode(mode);
  }

  void toggleHighContrastTables(bool val) {
    state = state.copyWith(highContrastTables: val);
  }
}

final settingsStorageProvider = Provider<SecureStorageService>((ref) => SecureStorageService());

final settingsViewModelProvider = StateNotifierProvider<SettingsViewModel, SettingsState>((ref) {
  return SettingsViewModel(storage: ref.watch(settingsStorageProvider));
});
