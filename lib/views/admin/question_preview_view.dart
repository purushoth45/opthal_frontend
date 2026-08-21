import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ophthal_vivaedge/core/constants/app_colors.dart';
import 'package:ophthal_vivaedge/models/question_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophthal_vivaedge/viewmodels/viva_viewmodel.dart';
import 'package:ophthal_vivaedge/shared/widgets/error_view.dart';
import 'package:ophthal_vivaedge/shared/widgets/loading_view.dart';
import 'package:ophthal_vivaedge/views/widgets/answer_content_renderer.dart';

class QuestionPreviewView extends ConsumerStatefulWidget {
  final int questionId;

  const QuestionPreviewView({super.key, required this.questionId});

  @override
  ConsumerState<QuestionPreviewView> createState() => _QuestionPreviewViewState();
}

class _QuestionPreviewViewState extends ConsumerState<QuestionPreviewView> {
  QuestionModel? _question;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = ref.read(questionRepositoryProvider);
      final q = await repo.getQuestionById(widget.questionId);
      setState(() {
        _question = q;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF0F172A) : AppColors.background;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderCol = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
    final primaryText = isDark ? Colors.white : AppColors.primaryNavy;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(
          title: const Text('Question Preview'),
          backgroundColor: isDark ? const Color(0xFF1E293B) : AppColors.primaryNavy,
          foregroundColor: Colors.white,
        ),
        body: const LoadingView(message: 'Loading preview...'),
      );
    }

    if (_error != null || _question == null) {
      return Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(
          title: const Text('Question Preview'),
          backgroundColor: isDark ? const Color(0xFF1E293B) : AppColors.primaryNavy,
          foregroundColor: Colors.white,
        ),
        body: ErrorView(message: _error ?? 'Question not found', onRetry: _fetch),
      );
    }

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text('Preview Q${widget.questionId.toString().padLeft(3, '0')}'),
        backgroundColor: isDark ? const Color(0xFF1E293B) : AppColors.primaryNavy,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.visibility_rounded, color: AppColors.accentBlue, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Student Viva View Preview Mode',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentBlue),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Card(
                    color: cardBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: borderCol, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _question!.questionText,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryText,
                            ),
                          ),
                          Divider(height: 24, color: borderCol),
                          const Text(
                            'CORRECT ANSWER',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(height: 12),

                          AnswerContentRenderer(blocks: _question!.answerBlocks),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
