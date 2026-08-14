import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ophthal_vivaedge/core/constants/app_colors.dart';
import 'package:ophthal_vivaedge/viewmodels/auth_viewmodel.dart';
import 'package:ophthal_vivaedge/views/widgets/app_background_wrapper.dart';

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

    // 25% card fill opacity = 75% background gradient visibility
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
                    // 1. HERO HEADER BANNER WITH GLASS GLOW
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
                                          '${user?.mbbsYear ?? "Final Year MBBS"} • ${user?.medicalCollege ?? "Grant Medical College"}',
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

                              Container(
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
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Cataract Viva Readiness',
                                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            '4 Clinical Modules Ready for Voice Practice',
                                            style: TextStyle(color: Colors.white70, fontSize: 11.5),
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
                                      child: const Text(
                                        '100% READY',
                                        style: TextStyle(
                                          color: AppColors.primaryNavy,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
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

                    const SizedBox(height: 24),

                    // 2. QUICK STATS CARDS GRID (70% GRADIENT VISIBILITY)
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatTile(
                            context: context,
                            icon: Icons.assignment_turned_in_rounded,
                            title: 'Viva Questions',
                            value: '4 Core',
                            subtitle: 'Full answers & tables',
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
                            value: 'Real-time',
                            subtitle: 'STT Spoken transcript',
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
                            icon: Icons.record_voice_over_rounded,
                            title: 'Audio Reader',
                            value: 'TTS Voice',
                            subtitle: 'Listen to prompt',
                            color: Colors.white,
                            cardBg: cardBg,
                            cardBorder: cardBorder,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatTile(
                            context: context,
                            icon: Icons.analytics_outlined,
                            title: 'Study Mode',
                            value: 'Interactive',
                            subtitle: 'Self-scoring feedback',
                            color: Colors.white,
                            cardBg: cardBg,
                            cardBorder: cardBorder,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // 3. FEATURED HERO CLINICAL VIVA CARD
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
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Cataract & Clinical Ophthalmology',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          '4 Essential MBBS Viva Voce Tasks',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                          ),
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
                                  _buildTag('Painless Loss of Vision'),
                                  _buildTag('Acute Painful Loss'),
                                  _buildTag('Diplopia Table'),
                                  _buildTag('Fincham\'s Test'),
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
                    ),

                    const SizedBox(height: 28),

                    // 4. OPHTHALMOLOGY SPECIALTY TOPICS SELECTOR
                    const Text(
                      'Viva Voce Specialties',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildCategoryChip('All Topics'),
                          _buildCategoryChip('Cornea & Lens'),
                          _buildCategoryChip('Glaucoma & Uvea'),
                          _buildCategoryChip('Neuro-Ophthal'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildSpecialtyCard(
                      title: 'Causes of Gradual Painless Loss of Vision',
                      subtitle: 'Cataract, POAG, Diabetic Retinopathy & AMD',
                      topic: 'Cornea & Lens',
                      questionCount: 'Question 01',
                      cardBg: cardBg,
                      cardBorder: cardBorder,
                      onTap: () => context.push('/student/viva'),
                    ),
                    const SizedBox(height: 12),
                    _buildSpecialtyCard(
                      title: 'Causes of Acute Painful Loss of Vision',
                      subtitle: 'Angle-Closure Glaucoma, Uveitis, Keratitis & Neuritis',
                      topic: 'Glaucoma & Uvea',
                      questionCount: 'Question 02',
                      cardBg: cardBg,
                      cardBorder: cardBorder,
                      onTap: () => context.push('/student/viva'),
                    ),
                    const SizedBox(height: 12),
                    _buildSpecialtyCard(
                      title: 'Monocular vs Binocular Diplopia Comparison',
                      subtitle: 'Includes full clinical diagnostic table',
                      topic: 'Neuro-Ophthal',
                      questionCount: 'Question 03',
                      cardBg: cardBg,
                      cardBorder: cardBorder,
                      onTap: () => context.push('/student/viva'),
                    ),

                    const SizedBox(height: 28),

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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
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
    required String title,
    required String subtitle,
    required String topic,
    required String questionCount,
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
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.5,
                color: Colors.white,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                '$topic • $subtitle',
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
