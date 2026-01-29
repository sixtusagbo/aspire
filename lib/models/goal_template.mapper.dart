// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'goal_template.dart';

class TargetDateTypeMapper extends EnumMapper<TargetDateType> {
  TargetDateTypeMapper._();

  static TargetDateTypeMapper? _instance;
  static TargetDateTypeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TargetDateTypeMapper._());
    }
    return _instance!;
  }

  static TargetDateType fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  TargetDateType decode(dynamic value) {
    switch (value) {
      case r'none':
        return TargetDateType.none;
      case r'endOfYear':
        return TargetDateType.endOfYear;
      case r'threeMonths':
        return TargetDateType.threeMonths;
      case r'sixMonths':
        return TargetDateType.sixMonths;
      case r'oneYear':
        return TargetDateType.oneYear;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(TargetDateType self) {
    switch (self) {
      case TargetDateType.none:
        return r'none';
      case TargetDateType.endOfYear:
        return r'endOfYear';
      case TargetDateType.threeMonths:
        return r'threeMonths';
      case TargetDateType.sixMonths:
        return r'sixMonths';
      case TargetDateType.oneYear:
        return r'oneYear';
    }
  }
}

extension TargetDateTypeMapperExtension on TargetDateType {
  String toValue() {
    TargetDateTypeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<TargetDateType>(this) as String;
  }
}

class GoalTemplateMapper extends ClassMapperBase<GoalTemplate> {
  GoalTemplateMapper._();

  static GoalTemplateMapper? _instance;
  static GoalTemplateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = GoalTemplateMapper._());
      GoalCategoryMapper.ensureInitialized();
      TargetDateTypeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'GoalTemplate';

  static String _$id(GoalTemplate v) => v.id;
  static const Field<GoalTemplate, String> _f$id = Field('id', _$id);
  static String _$title(GoalTemplate v) => v.title;
  static const Field<GoalTemplate, String> _f$title = Field('title', _$title);
  static String _$description(GoalTemplate v) => v.description;
  static const Field<GoalTemplate, String> _f$description = Field(
    'description',
    _$description,
  );
  static GoalCategory _$category(GoalTemplate v) => v.category;
  static const Field<GoalTemplate, GoalCategory> _f$category = Field(
    'category',
    _$category,
  );
  static List<String> _$suggestedActions(GoalTemplate v) => v.suggestedActions;
  static const Field<GoalTemplate, List<String>> _f$suggestedActions = Field(
    'suggestedActions',
    _$suggestedActions,
  );
  static TargetDateType _$targetDateType(GoalTemplate v) => v.targetDateType;
  static const Field<GoalTemplate, TargetDateType> _f$targetDateType = Field(
    'targetDateType',
    _$targetDateType,
    opt: true,
    def: TargetDateType.none,
  );
  static DateTime _$createdAt(GoalTemplate v) => v.createdAt;
  static const Field<GoalTemplate, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    hook: DateTimeHook(),
  );
  static bool _$isActive(GoalTemplate v) => v.isActive;
  static const Field<GoalTemplate, bool> _f$isActive = Field(
    'isActive',
    _$isActive,
    opt: true,
    def: true,
  );

  @override
  final MappableFields<GoalTemplate> fields = const {
    #id: _f$id,
    #title: _f$title,
    #description: _f$description,
    #category: _f$category,
    #suggestedActions: _f$suggestedActions,
    #targetDateType: _f$targetDateType,
    #createdAt: _f$createdAt,
    #isActive: _f$isActive,
  };

  static GoalTemplate _instantiate(DecodingData data) {
    return GoalTemplate(
      id: data.dec(_f$id),
      title: data.dec(_f$title),
      description: data.dec(_f$description),
      category: data.dec(_f$category),
      suggestedActions: data.dec(_f$suggestedActions),
      targetDateType: data.dec(_f$targetDateType),
      createdAt: data.dec(_f$createdAt),
      isActive: data.dec(_f$isActive),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static GoalTemplate fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<GoalTemplate>(map);
  }

  static GoalTemplate fromJson(String json) {
    return ensureInitialized().decodeJson<GoalTemplate>(json);
  }
}

mixin GoalTemplateMappable {
  String toJson() {
    return GoalTemplateMapper.ensureInitialized().encodeJson<GoalTemplate>(
      this as GoalTemplate,
    );
  }

  Map<String, dynamic> toMap() {
    return GoalTemplateMapper.ensureInitialized().encodeMap<GoalTemplate>(
      this as GoalTemplate,
    );
  }

  GoalTemplateCopyWith<GoalTemplate, GoalTemplate, GoalTemplate> get copyWith =>
      _GoalTemplateCopyWithImpl<GoalTemplate, GoalTemplate>(
        this as GoalTemplate,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return GoalTemplateMapper.ensureInitialized().stringifyValue(
      this as GoalTemplate,
    );
  }

  @override
  bool operator ==(Object other) {
    return GoalTemplateMapper.ensureInitialized().equalsValue(
      this as GoalTemplate,
      other,
    );
  }

  @override
  int get hashCode {
    return GoalTemplateMapper.ensureInitialized().hashValue(
      this as GoalTemplate,
    );
  }
}

extension GoalTemplateValueCopy<$R, $Out>
    on ObjectCopyWith<$R, GoalTemplate, $Out> {
  GoalTemplateCopyWith<$R, GoalTemplate, $Out> get $asGoalTemplate =>
      $base.as((v, t, t2) => _GoalTemplateCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class GoalTemplateCopyWith<$R, $In extends GoalTemplate, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>
  get suggestedActions;
  $R call({
    String? id,
    String? title,
    String? description,
    GoalCategory? category,
    List<String>? suggestedActions,
    TargetDateType? targetDateType,
    DateTime? createdAt,
    bool? isActive,
  });
  GoalTemplateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _GoalTemplateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, GoalTemplate, $Out>
    implements GoalTemplateCopyWith<$R, GoalTemplate, $Out> {
  _GoalTemplateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<GoalTemplate> $mapper =
      GoalTemplateMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>
  get suggestedActions => ListCopyWith(
    $value.suggestedActions,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(suggestedActions: v),
  );
  @override
  $R call({
    String? id,
    String? title,
    String? description,
    GoalCategory? category,
    List<String>? suggestedActions,
    TargetDateType? targetDateType,
    DateTime? createdAt,
    bool? isActive,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (title != null) #title: title,
      if (description != null) #description: description,
      if (category != null) #category: category,
      if (suggestedActions != null) #suggestedActions: suggestedActions,
      if (targetDateType != null) #targetDateType: targetDateType,
      if (createdAt != null) #createdAt: createdAt,
      if (isActive != null) #isActive: isActive,
    }),
  );
  @override
  GoalTemplate $make(CopyWithData data) => GoalTemplate(
    id: data.get(#id, or: $value.id),
    title: data.get(#title, or: $value.title),
    description: data.get(#description, or: $value.description),
    category: data.get(#category, or: $value.category),
    suggestedActions: data.get(#suggestedActions, or: $value.suggestedActions),
    targetDateType: data.get(#targetDateType, or: $value.targetDateType),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    isActive: data.get(#isActive, or: $value.isActive),
  );

  @override
  GoalTemplateCopyWith<$R2, GoalTemplate, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _GoalTemplateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

