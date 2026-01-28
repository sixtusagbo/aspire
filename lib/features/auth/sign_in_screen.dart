import 'package:aspire/core/utils/app_router.dart';
import 'package:aspire/core/utils/toast_helper.dart';
import 'package:aspire/features/auth/widgets/auth_text_field.dart';
import 'package:aspire/features/auth/widgets/google_sign_in_button.dart';
import 'package:aspire/features/auth/widgets/or_divider.dart';
import 'package:aspire/services/auth_service.dart';
import 'package:aspire/services/log_service.dart';
import 'package:aspire/services/revenue_cat_service.dart';
import 'package:aspire/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SignInScreen extends HookConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final obscurePassword = useState(true);
    final isLoading = useState(false);

    Future<void> handleEmailSignIn() async {
      if (isLoading.value) return;

      final email = emailController.text.trim();
      final password = passwordController.text;

      if (email.isEmpty || password.isEmpty) {
        ToastHelper.showWarning('Please fill in all fields');
        return;
      }

      isLoading.value = true;
      try {
        final authService = ref.read(authServiceProvider);
        await authService.signInWithEmail(email, password);

        final user = authService.currentUser;
        if (user != null && context.mounted) {
          // Login to RevenueCat with Firebase user ID
          final revenueCatService = ref.read(revenueCatServiceProvider);
          await revenueCatService.login(user.uid);

          final userService = ref.read(userServiceProvider);
          final profile = await userService.getUser(user.uid);

          if (profile != null && context.mounted) {
            if (profile.onboardingComplete) {
              context.go(AppRoutes.home);
            } else {
              context.go(AppRoutes.onboarding);
            }
          } else if (context.mounted) {
            context.go(AppRoutes.onboarding);
          }
        }
      } catch (e) {
        if (context.mounted) {
          ToastHelper.showError('Invalid email or password');
        }
        isLoading.value = false;
      }
    }

    Future<void> handleGoogleSignIn() async {
      if (isLoading.value) return;

      isLoading.value = true;
      try {
        final authService = ref.read(authServiceProvider);
        final userCredential = await authService.signInWithGoogle();

        if (userCredential == null) {
          // User cancelled
          isLoading.value = false;
          return;
        }

        if (context.mounted) {
          // Login to RevenueCat with Firebase user ID
          final revenueCatService = ref.read(revenueCatServiceProvider);
          await revenueCatService.login(userCredential.user!.uid);

          final userService = ref.read(userServiceProvider);
          final profile = await userService.getUser(userCredential.user!.uid);

          if (profile != null && context.mounted) {
            if (profile.onboardingComplete) {
              context.go(AppRoutes.home);
            } else {
              context.go(AppRoutes.onboarding);
            }
          } else if (context.mounted) {
            context.go(AppRoutes.onboarding);
          }
        }
      } catch (e, stackTrace) {
        Log.e('Google sign-in error', error: e, stackTrace: stackTrace);
        if (context.mounted) {
          ToastHelper.showError('Sign in was interrupted. Please try again.');
        }
        isLoading.value = false;
      }
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF151022)
          : const Color(0xFFF6F5F8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // App Icon
                Icon(
                  Icons.rocket_launch_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                // Welcome Text
                Text(
                  'Sign In',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Welcome back to Aspire',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                // Form with Autofill Group
                AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AuthTextField(
                        controller: emailController,
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        controller: passwordController,
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: obscurePassword.value,
                        autofillHints: const [AutofillHints.password],
                        onToggleVisibility: () {
                          obscurePassword.value = !obscurePassword.value;
                        },
                        onSubmitted: (_) => handleEmailSignIn(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      context.push(AppRoutes.forgotPassword);
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Sign In Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading.value ? null : handleEmailSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator.adaptive(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                const OrDivider(),
                const SizedBox(height: 24),
                GoogleSignInButton(
                  onPressed: handleGoogleSignIn,
                  isLoading: isLoading.value,
                ),
                const SizedBox(height: 32),
                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account? ',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.push(AppRoutes.signUp);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
