// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'user.dart';

class AppUserMapper extends ClassMapperBase<AppUser> {
  AppUserMapper._();

  static AppUserMapper? _instance;
  static AppUserMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AppUserMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'AppUser';

  static String _$id(AppUser v) => v.id;
  static const Field<AppUser, String> _f$id = Field('id', _$id);
  static String _$name(AppUser v) => v.name;
  static const Field<AppUser, String> _f$name = Field('name', _$name);
  static String _$email(AppUser v) => v.email;
  static const Field<AppUser, String> _f$email = Field('email', _$email);
  static bool _$notificationsEnabled(AppUser v) => v.notificationsEnabled;
  static const Field<AppUser, bool> _f$notificationsEnabled = Field(
    'notificationsEnabled',
    _$notificationsEnabled,
    opt: true,
    def: false,
  );
  static bool _$onboardingComplete(AppUser v) => v.onboardingComplete;
  static const Field<AppUser, bool> _f$onboardingComplete = Field(
    'onboardingComplete',
    _$onboardingComplete,
    opt: true,
    def: false,
  );
  static DateTime _$createdAt(AppUser v) => v.createdAt;
  static const Field<AppUser, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    hook: DateTimeHook(),
  );
  static int _$xp(AppUser v) => v.xp;
  static const Field<AppUser, int> _f$xp = Field('xp', _$xp, opt: true, def: 0);
  static int _$level(AppUser v) => v.level;
  static const Field<AppUser, int> _f$level = Field(
    'level',
    _$level,
    opt: true,
    def: 1,
  );
  static int _$currentStreak(AppUser v) => v.currentStreak;
  static const Field<AppUser, int> _f$currentStreak = Field(
    'currentStreak',
    _$currentStreak,
    opt: true,
    def: 0,
  );
  static int _$longestStreak(AppUser v) => v.longestStreak;
  static const Field<AppUser, int> _f$longestStreak = Field(
    'longestStreak',
    _$longestStreak,
    opt: true,
    def: 0,
  );
  static DateTime? _$lastActivityDate(AppUser v) => v.lastActivityDate;
  static const Field<AppUser, DateTime> _f$lastActivityDate = Field(
    'lastActivityDate',
    _$lastActivityDate,
    opt: true,
    hook: NullableDateTimeHook(),
  );
  static bool _$isPremium(AppUser v) => v.isPremium;
  static const Field<AppUser, bool> _f$isPremium = Field(
    'isPremium',
    _$isPremium,
    opt: true,
    def: false,
  );
  static DateTime? _$premiumExpiresAt(AppUser v) => v.premiumExpiresAt;
  static const Field<AppUser, DateTime> _f$premiumExpiresAt = Field(
    'premiumExpiresAt',
    _$premiumExpiresAt,
    opt: true,
    hook: NullableDateTimeHook(),
  );

  @override
  final MappableFields<AppUser> fields = const {
    #id: _f$id,
    #name: _f$name,
    #email: _f$email,
    #notificationsEnabled: _f$notificationsEnabled,
    #onboardingComplete: _f$onboardingComplete,
    #createdAt: _f$createdAt,
    #xp: _f$xp,
    #level: _f$level,
    #currentStreak: _f$currentStreak,
    #longestStreak: _f$longestStreak,
    #lastActivityDate: _f$lastActivityDate,
    #isPremium: _f$isPremium,
    #premiumExpiresAt: _f$premiumExpiresAt,
  };

  static AppUser _instantiate(DecodingData data) {
    return AppUser(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      email: data.dec(_f$email),
      notificationsEnabled: data.dec(_f$notificationsEnabled),
      onboardingComplete: data.dec(_f$onboardingComplete),
      createdAt: data.dec(_f$createdAt),
      xp: data.dec(_f$xp),
      level: data.dec(_f$level),
      currentStreak: data.dec(_f$currentStreak),
      longestStreak: data.dec(_f$longestStreak),
      lastActivityDate: data.dec(_f$lastActivityDate),
      isPremium: data.dec(_f$isPremium),
      premiumExpiresAt: data.dec(_f$premiumExpiresAt),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static AppUser fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AppUser>(map);
  }

  static AppUser fromJson(String json) {
    return ensureInitialized().decodeJson<AppUser>(json);
  }
}

