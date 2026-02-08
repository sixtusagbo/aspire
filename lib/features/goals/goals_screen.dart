import 'package:aspire/core/theme/app_theme.dart';
import 'package:aspire/core/utils/app_router.dart';
import 'package:aspire/features/goals/widgets/create_goal_sheet.dart';
import 'package:aspire/models/goal.dart';
import 'package:aspire/services/auth_service.dart';
import 'package:aspire/services/goal_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

/// Free tier limit for active goals
const int freeGoalLimit = 3;

class GoalsScreen extends HookConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);
    final goalService = ref.read(goalServiceProvider);
    final user = authService.currentUser;
    final showCompleted = useState(false);
    final isCreatingGoal = useState(false);

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please sign in')));
    }

    Future<void> handleNewGoal() async {
      if (isCreatingGoal.value) return;
      isCreatingGoal.value = true;
      try {
        await showCreateGoalSheet(context, ref, user.uid);
      } finally {
        isCreatingGoal.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Goals'),
        actions: [
          TextButton.icon(
            onPressed: () => showCompleted.value = !showCompleted.value,
            icon: Icon(
              showCompleted.value
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 20,
            ),
            label: Text(showCompleted.value ? 'Hide Done' : 'Show Done'),
          ),
        ],
      ),
      body: StreamBuilder<List<Goal>>(
        stream: showCompleted.value
            ? goalService.watchUserGoals(user.uid)
            : goalService.watchActiveGoals(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final goals = snapshot.data ?? [];

          if (goals.isEmpty) {
            return _EmptyGoalsState(showCompleted: showCompleted.value);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              return _GoalCard(goal: goal);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isCreatingGoal.value ? null : handleNewGoal,
        icon: isCreatingGoal.value
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.add),
        label: Text(isCreatingGoal.value ? 'Loading...' : 'New Goal'),
        shape: const StadiumBorder(),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;

  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.push(AppRoutes.goalDetailPath(goal.id)),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Category icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: goal.categoryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      goal.categoryIcon,
                      size: 20,
                      color: goal.categoryColor,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title and status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                decoration: goal.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                        ),
                        if (goal.daysRemaining != null && !goal.isCompleted)
                          Text(
                            '${goal.daysRemaining} days left',
                            style: TextStyle(
                              color: goal.daysRemaining! < 7
                                  ? Colors.orange
                                  : context.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Passport stamp for completed goals
                  if (goal.isCompleted)
                    _PassportStamp(completedAt: goal.completedAt),
                ],
              ),
              const SizedBox(height: 12),

              // Progress bar
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: goal.progress,
                        backgroundColor:
                            context.isDark ? AppTheme.darkBorder : Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(
                          goal.isCompleted
                              ? Colors.green
                              : AppTheme.primaryPink,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${goal.completedActionsCount}/${goal.totalActionsCount}',
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _EmptyGoalsState extends StatelessWidget {
  final bool showCompleted;

  const _EmptyGoalsState({required this.showCompleted});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            showCompleted ? Icons.check_circle_outline : Icons.flag_outlined,
            size: 64,
            color: context.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            showCompleted ? 'No goals yet' : 'No active goals',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: context.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            showCompleted
                ? 'Create your first goal to get started!'
                : 'All caught up! Create a new goal.',
            style: TextStyle(color: context.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Passport stamp visual for completed goals
class _PassportStamp extends StatelessWidget {
  final DateTime? completedAt;

  const _PassportStamp({this.completedAt});

  @override
  Widget build(BuildContext context) {
    final dateStr = completedAt != null
        ? DateFormat('MMM d').format(completedAt!)
        : 'Done';

    return Transform.rotate(
      angle: -0.1, // Slight tilt for stamp effect
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppTheme.primaryPink,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check,
              color: AppTheme.primaryPink,
              size: 14,
            ),
            Text(
              dateStr.toUpperCase(),
              style: const TextStyle(
                color: AppTheme.primaryPink,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
