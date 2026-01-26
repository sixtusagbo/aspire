import 'package:aspire/core/theme/app_theme.dart';
import 'package:aspire/core/utils/app_router.dart';
import 'package:aspire/models/goal.dart';
import 'package:aspire/services/auth_service.dart';
import 'package:aspire/services/goal_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GoalsScreen extends HookConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);
    final goalService = ref.read(goalServiceProvider);
    final user = authService.currentUser;
    final showCompleted = useState(false);

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please sign in')));
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
        onPressed: () => _showCreateGoalSheet(context, ref, user.uid),
        icon: const Icon(Icons.add),
        label: const Text('New Goal'),
      ),
    );
  }

  Future<void> _showCreateGoalSheet(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    GoalCategory selectedCategory = GoalCategory.personal;
    DateTime? targetDate;

    await showModalBottomSheet(
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
                      'Create New Goal',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
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
                    labelText: 'What\'s your goal?',
                    hintText: 'e.g., Visit Japan',
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
                    labelText: 'Why is this important? (optional)',
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

                // Create button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (titleController.text.trim().isEmpty) return;

                      final goalService = ref.read(goalServiceProvider);
                      final goal = await goalService.createGoal(
                        userId: userId,
                        title: titleController.text.trim(),
                        description: descController.text.trim().isNotEmpty
                            ? descController.text.trim()
                            : null,
                        targetDate: targetDate,
                        category: selectedCategory,
                      );

                      if (context.mounted) {
                        Navigator.pop(context);
                        context.push(AppRoutes.goalDetailPath(goal.id));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPink,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Create Goal',
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
                      color: _categoryColor(
                        goal.category,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _categoryIcon(goal.category),
                      size: 20,
                      color: _categoryColor(goal.category),
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
                                  : Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Completion badge
                  if (goal.isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
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
                        backgroundColor: Colors.grey.shade200,
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
                      color: Colors.grey.shade600,
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
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            showCompleted ? 'No goals yet' : 'No active goals',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            showCompleted
                ? 'Create your first goal to get started!'
                : 'All caught up! Create a new goal.',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
