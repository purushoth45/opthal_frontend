import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ophthal_vivaedge/core/constants/app_colors.dart';
import 'package:ophthal_vivaedge/repositories/mock_question_repository.dart';
import 'package:ophthal_vivaedge/shared/widgets/confirmation_dialog.dart';
import 'package:ophthal_vivaedge/shared/widgets/empty_view.dart';
import 'package:ophthal_vivaedge/viewmodels/admin_dashboard_viewmodel.dart';

class QuestionListView extends ConsumerStatefulWidget {
  const QuestionListView({super.key});

  @override
  ConsumerState<QuestionListView> createState() => _QuestionListViewState();
}

class _QuestionListViewState extends ConsumerState<QuestionListView> {
  String _searchQuery = '';
  String _selectedTopic = 'All Topics';

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(adminQuestionsViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Question Management'),
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
              constraints: const BoxConstraints(maxWidth: 850),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Search questions...',
                            prefixIcon: Icon(Icons.search_rounded),
                            isDense: true,
                          ),
                          onChanged: (val) {
                            setState(() => _searchQuery = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      DropdownButton<String>(
                        value: _selectedTopic,
                        items: const [
                          DropdownMenuItem(value: 'All Topics', child: Text('All Topics')),
                          DropdownMenuItem(value: 'Cornea & Lens', child: Text('Cornea & Lens')),
                          DropdownMenuItem(value: 'Glaucoma & Uvea', child: Text('Glaucoma & Uvea')),
                          DropdownMenuItem(value: 'Strabismus', child: Text('Strabismus')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedTopic = val);
                        },
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () => context.push('/admin/questions/add'),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('+ ADD QUESTION'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  questionsAsync.when(
                    data: (questions) {
                      final filtered = questions.where((q) {
                        final matchesSearch = q.questionText.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            q.topic.toLowerCase().contains(_searchQuery.toLowerCase());
                        final matchesTopic = _selectedTopic == 'All Topics' || q.topic.contains(_selectedTopic);
                        return matchesSearch && matchesTopic;
                      }).toList();

                      if (filtered.isEmpty) {
                        return const EmptyView(
                          title: 'No Questions Found',
                          message: 'Try adjusting your search query or topic filter.',
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final question = filtered[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.lightBlueBg,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Q${question.id.toString().padLeft(3, '0')}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryNavy,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          question.questionText,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Topic: ${question.topic} • ${question.answerBlocks.length} Block(s)',
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_red_eye_outlined, color: AppColors.accentBlue),
                                        tooltip: 'Preview',
                                        onPressed: () => context.push('/admin/questions/preview/${question.id}'),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: AppColors.primaryNavy),
                                        tooltip: 'Edit',
                                        onPressed: () => context.push('/admin/questions/edit/${question.id}'),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                                        tooltip: 'Delete',
                                        onPressed: () async {
                                          final confirmed = await ConfirmationDialog.show(
                                            context,
                                            title: 'Delete Question?',
                                            content: 'Are you sure you want to delete this viva question?',
                                          );
                                          if (confirmed == true) {
                                            final repo = MockQuestionRepository();
                                            await repo.deleteQuestion(question.id);
                                            ref.invalidate(adminQuestionsViewModelProvider);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Text('Error: $e'),
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
