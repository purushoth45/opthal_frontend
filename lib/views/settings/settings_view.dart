import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ophthal_vivaedge/core/constants/app_colors.dart';
import 'package:ophthal_vivaedge/services/secure_storage_service.dart';
import 'package:ophthal_vivaedge/viewmodels/settings_viewmodel.dart';
import 'package:ophthal_vivaedge/views/widgets/app_background_wrapper.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsViewModelProvider);
    final viewModel = ref.read(settingsViewModelProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const primaryTextColor = Colors.white;
    final secondaryTextColor = Colors.white.withOpacity(0.85);

    final cardBg = Colors.white.withOpacity(0.25);
    final cardBorder = Colors.white.withOpacity(0.35);

    const headerStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: primaryTextColor,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: AppBackgroundWrapper(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // THEME & APPEARANCE SECTION
                    const Row(
                      children: [
                        Icon(Icons.palette_outlined, size: 20, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Theme & Appearance', style: headerStyle),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: cardBorder, width: 1.2),
                          ),
                          padding: const EdgeInsets.all(18.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'App Theme Mode',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: primaryTextColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Select your preferred color mode or match system default',
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    _buildThemeOption(
                                      context: context,
                                      label: 'Light',
                                      icon: Icons.light_mode_outlined,
                                      mode: ThemeMode.light,
                                      selectedMode: settings.themeMode,
                                      isDark: isDark,
                                      onTap: () => viewModel.setThemeMode(ThemeMode.light),
                                    ),
                                    _buildThemeOption(
                                      context: context,
                                      label: 'Dark',
                                      icon: Icons.dark_mode_outlined,
                                      mode: ThemeMode.dark,
                                      selectedMode: settings.themeMode,
                                      isDark: isDark,
                                      onTap: () => viewModel.setThemeMode(ThemeMode.dark),
                                    ),
                                    _buildThemeOption(
                                      context: context,
                                      label: 'System',
                                      icon: Icons.brightness_auto_outlined,
                                      mode: ThemeMode.system,
                                      selectedMode: settings.themeMode,
                                      isDark: isDark,
                                      onTap: () => viewModel.setThemeMode(ThemeMode.system),
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

                    // VOICE & SPEECH ENGINE SECTION
                    const Row(
                      children: [
                        Icon(Icons.record_voice_over_outlined, size: 20, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Voice & Speech Engine', style: headerStyle),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: cardBorder, width: 1.2),
                          ),
                          padding: const EdgeInsets.all(18.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Text-To-Speech Speed',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: primaryTextColor,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Adjust audio reader playback rate for viva questions',
                                          style: TextStyle(
                                            color: secondaryTextColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${(settings.speechRate * 100).round()}%',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Slider(
                                value: settings.speechRate,
                                min: 0.2,
                                max: 1.0,
                                divisions: 8,
                                activeColor: Colors.white,
                                inactiveColor: Colors.white30,
                                onChanged: (val) => viewModel.setSpeechRate(val),
                              ),
                              const Divider(color: Colors.white30),
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text(
                                  'Auto-Play Question Audio',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: primaryTextColor,
                                  ),
                                ),
                                subtitle: Text(
                                  'Automatically speak question prompt when starting a new question',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: secondaryTextColor,
                                  ),
                                ),
                                value: settings.autoReadQuestion,
                                onChanged: (val) => viewModel.setAutoReadQuestion(val),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // DISPLAY & ACCESSIBILITY SECTION
                    const Row(
                      children: [
                        Icon(Icons.table_chart_outlined, size: 20, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Display & Table Preferences', style: headerStyle),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: cardBorder, width: 1.2),
                          ),
                          child: SwitchListTile(
                            title: const Text(
                              'High Contrast Medical Tables',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: primaryTextColor,
                              ),
                            ),
                            subtitle: Text(
                              'Enhanced column border separation for medical tables',
                              style: TextStyle(
                                fontSize: 12,
                                color: secondaryTextColor,
                              ),
                            ),
                            value: settings.highContrastTables,
                            onChanged: (val) => viewModel.toggleHighContrastTables(val),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // SYSTEM & CACHE
                    const Row(
                      children: [
                        Icon(Icons.shield_outlined, size: 20, color: Colors.white),
                        SizedBox(width: 8),
                        Text('System & Cache', style: headerStyle),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: cardBorder, width: 1.2),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(
                                  Icons.slideshow_rounded,
                                  color: Colors.white,
                                ),
                                title: const Text(
                                  'Replay Onboarding Guide',
                                  style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  'Watch the 3-step feature walkthrough',
                                  style: TextStyle(color: secondaryTextColor, fontSize: 12),
                                ),
                                onTap: () async {
                                  final storage = SecureStorageService();
                                  await storage.setCompletedOnboarding(false);
                                  if (context.mounted) {
                                    context.go('/onboarding');
                                  }
                                },
                              ),
                              const Divider(height: 1, color: Colors.white30),
                              ListTile(
                                leading: const Icon(
                                  Icons.info_outline_rounded,
                                  color: Colors.white,
                                ),
                                title: const Text(
                                  'About Ophthal VivaEdge',
                                  style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  'Version 1.0.0 (Master Release)',
                                  style: TextStyle(color: secondaryTextColor, fontSize: 12),
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

  Widget _buildThemeOption({
    required BuildContext context,
    required String label,
    required IconData icon,
    required ThemeMode mode,
    required ThemeMode selectedMode,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final isSelected = mode == selectedMode;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppColors.primaryNavy : Colors.white70,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isSelected ? AppColors.primaryNavy : Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
