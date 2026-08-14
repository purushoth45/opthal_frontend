import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ophthal_vivaedge/core/constants/app_colors.dart';
import 'package:ophthal_vivaedge/viewmodels/viva_viewmodel.dart';
import 'package:ophthal_vivaedge/shared/widgets/confirmation_dialog.dart';
import 'package:ophthal_vivaedge/viewmodels/admin_dashboard_viewmodel.dart';
import 'package:ophthal_vivaedge/viewmodels/auth_viewmodel.dart';

class AdminDashboardView extends ConsumerWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(adminQuestionsViewModelProvider);
    final user = ref.watch(authViewModelProvider).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings_rounded, size: 22, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'OPHTHAL VIVAEDGE',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.push('/profile'),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.accentBlue,
                    child: Text(
                      user?.name.substring(0, 1).toUpperCase() ?? 'A',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  user?.name ?? 'Admin',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Colors.white70, size: 20),
                  onPressed: () => context.push('/settings'),
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Colors.white70, size: 20),
                  onPressed: () async {
                    await ref.read(authViewModelProvider.notifier).logout();
                    if (context.mounted) {
                      context.go('/auth/login');
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, Admin',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.primaryNavy,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Manage your interactive ophthalmology viva question bank',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/admin/questions/add'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text('+ Add Question'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                questionsAsync.when(
                  data: (questions) {
                    return Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Questions',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${questions.length}',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryNavy,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Active Modules',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${questions.map((q) => q.topic).toSet().length}',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const SizedBox(
                    height: 80,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, s) => const SizedBox.shrink(),
                ),

                const SizedBox(height: 28),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Question Bank',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/admin/questions'),
                      child: const Text('View All Questions →'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                questionsAsync.when(
                  data: (questions) {
                    return Column(
                      children: questions.map((question) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: AppColors.lightBlueBg,
                              child: Text(
                                'Q${question.id}',
                                style: const TextStyle(
                                  color: AppColors.primaryNavy,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              question.questionText,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              '${question.topic} • ${question.answerBlocks.length} answer block(s)',
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_red_eye_outlined, size: 20, color: AppColors.accentBlue),
                                  tooltip: 'Preview Student View',
                                  onPressed: () => context.push('/admin/questions/preview/${question.id}'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primaryNavy),
                                  tooltip: 'Edit Question',
                                  onPressed: () => context.push('/admin/questions/edit/${question.id}'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
                                  tooltip: 'Delete Question',
                                  onPressed: () async {
                                    final confirmed = await ConfirmationDialog.show(
                                      context,
                                      title: 'Delete Question?',
                                      content: 'Are you sure you want to delete question Q00${question.id}? This action cannot be undone.',
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
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Text('Error: $err'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
