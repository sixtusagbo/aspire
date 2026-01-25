import 'package:dart_mappable/dart_mappable.dart';

import 'user.dart'; // For DateTimeHook

part 'daily_log.mapper.dart';

@MappableClass()
class DailyLog with DailyLogMappable {
  final String id;
  final String userId;

  @MappableField(hook: DateTimeHook())
  final DateTime date;

  final int actionsCompleted;
  final int xpEarned;
  final List<String> completedActionIds;

  DailyLog({
    required this.id,
    required this.userId,
    required this.date,
    this.actionsCompleted = 0,
    this.xpEarned = 0,
    this.completedActionIds = const [],
  });

  /// Generate document ID from date and userId
  static String generateId(DateTime date, String userId) {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return '${dateStr}_$userId';
  }
}
