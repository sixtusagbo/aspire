import 'package:aspire/core/widgets/app_shell.dart';
import 'package:aspire/features/auth/forgot_password_screen.dart';
import 'package:aspire/features/auth/sign_in_screen.dart';
import 'package:aspire/features/auth/sign_up_screen.dart';
import 'package:aspire/features/goals/goals_screen.dart';
import 'package:aspire/features/home/home_screen.dart';
import 'package:aspire/features/onboarding/onboarding_screen.dart';
import 'package:aspire/features/progress/progress_screen.dart';
import 'package:aspire/features/settings/settings_screen.dart';
import 'package:aspire/features/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// Route paths
class AppRoutes {
  static const splash = '/';
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const forgotPassword = '/forgot-password';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const goals = '/goals';
  static const progress = '/progress';
  static const settings = '/settings';
}

/// Global navigator key - enables navigation from anywhere without BuildContext.
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Main router provider
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      // Auth/splash routes stay outside shell
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Main app shell with bottom nav
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          // Home branch (index 0)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Goals branch (index 1)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.goals,
                builder: (context, state) => const GoalsScreen(),
              ),
            ],
          ),
          // Progress branch (index 2)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.progress,
                builder: (context, state) => const ProgressScreen(),
              ),
            ],
          ),
        ],
      ),

      // Routes outside shell (pushed on top)
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
  });

  return router;
}
