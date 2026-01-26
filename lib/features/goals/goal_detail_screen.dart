import 'package:aspire/core/theme/app_theme.dart';
import 'package:aspire/core/utils/toast_helper.dart';
import 'package:aspire/core/widgets/celebration_overlay.dart';
import 'package:aspire/models/goal.dart';
import 'package:aspire/models/micro_action.dart';
import 'package:aspire/services/auth_service.dart';
import 'package:aspire/services/goal_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GoalDetailScreen extends HookConsumerWidget {
  final String goalId;

  const GoalDetailScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalService = ref.read(goalServiceProvider);
    final authService = ref.read(authServiceProvider);
    final userId = authService.currentUser?.uid;

    if (userId == null) {
      return const Scaffold(body: Center(child: Text('Please sign in')));
    }

    return CelebrationOverlay(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Goal Details'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _showEditGoalDialog(context, ref, userId),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showDeleteDialog(context, goalService, userId),
            ),
          ],
        ),
        body: StreamBuilder<List<Goal>>(
          stream: goalService.watchUserGoals(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final goals = snapshot.data ?? [];
            final goal = goals.where((g) => g.id == goalId).firstOrNull;

            if (goal == null) {
              return const Center(child: Text('Goal not found'));
            }

            return _GoalDetailContent(goal: goal);
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddActionDialog(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Add Action'),
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    GoalService goalService,
    String userId,
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
      // Pop first to avoid showing "Goal not found" during delete
      Navigator.pop(context);
      try {
        await goalService.deleteGoal(goalId, userId);
        ToastHelper.showSuccess('Goal deleted');
      } catch (e) {
        ToastHelper.showError('Failed to delete goal');
      }
    }
  }

  Future<void> _showEditGoalDialog(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) async {
    final goalService = ref.read(goalServiceProvider);
    final goal = await goalService.getGoal(goalId);

    if (goal == null || !context.mounted) return;

    final titleController = TextEditingController(text: goal.title);
    final descController = TextEditingController(text: goal.description ?? '');
    GoalCategory selectedCategory = goal.category;
    DateTime? targetDate = goal.targetDate;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Goal',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context, false),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Title
                TextField(
                  controller: titleController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: 'Goal title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                TextField(
                  controller: descController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Category
                Text('Category', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: GoalCategory.values.map((cat) {
                    final isSelected = selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => selectedCategory = cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryPink
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          cat.name[0].toUpperCase() + cat.name.substring(1),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Target date
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: Text(
                    targetDate != null
                        ? '${targetDate!.day}/${targetDate!.month}/${targetDate!.year}'
                        : 'Set target date (optional)',
                  ),
                  trailing: targetDate != null
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() => targetDate = null),
                        )
                      : null,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate:
                          targetDate ??
                          DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(
                        const Duration(days: 365 * 5),
                      ),
                    );
                    if (picked != null) {
                      setState(() => targetDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPink,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );

    if (result == true && titleController.text.trim().isNotEmpty) {
      final updatedGoal = goal.copyWith(
        title: titleController.text.trim(),
        description: descController.text.trim().isNotEmpty
            ? descController.text.trim()
            : null,
        category: selectedCategory,
        targetDate: targetDate,
      );
      await goalService.updateGoal(updatedGoal);
      ToastHelper.showSuccess('Goal updated');
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
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
            stream: goalService.watchGoalActions(goal.id, goal.userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final actions = snapshot.data ?? [];

              if (actions.isEmpty) {
                return _EmptyActionsState(goalId: goal.id, userId: goal.userId);
              }

              return _ActionsList(actions: actions, goalId: goal.id);
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
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),

          if (goal.description != null && goal.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              goal.description!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
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
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
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
                    HapticFeedback.mediumImpact();
                    final result = await goalService.completeMicroAction(
                      actionId: action.id,
                      goalId: goalId,
                      userId: action.userId,
                    );
                    if (context.mounted) {
                      final celebrationType = result.isStreakMilestone
                          ? CelebrationType.streakMilestone
                          : CelebrationType.actionComplete;
                      CelebrationOverlay.of(context)?.celebrate(celebrationType);
                    }
                    if (result.isStreakMilestone) {
                      ToastHelper.showSuccess(
                        '${result.newStreak} day streak! +${result.xpEarned} XP',
                      );
                    } else {
                      ToastHelper.showSuccess('+${result.xpEarned} XP!');
                    }
                  }
                },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
          decoration: const InputDecoration(border: OutlineInputBorder()),
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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
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
