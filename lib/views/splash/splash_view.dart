import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ophthal_vivaedge/core/constants/app_colors.dart';
import 'package:ophthal_vivaedge/services/secure_storage_service.dart';
import 'package:ophthal_vivaedge/viewmodels/auth_viewmodel.dart';

class SplashView extends ConsumerStatefulWidget {
  const SplashView({super.key});

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _textController;
  late Animation<double> _pulseScaleAnim;
  late Animation<double> _pulseOpacityAnim;
  late Animation<double> _textFadeAnim;
  late Animation<Offset> _textSlideAnim;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseScaleAnim = Tween<double>(begin: 0.9, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseOpacityAnim = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _textFadeAnim = CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    );

    _textSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _textController.forward();
    _checkNextRoute();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _checkNextRoute() async {
    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;

    final storage = SecureStorageService();
    final completedOnboarding = await storage.hasCompletedOnboarding();

    if (!mounted) return;

    if (!completedOnboarding) {
      context.go('/onboarding');
      return;
    }

    final authState = ref.read(authViewModelProvider);
    if (authState.user != null) {
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0A192F),
              Color(0xFF0F172A),
              Color(0xFF1E3A5F),
              Color(0xFF0F2942),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ambient Radial Background Glow
            Positioned(
              top: MediaQuery.of(context).size.height * 0.25,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 320 * _pulseScaleAnim.value,
                    height: 320 * _pulseScaleAnim.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.accentBlue.withOpacity(0.25 * _pulseOpacityAnim.value),
                          const Color(0xFF0EA5E9).withOpacity(0.08),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // ANIMATED OPHTHALMIC EYE EMBLEM WITH PULSE RINGS
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseScaleAnim.value,
                        child: Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4 * _pulseOpacityAnim.value),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentBlue.withOpacity(0.4 * _pulseOpacityAnim.value),
                                blurRadius: 30,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(22),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.remove_red_eye_rounded,
                              size: 54,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 36),

                  // ANIMATED TYPOGRAPHY & BADGE
                  SlideTransition(
                    position: _textSlideAnim,
                    child: FadeTransition(
                      opacity: _textFadeAnim,
                      child: Column(
                        children: [
                          const Text(
                            'Ophthal VivaEdge',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.8,
                              shadows: [
                                Shadow(
                                  color: Colors.black38,
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.25)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.accentBlue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Voice-Based Interactive Viva Voce',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // BOTTOM PROGRESS INDICATOR
                  Column(
                    children: [
                      SizedBox(
                        width: 140,
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.white.withOpacity(0.15),
                          color: AppColors.accentBlue,
                          minHeight: 3.5,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Initializing Clinical Viva Engine...',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
