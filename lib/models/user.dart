import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'user.mapper.dart';

@MappableClass()
class AppUser with AppUserMappable {
  final String id;
  final String name;
  final String email;
  final bool notificationsEnabled;
  final bool onboardingComplete;

  @MappableField(hook: DateTimeHook())
  final DateTime createdAt;

  // Gamification stats
  final int xp;
  final int level;
  final int currentStreak;
  final int longestStreak;

  @MappableField(hook: NullableDateTimeHook())
  final DateTime? lastActivityDate;

  // Premium status
  final bool isPremium;

  @MappableField(hook: NullableDateTimeHook())
  final DateTime? premiumExpiresAt;

  // Daily reminder settings (synced to Firebase)
  final bool dailyReminderEnabled;
  final int reminderHour;
  final int reminderMinute;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.notificationsEnabled = false,
    this.onboardingComplete = false,
    required this.createdAt,
    this.xp = 0,
    this.level = 1,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActivityDate,
    this.isPremium = false,
    this.premiumExpiresAt,
    this.dailyReminderEnabled = false,
    this.reminderHour = 9,
    this.reminderMinute = 0,
  });
}

/// Custom hook to handle DateTime serialization from Firestore Timestamp
class DateTimeHook extends MappingHook {
  const DateTimeHook();

  @override
  Object? beforeDecode(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    return value;
  }

  @override
  Object? beforeEncode(Object? value) {
    if (value is DateTime) {
      return Timestamp.fromDate(value);
    }
    return value;
  }
}

/// Custom hook for nullable DateTime
class NullableDateTimeHook extends MappingHook {
  const NullableDateTimeHook();

  @override
  Object? beforeDecode(Object? value) {
    if (value == null) return null;
    if (value is Timestamp) {
      return value.toDate();
    }
    return value;
  }

  @override
  Object? beforeEncode(Object? value) {
    if (value == null) return null;
    if (value is DateTime) {
      return Timestamp.fromDate(value);
    }
    return value;
  }
}
