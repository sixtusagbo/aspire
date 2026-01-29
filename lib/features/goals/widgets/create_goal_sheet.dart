import 'package:aspire/core/theme/app_theme.dart';
import 'package:aspire/core/utils/app_router.dart';
import 'package:aspire/core/widgets/gradient_button.dart';
import 'package:aspire/features/goals/goals_screen.dart';
import 'package:aspire/models/goal.dart';
import 'package:aspire/services/goal_service.dart';
import 'package:aspire/services/revenue_cat_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Shows the create goal bottom sheet and navigates to goal detail on success.
/// Returns true if a goal was created, false otherwise.
Future<bool> showCreateGoalSheet(
  BuildContext context,
  WidgetRef ref,
  String userId,
) async {
  // Check if user can create more goals
  final revenueCatService = ref.read(revenueCatServiceProvider);
  final goalService = ref.read(goalServiceProvider);
  final isPremium = await revenueCatService.isPremium();

  if (!isPremium) {
    // Check active goal count
    final activeGoals = await goalService.watchActiveGoals(userId).first;
    if (activeGoals.length >= freeGoalLimit) {
      if (context.mounted) {
        _showUpgradeDialog(context);
      }
      return false;
    }
  }

  if (!context.mounted) return false;

  final createdGoalId = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _CreateGoalSheetContent(
      userId: userId,
      goalService: goalService,
    ),
  );

  if (createdGoalId != null && context.mounted) {
    context.push(AppRoutes.goalDetailPath(createdGoalId));
    return true;
  }

  return false;
}

void _showUpgradeDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Goal Limit Reached'),
      content: const Text(
        'You\'ve reached the limit of $freeGoalLimit active goals on the free plan.\n\n'
        'Upgrade to Premium for unlimited goals!',
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

class _CreateGoalSheetContent extends StatefulWidget {
  final String userId;
  final GoalService goalService;

  const _CreateGoalSheetContent({
    required this.userId,
    required this.goalService,
  });

  @override
  State<_CreateGoalSheetContent> createState() => _CreateGoalSheetContentState();
}

class _CreateGoalSheetContentState extends State<_CreateGoalSheetContent> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  GoalCategory _selectedCategory = GoalCategory.personal;
  DateTime? _targetDate;
  bool _isCreating = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _createGoal() async {
    if (_titleController.text.trim().isEmpty || _isCreating) return;

    setState(() => _isCreating = true);

    try {
      final goal = await widget.goalService.createGoal(
        userId: widget.userId,
        title: _titleController.text.trim(),
        description: _descController.text.trim().isNotEmpty
            ? _descController.text.trim()
            : null,
        targetDate: _targetDate,
        category: _selectedCategory,
      );

      if (mounted) {
        Navigator.pop(context, goal.id);
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              controller: _titleController,
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
              controller: _descController,
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
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
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
                        color: isSelected ? Colors.white : context.textPrimary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
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
                _targetDate != null
                    ? '${_targetDate!.day}/${_targetDate!.month}/${_targetDate!.year}'
                    : 'Set target date (optional)',
              ),
              trailing: _targetDate != null
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _targetDate = null),
                    )
                  : null,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate:
                      _targetDate ?? DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                );
                if (picked != null) {
                  setState(() => _targetDate = picked);
                }
              },
            ),
            const SizedBox(height: 24),

            // Create button
            GradientButton(
              text: 'Create Goal',
              onPressed: _isCreating ? null : _createGoal,
              isLoading: _isCreating,
              height: 50,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
