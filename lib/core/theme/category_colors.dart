import 'package:aspire/models/goal.dart';
import 'package:flutter/material.dart';

/// Centralized category colors, icons, and labels.
/// Design direction: warm, travel-inspired palette.
extension GoalCategoryStyle on GoalCategory {
  Color get color => switch (this) {
        GoalCategory.travel => const Color(0xFF00C1CF), // Cyan - destinations
        GoalCategory.career => const Color(0xFFE8863A), // Warm amber - ambition
        GoalCategory.finance => const Color(0xFF5BAE72), // Rich green - growth
        GoalCategory.wellness => const Color(0xFFF82EB3), // Magenta - vitality
        GoalCategory.personal => const Color(0xFF9B6DD7), // Purple - identity
      };

  IconData get icon => switch (this) {
        GoalCategory.travel => Icons.flight_rounded,
        GoalCategory.career => Icons.work_rounded,
        GoalCategory.finance => Icons.attach_money_rounded,
        GoalCategory.wellness => Icons.favorite_rounded,
        GoalCategory.personal => Icons.star_rounded,
      };

  String get label => switch (this) {
        GoalCategory.travel => 'Travel',
        GoalCategory.career => 'Career',
        GoalCategory.finance => 'Finance',
        GoalCategory.wellness => 'Wellness',
        GoalCategory.personal => 'Personal',
      };
}
