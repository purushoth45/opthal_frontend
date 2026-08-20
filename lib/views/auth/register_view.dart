import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ophthal_vivaedge/core/constants/app_colors.dart';
import 'package:ophthal_vivaedge/shared/widgets/app_button.dart';
import 'package:ophthal_vivaedge/shared/widgets/app_error_banner.dart';
import 'package:ophthal_vivaedge/shared/widgets/app_snack_bar.dart';
import 'package:ophthal_vivaedge/shared/widgets/app_text_field.dart';
import 'package:ophthal_vivaedge/viewmodels/auth_viewmodel.dart';

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authViewModelProvider.notifier).register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          phoneNumber: _phoneController.text.trim(),
        );

    if (success && mounted) {
      AppSnackBar.showSuccess(context, 'Registration successful! Please log in.');
      context.go('/auth/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final scaffoldBg = isDark ? const Color(0xFF0F172A) : AppColors.background;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF334155) : AppColors.border.withOpacity(0.6);
    final primaryTextColor = isDark ? Colors.white : AppColors.primaryNavy;
    final secondaryTextColor = isDark ? Colors.white70 : AppColors.textSecondary;
    final iconColor = isDark ? const Color(0xFF38BDF8) : AppColors.primaryNavy;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Stack(
        children: [
          // Top Decorative Gradient Arc Header
          Positioned(
            top: -120,
            left: -80,
            right: -80,
            height: 320,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryNavy,
                    const Color(0xFF1E3A5F),
                    AppColors.accentBlue.withOpacity(0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.elliptical(500, 160),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryNavy.withOpacity(0.3),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Custom App Bar Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Student Registration',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: SlideTransition(
                          position: _slideAnim,
                          child: FadeTransition(
                            opacity: _fadeAnim,
                            child: Container(
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
                                    blurRadius: 24,
                                    offset: const Offset(0, 10),
                                  ),
                                  BoxShadow(
                                    color: AppColors.primaryNavy.withOpacity(isDark ? 0.1 : 0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                border: Border.all(
                                  color: cardBorder,
                                  width: 1,
                                ),
                              ),
                              padding: const EdgeInsets.all(28.0),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Join Ophthal VivaEdge',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: primaryTextColor,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Enter your student & medical college credentials',
                                      style: TextStyle(
                                        color: secondaryTextColor,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    if (authState.errorMessage != null) ...[
                                      AppErrorBanner(message: authState.errorMessage!),
                                      const SizedBox(height: 16),
                                    ],

                                    AppTextField(
                                      label: 'Full Name',
                                      hint: 'e.g. Alex Smith',
                                      controller: _nameController,
                                      prefixIcon: Icon(Icons.person_outline_rounded, size: 20, color: iconColor),
                                      validator: (val) =>
                                          (val == null || val.trim().isEmpty) ? 'Please enter your full name' : null,
                                    ),
                                    const SizedBox(height: 16),

                                    AppTextField(
                                      label: 'Email Address',
                                      hint: 'e.g. alex@vivaedge.edu',
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      prefixIcon: Icon(Icons.email_outlined, size: 20, color: iconColor),
                                      validator: (val) =>
                                          (val == null || val.trim().isEmpty) ? 'Please enter your email address' : null,
                                    ),
                                    const SizedBox(height: 16),

                                    AppTextField(
                                      label: 'Phone Number',
                                      hint: 'e.g. +91 98765 43210',
                                      controller: _phoneController,
                                      keyboardType: TextInputType.phone,
                                      prefixIcon: Icon(Icons.phone_outlined, size: 20, color: iconColor),
                                      validator: (val) =>
                                          (val == null || val.trim().isEmpty) ? 'Please enter your phone number' : null,
                                    ),
                                    const SizedBox(height: 16),

                                    AppTextField(
                                      label: 'Password',
                                      hint: 'Create a secure password',
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      prefixIcon: Icon(Icons.lock_outline_rounded, size: 20, color: iconColor),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                          size: 20,
                                          color: iconColor,
                                        ),
                                        onPressed: () {
                                          setState(() => _obscurePassword = !_obscurePassword);
                                        },
                                      ),
                                      validator: (val) =>
                                          (val == null || val.length < 6) ? 'Password must be at least 6 characters' : null,
                                    ),
                                    const SizedBox(height: 16),

                                    AppTextField(
                                      label: 'Confirm Password',
                                      hint: 'Re-enter your password',
                                      controller: _confirmPasswordController,
                                      obscureText: _obscureConfirmPassword,
                                      prefixIcon: Icon(Icons.lock_reset_rounded, size: 20, color: iconColor),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                          size: 20,
                                          color: iconColor,
                                        ),
                                        onPressed: () {
                                          setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                                        },
                                      ),
                                      validator: (val) {
                                        if (val == null || val.isEmpty) {
                                          return 'Please confirm your password';
                                        }
                                        if (val != _passwordController.text) {
                                          return 'Passwords do not match';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 28),

                                    AppButton(
                                      text: 'CREATE ACCOUNT',
                                      isLoading: authState.isLoading,
                                      onPressed: _handleRegister,
                                    ),

                                    const SizedBox(height: 18),
                                    Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Already have an account? ',
                                            style: TextStyle(color: secondaryTextColor, fontSize: 14),
                                          ),
                                          GestureDetector(
                                            onTap: () => context.pop(),
                                            child: const Text(
                                              'Sign In',
                                              style: TextStyle(
                                                color: AppColors.accentBlue,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
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
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
