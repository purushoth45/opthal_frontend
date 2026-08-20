import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ophthal_vivaedge/core/constants/app_colors.dart';
import 'package:ophthal_vivaedge/core/enums/viva_voice_state.dart';
import 'package:ophthal_vivaedge/shared/widgets/error_view.dart';
import 'package:ophthal_vivaedge/shared/widgets/loading_view.dart';
import 'package:ophthal_vivaedge/viewmodels/viva_viewmodel.dart';
import 'package:ophthal_vivaedge/views/widgets/answer_content_renderer.dart';
import 'package:ophthal_vivaedge/views/widgets/app_background_wrapper.dart';

class VivaView extends ConsumerWidget {
  const VivaView({super.key});

  String _formatTimer(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vivaState = ref.watch(vivaViewModelProvider);
    final viewModel = ref.read(vivaViewModelProvider.notifier);

    const primaryTextColor = Colors.white;
    final secondaryTextColor = Colors.white.withOpacity(0.85);

    // 25% opacity fill = 75% background gradient visibility
    final cardBg = Colors.white.withOpacity(0.25);
    final cardBorder = Colors.white.withOpacity(0.35);

    if (vivaState.voiceState == VivaVoiceState.questionLoading) {
      return const Scaffold(
        body: LoadingView(message: 'Initializing Voice Viva Voce Engine...'),
      );
    }

    if (vivaState.errorMessage != null && vivaState.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Voice Viva')),
        body: ErrorView(
          message: vivaState.errorMessage!,
          onRetry: () => viewModel.loadQuestions(),
        ),
      );
    }

    final question = vivaState.currentQuestion;
    if (question == null) {
      return const Scaffold(
        body: Center(child: Text('No question available.')),
      );
    }

    final progress = (vivaState.currentIndex + 1) / vivaState.totalQuestions;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Interactive Voice Viva',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
                child: Text(
                  'Q${(vivaState.currentIndex + 1).toString().padLeft(2, '0')} / ${vivaState.totalQuestions.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: AppBackgroundWrapper(
        child: SafeArea(
          child: Column(
            children: [
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white24,
                color: Colors.white,
                minHeight: 3,
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // QUESTION CARD
                          ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(color: cardBorder, width: 1.2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.12),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(22.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.25),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            question.topic.toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.psychology_outlined, size: 16, color: Colors.white),
                                            const SizedBox(width: 4),
                                            Text(
                                              'MBBS Viva',
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                color: secondaryTextColor,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      question.questionText,
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            color: primaryTextColor,
                                            fontWeight: FontWeight.bold,
                                            height: 1.35,
                                            fontSize: 19,
                                          ),
                                    ),
                                    const SizedBox(height: 18),

                                    Center(
                                      child: OutlinedButton.icon(
                                        onPressed: () => viewModel.listenToQuestion(),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: Colors.white, width: 1.5),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                        ),
                                        icon: Icon(
                                          vivaState.voiceState == VivaVoiceState.speakingQuestion
                                              ? Icons.volume_off_rounded
                                              : Icons.volume_up_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        label: Text(
                                          vivaState.voiceState == VivaVoiceState.speakingQuestion
                                              ? 'Pause Question Audio'
                                              : 'Listen to Question Audio 🔊',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // SPEECH RECOGNITION CARD
                          ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: vivaState.voiceState == VivaVoiceState.listening
                                        ? AppColors.recordingRed
                                        : cardBorder,
                                    width: vivaState.voiceState == VivaVoiceState.listening ? 1.5 : 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: vivaState.voiceState == VivaVoiceState.listening
                                          ? AppColors.recordingRed.withOpacity(0.2)
                                          : Colors.black.withOpacity(0.12),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(22.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.mic_none_rounded,
                                              size: 20,
                                              color: vivaState.voiceState == VivaVoiceState.listening
                                                  ? AppColors.recordingRed
                                                  : secondaryTextColor,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'YOUR SPOKEN TRANSCRIPT',
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.bold,
                                                color: vivaState.voiceState == VivaVoiceState.listening
                                                    ? AppColors.recordingRed
                                                    : secondaryTextColor,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (vivaState.voiceState == VivaVoiceState.listening) ...[
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.recordingRed.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: const BoxDecoration(
                                                    color: AppColors.recordingRed,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  _formatTimer(vivaState.recordingSeconds),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 14),

                                    Container(
                                      width: double.infinity,
                                      constraints: const BoxConstraints(minHeight: 90),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.18),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                                      ),
                                      child: SelectableText(
                                        vivaState.spokenTranscript.isEmpty
                                            ? 'Tap "SPEAK NOW" and recite your viva answer clearly...'
                                            : vivaState.spokenTranscript,
                                        style: TextStyle(
                                          color: vivaState.spokenTranscript.isEmpty
                                              ? Colors.white70
                                              : Colors.white,
                                          fontStyle: vivaState.spokenTranscript.isEmpty
                                              ? FontStyle.italic
                                              : FontStyle.normal,
                                          fontSize: 15,
                                          height: 1.45,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    Center(
                                      child: vivaState.voiceState == VivaVoiceState.listening
                                          ? ElevatedButton.icon(
                                              onPressed: () => viewModel.stopRecording(),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.recordingRed,
                                                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(24),
                                                ),
                                              ),
                                              icon: const Icon(Icons.stop_rounded, size: 22),
                                              label: const Text('STOP RECORDING', style: TextStyle(fontWeight: FontWeight.bold)),
                                            )
                                          : ElevatedButton.icon(
                                              onPressed: () => viewModel.toggleRecording(),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                foregroundColor: AppColors.primaryNavy,
                                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(24),
                                                ),
                                                elevation: 4,
                                              ),
                                              icon: const Icon(Icons.mic_rounded, size: 22, color: AppColors.primaryNavy),
                                              label: const Text(
                                                'SPEAK NOW 🎙',
                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5, color: AppColors.primaryNavy),
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          if (!vivaState.showCorrectAnswer) ...[
                            Center(
                              child: OutlinedButton.icon(
                                onPressed: () => viewModel.toggleShowCorrectAnswer(),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white, width: 1.5),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                icon: const Icon(Icons.visibility_rounded, color: Colors.white),
                                label: const Text(
                                  'SHOW CORRECT VIVA ANSWER',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ),
                            ),
                          ],

                          if (vivaState.showCorrectAnswer) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.12),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(22.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Row(
                                            children: [
                                              Icon(
                                                Icons.check_circle_outline_rounded,
                                                size: 22,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'OFFICIAL VIVA ANSWER',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.close_rounded, size: 18, color: Colors.white),
                                            onPressed: () => viewModel.toggleShowCorrectAnswer(),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 24, color: Colors.white30),

                                      AnswerContentRenderer(
                                        blocks: question.answerBlocks,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (vivaState.currentIndex > 0)
                                OutlinedButton.icon(
                                  onPressed: () => viewModel.previousQuestion(),
                                  icon: const Icon(Icons.arrow_back_rounded, size: 18, color: Colors.white),
                                  label: const Text('Previous', style: TextStyle(color: Colors.white)),
                                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white54)),
                                )
                              else
                                const SizedBox.shrink(),
                              ElevatedButton(
                                onPressed: () {
                                  if (vivaState.hasNext) {
                                    viewModel.nextQuestion();
                                  } else {
                                    context.pop();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.primaryNavy,
                                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      vivaState.hasNext ? 'NEXT QUESTION' : 'FINISH SESSION',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      vivaState.hasNext
                                          ? Icons.arrow_forward_rounded
                                          : Icons.check_rounded,
                                      size: 18,
                                      color: AppColors.primaryNavy,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 90),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
