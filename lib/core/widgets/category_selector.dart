import 'package:aspire/core/theme/app_theme.dart';
import 'package:aspire/core/theme/category_colors.dart';
import 'package:aspire/core/utils/app_router.dart';
import 'package:aspire/models/goal.dart';
import 'package:aspire/models/user.dart';
import 'package:aspire/services/revenue_cat_service.dart';
import 'package:aspire/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Represents either a preset or custom category selection
class CategorySelection {
  final GoalCategory? presetCategory;
  final String? customCategoryName;

  const CategorySelection.preset(GoalCategory category)
      : presetCategory = category,
        customCategoryName = null;

  const CategorySelection.custom(String name)
      : presetCategory = null,
        customCategoryName = name;

  bool get isCustom => customCategoryName != null;

  String get label =>
      customCategoryName ?? presetCategory?.label ?? 'Personal';

  Color get color =>
      isCustom ? CustomCategoryStyle.defaultColor : presetCategory!.color;

  IconData get icon =>
      isCustom ? CustomCategoryStyle.defaultIcon : presetCategory!.icon;

  /// Create from a Goal's category fields
  factory CategorySelection.fromGoal(Goal goal) {
    if (goal.customCategoryName != null) {
      return CategorySelection.custom(goal.customCategoryName!);
    }
    return CategorySelection.preset(goal.category);
  }

  @override
  bool operator ==(Object other) {
    if (other is! CategorySelection) return false;
    if (isCustom != other.isCustom) return false;
    if (isCustom) return customCategoryName == other.customCategoryName;
    return presetCategory == other.presetCategory;
  }

  @override
  int get hashCode => Object.hash(presetCategory, customCategoryName);
}

/// Category selector supporting both preset and custom categories
class CategorySelector extends HookConsumerWidget {
  final CategorySelection selected;
  final ValueChanged<CategorySelection> onChanged;
  final AppUser? user;

  const CategorySelector({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = useState<bool>(false);
    // Local state for custom categories to avoid stale data issues
    final localCustomCategories = useState<List<String>>(
      user?.customCategories ?? [],
    );

    // Sync with user data when it changes
    useEffect(() {
      localCustomCategories.value = user?.customCategories ?? [];
      return null;
    }, [user?.customCategories]);

    // Check premium status from RevenueCat
    useEffect(() {
      ref.read(revenueCatServiceProvider).isPremium().then((value) {
        isPremium.value = value;
      });
      return null;
    }, []);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Preset categories
        ...GoalCategory.values.map((cat) => _CategoryChip(
              label: cat.label,
              icon: cat.icon,
              color: cat.color,
              isSelected: !selected.isCustom && selected.presetCategory == cat,
              onTap: () => onChanged(CategorySelection.preset(cat)),
            )),
        // Custom categories (premium)
        ...localCustomCategories.value.map((name) => _CategoryChip(
              label: name,
              icon: CustomCategoryStyle.defaultIcon,
              color: CustomCategoryStyle.defaultColor,
              isSelected: selected.isCustom && selected.customCategoryName == name,
              onTap: () => onChanged(CategorySelection.custom(name)),
              onLongPress: isPremium.value
                  ? () => _showDeleteDialog(context, ref, name, localCustomCategories)
                  : null,
            )),
        // Add custom category button (premium only)
        if (isPremium.value)
          _AddCategoryChip(
            onTap: () => _showAddCategoryDialog(context, ref, localCustomCategories),
          ),
        // Show upgrade prompt for non-premium users
        if (!isPremium.value && localCustomCategories.value.isEmpty)
          GestureDetector(
            onTap: () => context.push(AppRoutes.paywall),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: context.borderColor,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add,
                    size: 16,
                    color: context.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Custom',
                    style: TextStyle(
                      fontSize: 13,
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.lock_outline,
                    size: 12,
                    color: context.textSecondary,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _showAddCategoryDialog(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<List<String>> localCustomCategories,
  ) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Category'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Category name',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              Navigator.pop(context, value.trim());
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                Navigator.pop(context, value);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null && user != null) {
      // Update local state immediately for instant UI feedback
      localCustomCategories.value = [...localCustomCategories.value, result];
      // Select the newly created category
      onChanged(CategorySelection.custom(result));
      // Persist to Firestore in background
      final userService = ref.read(userServiceProvider);
      await userService.addCustomCategory(user!.id, result);
    }
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    String name,
    ValueNotifier<List<String>> localCustomCategories,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Remove "$name" from your custom categories?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && user != null) {
      // Update local state immediately for instant UI feedback
      localCustomCategories.value =
          localCustomCategories.value.where((c) => c != name).toList();
      // If deleted category was selected, reset to personal
      if (selected.isCustom && selected.customCategoryName == name) {
        onChanged(CategorySelection.preset(GoalCategory.personal));
      }
      // Persist to Firestore in background
      final userService = ref.read(userServiceProvider);
      await userService.removeCustomCategory(user!.id, name);
    }
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryPink : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppTheme.primaryPink : context.borderColor,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isSelected ? Colors.white : context.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddCategoryChip extends StatelessWidget {
  final VoidCallback onTap;

  const _AddCategoryChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppTheme.primaryPink,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add,
              size: 16,
              color: AppTheme.primaryPink,
            ),
            const SizedBox(width: 4),
            Text(
              'Add',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.primaryPink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
