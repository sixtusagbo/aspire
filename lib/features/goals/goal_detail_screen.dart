import 'package:aspire/core/theme/app_theme.dart';
import 'package:aspire/core/theme/category_colors.dart';
import 'package:aspire/core/utils/app_router.dart';
import 'package:aspire/core/utils/toast_helper.dart';
import 'package:aspire/core/widgets/celebration_overlay.dart';
import 'package:aspire/models/goal.dart';
import 'package:aspire/models/micro_action.dart';
import 'package:aspire/services/ai_service.dart';
import 'package:aspire/services/auth_service.dart';
import 'package:aspire/services/goal_service.dart';
import 'package:aspire/services/notification_service.dart';
import 'package:aspire/services/revenue_cat_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Action limits per goal
const int freeActionLimit = 5;
const int premiumActionLimit = 10;

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
              onPressed: () => _showDeleteDialog(context, ref, goalService, userId),
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
    WidgetRef ref,
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
        // Cancel any goal reminder
        final notificationService = ref.read(notificationServiceProvider);
        await notificationService.cancelGoalReminder(goalId);

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
                              : context.surfaceSubtle,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          cat.name[0].toUpperCase() + cat.name.substring(1),
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : context.textPrimary,
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
    final goalService = ref.read(goalServiceProvider);
    final revenueCatService = ref.read(revenueCatServiceProvider);
    final goal = await goalService.getGoal(goalId);

    if (goal == null || !context.mounted) return;

    // Check action limit
    final isPremium = await revenueCatService.isPremium();
    final actionLimit = isPremium ? premiumActionLimit : freeActionLimit;
    final currentCount = goal.totalActionsCount;

    if (currentCount >= actionLimit) {
      if (!context.mounted) return;
      await _showActionLimitDialog(context, isPremium, actionLimit);
      return;
    }

    final controller = TextEditingController();
    if (!context.mounted) return;

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

  Future<void> _showActionLimitDialog(
    BuildContext context,
    bool isPremium,
    int limit,
  ) async {
    if (isPremium) {
      // Premium users have hit the max limit
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Action Limit Reached'),
          content: Text(
            'You have $limit micro-actions for this goal. '
            'Complete or remove some actions to add more.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // Free users - prompt upgrade
      final upgrade = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Upgrade to Add More'),
          content: Text(
            'Free accounts can have up to $limit micro-actions per goal. '
            'Upgrade to premium for up to $premiumActionLimit actions per goal!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Upgrade'),
            ),
          ],
        ),
      );

      if (upgrade == true && context.mounted) {
        context.push('/paywall');
      }
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

        // Custom reminder section (premium feature)
        if (!goal.isCompleted) _GoalReminderSection(goal: goal),

        // Mark as complete button (only show if not completed and has actions)
        if (!goal.isCompleted && goal.totalActionsCount > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showMarkCompleteDialog(context, goalService),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Mark Goal as Complete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.goldAchievement,
                  foregroundColor: Colors.white,
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
              // AI Generate button (only show if there are already actions)
              if (!goal.isCompleted && goal.totalActionsCount > 0)
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
                  label: Text(
                    isGenerating.value ? 'Generating...' : 'AI Generate',
                  ),
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
          'This will mark all micro-actions as done and celebrate your achievement!',
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
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Completing goal...'),
            ],
          ),
        ),
      );

      try {
        // Mark all incomplete actions as complete first
        final actions = await goalService
            .watchGoalActions(goal.id, goal.userId)
            .first;
        for (final action in actions) {
          if (!action.isCompleted) {
            await goalService.completeMicroAction(
              actionId: action.id,
              goalId: goal.id,
              userId: goal.userId,
            );
          }
        }

        // Then complete the goal
        await goalService.completeGoal(goal.id);

        if (context.mounted) {
          // Dismiss loading dialog
          Navigator.pop(context);

          // Celebrate
          final overlay = CelebrationOverlay.of(context);
          overlay?.celebrate(CelebrationType.goalComplete);
          HapticFeedback.heavyImpact();
          ToastHelper.showSuccess('Congratulations! Goal completed!');
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context); // Dismiss loading
          ToastHelper.showError('Failed to complete goal');
        }
      }
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
      // Check premium status and limits
      final revenueCatService = ref.read(revenueCatServiceProvider);
      final isPremium = await revenueCatService.isPremium();
      final actionLimit = isPremium ? premiumActionLimit : freeActionLimit;
      final currentActionCount = goal.totalActionsCount;

      // Get existing actions to provide context to AI
      final existingActions =
          await goalService.watchGoalActions(goal.id, goal.userId).first;
      final existingActionInfo = existingActions
          .map((a) => ExistingActionInfo(
                title: a.title,
                isCompleted: a.isCompleted,
              ))
          .toList();

      final aiResult = await aiService.generateMicroActions(
        goalTitle: goal.title,
        goalDescription: goal.description,
        category: goal.category.name,
        targetDate: goal.targetDate,
        existingActions: existingActionInfo,
        actionLimit: actionLimit,
      );

      if (!context.mounted) return;

      // Show review bottom sheet with limit info and AI's mode suggestion
      final result = await showModalBottomSheet<_AIActionsResult>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        isDismissible: false,
        enableDrag: false,
        builder: (context) => _AIActionsReviewSheet(
          actions: aiResult.actions,
          goalTitle: goal.title,
          isPremium: isPremium,
          actionLimit: actionLimit,
          currentActionCount: currentActionCount,
          suggestReplace: aiResult.suggestReplace,
        ),
      );

      // Save the approved actions
      if (result != null && result.actions.isNotEmpty && context.mounted) {
        // If replace mode, delete existing actions first
        if (result.replaceMode) {
          final existingActions = await goalService
              .watchGoalActions(goal.id, goal.userId)
              .first;
          for (final action in existingActions) {
            await goalService.deleteMicroAction(action.id, goal.id);
          }
        }

        for (final action in result.actions) {
          await goalService.createMicroAction(
            goalId: goal.id,
            userId: goal.userId,
            title: action.title,
            sortOrder: action.sortOrder,
          );
        }
        ToastHelper.showSuccess(
          result.replaceMode
              ? '${result.actions.length} actions replaced!'
              : '${result.actions.length} actions added!',
        );
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

/// Result from AI actions review sheet
class _AIActionsResult {
  final List<GeneratedAction> actions;
  final bool replaceMode;

  _AIActionsResult({required this.actions, required this.replaceMode});
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
              color: goal.category.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  goal.category.icon,
                  size: 16,
                  color: goal.category.color,
                ),
                const SizedBox(width: 6),
                Text(
                  goal.category.label,
                  style: TextStyle(
                    color: goal.category.color,
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
              ).textTheme.bodyMedium?.copyWith(color: context.textSecondary),
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
                    style: TextStyle(color: context.textSecondary, fontSize: 13),
                  ),
                  if (goal.daysRemaining != null)
                    Text(
                      '${goal.daysRemaining} days left',
                      style: TextStyle(
                        color: goal.daysRemaining! < 7
                            ? Colors.orange
                            : context.textSecondary,
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
                  backgroundColor: context.borderColor,
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
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
              style: TextStyle(color: context.textSecondary),
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
              style: TextStyle(color: context.textSecondary, fontSize: 12),
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
  final bool isPremium;
  final int actionLimit;
  final int currentActionCount;
  final bool suggestReplace;

  const _AIActionsReviewSheet({
    required this.actions,
    required this.goalTitle,
    required this.isPremium,
    required this.actionLimit,
    required this.currentActionCount,
    this.suggestReplace = false,
  });

  @override
  State<_AIActionsReviewSheet> createState() => _AIActionsReviewSheetState();
}

class _AIActionsReviewSheetState extends State<_AIActionsReviewSheet> {
  late List<_EditableAction> _editableActions;
  late bool _replaceMode;

  /// How many actions can be added in current mode
  int get _availableSlots {
    if (_replaceMode) {
      return widget.actionLimit;
    }
    return (widget.actionLimit - widget.currentActionCount)
        .clamp(0, widget.actionLimit);
  }

  /// Whether we're over the limit
  bool get _isOverLimit => _editableActions.length > _availableSlots;

  @override
  void initState() {
    super.initState();
    // Use AI's suggestion, or default to replace if at limit
    _replaceMode = widget.suggestReplace ||
        widget.currentActionCount >= widget.actionLimit;

    // Initialize editable actions, trimmed to available slots
    final allActions = widget.actions
        .map((a) => _EditableAction(title: a.title, sortOrder: a.sortOrder))
        .toList();

    // Limit to available slots initially
    final slotsAvailable =
        _replaceMode ? widget.actionLimit : _availableSlots;
    _editableActions = allActions.take(slotsAvailable).toList();
  }

  @override
  Widget build(BuildContext context) {
    final actionCount = _editableActions.length;
    final hasExistingActions = widget.currentActionCount > 0;

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
                color: context.borderColor,
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
                  style: TextStyle(color: context.textSecondary),
                ),
                const SizedBox(height: 8),
                // Limit indicator
                _buildLimitInfo(context),
              ],
            ),
          ),

          // Replace/Append toggle (only show if user has existing actions)
          if (hasExistingActions) _buildModeToggle(context),

          const Divider(height: 1),

          // Actions list
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _editableActions.length,
              itemBuilder: (context, index) {
                final action = _editableActions[index];
                final isOverLimit = index >= _availableSlots;
                return _AIActionTile(
                  action: action,
                  index: index,
                  isDisabled: isOverLimit,
                  onEdit: isOverLimit ? null : () => _editAction(index),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isOverLimit && !widget.isPremium) ...[
                  _buildUpgradePrompt(context),
                  const SizedBox(height: 12),
                ],
                Row(
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
                        onPressed: actionCount > 0 && !_isOverLimit
                            ? () => _submitActions()
                            : null,
                        icon: const Icon(Icons.check),
                        label: Text(_replaceMode
                            ? 'Replace with $actionCount'
                            : 'Add $actionCount Actions'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryPink,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitInfo(BuildContext context) {
    final adding = _editableActions.length;
    final slotsLeft = _availableSlots - adding;
    final isOver = adding > _availableSlots;

    // Simple, friendly message
    String message;
    if (isOver) {
      final excess = adding - _availableSlots;
      message = 'Remove $excess to continue';
    } else if (slotsLeft == 0) {
      message = 'All $adding slots filled';
    } else {
      message = '$adding selected';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isOver ? Colors.orange.shade50 : context.surfaceSubtle,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isOver ? Icons.warning_amber_rounded : Icons.check_circle_outline,
            size: 16,
            color: isOver ? Colors.orange.shade700 : AppTheme.accentCyan,
          ),
          const SizedBox(width: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isOver ? Colors.orange.shade700 : context.textSecondary,
            ),
          ),
          const Spacer(),
          if (!widget.isPremium && !isOver)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.push('/paywall');
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Get more',
                style: TextStyle(fontSize: 12, color: AppTheme.primaryPink),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModeToggle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: _ModeButton(
              label: 'Add to existing',
              isSelected: !_replaceMode,
              onTap: () => _setMode(replaceMode: false),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ModeButton(
              label: 'Replace all',
              isSelected: _replaceMode,
              onTap: () => _setMode(replaceMode: true),
            ),
          ),
        ],
      ),
    );
  }

  void _setMode({required bool replaceMode}) {
    if (_replaceMode == replaceMode) return;
    setState(() {
      _replaceMode = replaceMode;
      // Re-trim actions to new available slots
      final slotsAvailable =
          replaceMode ? widget.actionLimit : _availableSlots;
      if (_editableActions.length > slotsAvailable) {
        _editableActions = _editableActions.take(slotsAvailable).toList();
      }
    });
  }

  Widget _buildUpgradePrompt(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryPink.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryPink.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, color: AppTheme.primaryPink, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Upgrade for $premiumActionLimit actions per goal',
              style: TextStyle(fontSize: 13, color: context.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/paywall');
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  void _submitActions() {
    final actions = _editableActions
        .take(_availableSlots)
        .map((a) => GeneratedAction(title: a.title, sortOrder: a.sortOrder))
        .toList();

    Navigator.pop(
      context,
      _AIActionsResult(actions: actions, replaceMode: _replaceMode),
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

  _EditableAction({required this.title, required this.sortOrder});
}

class _AIActionTile extends StatelessWidget {
  final _EditableAction action;
  final int index;
  final VoidCallback? onEdit;
  final VoidCallback onDelete;
  final bool isDisabled;

  const _AIActionTile({
    required this.action,
    required this.index,
    this.onEdit,
    required this.onDelete,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: ListTile(
        leading: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isDisabled
                ? context.borderColor
                : AppTheme.accentCyan.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            '${index + 1}',
            style: TextStyle(
              color: isDisabled ? context.textSecondary : AppTheme.accentCyan,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        title: Text(
          action.title,
          style: TextStyle(
            decoration: isDisabled ? TextDecoration.lineThrough : null,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isDisabled)
              IconButton(
                icon: Icon(Icons.edit_outlined, color: context.textSecondary),
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
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryPink.withValues(alpha: 0.1)
              : context.surfaceSubtle,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryPink
                : context.borderColor,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppTheme.primaryPink : context.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Custom reminder settings for a goal (premium feature)
class _GoalReminderSection extends HookConsumerWidget {
  final Goal goal;

  const _GoalReminderSection({required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revenueCatService = ref.read(revenueCatServiceProvider);
    final goalService = ref.read(goalServiceProvider);
    final notificationService = ref.read(notificationServiceProvider);
    final isUpdating = useState(false);

    Future<void> handleToggle(bool enabled) async {
      // Check premium status
      final isPremium = await revenueCatService.isPremium();
      if (!isPremium) {
        if (context.mounted) {
          _showPremiumDialog(context);
        }
        return;
      }

      isUpdating.value = true;
      try {
        if (enabled) {
          // Default to 9:00 AM if no time set
          final hour = goal.reminderHour ?? 9;
          final minute = goal.reminderMinute ?? 0;

          await goalService.updateGoalReminder(
            goalId: goal.id,
            enabled: true,
            hour: hour,
            minute: minute,
          );

          // Schedule notification
          await notificationService.scheduleGoalReminder(
            goalId: goal.id,
            goalTitle: goal.title,
            hour: hour,
            minute: minute,
          );

          ToastHelper.showSuccess('Reminder set for ${_formatTime(hour, minute)}');
        } else {
          await goalService.updateGoalReminder(
            goalId: goal.id,
            enabled: false,
            hour: null,
            minute: null,
          );

          // Cancel notification
          await notificationService.cancelGoalReminder(goal.id);

          ToastHelper.showInfo('Reminder disabled');
        }
      } catch (e) {
        ToastHelper.showError('Failed to update reminder');
      } finally {
        isUpdating.value = false;
      }
    }

    Future<void> handleTimeChange() async {
      final picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(
          hour: goal.reminderHour ?? 9,
          minute: goal.reminderMinute ?? 0,
        ),
      );

      if (picked != null) {
        isUpdating.value = true;
        try {
          await goalService.updateGoalReminder(
            goalId: goal.id,
            enabled: true,
            hour: picked.hour,
            minute: picked.minute,
          );

          // Reschedule notification
          await notificationService.scheduleGoalReminder(
            goalId: goal.id,
            goalTitle: goal.title,
            hour: picked.hour,
            minute: picked.minute,
          );

          ToastHelper.showSuccess(
            'Reminder updated to ${_formatTime(picked.hour, picked.minute)}',
          );
        } catch (e) {
          ToastHelper.showError('Failed to update reminder time');
        } finally {
          isUpdating.value = false;
        }
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surfaceSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.notifications_outlined,
                size: 20,
                color: goal.reminderEnabled
                    ? AppTheme.primaryPink
                    : context.textSecondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Custom Reminder',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.goldAchievement.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Premium',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.goldAchievement,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Get a daily nudge for this goal',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isUpdating.value)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Switch.adaptive(
                  value: goal.reminderEnabled,
                  onChanged: handleToggle,
                  activeTrackColor: AppTheme.primaryPink,
                ),
            ],
          ),
          if (goal.reminderEnabled && goal.hasReminderTime) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: isUpdating.value ? null : handleTimeChange,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.borderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: context.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatTime(goal.reminderHour!, goal.reminderMinute!),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.edit,
                      size: 14,
                      color: context.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(int hour, int minute) {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    final period = hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Feature'),
        content: const Text(
          'Custom reminders per goal is a premium feature.\n\n'
          'Upgrade to set different reminder times for each goal!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push(AppRoutes.paywall);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPink,
              foregroundColor: Colors.white,
            ),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }
}
