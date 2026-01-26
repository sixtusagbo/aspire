import 'package:aspire/core/utils/app_router.dart';
import 'package:aspire/services/auth_service.dart';
import 'package:aspire/services/revenue_cat_service.dart';
import 'package:aspire/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SplashScreen extends HookConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasNavigated = useState(false);

    useEffect(() {
      Future<void> checkAuth() async {
        // Small delay to allow hot reload to settle
        await Future.delayed(const Duration(milliseconds: 100));

        // Prevent re-navigation on hot reload
        if (hasNavigated.value) return;

        // Check if user is authenticated
        final authService = ref.read(authServiceProvider);
        final user = authService.currentUser;

        if (user != null) {
          // Login to RevenueCat with user ID
          final revenueCatService = ref.read(revenueCatServiceProvider);
          await revenueCatService.login(user.uid);

          // User is logged in, check if they have completed onboarding
          try {
            final userService = ref.read(userServiceProvider);
            final userProfile = await userService.getUser(user.uid);

            if (userProfile != null && context.mounted) {
              if (userProfile.onboardingComplete) {
                hasNavigated.value = true;
                context.go(AppRoutes.home);
              } else {
                hasNavigated.value = true;
                context.go(AppRoutes.onboarding);
              }
              return;
            }
          } catch (e) {
            // Error fetching profile, proceed to onboarding
          }
        }

        // No user or no profile found, show sign-in
        if (context.mounted) {
          hasNavigated.value = true;
          context.go(AppRoutes.signIn);
        }
      }

      checkAuth();
      return null;
    }, []);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).appBarTheme.systemOverlayStyle!,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.rocket_launch_rounded,
                size: 120,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text('Aspire', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 8),
              Text(
                'From dreaming to doing',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 32),
              CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
