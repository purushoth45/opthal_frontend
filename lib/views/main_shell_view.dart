import 'package:flutter/material.dart';
import 'package:ophthal_vivaedge/core/constants/app_colors.dart';
import 'package:ophthal_vivaedge/views/profile/profile_view.dart';
import 'package:ophthal_vivaedge/views/settings/settings_view.dart';
import 'package:ophthal_vivaedge/views/student/student_dashboard_view.dart';
import 'package:ophthal_vivaedge/views/student/viva_view.dart';

class MainShellView extends StatefulWidget {
  final int initialIndex;

  const MainShellView({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainShellView> createState() => _MainShellViewState();
}

class _MainShellViewState extends State<MainShellView> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    StudentDashboardView(),
    VivaView(),
    ProfileView(),
    SettingsView(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(covariant MainShellView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      setState(() {
        _currentIndex = widget.initialIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final glassBg = isDark
        ? const Color(0xFF1E293B).withOpacity(0.92)
        : Colors.white.withOpacity(0.90);

    final glassBorder = isDark
        ? Colors.white.withOpacity(0.15)
        : Colors.white.withOpacity(0.65);

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: glassBg,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: glassBorder,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.3)
                      : AppColors.primaryNavy.withOpacity(0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildGlassNavItem(
                  index: 0,
                  icon: Icons.grid_view_outlined,
                  activeIcon: Icons.grid_view_rounded,
                  tooltip: 'Dashboard',
                  isDark: isDark,
                ),
                _buildGlassNavItem(
                  index: 1,
                  icon: Icons.mic_none_rounded,
                  activeIcon: Icons.mic_rounded,
                  tooltip: 'Voice Viva',
                  isDark: isDark,
                ),
                _buildGlassNavItem(
                  index: 2,
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  tooltip: 'Profile',
                  isDark: isDark,
                ),
                _buildGlassNavItem(
                  index: 3,
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings_rounded,
                  tooltip: 'Settings',
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String tooltip,
    required bool isDark,
  }) {
    final isSelected = _currentIndex == index;

    const activeGradient = LinearGradient(
      colors: [AppColors.accentBlue, Color(0xFF0EA5E9)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final inactiveGradient = LinearGradient(
      colors: isDark
          ? [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)]
          : [AppColors.accentBlue.withOpacity(0.12), AppColors.accentBlue.withOpacity(0.06)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final iconColor = isSelected
        ? Colors.white
        : (isDark ? Colors.white70 : AppColors.primaryNavy);

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: isSelected ? activeGradient : inactiveGradient,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Colors.white.withOpacity(0.4)
                      : (isDark ? Colors.white.withOpacity(0.15) : AppColors.accentBlue.withOpacity(0.2)),
                  width: 1.2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.accentBlue.withOpacity(0.45),
                          blurRadius: 16,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : const [],
              ),
              child: Center(
                child: AnimatedScale(
                  scale: isSelected ? 1.12 : 1.0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    color: iconColor,
                    size: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: isSelected ? 5 : 0,
              height: isSelected ? 5 : 0,
              decoration: BoxDecoration(
                color: isDark ? AppColors.accentBlue : AppColors.primaryNavy,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
