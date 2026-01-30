import 'package:aspire/core/theme/app_theme.dart';
import 'package:aspire/core/theme/category_colors.dart';
import 'package:aspire/core/utils/app_router.dart';
import 'package:aspire/core/widgets/gradient_button.dart';
import 'package:aspire/features/goals/goals_screen.dart';
import 'package:aspire/models/goal.dart';
import 'package:aspire/models/goal_template.dart';
import 'package:aspire/services/goal_service.dart';
import 'package:aspire/services/goal_template_service.dart';
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
      isPremium: isPremium,
    ),
  );

  if (createdGoalId != null && context.mounted) {
    context.push(AppRoutes.goalDetailPath(createdGoalId));
    return true;
  }

  return false;
}

/// Shows the goal template selector and returns the selected template.
Future<GoalTemplate?> showGoalTemplateSelector(BuildContext context) {
  return showModalBottomSheet<GoalTemplate>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => const _TemplateSelectorSheet(),
  );
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
  final bool isPremium;

  const _CreateGoalSheetContent({
    required this.userId,
    required this.goalService,
    required this.isPremium,
  });

  @override
  State<_CreateGoalSheetContent> createState() =>
      _CreateGoalSheetContentState();
}

class _CreateGoalSheetContentState extends State<_CreateGoalSheetContent> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _titleFocusNode = FocusNode();
  GoalCategory _selectedCategory = GoalCategory.personal;
  DateTime? _targetDate;
  bool _isCreating = false;
  GoalTemplate? _selectedTemplate;
  List<String> _suggestedActions = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  void _applyTemplate(GoalTemplate template) {
    // Unfocus title field when template is applied
    _titleFocusNode.unfocus();
    setState(() {
      _selectedTemplate = template;
      _titleController.text = template.title;
      _descController.text = template.description;
      _selectedCategory = template.category;
      _targetDate = template.targetDateType.toDateTime();
      _suggestedActions = List.from(template.suggestedActions);
    });
  }

  Future<void> _showTemplateSelector() async {
    final template = await showModalBottomSheet<GoalTemplate>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const _TemplateSelectorSheet(),
    );

    if (template != null && mounted) {
      _applyTemplate(template);
    }
  }

  Future<void> _showSuggestedActions() async {
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _SuggestedActionsSheet(
        actions: _suggestedActions,
        isPremium: widget.isPremium,
      ),
    );

    if (result != null && mounted) {
      setState(() => _suggestedActions = result);
    }
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

      // Create micro actions from template if available
      if (_suggestedActions.isNotEmpty) {
        for (var i = 0; i < _suggestedActions.length; i++) {
          await widget.goalService.createMicroAction(
            goalId: goal.id,
            userId: widget.userId,
            title: _suggestedActions[i],
            sortOrder: i,
          );
        }
      }

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
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Create New Goal',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Template selector button
            OutlinedButton.icon(
              onPressed: _showTemplateSelector,
              icon: const Icon(Icons.auto_awesome_outlined, size: 18),
              label: Text(
                _selectedTemplate != null
                    ? 'Change template'
                    : 'Choose from templates',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryPink,
                side: BorderSide(
                  color: AppTheme.primaryPink.withValues(alpha: 0.5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            TextField(
              controller: _titleController,
              focusNode: _titleFocusNode,
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
                  initialDate: _targetDate ??
                      DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                );
                if (picked != null) {
                  setState(() => _targetDate = picked);
                }
              },
            ),

            // Suggested actions (only show if template selected)
            if (_suggestedActions.isNotEmpty) ...[
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.checklist_outlined),
                title: Text(
                  '${_suggestedActions.length} suggested actions',
                  style: TextStyle(color: AppTheme.primaryPink),
                ),
                trailing: const Icon(Icons.edit_outlined, size: 20),
                onTap: _showSuggestedActions,
              ),
            ],

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

const int _freeActionLimit = 5;
const int _premiumActionLimit = 10;

/// Bottom sheet for editing suggested actions
class _SuggestedActionsSheet extends StatefulWidget {
  final List<String> actions;
  final bool isPremium;

  const _SuggestedActionsSheet({
    required this.actions,
    required this.isPremium,
  });

  @override
  State<_SuggestedActionsSheet> createState() => _SuggestedActionsSheetState();
}

class _SuggestedActionsSheetState extends State<_SuggestedActionsSheet> {
  late List<TextEditingController> _controllers;

