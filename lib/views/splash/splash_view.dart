import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ophthal_vivaedge/core/constants/app_colors.dart';
import 'package:ophthal_vivaedge/services/secure_storage_service.dart';
import 'package:ophthal_vivaedge/viewmodels/auth_viewmodel.dart';

class SplashView extends ConsumerStatefulWidget {
  static bool hasCompletedLaunch = false;

  const SplashView({super.key});

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView> with TickerProviderStateMixin {
  late AnimationController _mainAnimController;
  late AnimationController _pulseAnimController;

  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _pulseScaleAnim;
  late Animation<double> _pulseOpacityAnim;

  @override
  void initState() {
    super.initState();

    // Main entrance animations
    _mainAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = CurvedAnimation(
      parent: _mainAnimController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _scaleAnim = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainAnimController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Continuous pulse glow animation for icon halo
    _pulseAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseScaleAnim = Tween<double>(begin: 0.95, end: 1.15).animate(
      CurvedAnimation(parent: _pulseAnimController, curve: Curves.easeInOut),
    );

    _pulseOpacityAnim = Tween<double>(begin: 0.25, end: 0.6).animate(
      CurvedAnimation(parent: _pulseAnimController, curve: Curves.easeInOut),
    );

    _mainAnimController.forward();
    _navigateToNextScreen();
  }

  @override
  void dispose() {
    _mainAnimController.dispose();
    _pulseAnimController.dispose();
    super.dispose();
  }

  Future<void> _navigateToNextScreen() async {
    // Keep splash visible for 2.2s for smooth brand presentation
    await Future.delayed(const Duration(milliseconds: 2200));
    SplashView.hasCompletedLaunch = true;
    if (!mounted) return;

    final storage = SecureStorageService();
    final completedOnboarding = await storage.hasCompletedOnboarding();

    if (!mounted) return;

    if (!completedOnboarding) {
      context.go('/onboarding');
      return;
    }

    final authState = ref.read(authViewModelProvider);
    if (authState.isAuthenticated && authState.user != null) {
      if (authState.user!.isAdmin) {
        context.go('/admin/dashboard');
      } else {
        context.go('/student/dashboard');
      }
    } else {
      context.go('/auth/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryNavy,
      body: Stack(
        children: [
          // Background Gradient Mesh with ambient medical glow
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF091827),
                  Color(0xFF0F2942),
                  Color(0xFF163E63),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Saveetha Campus Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/saveetha_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // Gradient Overlay for contrast and readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF091827).withValues(alpha: 0.72),
                    const Color(0xFF0F2942).withValues(alpha: 0.55),
                    const Color(0xFF163E63).withValues(alpha: 0.68),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Top right subtle ambient light circle
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentBlue.withOpacity(0.12),
              ),
            ),
          ),

          // Bottom left ambient circle
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentBlue.withOpacity(0.08),
              ),
            ),
          ),

          // Main Centered Content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  // Brand Icon with Animated Pulse Halo
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: ScaleTransition(
                      scale: _scaleAnim,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer Pulsing Glow Ring
                          AnimatedBuilder(
                            animation: _pulseAnimController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseScaleAnim.value,
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.accentBlue.withOpacity(_pulseOpacityAnim.value * 0.4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.accentBlue.withOpacity(_pulseOpacityAnim.value * 0.5),
                                        blurRadius: 30,
                                        spreadRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          // Glassmorphic Card Container around Icon
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.2),
                                  Colors.white.withOpacity(0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.remove_red_eye_rounded,
                                size: 54,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Animated App Name & Subtitle
                  SlideTransition(
                    position: _slideAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Column(
                        children: [
                          // Title
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: GoogleFonts.outfit(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                              children: const [
                                TextSpan(
                                  text: 'Ophthal ',
                                  style: TextStyle(color: Colors.white),
                                ),
                                TextSpan(
                                  text: 'VivaEdge',
                                  style: TextStyle(
                                    color: Color(0xFF38BDF8), // Vibrant cyan accent
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Medical Badge Subtitle
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.18),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.medical_services_rounded,
                                  size: 13,
                                  color: Color(0xFF38BDF8),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'OPHTHALMOLOGY VIVA & EXAM SUITE',
                                  style: GoogleFonts.inter(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Sleek Custom Loader Indicator
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withOpacity(0.85),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'v1.0.0 • Professional Medical Edition',
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
