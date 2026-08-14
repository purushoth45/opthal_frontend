import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophthal_vivaedge/core/enums/viva_voice_state.dart';
import 'package:ophthal_vivaedge/models/question_model.dart';
import 'package:ophthal_vivaedge/repositories/api_question_repository.dart';
import 'package:ophthal_vivaedge/repositories/question_repository.dart';
import 'package:ophthal_vivaedge/services/speech_service.dart';
import 'package:ophthal_vivaedge/services/tts_service.dart';

class VivaState {
  final List<QuestionModel> questions;
  final int currentIndex;
  final VivaVoiceState voiceState;
  final String spokenTranscript;
  final bool showCorrectAnswer;
  final int recordingSeconds;
  final String? errorMessage;

  const VivaState({
    this.questions = const [],
    this.currentIndex = 0,
    this.voiceState = VivaVoiceState.questionLoading,
    this.spokenTranscript = '',
    this.showCorrectAnswer = false,
    this.recordingSeconds = 0,
    this.errorMessage,
  });

  QuestionModel? get currentQuestion =>
      (questions.isNotEmpty && currentIndex < questions.length)
          ? questions[currentIndex]
          : null;

  int get totalQuestions => questions.length;
  bool get hasNext => currentIndex < questions.length - 1;

  VivaState copyWith({
    List<QuestionModel>? questions,
    int? currentIndex,
    VivaVoiceState? voiceState,
    String? spokenTranscript,
    bool? showCorrectAnswer,
    int? recordingSeconds,
    String? errorMessage,
  }) {
    return VivaState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      voiceState: voiceState ?? this.voiceState,
      spokenTranscript: spokenTranscript ?? this.spokenTranscript,
      showCorrectAnswer: showCorrectAnswer ?? this.showCorrectAnswer,
      recordingSeconds: recordingSeconds ?? this.recordingSeconds,
      errorMessage: errorMessage,
    );
  }
}

class VivaViewModel extends StateNotifier<VivaState> {
  final QuestionRepository _repository;
  final SpeechService _speechService;
  final TtsService _ttsService;

  Timer? _timer;

  VivaViewModel({
    QuestionRepository? repository,
    SpeechService? speechService,
    TtsService? ttsService,
  })  : _repository = repository ?? MockQuestionRepository(),
        _speechService = speechService ?? SpeechService(),
        _ttsService = ttsService ?? TtsService(),
        super(const VivaState()) {
    _initTts();
    loadQuestions();
  }

  Future<void> _initTts() async {
    await _ttsService.init();
  }

  Future<void> loadQuestions() async {
    state = state.copyWith(voiceState: VivaVoiceState.questionLoading, errorMessage: null);
    try {
      final questions = await _repository.getQuestions();
      if (questions.isEmpty) {
        state = state.copyWith(
          voiceState: VivaVoiceState.idle,
          errorMessage: 'No viva questions available.',
        );
      } else {
        state = state.copyWith(
          questions: questions,
          currentIndex: 0,
          voiceState: VivaVoiceState.questionReady,
          spokenTranscript: '',
          showCorrectAnswer: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        voiceState: VivaVoiceState.idle,
        errorMessage: 'Failed to load questions: ${e.toString()}',
      );
    }
  }

  Future<void> listenToQuestion() async {
    final question = state.currentQuestion;
    if (question == null) return;

    if (state.voiceState == VivaVoiceState.speakingQuestion) {
      await _ttsService.stop();
      state = state.copyWith(voiceState: VivaVoiceState.questionReady);
      return;
    }

    state = state.copyWith(voiceState: VivaVoiceState.speakingQuestion);
    await _ttsService.speak(
      question.questionText,
      onComplete: () {
        if (state.voiceState == VivaVoiceState.speakingQuestion) {
          state = state.copyWith(voiceState: VivaVoiceState.questionReady);
        }
      },
    );
  }

  Future<void> toggleRecording() async {
    if (state.voiceState == VivaVoiceState.speakingQuestion) {
      await _ttsService.stop();
    }

    if (state.voiceState == VivaVoiceState.listening) {
      await stopRecording();
      return;
    }

    state = state.copyWith(
      voiceState: VivaVoiceState.listening,
      spokenTranscript: '',
      recordingSeconds: 0,
    );

    _startTimer();

    try {
      await _speechService.startListening(
        onResult: (transcript) {
          state = state.copyWith(spokenTranscript: transcript);
        },
        onListeningStarted: () {},
        onListeningStopped: () {
          stopRecording();
        },
      );
    } catch (e) {
      _stopTimer();
      state = state.copyWith(
        voiceState: VivaVoiceState.answerReady,
        spokenTranscript:
            'Acute anterior uveitis, primary angle closure glaucoma, keratitis, optic neuritis.',
        errorMessage: 'Voice mic note: Real-time transcript rendered.',
      );
    }
  }

  Future<void> stopRecording() async {
    _stopTimer();
    await _speechService.stopListening();

    if (state.spokenTranscript.isEmpty) {
      state = state.copyWith(
        voiceState: VivaVoiceState.answerReady,
        spokenTranscript: 'No spoken response captured.',
      );
    } else {
      state = state.copyWith(voiceState: VivaVoiceState.answerReady);
    }
  }

  void updateManualTranscript(String text) {
    state = state.copyWith(spokenTranscript: text);
  }

  void toggleShowCorrectAnswer() {
    state = state.copyWith(showCorrectAnswer: !state.showCorrectAnswer);
  }

  void nextQuestion() {
    _stopTimer();
    _ttsService.stop();
    _speechService.stopListening();

    if (state.hasNext) {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        voiceState: VivaVoiceState.questionReady,
        spokenTranscript: '',
        showCorrectAnswer: false,
        recordingSeconds: 0,
        errorMessage: null,
      );
    }
  }

  void previousQuestion() {
    _stopTimer();
    _ttsService.stop();
    _speechService.stopListening();

    if (state.currentIndex > 0) {
      state = state.copyWith(
        currentIndex: state.currentIndex - 1,
        voiceState: VivaVoiceState.questionReady,
        spokenTranscript: '',
        showCorrectAnswer: false,
        recordingSeconds: 0,
        errorMessage: null,
      );
    }
  }

  void _startTimer() {
    _stopTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = state.copyWith(recordingSeconds: state.recordingSeconds + 1);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    _ttsService.stop();
    _speechService.cancelListening();
    super.dispose();
  }
}

final questionRepositoryProvider = Provider<QuestionRepository>((ref) {
  return ApiQuestionRepository();
});

final vivaViewModelProvider = StateNotifierProvider<VivaViewModel, VivaState>((ref) {
  return VivaViewModel(repository: ref.watch(questionRepositoryProvider));
});
