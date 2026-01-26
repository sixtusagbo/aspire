import 'package:aspire/core/theme/app_theme.dart';
import 'package:aspire/core/utils/app_router.dart';
import 'package:aspire/core/utils/toast_helper.dart';
import 'package:aspire/core/widgets/celebration_overlay.dart';
import 'package:aspire/core/widgets/streak_celebration_dialog.dart';
import 'package:aspire/features/home/widgets/stats_bar.dart';
import 'package:aspire/models/goal.dart';
import 'package:aspire/models/micro_action.dart';
import 'package:aspire/models/user.dart';
import 'package:aspire/services/auth_service.dart';
import 'package:aspire/services/goal_service.dart';
import 'package:aspire/services/log_service.dart';
import 'package:aspire/services/notification_service.dart';
import 'package:aspire/services/user_service.dart';
import 'package:flutter/foundation.dart';
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
    final userService = ref.read(userServiceProvider);
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: StreamBuilder<AppUser?>(
        stream: userService.watchUser(userId),
        builder: (context, userSnapshot) {
          final user = userSnapshot.data;

          return RefreshIndicator(
            onRefresh: () async {
              // Just trigger rebuild
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

                // Stats bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: user != null
                        ? StatsBar(user: user)
                        : _buildStatsPlaceholder(),
                  ),
                ),

                // Debug buttons (only in debug mode)
                if (kDebugMode)
                  SliverToBoxAdapter(
                    child: _DebugStreakButtons(userId: userId),
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
          );
        },
      ),
    );
  }

  Widget _buildStatsPlaceholder() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: CircularProgressIndicator()),
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
            child: _EmptyState(onCreateGoal: () => context.go(AppRoutes.goals)),
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
                      _categoryIcon(goal.category),
                      size: 16,
                      color: _categoryColor(goal.category),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        goal.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${goal.completedActionsCount}/${goal.totalActionsCount}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
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

  Color _categoryColor(GoalCategory category) {
    return switch (category) {
      GoalCategory.travel => Colors.blue,
      GoalCategory.career => Colors.orange,
      GoalCategory.finance => Colors.green,
      GoalCategory.wellness => Colors.pink,
      GoalCategory.personal => Colors.purple,
    };
  }

  IconData _categoryIcon(GoalCategory category) {
    return switch (category) {
      GoalCategory.travel => Icons.flight_rounded,
      GoalCategory.career => Icons.work_rounded,
      GoalCategory.finance => Icons.attach_money_rounded,
      GoalCategory.wellness => Icons.favorite_rounded,
      GoalCategory.personal => Icons.star_rounded,
    };
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
        side: BorderSide(color: Colors.grey.shade200),
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

      // Show streak increase dialog if streak went up
      final streakIncreased = result.newStreak > result.previousStreak;
      final newStreak = result.newStreak;
      if (streakIncreased) {
        // Small delay so confetti starts first
        Future.delayed(const Duration(milliseconds: 400), () {
          // Use overlay's context which stays mounted (it's at the root)
          if (overlay != null && overlay.mounted) {
            StreakCelebrationDialog.show(overlay.context, newStreak);
          }
        });
      }

      // Show appropriate toast (skip if showing streak dialog)
      if (result.goalCompleted) {
        ToastHelper.showSuccess('Goal completed! +${result.xpEarned} XP');
      } else if (!streakIncreased) {
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
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_outlined, color: Colors.amber.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stay on track!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
                ),
                Text(
                  'Enable notifications for daily reminders',
                  style: TextStyle(fontSize: 12, color: Colors.amber.shade800),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onEnable,
            child: const Text('Enable'),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
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
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rocket_launch_rounded,
              size: 80,
              color: Colors.grey.shade300,
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
              style: TextStyle(color: Colors.grey.shade600, height: 1.4),
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

/// Debug buttons for testing streak milestones (only visible in debug mode)
class _DebugStreakButtons extends ConsumerWidget {
  final String userId;

  const _DebugStreakButtons({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DEBUG: Reset & Set Streak (clears all data)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildButton(context, ref, 0),
                _buildButton(context, ref, 6),
                _buildButton(context, ref, 7),
                _buildButton(context, ref, 14),
                _buildButton(context, ref, 30),
                _buildButton(context, ref, 60),
                _buildButton(context, ref, 100),
                _buildButton(context, ref, 365),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, WidgetRef ref, int streak) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: () => _seedData(ref, streak),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange.shade100,
          foregroundColor: Colors.orange.shade900,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        child: Text('$streak'),
      ),
    );
  }

  Future<void> _seedData(WidgetRef ref, int streak) async {
    final userService = ref.read(userServiceProvider);
    final goalService = ref.read(goalServiceProvider);

    try {
      Log.i('Debug: Seeding data with streak $streak...');

      // 1. Delete all existing goals (this cascades to actions)
      final existingGoals = await goalService.watchUserGoals(userId).first;
      for (final goal in existingGoals) {
        await goalService.deleteGoal(goal.id, userId);
      }
      Log.d('Deleted ${existingGoals.length} existing goals');

      // 2. Reset user stats - set lastActivityDate to yesterday so next
      // action completion will increment the streak
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      await userService.updateUser(userId, {
        'currentStreak': streak,
        'longestStreak': streak > 0 ? streak : 0,
        'xp': 0,
        'level': 1,
        'lastActivityDate': yesterday,
      });

      // 3. Create test goals with actions
      final goal1 = await goalService.createGoal(
        userId: userId,
        title: 'Learn a new language',
        description: 'Become conversational in Spanish',
        category: GoalCategory.personal,
        targetDate: DateTime.now().add(const Duration(days: 90)),
      );
      await goalService.createMicroAction(
        goalId: goal1.id,
        userId: userId,
        title: 'Practice on Duolingo for 10 min',
      );
      await goalService.createMicroAction(
        goalId: goal1.id,
        userId: userId,
        title: 'Watch a Spanish YouTube video',
      );
      await goalService.createMicroAction(
        goalId: goal1.id,
        userId: userId,
        title: 'Learn 5 new vocabulary words',
      );

      final goal2 = await goalService.createGoal(
        userId: userId,
        title: 'Save for dream trip',
        description: 'Save \$3000 for Japan trip',
        category: GoalCategory.travel,
        targetDate: DateTime.now().add(const Duration(days: 180)),
      );
      await goalService.createMicroAction(
        goalId: goal2.id,
        userId: userId,
        title: 'Transfer \$50 to savings',
      );
      await goalService.createMicroAction(
        goalId: goal2.id,
        userId: userId,
        title: 'Skip one takeout meal this week',
      );

      final goal3 = await goalService.createGoal(
        userId: userId,
        title: 'Get promoted',
        description: 'Reach senior level by end of year',
        category: GoalCategory.career,
        targetDate: DateTime.now().add(const Duration(days: 365)),
      );
      await goalService.createMicroAction(
        goalId: goal3.id,
        userId: userId,
        title: 'Ask manager for feedback',
      );
      await goalService.createMicroAction(
        goalId: goal3.id,
        userId: userId,
        title: 'Complete one online course module',
      );

      Log.i('Debug: Seeded 3 goals with actions, streak=$streak');
      ToastHelper.showSuccess('Reset! Streak: $streak');
    } catch (e, stack) {
      Log.e('Failed to seed data', error: e, stackTrace: stack);
      ToastHelper.showError('Failed to seed');
    }
  }
}
