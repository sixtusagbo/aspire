import 'package:aspire/core/theme/app_theme.dart';
import 'package:aspire/core/utils/toast_helper.dart';
import 'package:aspire/core/widgets/celebration_overlay.dart';
import 'package:aspire/models/goal.dart';
import 'package:aspire/models/micro_action.dart';
import 'package:aspire/services/ai_service.dart';
import 'package:aspire/services/auth_service.dart';
import 'package:aspire/services/goal_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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
    final aiService = ref.read(aiServiceProvider);
    final isGenerating = useState(false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Goal header with mark complete
        _GoalHeader(goal: goal),

        // Mark as complete button (only show if not completed and has actions)
        if (!goal.isCompleted && goal.totalActionsCount > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showMarkCompleteDialog(context, goalService),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Mark Goal as Complete'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.goldAchievement,
                  side: BorderSide(color: AppTheme.goldAchievement),
                ),
              ),
            ),
          ),

        const SizedBox(height: 8),
        const Divider(height: 1),

        // Micro-actions section header
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
              const Spacer(),
              // AI Generate button
              if (!goal.isCompleted)
                TextButton.icon(
                  onPressed: isGenerating.value
                      ? null
                      : () => _generateAIActions(
                            context,
                            ref,
                            goal,
                            aiService,
                            goalService,
                            isGenerating,
                          ),
                  icon: isGenerating.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome, size: 18),
                  label: Text(isGenerating.value ? 'Generating...' : 'AI Generate'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.accentCyan,
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
                return _EmptyActionsState(
                  goal: goal,
                  onGenerateAI: isGenerating.value
                      ? null
                      : () => _generateAIActions(
                            context,
                            ref,
                            goal,
                            aiService,
                            goalService,
                            isGenerating,
                          ),
                  isGenerating: isGenerating.value,
                );
              }

              return _ActionsList(actions: actions, goalId: goal.id);
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showMarkCompleteDialog(
    BuildContext context,
    GoalService goalService,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Goal'),
        content: Text(
          'Mark "${goal.title}" as complete?\n\n'
          'This will celebrate your achievement!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.goldAchievement,
              foregroundColor: Colors.white,
            ),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final overlay = CelebrationOverlay.of(context);
      await goalService.completeGoal(goal.id);
      overlay?.celebrate(CelebrationType.goalComplete);
      HapticFeedback.heavyImpact();
      ToastHelper.showSuccess('Congratulations! Goal completed!');
    }
  }

  Future<void> _generateAIActions(
    BuildContext context,
    WidgetRef ref,
    Goal goal,
    AIService aiService,
    GoalService goalService,
    ValueNotifier<bool> isGenerating,
  ) async {
    isGenerating.value = true;

    try {
      final actions = await aiService.generateMicroActions(
        goalTitle: goal.title,
        goalDescription: goal.description,
        category: goal.category.name,
        targetDate: goal.targetDate,
      );

      if (!context.mounted) return;

      // Show review bottom sheet
      final result = await showModalBottomSheet<List<GeneratedAction>>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (context) => _AIActionsReviewSheet(
          actions: actions,
          goalTitle: goal.title,
        ),
      );

      // Save the approved actions
      if (result != null && result.isNotEmpty && context.mounted) {
        for (final action in result) {
          await goalService.createMicroAction(
            goalId: goal.id,
            userId: goal.userId,
            title: action.title,
            sortOrder: action.sortOrder,
          );
        }
        ToastHelper.showSuccess('${result.length} actions added!');
      }
    } catch (e) {
      if (context.mounted) {
        ToastHelper.showError('Failed to generate actions. Please try again.');
      }
    } finally {
      isGenerating.value = false;
    }
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
                    // Capture overlay BEFORE async call
                    final overlay = CelebrationOverlay.of(context);
                    HapticFeedback.mediumImpact();
                    final result = await goalService.completeMicroAction(
                      actionId: action.id,
                      goalId: goalId,
                      userId: action.userId,
                    );

                    // Trigger celebration
                    final CelebrationType celebrationType;
                    if (result.goalCompleted) {
                      celebrationType = CelebrationType.goalComplete;
                    } else if (result.isStreakMilestone) {
                      celebrationType = CelebrationType.streakMilestone;
                    } else {
                      celebrationType = CelebrationType.actionComplete;
                    }
                    overlay?.celebrate(celebrationType);

                    // Show toast
                    if (result.goalCompleted) {
                      ToastHelper.showSuccess(
                        'Goal completed! +${result.xpEarned} XP',
                      );
                    } else if (result.isStreakMilestone) {
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

class _EmptyActionsState extends StatelessWidget {
  final Goal goal;
  final VoidCallback? onGenerateAI;
  final bool isGenerating;

  const _EmptyActionsState({
    required this.goal,
    required this.onGenerateAI,
    required this.isGenerating,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 64,
              color: AppTheme.accentCyan.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'No micro-actions yet',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Let AI help break down your goal into\nsmall, achievable daily steps',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onGenerateAI,
              icon: isGenerating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(isGenerating ? 'Generating...' : 'Generate with AI'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCyan,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Or tap + to add manually',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet to review AI-generated actions before saving
class _AIActionsReviewSheet extends StatefulWidget {
  final List<GeneratedAction> actions;
  final String goalTitle;

  const _AIActionsReviewSheet({
    required this.actions,
    required this.goalTitle,
  });

  @override
  State<_AIActionsReviewSheet> createState() => _AIActionsReviewSheetState();
}

class _AIActionsReviewSheetState extends State<_AIActionsReviewSheet> {
  late List<_EditableAction> _editableActions;

  @override
  void initState() {
    super.initState();
    _editableActions = widget.actions
        .map((a) => _EditableAction(
              title: a.title,
              sortOrder: a.sortOrder,
              isSelected: true,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _editableActions.where((a) => a.isSelected).length;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: AppTheme.accentCyan),
                    const SizedBox(width: 8),
                    Text(
                      'AI Suggestions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Review and edit the suggested actions for "${widget.goalTitle}"',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Actions list
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _editableActions.length,
              itemBuilder: (context, index) {
                final action = _editableActions[index];
                return _AIActionTile(
                  action: action,
                  onToggle: () {
                    setState(() {
                      action.isSelected = !action.isSelected;
                    });
                  },
                  onEdit: () => _editAction(index),
                  onDelete: () {
                    setState(() {
                      _editableActions.removeAt(index);
                    });
                  },
                );
              },
            ),
          ),

          // Bottom buttons
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              16 + MediaQuery.of(context).viewPadding.bottom,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: selectedCount > 0
                        ? () {
                            final selected = _editableActions
                                .where((a) => a.isSelected)
                                .map((a) => GeneratedAction(
                                      title: a.title,
                                      sortOrder: a.sortOrder,
                                    ))
                                .toList();
                            Navigator.pop(context, selected);
                          }
                        : null,
                    icon: const Icon(Icons.check),
                    label: Text('Add $selectedCount Actions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPink,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editAction(int index) async {
    final action = _editableActions[index];
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
            hintText: 'Action title',
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

    if (result != null && result.trim().isNotEmpty) {
      setState(() {
        action.title = result.trim();
      });
    }
  }
}

class _EditableAction {
  String title;
  int sortOrder;
  bool isSelected;

  _EditableAction({
    required this.title,
    required this.sortOrder,
    required this.isSelected,
  });
}

class _AIActionTile extends StatelessWidget {
  final _EditableAction action;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AIActionTile({
    required this.action,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: action.isSelected,
        onChanged: (_) => onToggle(),
        activeColor: AppTheme.primaryPink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      title: Text(
        action.title,
        style: TextStyle(
          color: action.isSelected ? null : Colors.grey,
          decoration: action.isSelected ? null : TextDecoration.lineThrough,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: Colors.grey.shade600),
            onPressed: onEdit,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
            onPressed: onDelete,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
