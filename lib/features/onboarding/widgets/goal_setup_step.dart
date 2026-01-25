import 'package:aspire/core/theme/app_theme.dart';
import 'package:aspire/models/goal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GoalSetupStep extends StatefulWidget {
  final ValueNotifier<String> title;
  final ValueNotifier<String> description;
  final ValueNotifier<DateTime?> targetDate;
  final ValueNotifier<GoalCategory> category;
  final bool isLoading;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const GoalSetupStep({
    super.key,
    required this.title,
    required this.description,
    required this.targetDate,
    required this.category,
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

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title.value);
    _descriptionController =
        TextEditingController(text: widget.description.value);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isValid => _titleController.text.trim().isNotEmpty;

  void _handleNext() {
    widget.title.value = _titleController.text.trim();
    widget.description.value = _descriptionController.text.trim();
    widget.onNext();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          widget.targetDate.value ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.primaryPink,
                ),
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
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.shade100,
            ),
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
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 32),

          // Goal title
          TextField(
            controller: _titleController,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(fontSize: 18),
            decoration: InputDecoration(
              hintText: 'e.g., Visit Japan, Get a six-figure job',
              filled: true,
              fillColor: Colors.grey.shade100,
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
              fillColor: Colors.grey.shade100,
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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
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
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _categoryIcon(cat),
                        size: 18,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _categoryLabel(cat),
                        style: TextStyle(
                          color:
                              isSelected ? Colors.white : Colors.grey.shade700,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.targetDate.value != null
                        ? DateFormat('MMMM d, yyyy')
                            .format(widget.targetDate.value!)
                        : 'Select a target date',
                    style: TextStyle(
                      fontSize: 16,
                      color: widget.targetDate.value != null
                          ? Colors.black
                          : Colors.grey.shade500,
                    ),
                  ),
                  const Spacer(),
                  if (widget.targetDate.value != null)
                    GestureDetector(
                      onTap: () => setState(() => widget.targetDate.value = null),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.grey.shade500,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Complete button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: widget.isLoading || !_isValid ? null : _handleNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPink,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Start My Journey',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
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
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
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

  String _categoryLabel(GoalCategory category) {
    return switch (category) {
      GoalCategory.travel => 'Travel',
      GoalCategory.career => 'Career',
      GoalCategory.finance => 'Finance',
      GoalCategory.wellness => 'Wellness',
      GoalCategory.personal => 'Personal',
    };
  }
}
