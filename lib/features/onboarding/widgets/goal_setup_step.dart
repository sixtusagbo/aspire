import 'package:aspire/core/theme/app_theme.dart';
import 'package:aspire/core/theme/category_colors.dart';
import 'package:aspire/core/widgets/gradient_button.dart';
import 'package:aspire/features/goals/widgets/create_goal_sheet.dart';
import 'package:aspire/models/goal.dart';
import 'package:aspire/models/goal_template.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GoalSetupStep extends StatefulWidget {
  final ValueNotifier<String> title;
  final ValueNotifier<String> description;
  final ValueNotifier<DateTime?> targetDate;
  final ValueNotifier<GoalCategory> category;
  final ValueNotifier<List<String>> suggestedActions;
  final bool isLoading;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const GoalSetupStep({
    super.key,
    required this.title,
    required this.description,
    required this.targetDate,
    required this.category,
    required this.suggestedActions,
    required this.isLoading,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<GoalSetupStep> createState() => _GoalSetupStepState();
}

class _GoalSetupStepState extends State<GoalSetupStep> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final FocusNode _titleFocusNode;
  bool _hasAppliedTemplate = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title.value);
    _descriptionController = TextEditingController(
      text: widget.description.value,
    );
    _titleFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  bool get _isValid => _titleController.text.trim().isNotEmpty;

  void _applyTemplate(GoalTemplate template) {
    // Clear all focus and mark template as applied to prevent autofocus
    _hasAppliedTemplate = true;
    FocusScope.of(context).unfocus();
    setState(() {
      _titleController.text = template.title;
      _descriptionController.text = template.description;
      widget.category.value = template.category;
      widget.targetDate.value = template.targetDateType.toDateTime();
      widget.suggestedActions.value = List.from(template.suggestedActions);
    });
  }

  Future<void> _showTemplateSelector() async {
    final template = await showGoalTemplateSelector(context);
    if (template != null && mounted) {
      _applyTemplate(template);
    }
  }

  void _handleNext() {
    widget.title.value = _titleController.text.trim();
    widget.description.value = _descriptionController.text.trim();
    widget.onNext();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          widget.targetDate.value ??
          DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppTheme.primaryPink),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        widget.targetDate.value = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Back button
          IconButton(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(backgroundColor: context.surfaceSubtle),
          ),
          const SizedBox(height: 32),

          // Title
          Text(
            'What\'s your first\nbig dream?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          Text(
            'Don\'t hold back. Dream big, we\'ll help you break it down.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),

          // Template selector button
          OutlinedButton.icon(
            onPressed: _showTemplateSelector,
            icon: const Icon(Icons.auto_awesome_outlined, size: 18),
            label: const Text('Choose from templates'),
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
          const SizedBox(height: 24),

          // Goal title
          TextField(
            controller: _titleController,
            focusNode: _titleFocusNode,
            autofocus: !_hasAppliedTemplate,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(fontSize: 18),
            decoration: InputDecoration(
              hintText: 'e.g., Visit Japan, Get a six-figure job',
              filled: true,
              fillColor: context.surfaceSubtle,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppTheme.primaryPink,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),

          // Description (optional)
          TextField(
            controller: _descriptionController,
            textCapitalization: TextCapitalization.sentences,
            maxLines: 3,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Why is this important to you? (optional)',
              filled: true,
              fillColor: context.surfaceSubtle,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppTheme.primaryPink,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Category selection
          Text(
            'Category',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: GoalCategory.values.map((cat) {
              final isSelected = widget.category.value == cat;
              return GestureDetector(
                onTap: () => setState(() => widget.category.value = cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryPink
                        : context.surfaceSubtle,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        cat.icon,
                        size: 18,
                        color: isSelected
                            ? Colors.white
                            : context.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        cat.label,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : context.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Target date
          Text(
            'Target Date (optional)',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: context.surfaceSubtle,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: context.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.targetDate.value != null
                        ? DateFormat(
                            'MMMM d, yyyy',
                          ).format(widget.targetDate.value!)
                        : 'Select a target date',
                    style: TextStyle(
                      fontSize: 16,
                      color: widget.targetDate.value != null
                          ? context.textPrimary
                          : context.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  if (widget.targetDate.value != null)
                    GestureDetector(
                      onTap: () =>
                          setState(() => widget.targetDate.value = null),
                      child: Icon(
                        Icons.close_rounded,
                        color: context.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Complete button
          GradientButton(
            text: 'Start My Journey',
            onPressed: widget.isLoading || !_isValid ? null : _handleNext,
            isLoading: widget.isLoading,
          ),

          // Skip option
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: widget.isLoading
                  ? null
                  : () {
                      widget.title.value = '';
                      widget.onNext();
                    },
              child: Text(
                'Skip for now',
                style: TextStyle(color: context.textSecondary),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
