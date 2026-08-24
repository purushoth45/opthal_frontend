import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ophthal_vivaedge/core/constants/app_colors.dart';
import 'package:ophthal_vivaedge/viewmodels/viva_viewmodel.dart';
import 'package:ophthal_vivaedge/shared/widgets/app_shimmer.dart';
import 'package:ophthal_vivaedge/shared/widgets/confirmation_dialog.dart';
import 'package:ophthal_vivaedge/viewmodels/admin_dashboard_viewmodel.dart';
import 'package:ophthal_vivaedge/viewmodels/auth_viewmodel.dart';

class AdminDashboardView extends ConsumerWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(adminQuestionsViewModelProvider);
    final user = ref.watch(authViewModelProvider).user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final scaffoldBg = isDark ? const Color(0xFF0F172A) : AppColors.background;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderCol = isDark ? const Color(0xFF334155) : AppColors.border;
    final primaryText = isDark ? Colors.white : AppColors.primaryNavy;
    final secondaryText = isDark ? Colors.white70 : AppColors.textSecondary;
    final badgeBg = isDark ? const Color(0xFF334155) : AppColors.lightBlueBg;
    final badgeText = isDark ? const Color(0xFF38BDF8) : AppColors.primaryNavy;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
        titleSpacing: 12,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.admin_panel_settings_rounded, size: 19, color: Colors.white),
            SizedBox(width: 6),
            Flexible(
              child: Text(
                'OPHTHAL VIVAEDGE',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => context.push('/profile'),
                  child: Tooltip(
                    message: user?.name ?? 'Admin Profile',
                    child: CircleAvatar(
                      radius: 13,
                      backgroundColor: AppColors.accentBlue,
                      child: Text(
                        user?.name.substring(0, 1).toUpperCase() ?? 'A',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Colors.white70, size: 18),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  tooltip: 'Settings',
                  onPressed: () => context.push('/settings'),
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Colors.white70, size: 18),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  tooltip: 'Sign Out',
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // RESPONSIVE HEADER ROW
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 600;
                      if (isNarrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, Admin',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: primaryText,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manage your interactive ophthalmology viva question bank',
                              style: TextStyle(color: secondaryText, fontSize: 13.5),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => context.push('/admin/users'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: primaryText,
                                      side: BorderSide(color: borderCol),
                                      backgroundColor: cardBg,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    icon: const Icon(Icons.people_alt_rounded, size: 18, color: AppColors.accentBlue),
                                    label: const Text('Manage Users', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => context.push('/admin/questions/add'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.accentBlue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    icon: const Icon(Icons.add_rounded, size: 18),
                                    label: const Text('+ Add Question', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome, Admin',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        color: primaryText,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Manage your interactive ophthalmology viva question bank',
                                  style: TextStyle(color: secondaryText, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Row(
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => context.push('/admin/users'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: primaryText,
                                  side: BorderSide(color: borderCol),
                                  backgroundColor: cardBg,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                icon: const Icon(Icons.people_alt_rounded, size: 18, color: AppColors.accentBlue),
                                label: const Text('Manage Users', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: () => context.push('/admin/questions/add'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accentBlue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                icon: const Icon(Icons.add_rounded, size: 20),
                                label: const Text('+ Add Question', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // RESPONSIVE CARDS ROW
                  questionsAsync.when(
                    data: (questions) {
                      final totalCard = Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderCol),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Questions',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: secondaryText,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${questions.length}',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: primaryText,
                              ),
                            ),
                          ],
                        ),
                      );

                      final activeModulesCard = Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderCol),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Active Modules',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: secondaryText,
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
                      );

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 480) {
                            return Column(
                              children: [
                                SizedBox(width: double.infinity, child: totalCard),
                                const SizedBox(height: 12),
                                SizedBox(width: double.infinity, child: activeModulesCard),
                              ],
                            );
                          }
                          return Row(
                            children: [
                              Expanded(child: totalCard),
                              const SizedBox(width: 14),
                              Expanded(child: activeModulesCard),
                            ],
                          );
                        },
                      );
                    },
                    loading: () => const AppShimmer(
                      child: Row(
                        children: [
                          Expanded(child: ShimmerBox(width: double.infinity, height: 80, borderRadius: 14)),
                          SizedBox(width: 14),
                          Expanded(child: ShimmerBox(width: double.infinity, height: 80, borderRadius: 14)),
                        ],
                      ),
                    ),
                    error: (e, s) => const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 28),

                  // RECENT QUESTION BANK HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Question Bank',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryText,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/admin/questions'),
                        child: const Text(
                          'View All Questions →',
                          style: TextStyle(
                            color: AppColors.accentBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // QUESTION CARDS LIST
                  questionsAsync.when(
                    data: (questions) {
                      if (questions.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderCol),
                          ),
                          child: Center(
                            child: Text(
                              'No questions created yet. Click "+ Add Question" to get started.',
                              style: TextStyle(color: secondaryText, fontSize: 14),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: questions.map((question) {
                          return Card(
                            color: cardBg,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(color: borderCol, width: 1),
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: LayoutBuilder(
                                builder: (context, itemConstraints) {
                                  final isMobileItem = itemConstraints.maxWidth < 450;

                                  if (isMobileItem) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 14,
                                              backgroundColor: badgeBg,
                                              child: Text(
                                                'Q${question.id}',
                                                style: TextStyle(
                                                  color: badgeText,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
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
                                          '${question.topic} • ${question.answerBlocks.length} block(s)',
                                          style: TextStyle(fontSize: 12, color: secondaryText),
                                        ),
                                        Divider(height: 16, color: borderCol),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove_red_eye_outlined, size: 20, color: AppColors.accentBlue),
                                              tooltip: 'Preview',
                                              onPressed: () => context.push('/admin/questions/preview/${question.id}'),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.edit_outlined, size: 20, color: primaryText),
                                              tooltip: 'Edit',
                                              onPressed: () => context.push('/admin/questions/edit/${question.id}'),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
                                              tooltip: 'Delete',
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
                                      ],
                                    );
                                  }

                                  return Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: badgeBg,
                                        child: Text(
                                          'Q${question.id}',
                                          style: TextStyle(
                                            color: badgeText,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
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
                                            const SizedBox(height: 2),
                                            Text(
                                              '${question.topic} • ${question.answerBlocks.length} answer block(s)',
                                              style: TextStyle(fontSize: 13, color: secondaryText),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove_red_eye_outlined, size: 20, color: AppColors.accentBlue),
                                            tooltip: 'Preview Student View',
                                            onPressed: () => context.push('/admin/questions/preview/${question.id}'),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.edit_outlined, size: 20, color: primaryText),
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
                                    ],
                                  );
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => AppShimmer(
                      child: Column(
                        children: List.generate(
                          3,
                          (index) => const Padding(
                            padding: EdgeInsets.only(bottom: 12.0),
                            child: ShimmerBox(width: double.infinity, height: 72, borderRadius: 14),
                          ),
                        ),
                      ),
                    ),
                    error: (err, stack) => Text('Error: $err', style: TextStyle(color: primaryText)),
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
