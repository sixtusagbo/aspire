import 'package:aspire/core/theme/app_theme.dart';
import 'package:aspire/models/goal.dart';
import 'package:aspire/models/user.dart';
import 'package:aspire/services/auth_service.dart';
import 'package:aspire/services/goal_service.dart';
import 'package:aspire/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProgressScreen extends HookConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);
    final userService = ref.read(userServiceProvider);
    final goalService = ref.read(goalServiceProvider);
    final userId = authService.currentUser?.uid;

    if (userId == null) {
      return const Scaffold(body: Center(child: Text('Please sign in')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: StreamBuilder<AppUser?>(
        stream: userService.watchUser(userId),
        builder: (context, userSnapshot) {
          final user = userSnapshot.data;

          return StreamBuilder<List<Goal>>(
            stream: goalService.watchUserGoals(userId),
            builder: (context, goalsSnapshot) {
              final goals = goalsSnapshot.data ?? [];

              if (userSnapshot.connectionState == ConnectionState.waiting &&
                  user == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatsOverview(user: user, goals: goals),
                    const SizedBox(height: 24),
                    _StreakSection(user: user),
                    const SizedBox(height: 24),
                    _GoalsProgress(goals: goals),
                    const SizedBox(height: 24),
                    _LevelProgress(user: user),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatsOverview extends StatelessWidget {
  final AppUser? user;
  final List<Goal> goals;

  const _StatsOverview({required this.user, required this.goals});

  @override
  Widget build(BuildContext context) {
    final completedGoals = goals.where((g) => g.isCompleted).length;
    final activeGoals = goals.where((g) => !g.isCompleted).length;
    final completedActions =
        goals.fold<int>(0, (sum, g) => sum + g.completedActionsCount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.emoji_events_rounded,
                iconColor: AppTheme.goldAchievement,
                label: 'Goals Done',
                value: '$completedGoals',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.flag_rounded,
                iconColor: AppTheme.primaryPink,
                label: 'Active Goals',
                value: '$activeGoals',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.check_circle_rounded,
                iconColor: Colors.green,
                label: 'Actions Done',
                value: '$completedActions',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.bolt_rounded,
                iconColor: AppTheme.accentCyan,
                label: 'Total XP',
                value: '${user?.xp ?? 0}',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _StreakSection extends StatelessWidget {
  final AppUser? user;

  const _StreakSection({required this.user});

  @override
  Widget build(BuildContext context) {
    final currentStreak = user?.currentStreak ?? 0;
    final longestStreak = user?.longestStreak ?? 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryPink.withValues(alpha: 0.1),
            AppTheme.secondaryPink.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryPink.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Streak',
                    style: TextStyle(
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '$currentStreak ${currentStreak == 1 ? 'day' : 'days'}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryPink,
                        ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StreakMilestone(days: 7, achieved: longestStreak >= 7),
              _StreakMilestone(days: 14, achieved: longestStreak >= 14),
              _StreakMilestone(days: 30, achieved: longestStreak >= 30),
              _StreakMilestone(days: 60, achieved: longestStreak >= 60),
              _StreakMilestone(days: 100, achieved: longestStreak >= 100),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Longest streak: $longestStreak days',
            style: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakMilestone extends StatelessWidget {
  final int days;
  final bool achieved;

  const _StreakMilestone({required this.days, required this.achieved});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: achieved
                  ? AppTheme.goldAchievement
                  : Colors.grey.shade300.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              achieved ? Icons.check : Icons.lock_outline,
              color: achieved ? Colors.white : Colors.grey.shade500,
              size: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$days',
            style: TextStyle(
              fontSize: 11,
              fontWeight: achieved ? FontWeight.bold : FontWeight.normal,
              color: achieved ? AppTheme.goldAchievement : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalsProgress extends StatelessWidget {
  final List<Goal> goals;

  const _GoalsProgress({required this.goals});

  @override
  Widget build(BuildContext context) {
    final activeGoals = goals.where((g) => !g.isCompleted).toList();

    if (activeGoals.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Goals',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ...activeGoals.map((goal) => _GoalProgressCard(goal: goal)),
      ],
    );
  }
}

class _GoalProgressCard extends StatelessWidget {
  final Goal goal;

  const _GoalProgressCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _categoryIcon(goal.category),
                color: _categoryColor(goal.category),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  goal.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${(goal.progress * 100).toInt()}%',
                style: TextStyle(
                  color: AppTheme.primaryPink,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: goal.progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(_categoryColor(goal.category)),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${goal.completedActionsCount} of ${goal.totalActionsCount} actions completed',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
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

class _LevelProgress extends StatelessWidget {
  final AppUser? user;

  const _LevelProgress({required this.user});

  @override
  Widget build(BuildContext context) {
    final level = user?.level ?? 1;
    final xp = user?.xp ?? 0;
    final xpForCurrentLevel = _xpForLevel(level);
    final xpForNextLevel = _xpForLevel(level + 1);
    final xpProgress = xpForNextLevel > xpForCurrentLevel
        ? (xp - xpForCurrentLevel) / (xpForNextLevel - xpForCurrentLevel)
        : 0.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.accentCyan, AppTheme.accentTeal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$level',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level $level',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      _levelTitle(level),
                      style: TextStyle(
                        color: AppTheme.accentCyan,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$xp XP',
                style: TextStyle(
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$xpForNextLevel XP',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: xpProgress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation(AppTheme.accentCyan),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${xpForNextLevel - xp} XP until Level ${level + 1}',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
    );
  }

  int _xpForLevel(int level) {
    // Simple exponential XP curve
    return (level * level * 50);
  }

  String _levelTitle(int level) {
    if (level < 5) return 'Dreamer';
    if (level < 10) return 'Achiever';
    if (level < 20) return 'Go-Getter';
    if (level < 30) return 'Trailblazer';
    if (level < 50) return 'Unstoppable';
    return 'Legend';
  }
}
