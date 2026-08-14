import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ophthal_vivaedge/core/constants/app_colors.dart';
import 'package:ophthal_vivaedge/services/secure_storage_service.dart';
import 'package:ophthal_vivaedge/viewmodels/auth_viewmodel.dart';
import 'package:ophthal_vivaedge/views/widgets/app_background_wrapper.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authViewModelProvider).user;

    const primaryTextColor = Colors.white;
    final secondaryTextColor = Colors.white.withOpacity(0.85);
    final mutedTextColor = Colors.white.withOpacity(0.7);

    // 25% fill = 75% background gradient visibility
    final cardBg = Colors.white.withOpacity(0.25);
    final cardBorder = Colors.white.withOpacity(0.35);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            tooltip: 'Edit Profile',
            onPressed: () => _showEditProfileDialog(context, ref, user),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: AppBackgroundWrapper(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    // PROFILE AVATAR & ID CARD (70% GRADIENT VISIBILITY)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: cardBorder, width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  CircleAvatar(
                                    radius: 44,
                                    backgroundColor: Colors.white.withOpacity(0.3),
                                    child: Text(
                                      user?.name.substring(0, 1).toUpperCase() ?? 'U',
                                      style: const TextStyle(
                                        fontSize: 34,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: AppColors.success,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                user?.name ?? 'Alex MBBS Student',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: primaryTextColor,
                                      fontSize: 20,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.email ?? 'student@vivaedge.edu',
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  user?.isAdmin == true ? 'FACULTY ADMIN' : 'VERIFIED STUDENT',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ACCOUNT & CONTACT DETAILS CARD
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
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Account & Contact Details',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.email_outlined, size: 18, color: Colors.white),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Email Address', style: TextStyle(fontSize: 12, color: mutedTextColor)),
                                        const SizedBox(height: 2),
                                        Text(
                                          user?.email ?? 'student@vivaedge.edu',
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24, color: Colors.white30),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.phone_outlined, size: 18, color: Colors.white),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Phone Number', style: TextStyle(fontSize: 12, color: mutedTextColor)),
                                        const SizedBox(height: 2),
                                        Text(
                                          user?.phoneNumber ?? '+91 98765 43210',
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ACCOUNT & PREFERENCES ACTIONS
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
                                leading: const Icon(Icons.settings_outlined, color: Colors.white),
                                title: const Text('App Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                subtitle: const Text('Voice speed, theme mode, cache', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white70),
                                onTap: () => context.push('/settings'),
                              ),
                              const Divider(height: 1, color: Colors.white30),
                              ListTile(
                                leading: const Icon(Icons.cleaning_services_outlined, color: Colors.white),
                                title: const Text('Clear Local Cache', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                subtitle: const Text('Reset offline data and local storage', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                onTap: () async {
                                  final storage = SecureStorageService();
                                  await storage.clearAll();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Local storage cache cleared.')),
                                    );
                                  }
                                },
                              ),
                              const Divider(height: 1, color: Colors.white30),
                              ListTile(
                                leading: const Icon(Icons.help_outline_rounded, color: Colors.white),
                                title: const Text('Help & Support', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                subtitle: const Text('Viva Voce practice guidelines', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                onTap: () {
                                  showAboutDialog(
                                    context: context,
                                    applicationName: 'Ophthal VivaEdge',
                                    applicationVersion: '1.0.0',
                                    applicationLegalese: 'Interactive Voice-Based Viva Voce for MBBS Students.',
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await ref.read(authViewModelProvider.notifier).logout();
                          if (context.mounted) {
                            context.go('/auth/login');
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white70),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.logout_rounded, size: 20, color: Colors.white),
                        label: const Text('LOG OUT ACCOUNT', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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

  void _showEditProfileDialog(BuildContext context, WidgetRef ref, UserModel? user) {
    final nameController = TextEditingController(text: user?.name);
    final phoneController = TextEditingController(text: user?.phoneNumber);
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'Edit Profile',
                style: TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold),
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      style: const TextStyle(color: AppColors.primaryNavy),
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                        prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.primaryNavy),
                      ),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter name' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: phoneController,
                      style: const TextStyle(color: AppColors.primaryNavy),
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                        prefixIcon: Icon(Icons.phone_outlined, color: AppColors.primaryNavy),
                      ),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter phone number' : null,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text('CANCEL', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setState(() => isSaving = true);
                          try {
                            final repo = ref.read(authRepositoryProvider);
                            final updatedUser = await repo.updateProfile(
                              name: nameController.text.trim(),
                              phoneNumber: phoneController.text.trim(),
                            );
                            ref.read(authViewModelProvider.notifier).updateUser(updatedUser);
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Profile updated successfully!')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to update profile: $e')),
                              );
                            }
                          } finally {
                            if (context.mounted) setState(() => isSaving = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryNavy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('SAVE', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
