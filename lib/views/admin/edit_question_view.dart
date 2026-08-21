import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ophthal_vivaedge/core/constants/app_colors.dart';
import 'package:ophthal_vivaedge/core/enums/answer_block_type.dart';
import 'package:ophthal_vivaedge/models/answer_block_model.dart';
import 'package:ophthal_vivaedge/models/question_model.dart';
import 'package:ophthal_vivaedge/viewmodels/viva_viewmodel.dart';
import 'package:ophthal_vivaedge/shared/widgets/app_button.dart';
import 'package:ophthal_vivaedge/shared/widgets/app_text_field.dart';
import 'package:ophthal_vivaedge/shared/widgets/loading_view.dart';
import 'package:ophthal_vivaedge/viewmodels/admin_dashboard_viewmodel.dart';
import 'package:ophthal_vivaedge/views/widgets/answer_content_renderer.dart';
import 'package:ophthal_vivaedge/views/widgets/heading_block_editor.dart';
import 'package:ophthal_vivaedge/views/widgets/image_block_editor.dart';
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
      final repo = ref.read(questionRepositoryProvider);
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
      } else if (type == AnswerBlockType.image) {
        _blocks.add(AnswerBlockModel.image(
          filename: '',
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

      final repo = ref.read(questionRepositoryProvider);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF0F172A) : AppColors.background;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderCol = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
    final primaryText = isDark ? Colors.white : AppColors.primaryNavy;
    final secondaryText = isDark ? Colors.white70 : AppColors.textSecondary;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(
          title: const Text('Edit Viva Question', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: isDark ? const Color(0xFF1E293B) : AppColors.primaryNavy,
          foregroundColor: Colors.white,
        ),
        body: const LoadingView(message: 'Loading question details...'),
      );
    }

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(
          'Edit Question Q${widget.questionId.toString().padLeft(3, '0')}',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: isDark ? const Color(0xFF1E293B) : AppColors.primaryNavy,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3.0,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.edit_note_rounded, color: Colors.white), text: 'EDIT & BUILD'),
            Tab(icon: Icon(Icons.preview_rounded, color: Colors.white70), text: 'STUDENT PREVIEW'),
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
                                  'Question Details',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryText),
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

                        Text(
                          'Answer Content Blocks',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryText),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Construct dynamic text, section headings, and medical comparison tables.',
                          style: TextStyle(fontSize: 13, color: secondaryText),
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
                            case AnswerBlockType.image:
                              return ImageBlockEditor(
                                block: block,
                                onChanged: (updated) => setState(() => _blocks[index] = updated),
                                onDelete: () => _deleteBlock(index),
                                onMoveUp: index > 0 ? () => _moveBlock(index, -1) : null,
                                onMoveDown: index < _blocks.length - 1 ? () => _moveBlock(index, 1) : null,
                              );
                          }
                        }),

                        const SizedBox(height: 12),

                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _addBlock(AnswerBlockType.text),
                              icon: const Icon(Icons.notes_rounded, size: 16),
                              label: const Text('+ Text'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _addBlock(AnswerBlockType.heading),
                              icon: const Icon(Icons.title_rounded, size: 16),
                              label: const Text('+ Heading'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _addBlock(AnswerBlockType.table),
                              icon: const Icon(Icons.table_chart_outlined, size: 16),
                              label: const Text('+ Table'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _addBlock(AnswerBlockType.image),
                              icon: const Icon(Icons.image_outlined, size: 16),
                              label: const Text('+ Image'),
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
                            _questionController.text,
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
