import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophthal_vivaedge/services/secure_storage_service.dart';
import 'package:ophthal_vivaedge/services/tts_service.dart';

class SettingsState {
  final double speechRate;
  final bool autoReadQuestion;
  final bool highContrastTables;
  final ThemeMode themeMode;
  final bool isSpeakingPreview;
  final bool isLoading;

  const SettingsState({
    this.speechRate = 0.5,
    this.autoReadQuestion = false,
    this.highContrastTables = true,
    this.themeMode = ThemeMode.system,
    this.isSpeakingPreview = false,
    this.isLoading = false,
  });

  SettingsState copyWith({
    double? speechRate,
    bool? autoReadQuestion,
    bool? highContrastTables,
    ThemeMode? themeMode,
    bool? isSpeakingPreview,
    bool? isLoading,
  }) {
    return SettingsState(
      speechRate: speechRate ?? this.speechRate,
      autoReadQuestion: autoReadQuestion ?? this.autoReadQuestion,
      highContrastTables: highContrastTables ?? this.highContrastTables,
      themeMode: themeMode ?? this.themeMode,
      isSpeakingPreview: isSpeakingPreview ?? this.isSpeakingPreview,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SettingsViewModel extends StateNotifier<SettingsState> {
  final SecureStorageService _storage;
  final TtsService _ttsService;

  SettingsViewModel({
    SecureStorageService? storage,
    TtsService? ttsService,
  })  : _storage = storage ?? SecureStorageService(),
        _ttsService = ttsService ?? TtsService(),
        super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final rate = await _storage.getTtsSpeechRate();
    final autoRead = await _storage.getAutoReadQuestion();
    final mode = await _storage.getThemeMode();
    final highContrast = await _storage.getHighContrastTables();

    await _ttsService.init(rate);

    state = state.copyWith(
      speechRate: rate,
      autoReadQuestion: autoRead,
      highContrastTables: highContrast,
      themeMode: mode,
    );
  }

  Future<void> setSpeechRate(double rate) async {
    state = state.copyWith(speechRate: rate);
    await _ttsService.setSpeechRate(rate);
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

  Future<void> toggleHighContrastTables(bool val) async {
    state = state.copyWith(highContrastTables: val);
    await _storage.saveHighContrastTables(val);
  }

  Future<void> previewSpeech() async {
    if (state.isSpeakingPreview) {
      await _ttsService.stop();
      state = state.copyWith(isSpeakingPreview: false);
      return;
    }

    state = state.copyWith(isSpeakingPreview: true);
    await _ttsService.setSpeechRate(state.speechRate);
    await _ttsService.speak(
      'Text to speech playback at ${(state.speechRate * 100).round()} percent speed.',
      onComplete: () {
        state = state.copyWith(isSpeakingPreview: false);
      },
    );
  }

  Future<void> stopPreview() async {
    await _ttsService.stop();
    state = state.copyWith(isSpeakingPreview: false);
  }
}

final settingsStorageProvider = Provider<SecureStorageService>((ref) => SecureStorageService());

final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService();
  service.init();
  return service;
});

final settingsViewModelProvider = StateNotifierProvider<SettingsViewModel, SettingsState>((ref) {
  return SettingsViewModel(
    storage: ref.watch(settingsStorageProvider),
    ttsService: ref.watch(ttsServiceProvider),
  );
});

