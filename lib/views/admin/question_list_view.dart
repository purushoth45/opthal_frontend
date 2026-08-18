import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ophthal_vivaedge/core/constants/app_colors.dart';
import 'package:ophthal_vivaedge/viewmodels/viva_viewmodel.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final scaffoldBg = isDark ? const Color(0xFF0F172A) : AppColors.background;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderCol = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
    final primaryText = isDark ? Colors.white : AppColors.primaryNavy;
    final secondaryText = isDark ? Colors.white70 : AppColors.textSecondary;
    final badgeBg = isDark ? const Color(0xFF334155) : AppColors.lightBlueBg;
    final badgeText = isDark ? const Color(0xFF38BDF8) : AppColors.primaryNavy;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: const Text('Question Management'),
        backgroundColor: isDark ? const Color(0xFF1E293B) : AppColors.primaryNavy,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 850),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // RESPONSIVE FILTER BAR
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 640;

                      final searchField = TextField(
                        style: TextStyle(color: primaryText, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search questions...',
                          hintStyle: TextStyle(color: isDark ? Colors.white54 : AppColors.textMuted),
                          prefixIcon: Icon(Icons.search_rounded, color: secondaryText),
                          filled: true,
                          fillColor: cardBg,
                          isDense: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: borderCol),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.accentBlue, width: 2),
                          ),
                        ),
                        onChanged: (val) {
                          setState(() => _searchQuery = val);
                        },
                      );

                      final dropdown = Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderCol),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedTopic,
                            dropdownColor: cardBg,
                            style: TextStyle(color: primaryText, fontSize: 13, fontWeight: FontWeight.w600),
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
                        ),
                      );

                      if (isNarrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            searchField,
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(child: dropdown),
                                const SizedBox(width: 10),
                                ElevatedButton.icon(
                                  onPressed: () => context.push('/admin/questions/add'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accentBlue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  ),
                                  icon: const Icon(Icons.add_rounded, size: 18),
                                  label: const Text('+ ADD'),
                                ),
                              ],
                            ),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: searchField),
                          const SizedBox(width: 12),
                          dropdown,
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () => context.push('/admin/questions/add'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('+ ADD QUESTION'),
                          ),
                        ],
                      );
                    },
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
                            color: cardBg,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(color: borderCol, width: 1),
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: LayoutBuilder(
                                builder: (context, itemConstraints) {
                                  final isMobileItem = itemConstraints.maxWidth < 460;

                                  if (isMobileItem) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: badgeBg,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                'Q${question.id.toString().padLeft(3, '0')}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: badgeText,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                question.questionText,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: primaryText,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Topic: ${question.topic} • ${question.answerBlocks.length} Block(s)',
                                          style: TextStyle(
                                            color: secondaryText,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                        Divider(height: 16, color: borderCol),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove_red_eye_outlined, color: AppColors.accentBlue, size: 20),
                                              tooltip: 'Preview',
                                              onPressed: () => context.push('/admin/questions/preview/${question.id}'),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.edit_outlined, color: primaryText, size: 20),
                                              tooltip: 'Edit',
                                              onPressed: () => context.push('/admin/questions/edit/${question.id}'),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                                              tooltip: 'Delete',
                                              onPressed: () async {
                                                final confirmed = await ConfirmationDialog.show(
                                                  context,
                                                  title: 'Delete Question?',
                                                  content: 'Are you sure you want to delete this viva question?',
                                                );
                                                if (confirmed == true) {
                                                  final repo = ref.read(questionRepositoryProvider);
                                                  await repo.deleteQuestion(question.id);
                                                  ref.invalidate(adminQuestionsViewModelProvider);
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  }

                                  return Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: badgeBg,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'Q${question.id.toString().padLeft(3, '0')}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: badgeText,
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
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: primaryText,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Topic: ${question.topic} • ${question.answerBlocks.length} Block(s)',
                                              style: TextStyle(
                                                color: secondaryText,
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
                                            icon: Icon(Icons.edit_outlined, color: primaryText),
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
                                                final repo = ref.read(questionRepositoryProvider);
                                                await repo.deleteQuestion(question.id);
                                                ref.invalidate(adminQuestionsViewModelProvider);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Text('Error: $e', style: TextStyle(color: primaryText)),
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
