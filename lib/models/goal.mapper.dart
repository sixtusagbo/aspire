// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'goal.dart';

class GoalCategoryMapper extends EnumMapper<GoalCategory> {
  GoalCategoryMapper._();

  static GoalCategoryMapper? _instance;
  static GoalCategoryMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = GoalCategoryMapper._());
    }
    return _instance!;
  }

  static GoalCategory fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  GoalCategory decode(dynamic value) {
    switch (value) {
      case r'travel':
        return GoalCategory.travel;
      case r'career':
        return GoalCategory.career;
      case r'finance':
        return GoalCategory.finance;
      case r'wellness':
        return GoalCategory.wellness;
      case r'personal':
        return GoalCategory.personal;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(GoalCategory self) {
    switch (self) {
      case GoalCategory.travel:
        return r'travel';
      case GoalCategory.career:
        return r'career';
      case GoalCategory.finance:
        return r'finance';
      case GoalCategory.wellness:
        return r'wellness';
      case GoalCategory.personal:
        return r'personal';
    }
  }
}

extension GoalCategoryMapperExtension on GoalCategory {
  String toValue() {
    GoalCategoryMapper.ensureInitialized();
    return MapperContainer.globals.toValue<GoalCategory>(this) as String;
  }
}

class GoalMapper extends ClassMapperBase<Goal> {
  GoalMapper._();

  static GoalMapper? _instance;
  static GoalMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = GoalMapper._());
      GoalCategoryMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Goal';

  static String _$id(Goal v) => v.id;
  static const Field<Goal, String> _f$id = Field('id', _$id);
  static String _$userId(Goal v) => v.userId;
  static const Field<Goal, String> _f$userId = Field('userId', _$userId);
  static String _$title(Goal v) => v.title;
  static const Field<Goal, String> _f$title = Field('title', _$title);
  static String? _$description(Goal v) => v.description;
  static const Field<Goal, String> _f$description = Field(
    'description',
    _$description,
    opt: true,
  );
  static DateTime? _$targetDate(Goal v) => v.targetDate;
  static const Field<Goal, DateTime> _f$targetDate = Field(
    'targetDate',
    _$targetDate,
    opt: true,
    hook: NullableDateTimeHook(),
  );
  static DateTime _$createdAt(Goal v) => v.createdAt;
  static const Field<Goal, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    hook: DateTimeHook(),
  );
  static bool _$isCompleted(Goal v) => v.isCompleted;
  static const Field<Goal, bool> _f$isCompleted = Field(
    'isCompleted',
    _$isCompleted,
    opt: true,
    def: false,
  );
  static DateTime? _$completedAt(Goal v) => v.completedAt;
  static const Field<Goal, DateTime> _f$completedAt = Field(
    'completedAt',
    _$completedAt,
    opt: true,
    hook: NullableDateTimeHook(),
  );
  static GoalCategory _$category(Goal v) => v.category;
  static const Field<Goal, GoalCategory> _f$category = Field(
    'category',
    _$category,
    opt: true,
    def: GoalCategory.personal,
  );
  static int _$completedActionsCount(Goal v) => v.completedActionsCount;
  static const Field<Goal, int> _f$completedActionsCount = Field(
    'completedActionsCount',
    _$completedActionsCount,
    opt: true,
    def: 0,
  );
  static int _$totalActionsCount(Goal v) => v.totalActionsCount;
  static const Field<Goal, int> _f$totalActionsCount = Field(
    'totalActionsCount',
    _$totalActionsCount,
    opt: true,
    def: 0,
  );
  static bool _$reminderEnabled(Goal v) => v.reminderEnabled;
  static const Field<Goal, bool> _f$reminderEnabled = Field(
    'reminderEnabled',
    _$reminderEnabled,
    opt: true,
    def: false,
  );
  static int? _$reminderHour(Goal v) => v.reminderHour;
  static const Field<Goal, int> _f$reminderHour = Field(
    'reminderHour',
    _$reminderHour,
    opt: true,
  );
  static int? _$reminderMinute(Goal v) => v.reminderMinute;
  static const Field<Goal, int> _f$reminderMinute = Field(
    'reminderMinute',
    _$reminderMinute,
    opt: true,
  );

  @override
  final MappableFields<Goal> fields = const {
    #id: _f$id,
    #userId: _f$userId,
    #title: _f$title,
    #description: _f$description,
    #targetDate: _f$targetDate,
    #createdAt: _f$createdAt,
    #isCompleted: _f$isCompleted,
    #completedAt: _f$completedAt,
    #category: _f$category,
    #completedActionsCount: _f$completedActionsCount,
    #totalActionsCount: _f$totalActionsCount,
    #reminderEnabled: _f$reminderEnabled,
    #reminderHour: _f$reminderHour,
    #reminderMinute: _f$reminderMinute,
  };

  static Goal _instantiate(DecodingData data) {
    return Goal(
      id: data.dec(_f$id),
      userId: data.dec(_f$userId),
      title: data.dec(_f$title),
      description: data.dec(_f$description),
      targetDate: data.dec(_f$targetDate),
      createdAt: data.dec(_f$createdAt),
      isCompleted: data.dec(_f$isCompleted),
      completedAt: data.dec(_f$completedAt),
      category: data.dec(_f$category),
      completedActionsCount: data.dec(_f$completedActionsCount),
      totalActionsCount: data.dec(_f$totalActionsCount),
      reminderEnabled: data.dec(_f$reminderEnabled),
      reminderHour: data.dec(_f$reminderHour),
      reminderMinute: data.dec(_f$reminderMinute),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Goal fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Goal>(map);
  }

  static Goal fromJson(String json) {
    return ensureInitialized().decodeJson<Goal>(json);
  }
}

