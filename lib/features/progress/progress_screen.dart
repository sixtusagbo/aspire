import 'package:aspire/core/theme/app_theme.dart';
import 'package:aspire/features/home/widgets/stats_bar.dart';
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
                    if (user != null) StatsBar(user: user, showStreak: false),
                    if (user != null) const SizedBox(height: 24),
                    _StreakSection(user: user),
                    const SizedBox(height: 24),
                    _GoalsProgress(goals: goals),
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
                iconColor: AppTheme.primaryPink,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceSubtle,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
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
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 13,
            ),
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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryPink.withValues(alpha: 0.1),
            AppTheme.coralSunset.withValues(alpha: 0.05),
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
                      color: context.textSecondary,
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
              color: context.textSecondary,
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
                  ? AppTheme.primaryPink
                  : context.borderColor.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              achieved ? Icons.check : Icons.lock_outline,
              color: achieved
                  ? Colors.white
                  : context.textSecondary,
              size: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$days',
            style: TextStyle(
              fontSize: 11,
              fontWeight:
                  achieved ? FontWeight.bold : FontWeight.normal,
              color: achieved
                  ? AppTheme.primaryPink
                  : context.textSecondary,
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.surfaceSubtle,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.borderColor),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.flag_rounded,
                  size: 48,
                  color: AppTheme.primaryPink.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No active goals yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start your journey by setting a goal.\nEvery big achievement begins with a single step.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                goal.categoryIcon,
                color: goal.categoryColor,
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
              backgroundColor: context.borderColor,
              valueColor:
                  AlwaysStoppedAnimation(goal.categoryColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${goal.completedActionsCount} of ${goal.totalActionsCount} actions completed',
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

