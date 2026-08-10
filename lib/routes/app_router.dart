import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/home/main_shell.dart';
import '../screens/home/home_screen.dart';
import '../screens/medicines/medicines_screen.dart';
import '../screens/add_medicine/add_medicine_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/health/health_tips_screen.dart';
import '../models/medicine_model.dart';

/// Route name constants
class Routes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';
  static const forgotPassword = '/forgot-password';
  static const main = '/main';
  static const home = '/main/home';
  static const medicines = '/main/medicines';
  static const addMedicine = '/main/medicines/add';
  static const editMedicine = '/main/medicines/edit';
  static const history = '/main/history';
  static const profile = '/main/profile';
  static const healthTips = '/health-tips';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// GoRouter configuration provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isAuthRoute = state.matchedLocation == Routes.login ||
          state.matchedLocation == Routes.signup ||
          state.matchedLocation == Routes.forgotPassword;
      final isSplash = state.matchedLocation == Routes.splash;

      if (isSplash) return null;
      if (!isLoggedIn && !isAuthRoute) return Routes.login;
      if (isLoggedIn && isAuthRoute) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.splash,
        pageBuilder: (context, state) => _fadeTransitionPage(
          key: state.pageKey,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: Routes.onboarding,
        pageBuilder: (context, state) => _fadeTransitionPage(
          key: state.pageKey,
          child: OnboardingScreen(
            onFinished: () => context.go(Routes.login),
          ),
        ),
      ),
      GoRoute(
        path: Routes.login,
        pageBuilder: (context, state) => _slideTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: Routes.signup,
        pageBuilder: (context, state) => _slideTransitionPage(
          key: state.pageKey,
          child: const SignupScreen(),
        ),
      ),
      GoRoute(
        path: Routes.forgotPassword,
        pageBuilder: (context, state) => _slideTransitionPage(
          key: state.pageKey,
          child: const ForgotPasswordScreen(),
        ),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: Routes.home,
            pageBuilder: (context, state) => _fadeTransitionPage(
              key: state.pageKey,
              child: const HomeScreen(),
            ),
          ),
          GoRoute(
            path: Routes.medicines,
            pageBuilder: (context, state) => _fadeTransitionPage(
              key: state.pageKey,
              child: const MedicinesScreen(),
            ),
            routes: [
              GoRoute(
                path: 'add',
                parentNavigatorKey: _rootNavigatorKey,
                pageBuilder: (context, state) => _slideUpTransitionPage(
                  key: state.pageKey,
                  child: const AddMedicineScreen(),
                ),
              ),
              GoRoute(
                path: 'edit',
                parentNavigatorKey: _rootNavigatorKey,
                pageBuilder: (context, state) {
                  final medicine = state.extra as MedicineModel?;
                  return _slideUpTransitionPage(
                    key: state.pageKey,
                    child: AddMedicineScreen(medicine: medicine),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: Routes.history,
            pageBuilder: (context, state) => _fadeTransitionPage(
              key: state.pageKey,
              child: const HistoryScreen(),
            ),
          ),
          GoRoute(
            path: Routes.profile,
            pageBuilder: (context, state) => _fadeTransitionPage(
              key: state.pageKey,
              child: const ProfileScreen(),
            ),
          ),
        ],
      ),
      // Health Tips — top-level route (full-screen, no shell/bottom nav)
      GoRoute(
        path: Routes.healthTips,
        pageBuilder: (context, state) => _slideTransitionPage(
          key: state.pageKey,
          child: const HealthTipsScreen(),
        ),
      ),
      // Redirect /main to /main/home
      GoRoute(
        path: Routes.main,
        redirect: (_, __) => Routes.home,
      ),
    ],
  );
});

/// Fade transition
CustomTransitionPage _fadeTransitionPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

/// Slide from right transition
CustomTransitionPage _slideTransitionPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 350),
  );
}

/// Slide up transition (for modal-style screens)
CustomTransitionPage _slideUpTransitionPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutQuart));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 400),
  );
}
