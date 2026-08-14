import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;

  bool get isListening => _speech.isListening;
  bool get isAvailable => _isInitialized;

  Future<bool> initialize({
    Function(SpeechRecognitionError)? onError,
    Function(String)? onStatus,
  }) async {
    if (_isInitialized) return true;

    final micPermission = await Permission.microphone.request();
    if (!micPermission.isGranted) {
      return false;
    }

    try {
      _isInitialized = await _speech.initialize(
        onError: onError,
        onStatus: onStatus,
      );
    } catch (_) {
      _isInitialized = false;
    }

    return _isInitialized;
  }

  Future<void> startListening({
    required Function(String transcript) onResult,
    required Function() onListeningStarted,
    required Function() onListeningStopped,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        throw Exception('Microphone permission or speech engine unavailable');
      }
    }

    if (_speech.isListening) return;

    onListeningStarted();

    await _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        onResult(result.recognizedWords);
        if (result.finalResult) {
          onListeningStopped();
        }
      },
    );
  }

  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  Future<void> cancelListening() async {
    if (_speech.isListening) {
      await _speech.cancel();
    }
  }
}
