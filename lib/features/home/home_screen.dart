import 'package:aspire/core/theme/app_theme.dart';
import 'package:aspire/core/theme/category_colors.dart';
import 'package:aspire/core/utils/app_router.dart';
import 'package:aspire/core/utils/toast_helper.dart';
import 'package:aspire/core/widgets/celebration_overlay.dart';
import 'package:aspire/core/widgets/goal_completion_dialog.dart';
import 'package:aspire/core/widgets/streak_celebration_dialog.dart';
import 'package:aspire/features/goals/widgets/create_goal_sheet.dart';
import 'package:aspire/features/home/widgets/tip_card.dart';
import 'package:aspire/models/goal.dart';
import 'package:aspire/models/micro_action.dart';
import 'package:aspire/services/auth_service.dart';
import 'package:aspire/services/goal_service.dart';
import 'package:aspire/services/notification_service.dart';
import 'package:aspire/services/tip_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);
    final goalService = ref.read(goalServiceProvider);
    final notificationService = ref.read(notificationServiceProvider);
    final userId = authService.currentUser?.uid;

    // Track notification permission state
    final notificationsEnabled = useState<bool?>(null);
    final bannerDismissed = useState(false);

    // Check notification permission on mount
    useEffect(() {
      notificationService.areNotificationsEnabled().then((enabled) {
        notificationsEnabled.value = enabled;
      });
      return null;
    }, []);

    if (userId == null) {
      return const Scaffold(body: Center(child: Text('Please sign in')));
    }

    Future<void> handleEnableNotifications() async {
      final granted = await notificationService.requestPermission();
      notificationsEnabled.value = granted;
      if (granted) {
        ToastHelper.showSuccess('Notifications enabled!');
      }
    }

    final userName = authService.currentUser?.displayName?.split(' ').first;
    final greeting = _getGreeting(userName);

    return Scaffold(
      appBar: AppBar(
        title: Text(greeting),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(tipOfTheDayProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Notification permission banner
            if (notificationsEnabled.value == false && !bannerDismissed.value)
              SliverToBoxAdapter(
                child: _NotificationBanner(
                  onEnable: handleEnableNotifications,
                  onDismiss: () => bannerDismissed.value = true,
                ),
              ),

            // Tip of the day
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: TipCard(),
              ),
            ),

            // Section header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    const Text(
                      'Your Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.goals),
                      child: Text(
                        'See Goals',
                        style: TextStyle(color: AppTheme.primaryPink),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Actions list
            _ActionsList(userId: userId, goalService: goalService),
          ],
        ),
      ),
    );
  }
}

class _ActionsList extends HookConsumerWidget {
  final String userId;
  final GoalService goalService;

  const _ActionsList({required this.userId, required this.goalService});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<List<Goal>>(
      stream: goalService.watchActiveGoals(userId),
      builder: (context, goalsSnapshot) {
        if (goalsSnapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final goals = goalsSnapshot.data ?? [];

        if (goals.isEmpty) {
          return SliverFillRemaining(
            child: _EmptyState(
              onCreateGoal: () => showCreateGoalSheet(context, ref, userId),
            ),
          );
        }

        // Build a combined list of goal headers and actions
        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            return _GoalActionsSection(
              goal: goals[index],
              goalService: goalService,
            );
          }, childCount: goals.length),
        );
      },
    );
  }
}

class _GoalActionsSection extends HookConsumerWidget {
  final Goal goal;
  final GoalService goalService;

