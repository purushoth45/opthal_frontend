import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ophthal_vivaedge/services/secure_storage_service.dart';
import 'package:ophthal_vivaedge/viewmodels/auth_viewmodel.dart';

class SplashView extends ConsumerStatefulWidget {
  static bool hasCompletedLaunch = false;

  const SplashView({super.key});

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView> with SingleTickerProviderStateMixin {
  late AnimationController _mainAnimController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    // Main entrance animations
    _mainAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnim = CurvedAnimation(
      parent: _mainAnimController,
      curve: Curves.easeOut,
    );

    _mainAnimController.forward();
    _navigateToNextScreen();
  }

  @override
  void dispose() {
    _mainAnimController.dispose();
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
      backgroundColor: const Color(0xFF0D1D2D),
      body: Stack(
        children: [
          // Full-Screen Official Splash Graphic
          Positioned.fill(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Image.asset(
                'assets/images/splash.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),

          // Bottom Loading Indicator Overlay
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 28.0),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF38BDF8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'v1.0.0 • Professional Medical Edition',
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
