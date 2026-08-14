import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ophthal_vivaedge/core/constants/app_colors.dart';
import 'package:ophthal_vivaedge/core/enums/answer_block_type.dart';
import 'package:ophthal_vivaedge/models/answer_block_model.dart';
import 'package:ophthal_vivaedge/models/question_model.dart';
import 'package:ophthal_vivaedge/repositories/mock_question_repository.dart';
import 'package:ophthal_vivaedge/shared/widgets/app_button.dart';
import 'package:ophthal_vivaedge/shared/widgets/app_text_field.dart';
import 'package:ophthal_vivaedge/shared/widgets/loading_view.dart';
import 'package:ophthal_vivaedge/viewmodels/admin_dashboard_viewmodel.dart';
import 'package:ophthal_vivaedge/views/widgets/answer_content_renderer.dart';
import 'package:ophthal_vivaedge/views/widgets/heading_block_editor.dart';
import 'package:ophthal_vivaedge/views/widgets/table_block_editor.dart';
import 'package:ophthal_vivaedge/views/widgets/text_block_editor.dart';

class EditQuestionView extends ConsumerStatefulWidget {
  final int questionId;

  const EditQuestionView({super.key, required this.questionId});

  @override
  ConsumerState<EditQuestionView> createState() => _EditQuestionViewState();
}

class _EditQuestionViewState extends ConsumerState<EditQuestionView> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  late TextEditingController _topicController;
  late TabController _tabController;

  List<AnswerBlockModel> _blocks = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController();
    _topicController = TextEditingController();
    _tabController = TabController(length: 2, vsync: this);
    _loadQuestion();
  }

  Future<void> _loadQuestion() async {
    try {
      final repo = MockQuestionRepository();
      final question = await repo.getQuestionById(widget.questionId);
      setState(() {
        _questionController.text = question.questionText;
        _topicController.text = question.topic;
        _blocks = List<AnswerBlockModel>.from(question.answerBlocks);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load question details: $e')),
        );
        context.pop();
      }
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _topicController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _addBlock(AnswerBlockType type) {
    setState(() {
      final newOrder = _blocks.length + 1;
      if (type == AnswerBlockType.text) {
        _blocks.add(AnswerBlockModel.text(text: '', displayOrder: newOrder));
      } else if (type == AnswerBlockType.heading) {
        _blocks.add(AnswerBlockModel.heading(heading: '', displayOrder: newOrder));
      } else if (type == AnswerBlockType.table) {
        _blocks.add(AnswerBlockModel.table(
          columns: ['Column 1', 'Column 2'],
          rows: [
            ['Cell 1', 'Cell 2']
          ],
          displayOrder: newOrder,
        ));
      }
    });
  }

  void _moveBlock(int index, int delta) {
    final newIndex = index + delta;
    if (newIndex < 0 || newIndex >= _blocks.length) return;
    setState(() {
      final block = _blocks.removeAt(index);
      _blocks.insert(newIndex, block);
      _reindexBlocks();
    });
  }

  void _deleteBlock(int index) {
    setState(() {
      _blocks.removeAt(index);
      _reindexBlocks();
    });
  }

  void _reindexBlocks() {
    for (int i = 0; i < _blocks.length; i++) {
      _blocks[i] = _blocks[i].copyWith(displayOrder: i + 1);
    }
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_blocks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one answer block.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updatedQuestion = QuestionModel(
        id: widget.questionId,
        questionText: _questionController.text.trim(),
        topic: _topicController.text.trim(),
        answerBlocks: _blocks,
      );

      final repo = MockQuestionRepository();
      await repo.updateQuestion(widget.questionId, updatedQuestion);
      ref.invalidate(adminQuestionsViewModelProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Question updated successfully!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update question: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Viva Question')),
        body: const LoadingView(message: 'Loading question data...'),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Edit Question Q${widget.questionId.toString().padLeft(3, '0')}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryNavy,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primaryNavy,
          tabs: const [
            Tab(icon: Icon(Icons.edit_note_rounded), text: 'EDIT & BUILD'),
            Tab(icon: Icon(Icons.preview_rounded), text: 'STUDENT PREVIEW'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 750),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Question Details',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 16),
                                AppTextField(
                                  label: 'Question Prompt Text',
                                  controller: _questionController,
                                  maxLines: 2,
                                  validator: (val) =>
                                      (val == null || val.trim().isEmpty) ? 'Please enter question text' : null,
                                ),
                                const SizedBox(height: 16),
                                AppTextField(
                                  label: 'Topic / Sub-specialty',
                                  controller: _topicController,
                                  validator: (val) =>
                                      (val == null || val.trim().isEmpty) ? 'Please enter topic' : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          'Answer Content Blocks',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                        ),
                        const SizedBox(height: 16),

                        ...List.generate(_blocks.length, (index) {
                          final block = _blocks[index];
                          switch (block.type) {
                            case AnswerBlockType.text:
                              return TextBlockEditor(
                                block: block,
                                onChanged: (updated) => setState(() => _blocks[index] = updated),
                                onDelete: () => _deleteBlock(index),
                                onMoveUp: index > 0 ? () => _moveBlock(index, -1) : null,
                                onMoveDown: index < _blocks.length - 1 ? () => _moveBlock(index, 1) : null,
                              );
                            case AnswerBlockType.heading:
                              return HeadingBlockEditor(
                                block: block,
                                onChanged: (updated) => setState(() => _blocks[index] = updated),
                                onDelete: () => _deleteBlock(index),
                                onMoveUp: index > 0 ? () => _moveBlock(index, -1) : null,
                                onMoveDown: index < _blocks.length - 1 ? () => _moveBlock(index, 1) : null,
                              );
                            case AnswerBlockType.table:
                              return TableBlockEditor(
                                block: block,
                                onChanged: (updated) => setState(() => _blocks[index] = updated),
                                onDelete: () => _deleteBlock(index),
                                onMoveUp: index > 0 ? () => _moveBlock(index, -1) : null,
                                onMoveDown: index < _blocks.length - 1 ? () => _moveBlock(index, 1) : null,
                              );
                          }
                        }),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _addBlock(AnswerBlockType.text),
                                icon: const Icon(Icons.notes_rounded, size: 16),
                                label: const Text('+ Text'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _addBlock(AnswerBlockType.heading),
                                icon: const Icon(Icons.title_rounded, size: 16),
                                label: const Text('+ Heading'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _addBlock(AnswerBlockType.table),
                                icon: const Icon(Icons.table_chart_outlined, size: 16),
                                label: const Text('+ Table'),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        AppButton(
                          text: 'SAVE CHANGES',
                          isLoading: _isSaving,
                          onPressed: _handleSave,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _questionController.text,
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
                          AnswerContentRenderer(blocks: _blocks),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
