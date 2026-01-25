import 'package:dart_mappable/dart_mappable.dart';

import 'user.dart'; // For DateTimeHook, NullableDateTimeHook

part 'goal.mapper.dart';

/// Goal categories
enum GoalCategory {
  travel,
  career,
  finance,
  wellness,
  personal,
}

@MappableClass()
class Goal with GoalMappable {
  final String id;
  final String userId;
  final String title;
  final String? description;

  @MappableField(hook: NullableDateTimeHook())
  final DateTime? targetDate;

  @MappableField(hook: DateTimeHook())
  final DateTime createdAt;

  final bool isCompleted;

  @MappableField(hook: NullableDateTimeHook())
  final DateTime? completedAt;

  final GoalCategory category;

  /// Number of micro-actions completed (denormalized for quick access)
  final int completedActionsCount;

  /// Total number of micro-actions (denormalized for quick access)
  final int totalActionsCount;

  Goal({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.targetDate,
    required this.createdAt,
    this.isCompleted = false,
    this.completedAt,
    this.category = GoalCategory.personal,
    this.completedActionsCount = 0,
    this.totalActionsCount = 0,
  });

  /// Progress as a percentage (0.0 to 1.0)
  double get progress {
    if (totalActionsCount == 0) return 0.0;
    return completedActionsCount / totalActionsCount;
  }

  /// Days remaining until target date
  int? get daysRemaining {
    if (targetDate == null) return null;
    return targetDate!.difference(DateTime.now()).inDays;
  }
}
