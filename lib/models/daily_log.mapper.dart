// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'daily_log.dart';

class DailyLogMapper extends ClassMapperBase<DailyLog> {
  DailyLogMapper._();

  static DailyLogMapper? _instance;
  static DailyLogMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DailyLogMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'DailyLog';

  static String _$id(DailyLog v) => v.id;
  static const Field<DailyLog, String> _f$id = Field('id', _$id);
  static String _$userId(DailyLog v) => v.userId;
  static const Field<DailyLog, String> _f$userId = Field('userId', _$userId);
  static DateTime _$date(DailyLog v) => v.date;
  static const Field<DailyLog, DateTime> _f$date = Field(
    'date',
    _$date,
    hook: DateTimeHook(),
  );
  static int _$actionsCompleted(DailyLog v) => v.actionsCompleted;
  static const Field<DailyLog, int> _f$actionsCompleted = Field(
    'actionsCompleted',
    _$actionsCompleted,
    opt: true,
    def: 0,
  );
  static int _$xpEarned(DailyLog v) => v.xpEarned;
  static const Field<DailyLog, int> _f$xpEarned = Field(
    'xpEarned',
    _$xpEarned,
    opt: true,
    def: 0,
  );
  static List<String> _$completedActionIds(DailyLog v) => v.completedActionIds;
  static const Field<DailyLog, List<String>> _f$completedActionIds = Field(
    'completedActionIds',
    _$completedActionIds,
    opt: true,
    def: const [],
  );

  @override
  final MappableFields<DailyLog> fields = const {
    #id: _f$id,
    #userId: _f$userId,
    #date: _f$date,
    #actionsCompleted: _f$actionsCompleted,
    #xpEarned: _f$xpEarned,
    #completedActionIds: _f$completedActionIds,
  };

  static DailyLog _instantiate(DecodingData data) {
    return DailyLog(
      id: data.dec(_f$id),
      userId: data.dec(_f$userId),
      date: data.dec(_f$date),
      actionsCompleted: data.dec(_f$actionsCompleted),
      xpEarned: data.dec(_f$xpEarned),
      completedActionIds: data.dec(_f$completedActionIds),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static DailyLog fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DailyLog>(map);
  }

  static DailyLog fromJson(String json) {
    return ensureInitialized().decodeJson<DailyLog>(json);
  }
}

mixin DailyLogMappable {
  String toJson() {
    return DailyLogMapper.ensureInitialized().encodeJson<DailyLog>(
      this as DailyLog,
    );
  }

  Map<String, dynamic> toMap() {
    return DailyLogMapper.ensureInitialized().encodeMap<DailyLog>(
      this as DailyLog,
    );
  }

  DailyLogCopyWith<DailyLog, DailyLog, DailyLog> get copyWith =>
      _DailyLogCopyWithImpl<DailyLog, DailyLog>(
        this as DailyLog,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return DailyLogMapper.ensureInitialized().stringifyValue(this as DailyLog);
  }

  @override
  bool operator ==(Object other) {
    return DailyLogMapper.ensureInitialized().equalsValue(
      this as DailyLog,
      other,
    );
  }

  @override
  int get hashCode {
    return DailyLogMapper.ensureInitialized().hashValue(this as DailyLog);
  }
}

extension DailyLogValueCopy<$R, $Out> on ObjectCopyWith<$R, DailyLog, $Out> {
  DailyLogCopyWith<$R, DailyLog, $Out> get $asDailyLog =>
      $base.as((v, t, t2) => _DailyLogCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DailyLogCopyWith<$R, $In extends DailyLog, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>
  get completedActionIds;
  $R call({
    String? id,
    String? userId,
    DateTime? date,
    int? actionsCompleted,
    int? xpEarned,
    List<String>? completedActionIds,
  });
  DailyLogCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _DailyLogCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DailyLog, $Out>
    implements DailyLogCopyWith<$R, DailyLog, $Out> {
  _DailyLogCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DailyLog> $mapper =
      DailyLogMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>
  get completedActionIds => ListCopyWith(
    $value.completedActionIds,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(completedActionIds: v),
  );
  @override
  $R call({
    String? id,
    String? userId,
    DateTime? date,
    int? actionsCompleted,
    int? xpEarned,
    List<String>? completedActionIds,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (userId != null) #userId: userId,
      if (date != null) #date: date,
      if (actionsCompleted != null) #actionsCompleted: actionsCompleted,
      if (xpEarned != null) #xpEarned: xpEarned,
      if (completedActionIds != null) #completedActionIds: completedActionIds,
    }),
  );
  @override
  DailyLog $make(CopyWithData data) => DailyLog(
    id: data.get(#id, or: $value.id),
    userId: data.get(#userId, or: $value.userId),
    date: data.get(#date, or: $value.date),
    actionsCompleted: data.get(#actionsCompleted, or: $value.actionsCompleted),
    xpEarned: data.get(#xpEarned, or: $value.xpEarned),
    completedActionIds: data.get(
      #completedActionIds,
      or: $value.completedActionIds,
    ),
  );

  @override
  DailyLogCopyWith<$R2, DailyLog, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _DailyLogCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

