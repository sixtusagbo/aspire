import 'package:aspire/core/theme/app_theme.dart';
import 'package:aspire/core/utils/app_router.dart';
import 'package:aspire/core/utils/toast_helper.dart';
import 'package:aspire/features/onboarding/widgets/goal_setup_step.dart';
import 'package:aspire/features/onboarding/widgets/name_step.dart';
import 'package:aspire/features/onboarding/widgets/notification_step.dart';
import 'package:aspire/features/onboarding/widgets/welcome_step.dart';
import 'package:aspire/models/goal.dart';
import 'package:aspire/services/ai_service.dart';
import 'package:aspire/services/auth_service.dart';
import 'package:aspire/services/goal_service.dart';
import 'package:aspire/services/log_service.dart';
import 'package:aspire/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class OnboardingScreen extends HookConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);
    final user = authService.currentUser;

    // Check if user has a display name (OAuth users have this pre-filled)
    final hasDisplayName =
        user?.displayName != null && user!.displayName!.isNotEmpty;
    final totalPages = hasDisplayName ? 3 : 4;

    final pageController = usePageController();
    final currentPage = useState(0);
    final isLoading = useState(false);
    final skippedNotifications = useState(false);

    // Form data - pre-fill name for OAuth users
    final name = useState(hasDisplayName ? user.displayName! : '');
    final goalTitle = useState('');
    final goalDescription = useState('');
    final goalTargetDate = useState<DateTime?>(null);
    final goalCategory = useState(GoalCategory.personal);
    final goalSuggestedActions = useState<List<String>>([]);

    Future<void> completeOnboarding() async {
      // Prevent multiple submissions
      if (isLoading.value) return;
      isLoading.value = true;

      try {
        final userService = ref.read(userServiceProvider);
        final goalService = ref.read(goalServiceProvider);
        final aiService = ref.read(aiServiceProvider);

        if (user == null) {
          if (context.mounted) {
            context.go(AppRoutes.signIn);
          }
          return;
        }

        // Update user profile and mark onboarding complete
        final userData = <String, dynamic>{
          'name': name.value,
          'email': user.email ?? '',
          'createdAt': DateTime.now(),
          'onboardingComplete': true,
          'dailyReminderEnabled': true,
          'reminderHour': 9,
          'reminderMinute': 0,
        };
        if (skippedNotifications.value) {
          userData['notificationPromptDeclinedAt'] = Timestamp.now();
        }
        await userService.updateUser(user.uid, userData);

        // Create first goal if title provided
        if (goalTitle.value.isNotEmpty) {
          final goal = await goalService.createGoal(
            userId: user.uid,
            title: goalTitle.value,
            description: goalDescription.value.isNotEmpty
                ? goalDescription.value
                : null,
            targetDate: goalTargetDate.value,
            category: goalCategory.value,
          );

          // Create micro-actions (use template actions if available, otherwise AI)
          try {
            if (goalSuggestedActions.value.isNotEmpty) {
              // Use template's suggested actions
              for (var i = 0; i < goalSuggestedActions.value.length; i++) {
                await goalService.createMicroAction(
                  goalId: goal.id,
                  userId: user.uid,
                  title: goalSuggestedActions.value[i],
                  sortOrder: i,
                );
              }
            } else {
              // Generate AI micro-actions for the goal
              final aiResult = await aiService.generateMicroActions(
                goalTitle: goalTitle.value,
                goalDescription: goalDescription.value.isNotEmpty
                    ? goalDescription.value
                    : null,
                category: goalCategory.value.name,
                targetDate: goalTargetDate.value,
              );

              // Save the generated actions
              for (final action in aiResult.actions) {
                await goalService.createMicroAction(
                  goalId: goal.id,
                  userId: user.uid,
                  title: action.title,
                  sortOrder: action.sortOrder,
                );
              }
            }
          } catch (e) {
            // Action creation failed - user can add manually later
            Log.w('Action creation failed during onboarding: $e');
          }
        }

        if (context.mounted) {
          context.go(AppRoutes.home);
        }
      } catch (e, stackTrace) {
        Log.e('Error completing onboarding', error: e, stackTrace: stackTrace);
        ToastHelper.showError('Something went wrong', details: e.toString());
      } finally {
        isLoading.value = false;
      }
    }

    void nextPage() {
      FocusScope.of(context).unfocus();
      if (currentPage.value < totalPages - 1) {
        pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }

    void previousPage() {
      if (currentPage.value > 0) {
        pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }

    // Build pages based on whether we need the name step
    final pages = <Widget>[
      WelcomeStep(onNext: nextPage),
      if (!hasDisplayName)
        NameStep(name: name, onNext: nextPage, onBack: previousPage),
      GoalSetupStep(
        title: goalTitle,
        description: goalDescription,
        targetDate: goalTargetDate,
        category: goalCategory,
        suggestedActions: goalSuggestedActions,
        isLoading: false,
        onNext: nextPage,
        onBack: previousPage,
      ),
      NotificationStep(
        onNext: () => completeOnboarding(),
        onBack: previousPage,
        onSkip: () async => skippedNotifications.value = true,
        isLoading: isLoading.value,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: List.generate(totalPages, (index) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                        right: index < totalPages - 1 ? 8 : 0,
                      ),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index <= currentPage.value
                            ? AppTheme.primaryPink
                            : AppTheme.primaryPink.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => currentPage.value = page,
                children: pages,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
