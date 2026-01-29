// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'tip.dart';

class TipMapper extends ClassMapperBase<Tip> {
  TipMapper._();

  static TipMapper? _instance;
  static TipMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TipMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Tip';

  static String _$id(Tip v) => v.id;
  static const Field<Tip, String> _f$id = Field('id', _$id);
  static String _$text(Tip v) => v.text;
  static const Field<Tip, String> _f$text = Field('text', _$text);
  static String? _$author(Tip v) => v.author;
  static const Field<Tip, String> _f$author = Field(
    'author',
    _$author,
    opt: true,
  );
  static bool _$isActive(Tip v) => v.isActive;
  static const Field<Tip, bool> _f$isActive = Field(
    'isActive',
    _$isActive,
    opt: true,
    def: true,
  );

  @override
  final MappableFields<Tip> fields = const {
    #id: _f$id,
    #text: _f$text,
    #author: _f$author,
    #isActive: _f$isActive,
  };

  static Tip _instantiate(DecodingData data) {
    return Tip(
      id: data.dec(_f$id),
      text: data.dec(_f$text),
      author: data.dec(_f$author),
      isActive: data.dec(_f$isActive),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Tip fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Tip>(map);
  }

  static Tip fromJson(String json) {
    return ensureInitialized().decodeJson<Tip>(json);
  }
}

mixin TipMappable {
  String toJson() {
    return TipMapper.ensureInitialized().encodeJson<Tip>(this as Tip);
  }

  Map<String, dynamic> toMap() {
    return TipMapper.ensureInitialized().encodeMap<Tip>(this as Tip);
  }

  TipCopyWith<Tip, Tip, Tip> get copyWith =>
      _TipCopyWithImpl<Tip, Tip>(this as Tip, $identity, $identity);
  @override
  String toString() {
    return TipMapper.ensureInitialized().stringifyValue(this as Tip);
  }

  @override
  bool operator ==(Object other) {
    return TipMapper.ensureInitialized().equalsValue(this as Tip, other);
  }

  @override
  int get hashCode {
    return TipMapper.ensureInitialized().hashValue(this as Tip);
  }
}

extension TipValueCopy<$R, $Out> on ObjectCopyWith<$R, Tip, $Out> {
  TipCopyWith<$R, Tip, $Out> get $asTip =>
      $base.as((v, t, t2) => _TipCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class TipCopyWith<$R, $In extends Tip, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? id, String? text, String? author, bool? isActive});
  TipCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _TipCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Tip, $Out>
    implements TipCopyWith<$R, Tip, $Out> {
  _TipCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Tip> $mapper = TipMapper.ensureInitialized();
  @override
  $R call({String? id, String? text, Object? author = $none, bool? isActive}) =>
      $apply(
        FieldCopyWithData({
          if (id != null) #id: id,
          if (text != null) #text: text,
          if (author != $none) #author: author,
          if (isActive != null) #isActive: isActive,
        }),
      );
  @override
  Tip $make(CopyWithData data) => Tip(
    id: data.get(#id, or: $value.id),
    text: data.get(#text, or: $value.text),
    author: data.get(#author, or: $value.author),
    isActive: data.get(#isActive, or: $value.isActive),
  );

  @override
  TipCopyWith<$R2, Tip, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _TipCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

