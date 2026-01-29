import 'package:dart_mappable/dart_mappable.dart';

import 'goal.dart';
import 'user.dart';

part 'goal_template.mapper.dart';

/// Target date type for templates
@MappableEnum()
enum TargetDateType {
  none,
  endOfYear,
  threeMonths,
  sixMonths,
  oneYear,
}

extension TargetDateTypeX on TargetDateType {
  DateTime? toDateTime() {
    final now = DateTime.now();
    return switch (this) {
      TargetDateType.none => null,
      TargetDateType.endOfYear => DateTime(now.year, 12, 31),
      TargetDateType.threeMonths => now.add(const Duration(days: 90)),
      TargetDateType.sixMonths => now.add(const Duration(days: 180)),
      TargetDateType.oneYear => now.add(const Duration(days: 365)),
    };
  }

  String get label => switch (this) {
        TargetDateType.none => 'No target date',
        TargetDateType.endOfYear => 'End of year',
        TargetDateType.threeMonths => '3 months',
        TargetDateType.sixMonths => '6 months',
        TargetDateType.oneYear => '1 year',
      };
}

/// A template for creating pre-made goals
@MappableClass()
class GoalTemplate with GoalTemplateMappable {
  final String id;
  final String title;
  final String description;
  final GoalCategory category;
  final List<String> suggestedActions;
  final TargetDateType targetDateType;

  @MappableField(hook: DateTimeHook())
  final DateTime createdAt;

  final bool isActive;

  GoalTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.suggestedActions,
    this.targetDateType = TargetDateType.none,
    required this.createdAt,
    this.isActive = true,
  });
}