mixin AppUserMappable {
  String toJson() {
    return AppUserMapper.ensureInitialized().encodeJson<AppUser>(
      this as AppUser,
    );
  }

  Map<String, dynamic> toMap() {
    return AppUserMapper.ensureInitialized().encodeMap<AppUser>(
      this as AppUser,
    );
  }

  AppUserCopyWith<AppUser, AppUser, AppUser> get copyWith =>
      _AppUserCopyWithImpl<AppUser, AppUser>(
        this as AppUser,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return AppUserMapper.ensureInitialized().stringifyValue(this as AppUser);
  }

  @override
  bool operator ==(Object other) {
    return AppUserMapper.ensureInitialized().equalsValue(
      this as AppUser,
      other,
    );
  }

  @override
  int get hashCode {
    return AppUserMapper.ensureInitialized().hashValue(this as AppUser);
  }
}

extension AppUserValueCopy<$R, $Out> on ObjectCopyWith<$R, AppUser, $Out> {
  AppUserCopyWith<$R, AppUser, $Out> get $asAppUser =>
      $base.as((v, t, t2) => _AppUserCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class AppUserCopyWith<$R, $In extends AppUser, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? name,
    String? email,
    bool? notificationsEnabled,
    bool? onboardingComplete,
    DateTime? createdAt,
    int? xp,
    int? level,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActivityDate,
    bool? isPremium,
    DateTime? premiumExpiresAt,
  });
  AppUserCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _AppUserCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AppUser, $Out>
    implements AppUserCopyWith<$R, AppUser, $Out> {
  _AppUserCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AppUser> $mapper =
      AppUserMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? name,
    String? email,
    bool? notificationsEnabled,
    bool? onboardingComplete,
    DateTime? createdAt,
    int? xp,
    int? level,
    int? currentStreak,
    int? longestStreak,
    Object? lastActivityDate = $none,
    bool? isPremium,
    Object? premiumExpiresAt = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (name != null) #name: name,
      if (email != null) #email: email,
      if (notificationsEnabled != null)
        #notificationsEnabled: notificationsEnabled,
      if (onboardingComplete != null) #onboardingComplete: onboardingComplete,
      if (createdAt != null) #createdAt: createdAt,
      if (xp != null) #xp: xp,
      if (level != null) #level: level,
      if (currentStreak != null) #currentStreak: currentStreak,
      if (longestStreak != null) #longestStreak: longestStreak,
      if (lastActivityDate != $none) #lastActivityDate: lastActivityDate,
      if (isPremium != null) #isPremium: isPremium,
      if (premiumExpiresAt != $none) #premiumExpiresAt: premiumExpiresAt,
    }),
  );
  @override
  AppUser $make(CopyWithData data) => AppUser(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    email: data.get(#email, or: $value.email),
    notificationsEnabled: data.get(
      #notificationsEnabled,
      or: $value.notificationsEnabled,
    ),
    onboardingComplete: data.get(
      #onboardingComplete,
      or: $value.onboardingComplete,
    ),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    xp: data.get(#xp, or: $value.xp),
    level: data.get(#level, or: $value.level),
    currentStreak: data.get(#currentStreak, or: $value.currentStreak),
    longestStreak: data.get(#longestStreak, or: $value.longestStreak),
    lastActivityDate: data.get(#lastActivityDate, or: $value.lastActivityDate),
    isPremium: data.get(#isPremium, or: $value.isPremium),
    premiumExpiresAt: data.get(#premiumExpiresAt, or: $value.premiumExpiresAt),
  );

  @override
  AppUserCopyWith<$R2, AppUser, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _AppUserCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