mixin GoalMappable {
  String toJson() {
    return GoalMapper.ensureInitialized().encodeJson<Goal>(this as Goal);
  }

  Map<String, dynamic> toMap() {
    return GoalMapper.ensureInitialized().encodeMap<Goal>(this as Goal);
  }

  GoalCopyWith<Goal, Goal, Goal> get copyWith =>
      _GoalCopyWithImpl<Goal, Goal>(this as Goal, $identity, $identity);
  @override
  String toString() {
    return GoalMapper.ensureInitialized().stringifyValue(this as Goal);
  }

  @override
  bool operator ==(Object other) {
    return GoalMapper.ensureInitialized().equalsValue(this as Goal, other);
  }

  @override
  int get hashCode {
    return GoalMapper.ensureInitialized().hashValue(this as Goal);
  }
}

extension GoalValueCopy<$R, $Out> on ObjectCopyWith<$R, Goal, $Out> {
  GoalCopyWith<$R, Goal, $Out> get $asGoal =>
      $base.as((v, t, t2) => _GoalCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class GoalCopyWith<$R, $In extends Goal, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? targetDate,
    DateTime? createdAt,
    bool? isCompleted,
    DateTime? completedAt,
    GoalCategory? category,
    int? completedActionsCount,
    int? totalActionsCount,
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
  });
  GoalCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _GoalCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Goal, $Out>
    implements GoalCopyWith<$R, Goal, $Out> {
  _GoalCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Goal> $mapper = GoalMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? userId,
    String? title,
    Object? description = $none,
    Object? targetDate = $none,
    DateTime? createdAt,
    bool? isCompleted,
    Object? completedAt = $none,
    GoalCategory? category,
    int? completedActionsCount,
    int? totalActionsCount,
    bool? reminderEnabled,
    Object? reminderHour = $none,
    Object? reminderMinute = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (userId != null) #userId: userId,
      if (title != null) #title: title,
      if (description != $none) #description: description,
      if (targetDate != $none) #targetDate: targetDate,
      if (createdAt != null) #createdAt: createdAt,
      if (isCompleted != null) #isCompleted: isCompleted,
      if (completedAt != $none) #completedAt: completedAt,
      if (category != null) #category: category,
      if (completedActionsCount != null)
        #completedActionsCount: completedActionsCount,
      if (totalActionsCount != null) #totalActionsCount: totalActionsCount,
      if (reminderEnabled != null) #reminderEnabled: reminderEnabled,
      if (reminderHour != $none) #reminderHour: reminderHour,
      if (reminderMinute != $none) #reminderMinute: reminderMinute,
    }),
  );
  @override
  Goal $make(CopyWithData data) => Goal(
    id: data.get(#id, or: $value.id),
    userId: data.get(#userId, or: $value.userId),
    title: data.get(#title, or: $value.title),
    description: data.get(#description, or: $value.description),
    targetDate: data.get(#targetDate, or: $value.targetDate),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    isCompleted: data.get(#isCompleted, or: $value.isCompleted),
    completedAt: data.get(#completedAt, or: $value.completedAt),
    category: data.get(#category, or: $value.category),
    completedActionsCount: data.get(
      #completedActionsCount,
      or: $value.completedActionsCount,
    ),
    totalActionsCount: data.get(
      #totalActionsCount,
      or: $value.totalActionsCount,
    ),
    reminderEnabled: data.get(#reminderEnabled, or: $value.reminderEnabled),
    reminderHour: data.get(#reminderHour, or: $value.reminderHour),
    reminderMinute: data.get(#reminderMinute, or: $value.reminderMinute),
  );

  @override
  GoalCopyWith<$R2, Goal, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _GoalCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

