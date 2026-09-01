import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ophthal_vivaedge/viewmodels/auth_viewmodel.dart';
import 'package:ophthal_vivaedge/views/admin/add_question_view.dart';
import 'package:ophthal_vivaedge/views/admin/admin_dashboard_view.dart';
import 'package:ophthal_vivaedge/views/admin/edit_question_view.dart';
import 'package:ophthal_vivaedge/views/admin/question_list_view.dart';
import 'package:ophthal_vivaedge/views/admin/question_preview_view.dart';
import 'package:ophthal_vivaedge/views/admin/user_management_view.dart';
import 'package:ophthal_vivaedge/views/auth/login_view.dart';
import 'package:ophthal_vivaedge/views/auth/register_view.dart';
import 'package:ophthal_vivaedge/views/main_shell_view.dart';
import 'package:ophthal_vivaedge/views/onboarding/onboarding_view.dart';
import 'package:ophthal_vivaedge/views/profile/profile_view.dart';
import 'package:ophthal_vivaedge/views/settings/settings_view.dart';
import 'package:ophthal_vivaedge/views/splash/splash_view.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (previous?.isAuthenticated != next.isAuthenticated) {
        notifyListeners();
      }
    });
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.read(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authViewModelProvider);
      final isAuth = authState.isAuthenticated;
      final location = state.matchedLocation;

      // 1. Once launch splash has finished, NEVER allow returning to /splash
      if (SplashView.hasCompletedLaunch && location == '/splash') {
        if (isAuth) {
          final user = authState.user;
          return (user != null && user.isAdmin) ? '/admin/dashboard' : '/student/dashboard';
        }
        return '/auth/login';
      }

      // 2. Allow Splash & Onboarding during launch
      if (location == '/splash' || location == '/onboarding') {
        return null;
      }

      final isLoggingIn = location == '/auth/login' ||
          location == '/auth/register' ||
          location == '/auth/forgot-password';

      if (!isAuth && !isLoggingIn) {
        return '/auth/login';
      }

      if (isAuth && isLoggingIn) {
        final user = authState.user;
        if (user != null && user.isAdmin) {
          return '/admin/dashboard';
        }
        return '/student/dashboard';
      }

      if (isAuth && location.startsWith('/admin')) {
        final user = authState.user;
        if (user != null && !user.isAdmin) {
          return '/student/dashboard';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingView(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterView(),
      ),
      GoRoute(
        path: '/student/dashboard',
        builder: (context, state) => const MainShellView(initialIndex: 0),
      ),
      GoRoute(
        path: '/student/viva',
        builder: (context, state) => const MainShellView(initialIndex: 1),
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardView(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const UserManagementView(),
      ),
      GoRoute(
        path: '/admin/questions',
        builder: (context, state) => const QuestionListView(),
      ),
      GoRoute(
        path: '/admin/questions/add',
        builder: (context, state) => const AddQuestionView(),
      ),
      GoRoute(
        path: '/admin/questions/edit/:id',
        builder: (context, state) {
          final idStr = state.pathParameters['id'] ?? '1';
          final id = int.tryParse(idStr) ?? 1;
          return EditQuestionView(questionId: id);
        },
      ),
      GoRoute(
        path: '/admin/questions/preview/:id',
        builder: (context, state) {
          final idStr = state.pathParameters['id'] ?? '1';
          final id = int.tryParse(idStr) ?? 1;
          return QuestionPreviewView(questionId: id);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileView(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsView(),
      ),
    ],
  );
});
