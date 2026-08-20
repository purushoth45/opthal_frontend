import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ophthal_vivaedge/core/constants/app_colors.dart';
import 'package:ophthal_vivaedge/models/question_model.dart';
import 'package:ophthal_vivaedge/viewmodels/admin_dashboard_viewmodel.dart';
import 'package:ophthal_vivaedge/viewmodels/auth_viewmodel.dart';
import 'package:ophthal_vivaedge/views/widgets/app_background_wrapper.dart';
import 'package:ophthal_vivaedge/shared/widgets/app_shimmer.dart';

class StudentDashboardView extends ConsumerStatefulWidget {
  const StudentDashboardView({super.key});

  @override
  ConsumerState<StudentDashboardView> createState() => _StudentDashboardViewState();
}

class _StudentDashboardViewState extends ConsumerState<StudentDashboardView> {
  String _selectedCategory = 'All Topics';

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authViewModelProvider).user;
    final questionsAsync = ref.watch(adminQuestionsViewModelProvider);

    final cardBg = Colors.white.withOpacity(0.25);
    final cardBorder = Colors.white.withOpacity(0.35);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackgroundWrapper(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. HERO HEADER BANNER WITH REALTIME DB STATS
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: Colors.white.withOpacity(0.3),
                                    child: Text(
                                      user?.name.substring(0, 1).toUpperCase() ?? 'S',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${_getGreeting()}, ${user?.name.split(' ').first ?? 'Student'} 👋',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Role: ${user?.isAdmin == true ? "Faculty Admin" : "Student"} • Status: Active',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12.5,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 20),
                                      tooltip: 'My Profile',
                                      onPressed: () => context.push('/profile'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              questionsAsync.when(
                                data: (questions) {
                                  final totalQ = questions.length;
                                  final topicCount = questions.map((q) => q.topic).toSet().length;

                                  return Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.3),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.auto_graph_rounded, color: Colors.white, size: 18),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Viva Readiness ($totalQ Questions)',
                                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '$topicCount Specialty Modules Active in Database',
                                                style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            totalQ > 0 ? '100% READY' : 'EMPTY',
                                            style: const TextStyle(
                                              color: AppColors.primaryNavy,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                loading: () => const SizedBox.shrink(),
                                error: (e, s) => const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 2. REALTIME QUICK STATS CARDS GRID
                    questionsAsync.when(
                      data: (questions) {
                        final totalQ = questions.length;
                        final totalTopics = questions.map((q) => q.topic).toSet().length;
                        final totalBlocks = questions.fold<int>(0, (sum, q) => sum + q.answerBlocks.length);

                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatTile(
                                    context: context,
                                    icon: Icons.assignment_turned_in_rounded,
                                    title: 'Total Viva Questions',
                                    value: '$totalQ Questions',
                                    subtitle: 'From Database',
                                    color: Colors.white,
                                    cardBg: cardBg,
                                    cardBorder: cardBorder,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatTile(
                                    context: context,
                                    icon: Icons.grid_view_rounded,
                                    title: 'Active Modules',
                                    value: '$totalTopics Topics',
                                    subtitle: 'Specialties loaded',
                                    color: Colors.white,
                                    cardBg: cardBg,
                                    cardBorder: cardBorder,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatTile(
                                    context: context,
                                    icon: Icons.view_list_rounded,
                                    title: 'Answer Blocks',
                                    value: '$totalBlocks Blocks',
                                    subtitle: 'Detailed tables & notes',
                                    color: Colors.white,
                                    cardBg: cardBg,
                                    cardBorder: cardBorder,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatTile(
                                    context: context,
                                    icon: Icons.mic_rounded,
                                    title: 'Speech Engine',
                                    value: 'STT & TTS',
                                    subtitle: 'Voice Practice Ready',
                                    color: Colors.white,
                                    cardBg: cardBg,
                                    cardBorder: cardBorder,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                      loading: () => const SizedBox(
                        height: 100,
                        child: Center(child: CircularProgressIndicator(color: Colors.white)),
                      ),
                      error: (e, s) => const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 28),

                    // 3. FEATURED HERO CLINICAL VIVA CARD (REALTIME DB)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Featured Viva Session',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/student/viva'),
                          child: const Text('Start Now →', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    questionsAsync.when(
                      data: (questions) {
                        if (questions.isEmpty) {
                          return _buildEmptyCard(cardBg, cardBorder);
                        }

                        final featuredQ = questions.first;

                        return ClipRRect(
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
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.25),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: const Icon(
                                          Icons.remove_red_eye_rounded,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              featuredQ.topic,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              featuredQ.questionText,
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 13,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _buildTag(featuredQ.topic),
                                      _buildTag('${featuredQ.answerBlocks.length} Answer Blocks'),
                                      _buildTag('Voice Viva'),
                                    ],
                                  ),

                                  const SizedBox(height: 20),

                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () => context.push('/student/viva'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: AppColors.primaryNavy,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                      ),
                                      icon: const Icon(Icons.play_circle_fill_rounded, size: 22, color: AppColors.primaryNavy),
                                      label: const Text(
                                        'LAUNCH VIVA VOCE SESSION',
                                        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5, color: AppColors.primaryNavy),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      loading: () => const AppShimmer(
                        child: ShimmerBox(width: double.infinity, height: 140, borderRadius: 22),
                      ),
                      error: (e, s) => _buildEmptyCard(cardBg, cardBorder),
                    ),

                    const SizedBox(height: 28),

                    // 4. DYNAMIC OPHTHALMOLOGY SPECIALTY TOPICS & QUESTION LIST
                    const Text(
                      'Viva Voce Specialty Modules',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),

                    questionsAsync.when(
                      data: (questions) {
                        if (questions.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        // Extract dynamic categories from DB questions
                        final dynamicTopics = ['All Topics', ...questions.map((q) => q.topic).toSet()];

                        final filteredQuestions = _selectedCategory == 'All Topics'
                            ? questions
                            : questions.where((q) => q.topic == _selectedCategory).toList();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: dynamicTopics.map((topic) => _buildCategoryChip(topic)).toList(),
                              ),
                            ),
                            const SizedBox(height: 16),

                            ...filteredQuestions.map((q) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: _buildSpecialtyCard(
                                  question: q,
                                  cardBg: cardBg,
                                  cardBorder: cardBorder,
                                  onTap: () => context.push('/student/viva'),
                                ),
                              );
                            }),
                          ],
                        );
                      },
                      loading: () => AppShimmer(
                        child: Column(
                          children: List.generate(
                            3,
                            (index) => const Padding(
                              padding: EdgeInsets.only(bottom: 12.0),
                              child: ShimmerBox(width: double.infinity, height: 80, borderRadius: 16),
                            ),
                          ),
                        ),
                      ),
                      error: (e, s) => const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 20),

                    // 5. DAILY VIVA CLINICAL PEARL CARD
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.22),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.35),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.lightbulb_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'DAILY VIVA PEARL',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Fincham\'s Test differentiates cataract haloes (splits into spectrum colors when a stenopaeic slit moves) from glaucoma haloes (remains intact).',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white,
                                        height: 1.45,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCard(Color cardBg, Color cardBorder) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardBorder),
      ),
      child: const Center(
        child: Text(
          'No viva questions loaded in database yet.',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildStatTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required Color cardBg,
    required Color cardBorder,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: cardBorder, width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    final isSelected = _selectedCategory == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: Colors.white,
        backgroundColor: Colors.white.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primaryNavy : Colors.white,
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.35),
          ),
        ),
        onSelected: (val) {
          setState(() => _selectedCategory = label);
        },
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSpecialtyCard({
    required QuestionModel question,
    required Color cardBg,
    required Color cardBorder,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cardBorder, width: 1.2),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 20),
            ),
            title: Text(
              question.questionText,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.5,
                color: Colors.white,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                '${question.topic} • ${question.answerBlocks.length} Answer Block(s)',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white),
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}