  const _GoalActionsSection({required this.goal, required this.goalService});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<List<MicroAction>>(
      stream: goalService.watchGoalActions(goal.id, goal.userId),
      builder: (context, snapshot) {
        final allActions = snapshot.data ?? [];
        final pendingActions = allActions.where((a) => !a.isCompleted).toList();

        if (pendingActions.isEmpty && allActions.isNotEmpty) {
          // All actions completed for this goal
          return _CompletedGoalCard(goal: goal);
        }

        if (pendingActions.isEmpty) {
          // No actions yet
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Goal header
              GestureDetector(
                onTap: () => context.push(AppRoutes.goalDetailPath(goal.id)),
                child: Row(
                  children: [
                    Icon(
                      goal.category.icon,
                      size: 16,
                      color: goal.category.color,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        goal.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${goal.completedActionsCount}/${goal.totalActionsCount}',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Actions
              ...pendingActions
                  .take(3)
                  .map(
                    (action) => _ActionTile(
                      action: action,
                      goal: goal,
                      goalService: goalService,
                    ),
                  ),

              if (pendingActions.length > 3)
                TextButton(
                  onPressed: () =>
                      context.push(AppRoutes.goalDetailPath(goal.id)),
                  child: Text(
                    '+${pendingActions.length - 3} more actions',
                    style: TextStyle(color: AppTheme.primaryPink, fontSize: 13),
                  ),
                ),

              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class _ActionTile extends HookConsumerWidget {
  final MicroAction action;
  final Goal goal;
  final GoalService goalService;

  const _ActionTile({
    required this.action,
    required this.goal,
    required this.goalService,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.borderColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _completeAction(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primaryPink, width: 2),
                ),
                child: const Icon(
                  Icons.check,
                  size: 14,
                  color: Colors.transparent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(action.title, style: const TextStyle(fontSize: 15)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+10 XP',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryPink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _completeAction(BuildContext context) async {
    // Capture overlay BEFORE async call (context may become unmounted)
    final overlay = CelebrationOverlay.of(context);

    // Haptic feedback
    HapticFeedback.mediumImpact();

    try {
      final result = await goalService.completeMicroAction(
        actionId: action.id,
        goalId: goal.id,
        userId: action.userId,
      );

      // Trigger appropriate celebration
      final CelebrationType celebrationType;
      if (result.goalCompleted) {
        celebrationType = CelebrationType.goalComplete;
      } else if (result.isStreakMilestone) {
        celebrationType = CelebrationType.streakMilestone;
      } else {
        celebrationType = CelebrationType.actionComplete;
      }
      overlay?.celebrate(celebrationType);

      // Show goal completion dialog if goal was completed
      final goalTitle = goal.title;
      if (result.goalCompleted) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (overlay != null && overlay.mounted) {
            GoalCompletionDialog.show(overlay.context, goalTitle);
          }
        });
      }

      // Show streak increase dialog if streak went up (and goal not completed)
      final streakIncreased = result.newStreak > result.previousStreak;
      final newStreak = result.newStreak;
      if (streakIncreased && !result.goalCompleted) {
        // Small delay so confetti starts first
        Future.delayed(const Duration(milliseconds: 400), () {
          // Use overlay's context which stays mounted (it's at the root)
          if (overlay != null && overlay.mounted) {
            StreakCelebrationDialog.show(overlay.context, newStreak);
          }
        });
      }

      // Show appropriate toast (skip if showing dialog)
      if (!result.goalCompleted && !streakIncreased) {
        ToastHelper.showSuccess('+${result.xpEarned} XP earned!');
      }
    } catch (e) {
      ToastHelper.showError('Failed to complete action');
    }
  }
}

class _CompletedGoalCard extends StatelessWidget {
  final Goal goal;

  const _CompletedGoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 0,
        color: Colors.green.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade600),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                    Text(
                      'All actions completed!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationBanner extends StatelessWidget {
  final VoidCallback onEnable;
  final VoidCallback onDismiss;

  const _NotificationBanner({required this.onEnable, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surfaceSubtle,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.notifications_outlined,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stay on track!',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Enable notifications for daily reminders',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onEnable,
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
            ),
            child: const Text('Enable'),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              size: 18,
              color: context.textSecondary,
            ),
            onPressed: onDismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreateGoal;

  const _EmptyState({required this.onCreateGoal});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.rocket_launch_rounded,
              size: 80,
              color: context.borderColor,
            ),
            const SizedBox(height: 24),
            const Text(
              'Ready to start achieving?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first goal and break it down\ninto small, achievable actions.',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onCreateGoal,
              icon: const Icon(Icons.add),
              label: const Text('Create a Goal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _getGreeting(String? name) {
  final hour = DateTime.now().hour;
  String timeGreeting;

  if (hour < 12) {
    timeGreeting = 'Good morning';
  } else if (hour < 17) {
    timeGreeting = 'Good afternoon';
  } else {
    timeGreeting = 'Good evening';
  }

  if (name != null && name.isNotEmpty) {
    return '$timeGreeting, $name';
  }
  return timeGreeting;
}

