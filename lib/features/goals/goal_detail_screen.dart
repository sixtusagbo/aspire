import 'package:aspire/core/theme/app_theme.dart';
import 'package:aspire/core/utils/toast_helper.dart';
import 'package:aspire/models/goal.dart';
import 'package:aspire/models/micro_action.dart';
import 'package:aspire/services/goal_service.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GoalDetailScreen extends HookConsumerWidget {
  final String goalId;

  const GoalDetailScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalService = ref.read(goalServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // TODO: Edit goal
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteDialog(context, goalService),
          ),
        ],
      ),
      body: StreamBuilder<Goal?>(
        stream: goalService.watchUserGoals('').map(
              (goals) => goals.where((g) => g.id == goalId).firstOrNull,
            ),
        builder: (context, snapshot) {
          // Use FutureBuilder for initial load
          return FutureBuilder<Goal?>(
            future: goalService.getGoal(goalId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final goal = snapshot.data;
              if (goal == null) {
                return const Center(child: Text('Goal not found'));
              }

              return _GoalDetailContent(goal: goal);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddActionDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Action'),
      ),
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    GoalService goalService,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: const Text(
          'Are you sure you want to delete this goal and all its micro-actions?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await goalService.deleteGoal(goalId);
      if (context.mounted) {
        Navigator.pop(context);
        ToastHelper.showSuccess('Goal deleted');
      }
    }
  }

  Future<void> _showAddActionDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final goalService = ref.read(goalServiceProvider);
    final goal = await goalService.getGoal(goalId);

    if (goal == null || !context.mounted) return;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Micro-Action'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'e.g., Research flight prices',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null && result.trim().isNotEmpty) {
      await goalService.createMicroAction(
        goalId: goalId,
        userId: goal.userId,
        title: result.trim(),
      );
      ToastHelper.showSuccess('Action added');
    }
  }
}

class _GoalDetailContent extends HookConsumerWidget {
  final Goal goal;

  const _GoalDetailContent({required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalService = ref.read(goalServiceProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Goal header
        _GoalHeader(goal: goal),

        const Divider(height: 1),

        // Micro-actions section
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Micro-Actions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${goal.completedActionsCount}/${goal.totalActionsCount}',
                  style: TextStyle(
                    color: AppTheme.primaryPink,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Actions list
        Expanded(
          child: StreamBuilder<List<MicroAction>>(
            stream: goalService.watchGoalActions(goal.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final actions = snapshot.data ?? [];

              if (actions.isEmpty) {
                return _EmptyActionsState(goalId: goal.id, userId: goal.userId);
              }

              return _ActionsList(
                actions: actions,
                goalId: goal.id,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _GoalHeader extends StatelessWidget {
  final Goal goal;

  const _GoalHeader({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _categoryColor(goal.category).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _categoryIcon(goal.category),
                  size: 16,
                  color: _categoryColor(goal.category),
                ),
                const SizedBox(width: 6),
                Text(
                  goal.category.name[0].toUpperCase() +
                      goal.category.name.substring(1),
                  style: TextStyle(
                    color: _categoryColor(goal.category),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            goal.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          if (goal.description != null && goal.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              goal.description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ],

          const SizedBox(height: 16),

          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(goal.progress * 100).toInt()}% complete',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  if (goal.daysRemaining != null)
                    Text(
                      '${goal.daysRemaining} days left',
                      style: TextStyle(
                        color: goal.daysRemaining! < 7
                            ? Colors.orange
                            : Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: goal.progress,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(AppTheme.primaryPink),
                  minHeight: 8,
                ),
              ),
            ],
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

class _ActionsList extends HookConsumerWidget {
  final List<MicroAction> actions;
  final String goalId;

  const _ActionsList({required this.actions, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalService = ref.read(goalServiceProvider);

    return ReorderableListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: actions.length,
      onReorder: (oldIndex, newIndex) async {
        if (newIndex > oldIndex) newIndex--;
        final reordered = List<MicroAction>.from(actions);
        final item = reordered.removeAt(oldIndex);
        reordered.insert(newIndex, item);
        await goalService.reorderActions(reordered);
      },
      itemBuilder: (context, index) {
        final action = actions[index];
        return _ActionTile(
          key: ValueKey(action.id),
          action: action,
          goalId: goalId,
        );
      },
    );
  }
}

class _ActionTile extends HookConsumerWidget {
  final MicroAction action;
  final String goalId;

  const _ActionTile({super.key, required this.action, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalService = ref.read(goalServiceProvider);

    return Dismissible(
      key: ValueKey('dismiss_${action.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Action'),
            content: const Text('Delete this micro-action?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) async {
        await goalService.deleteMicroAction(action.id, goalId);
        ToastHelper.showSuccess('Action deleted');
      },
      child: ListTile(
        leading: Checkbox(
          value: action.isCompleted,
          onChanged: action.isCompleted
              ? null
              : (value) async {
                  if (value == true) {
                    await goalService.completeMicroAction(
                      actionId: action.id,
                      goalId: goalId,
                      userId: action.userId,
                    );
                    ToastHelper.showSuccess('+10 XP!');
                  }
                },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          activeColor: AppTheme.primaryPink,
        ),
        title: Text(
          action.title,
          style: TextStyle(
            decoration: action.isCompleted ? TextDecoration.lineThrough : null,
            color: action.isCompleted ? Colors.grey : null,
          ),
        ),
        trailing: ReorderableDragStartListener(
          index: 0, // This will be set by parent
          child: const Icon(Icons.drag_handle, color: Colors.grey),
        ),
        onTap: () => _showEditDialog(context, goalService),
      ),
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    GoalService goalService,
  ) async {
    final controller = TextEditingController(text: action.title);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Action'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result.trim().isNotEmpty && result != action.title) {
      await goalService.updateMicroAction(
        action.copyWith(title: result.trim()),
      );
      ToastHelper.showSuccess('Action updated');
    }
  }
}

class _EmptyActionsState extends HookConsumerWidget {
  final String goalId;
  final String userId;

  const _EmptyActionsState({required this.goalId, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.checklist_rounded,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No micro-actions yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Break down your goal into small,\nachievable steps',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
