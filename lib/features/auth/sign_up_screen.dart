import 'package:aspire/core/utils/app_router.dart';
import 'package:aspire/core/utils/toast_helper.dart';
import 'package:aspire/features/auth/widgets/auth_text_field.dart';
import 'package:aspire/features/auth/widgets/google_sign_in_button.dart';
import 'package:aspire/features/auth/widgets/or_divider.dart';
import 'package:aspire/services/auth_service.dart';
import 'package:aspire/services/log_service.dart';
import 'package:aspire/services/revenue_cat_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SignUpScreen extends HookConsumerWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final obscurePassword = useState(true);
    final obscureConfirmPassword = useState(true);
    final isLoading = useState(false);

    Future<void> handleSignUp() async {
      if (isLoading.value) return;

      final email = emailController.text.trim();
      final password = passwordController.text;
      final confirmPassword = confirmPasswordController.text;

      if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
        ToastHelper.showWarning('Please fill in all fields');
        return;
      }

      if (password != confirmPassword) {
        ToastHelper.showWarning('Passwords do not match');
        return;
      }

      if (password.length < 6) {
        ToastHelper.showWarning('Password must be at least 6 characters');
        return;
      }

      isLoading.value = true;
      try {
        final authService = ref.read(authServiceProvider);
        await authService.signUpWithEmail(email, password);

        final user = authService.currentUser;
        if (user != null && context.mounted) {
          // Login to RevenueCat with Firebase user ID
          final revenueCatService = ref.read(revenueCatServiceProvider);
          await revenueCatService.login(user.uid);

          if (context.mounted) {
            ToastHelper.showSuccess('Account created successfully!');
            context.go(AppRoutes.onboarding);
          }
        }
      } catch (e) {
        if (context.mounted) {
          String errorMessage = 'Sign up failed';
          if (e.toString().contains('email-already-in-use')) {
            errorMessage = 'This email is already registered';
          } else if (e.toString().contains('weak-password')) {
            errorMessage = 'Password is too weak';
          } else if (e.toString().contains('invalid-email')) {
            errorMessage = 'Invalid email address';
          }
          ToastHelper.showError(errorMessage);
        }
        isLoading.value = false;
      }
    }

    Future<void> handleGoogleSignUp() async {
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

          if (context.mounted) {
            context.go(AppRoutes.onboarding);
          }
        }
      } catch (e, stackTrace) {
        Log.e('Google sign-up error', error: e, stackTrace: stackTrace);
        if (context.mounted) {
          ToastHelper.showError('Sign up was interrupted. Please try again.');
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
                // App Icon
                Icon(
                  Icons.rocket_launch_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                // Title
                Text(
                  'Sign Up',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Start your journey with Aspire',
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
                        hintText: 'Create a password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: obscurePassword.value,
                        autofillHints: const [AutofillHints.newPassword],
                        onToggleVisibility: () {
                          obscurePassword.value = !obscurePassword.value;
                        },
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        controller: confirmPasswordController,
                        labelText: 'Confirm Password',
                        hintText: 'Re-enter your password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: obscureConfirmPassword.value,
                        autofillHints: const [AutofillHints.newPassword],
                        onToggleVisibility: () {
                          obscureConfirmPassword.value =
                              !obscureConfirmPassword.value;
                        },
                        onSubmitted: (_) => handleSignUp(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Sign Up Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading.value ? null : handleSignUp,
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
                  onPressed: handleGoogleSignUp,
                  isLoading: isLoading.value,
                ),
                const SizedBox(height: 32),
                // Sign In Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.pop();
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
