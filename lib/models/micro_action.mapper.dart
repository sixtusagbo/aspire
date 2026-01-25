// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'micro_action.dart';

class MicroActionMapper extends ClassMapperBase<MicroAction> {
  MicroActionMapper._();

  static MicroActionMapper? _instance;
  static MicroActionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MicroActionMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'MicroAction';

  static String _$id(MicroAction v) => v.id;
  static const Field<MicroAction, String> _f$id = Field('id', _$id);
  static String _$goalId(MicroAction v) => v.goalId;
  static const Field<MicroAction, String> _f$goalId = Field('goalId', _$goalId);
  static String _$userId(MicroAction v) => v.userId;
  static const Field<MicroAction, String> _f$userId = Field('userId', _$userId);
  static String _$title(MicroAction v) => v.title;
  static const Field<MicroAction, String> _f$title = Field('title', _$title);
  static bool _$isCompleted(MicroAction v) => v.isCompleted;
  static const Field<MicroAction, bool> _f$isCompleted = Field(
    'isCompleted',
    _$isCompleted,
    opt: true,
    def: false,
  );
  static DateTime? _$completedAt(MicroAction v) => v.completedAt;
  static const Field<MicroAction, DateTime> _f$completedAt = Field(
    'completedAt',
    _$completedAt,
    opt: true,
    hook: NullableDateTimeHook(),
  );
  static DateTime? _$scheduledFor(MicroAction v) => v.scheduledFor;
  static const Field<MicroAction, DateTime> _f$scheduledFor = Field(
    'scheduledFor',
    _$scheduledFor,
    opt: true,
    hook: NullableDateTimeHook(),
  );
  static int _$sortOrder(MicroAction v) => v.sortOrder;
  static const Field<MicroAction, int> _f$sortOrder = Field(
    'sortOrder',
    _$sortOrder,
    opt: true,
    def: 0,
  );

  @override
  final MappableFields<MicroAction> fields = const {
    #id: _f$id,
    #goalId: _f$goalId,
    #userId: _f$userId,
    #title: _f$title,
    #isCompleted: _f$isCompleted,
    #completedAt: _f$completedAt,
    #scheduledFor: _f$scheduledFor,
    #sortOrder: _f$sortOrder,
  };

  static MicroAction _instantiate(DecodingData data) {
    return MicroAction(
      id: data.dec(_f$id),
      goalId: data.dec(_f$goalId),
      userId: data.dec(_f$userId),
      title: data.dec(_f$title),
      isCompleted: data.dec(_f$isCompleted),
      completedAt: data.dec(_f$completedAt),
      scheduledFor: data.dec(_f$scheduledFor),
      sortOrder: data.dec(_f$sortOrder),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MicroAction fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MicroAction>(map);
  }

  static MicroAction fromJson(String json) {
    return ensureInitialized().decodeJson<MicroAction>(json);
  }
}

mixin MicroActionMappable {
  String toJson() {
    return MicroActionMapper.ensureInitialized().encodeJson<MicroAction>(
      this as MicroAction,
    );
  }

  Map<String, dynamic> toMap() {
    return MicroActionMapper.ensureInitialized().encodeMap<MicroAction>(
      this as MicroAction,
    );
  }

  MicroActionCopyWith<MicroAction, MicroAction, MicroAction> get copyWith =>
      _MicroActionCopyWithImpl<MicroAction, MicroAction>(
        this as MicroAction,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return MicroActionMapper.ensureInitialized().stringifyValue(
      this as MicroAction,
    );
  }

  @override
  bool operator ==(Object other) {
    return MicroActionMapper.ensureInitialized().equalsValue(
      this as MicroAction,
      other,
    );
  }

  @override
  int get hashCode {
    return MicroActionMapper.ensureInitialized().hashValue(this as MicroAction);
  }
}

extension MicroActionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MicroAction, $Out> {
  MicroActionCopyWith<$R, MicroAction, $Out> get $asMicroAction =>
      $base.as((v, t, t2) => _MicroActionCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MicroActionCopyWith<$R, $In extends MicroAction, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? goalId,
    String? userId,
    String? title,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? scheduledFor,
    int? sortOrder,
  });
  MicroActionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _MicroActionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MicroAction, $Out>
    implements MicroActionCopyWith<$R, MicroAction, $Out> {
  _MicroActionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MicroAction> $mapper =
      MicroActionMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? goalId,
    String? userId,
    String? title,
    bool? isCompleted,
    Object? completedAt = $none,
    Object? scheduledFor = $none,
    int? sortOrder,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (goalId != null) #goalId: goalId,
      if (userId != null) #userId: userId,
      if (title != null) #title: title,
      if (isCompleted != null) #isCompleted: isCompleted,
      if (completedAt != $none) #completedAt: completedAt,
      if (scheduledFor != $none) #scheduledFor: scheduledFor,
      if (sortOrder != null) #sortOrder: sortOrder,
    }),
  );
  @override
  MicroAction $make(CopyWithData data) => MicroAction(
    id: data.get(#id, or: $value.id),
    goalId: data.get(#goalId, or: $value.goalId),
    userId: data.get(#userId, or: $value.userId),
    title: data.get(#title, or: $value.title),
    isCompleted: data.get(#isCompleted, or: $value.isCompleted),
    completedAt: data.get(#completedAt, or: $value.completedAt),
    scheduledFor: data.get(#scheduledFor, or: $value.scheduledFor),
    sortOrder: data.get(#sortOrder, or: $value.sortOrder),
  );

  @override
  MicroActionCopyWith<$R2, MicroAction, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MicroActionCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