  int get _actionLimit =>
      widget.isPremium ? _premiumActionLimit : _freeActionLimit;

  bool get _canAddMore => _controllers.length < _actionLimit;

  @override
  void initState() {
    super.initState();
    // Limit initial actions to the user's limit
    final limitedActions = widget.actions.take(_actionLimit).toList();
    _controllers = limitedActions
        .map((action) => TextEditingController(text: action))
        .toList();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addAction() {
    if (!_canAddMore) return;
    setState(() {
      _controllers.add(TextEditingController());
    });
  }

  void _removeAction(int index) {
    setState(() {
      _controllers[index].dispose();
      _controllers.removeAt(index);
    });
  }

  void _save() {
    final actions = _controllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    Navigator.pop(context, actions);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.borderColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Suggested Actions',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: _save,
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Edit the actions that will be created with your goal (${_controllers.length}/$_actionLimit)',
                    style: TextStyle(color: context.textSecondary),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                itemCount: _controllers.length + 1,
                itemBuilder: (context, index) {
                  if (index == _controllers.length) {
                    if (!_canAddMore) {
                      if (widget.isPremium) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Maximum $_premiumActionLimit actions reached',
                            style: TextStyle(
                              color: context.textSecondary,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Free plan: $_freeActionLimit actions. ',
                              style: TextStyle(
                                color: context.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                context.push(AppRoutes.paywall);
                              },
                              child: Text(
                                'Upgrade for more!',
                                style: TextStyle(
                                  color: AppTheme.primaryPink,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return TextButton.icon(
                      onPressed: _addAction,
                      icon: const Icon(Icons.add),
                      label: const Text('Add action'),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Text(
                          '${index + 1}.',
                          style: TextStyle(
                            color: context.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _controllers[index],
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText: 'Action description',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.remove_circle_outline,
                            color: Colors.red.shade400,
                          ),
                          onPressed: () => _removeAction(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet for selecting a goal template
class _TemplateSelectorSheet extends HookConsumerWidget {
  const _TemplateSelectorSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(goalTemplatesProvider);

    return templatesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading templates: $e')),
      data: (templates) => _TemplateSelectorContent(templates: templates),
    );
  }
}

class _TemplateSelectorContent extends StatefulWidget {
  final List<GoalTemplate> templates;

  const _TemplateSelectorContent({required this.templates});

  @override
  State<_TemplateSelectorContent> createState() =>
      _TemplateSelectorContentState();
}

class _TemplateSelectorContentState extends State<_TemplateSelectorContent> {
  GoalCategory? _selectedCategory;

  List<GoalTemplate> get _filteredTemplates {
    if (_selectedCategory == null) return widget.templates;
    return widget.templates
        .where((t) => t.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Column(
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Goal Templates',
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
                const SizedBox(height: 8),
                Text(
                  'Choose a template to get started quickly',
                  style: TextStyle(color: context.textSecondary),
                ),
                const SizedBox(height: 16),

                // Category filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _CategoryChip(
                        label: 'All',
                        isSelected: _selectedCategory == null,
                        onTap: () => setState(() => _selectedCategory = null),
                      ),
                      const SizedBox(width: 8),
                      ...GoalCategory.values.map(
                        (cat) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _CategoryChip(
                            label: cat.label,
                            icon: cat.icon,
                            color: cat.color,
                            isSelected: _selectedCategory == cat,
                            onTap: () =>
                                setState(() => _selectedCategory = cat),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Template list
          Expanded(
            child: _filteredTemplates.isEmpty
                ? Center(
                    child: Text(
                      'No templates available',
                      style: TextStyle(color: context.textSecondary),
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    itemCount: _filteredTemplates.length,
                    itemBuilder: (context, index) {
                      final template = _filteredTemplates[index];
                      return _TemplateCard(
                        template: template,
                        onTap: () => Navigator.pop(context, template),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    this.icon,
    this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? AppTheme.primaryPink)
              : context.surfaceSubtle,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : context.textSecondary,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : context.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final GoalTemplate template;
  final VoidCallback onTap;

  const _TemplateCard({required this.template, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: template.category.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      template.category.icon,
                      size: 20,
                      color: template.category.color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      template.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: context.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                template.description,
                style: TextStyle(color: context.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    '${template.suggestedActions.length} suggested actions',
                    style: TextStyle(
                      color: AppTheme.primaryPink,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (template.targetDateType != TargetDateType.none) ...[
                    const SizedBox(width: 12),
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: context.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      template.targetDateType.label,
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
