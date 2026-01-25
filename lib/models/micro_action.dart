import 'package:dart_mappable/dart_mappable.dart';

import 'user.dart'; // For NullableDateTimeHook

part 'micro_action.mapper.dart';

@MappableClass()
class MicroAction with MicroActionMappable {
  final String id;
  final String goalId;
  final String userId;
  final String title;
  final bool isCompleted;

  @MappableField(hook: NullableDateTimeHook())
  final DateTime? completedAt;

  @MappableField(hook: NullableDateTimeHook())
  final DateTime? scheduledFor;

  final int sortOrder;

  MicroAction({
    required this.id,
    required this.goalId,
    required this.userId,
    required this.title,
    this.isCompleted = false,
    this.completedAt,
    this.scheduledFor,
    this.sortOrder = 0,
  });
}
