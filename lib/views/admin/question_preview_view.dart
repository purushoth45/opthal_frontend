import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ophthal_vivaedge/core/constants/app_colors.dart';
import 'package:ophthal_vivaedge/models/question_model.dart';
import 'package:ophthal_vivaedge/repositories/mock_question_repository.dart';
import 'package:ophthal_vivaedge/shared/widgets/error_view.dart';
import 'package:ophthal_vivaedge/shared/widgets/loading_view.dart';
import 'package:ophthal_vivaedge/views/widgets/answer_content_renderer.dart';

class QuestionPreviewView extends StatefulWidget {
  final int questionId;

  const QuestionPreviewView({super.key, required this.questionId});

  @override
  State<QuestionPreviewView> createState() => _QuestionPreviewViewState();
}

class _QuestionPreviewViewState extends State<QuestionPreviewView> {
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
      final repo = MockQuestionRepository();
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Question Preview')),
        body: const LoadingView(message: 'Loading preview...'),
      );
    }

    if (_error != null || _question == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Question Preview')),
        body: ErrorView(message: _error ?? 'Question not found', onRetry: _fetch),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Preview Q${widget.questionId.toString().padLeft(3, '0')}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
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
                      color: AppColors.accentBlue.withOpacity(0.1),
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
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _question!.questionText,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                          const Divider(height: 24),
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
