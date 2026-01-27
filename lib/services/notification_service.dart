import 'package:aspire/services/log_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/timezone.dart' as tz;

part 'notification_service.g.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize the notification plugin
  Future<void> initialize() async {
    if (_initialized) return;

    // Set up timezone
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
    Log.d('Timezone set to: ${timezoneInfo.identifier}');

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    final initialized = await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        Log.i('Notification tapped: ${response.payload}');
      },
    );
    Log.d('Notifications initialized: $initialized');
    _initialized = true;
  }

  /// Request all notification permissions (notifications + exact alarms)
  Future<bool> requestPermission() async {
    await initialize();

    // Android
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      // Request notification permission (Android 13+)
      final notifGranted = await androidPlugin.requestNotificationsPermission();
      Log.d('Android notification permission granted: $notifGranted');

      // Request exact alarm permission (Android 12+)
      final exactAlarmGranted = await androidPlugin.requestExactAlarmsPermission();
      Log.d('Android exact alarm permission granted: $exactAlarmGranted');

      return (notifGranted ?? false) && (exactAlarmGranted ?? true);
    }

    // iOS permission request
    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      Log.d('iOS notification permission granted: $granted');
      return granted ?? false;
    }

    return true;
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    await initialize();

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      final enabled = await androidPlugin.areNotificationsEnabled() ?? false;
      Log.d('Notifications enabled: $enabled');
      return enabled;
    }

    return true;
  }

  /// Show an immediate test notification
  Future<void> showTestNotification() async {
    await initialize();

    Log.i('Showing test notification...');

    await _notifications.show(
      99,
      'Test Notification',
      'If you see this, notifications are working!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          channelDescription: 'For testing notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// Schedule a daily reminder notification
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    await initialize();

    // Cancel existing reminders
    await _notifications.cancel(0);

    final scheduledTime = _nextInstanceOfTime(hour, minute);
    Log.i('Scheduling daily reminder for: $scheduledTime');

    // Schedule new reminder
    await _notifications.zonedSchedule(
      0,
      'Time to take action!',
      'Check your micro-actions for today',
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminders',
          channelDescription: 'Daily micro-action reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    Log.i('Daily reminder scheduled successfully');
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
    Log.i('All notifications cancelled');
  }

  /// Schedule a goal-specific reminder notification
  Future<void> scheduleGoalReminder({
    required String goalId,
    required String goalTitle,
    required int hour,
    required int minute,
  }) async {
    await initialize();

    final notificationId = _goalNotificationId(goalId);
    final scheduledTime = _nextInstanceOfTime(hour, minute);
    Log.i('Scheduling goal reminder for "$goalTitle" at $scheduledTime');

    await _notifications.zonedSchedule(
      notificationId,
      'Time to work on your goal!',
      goalTitle,
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'goal_reminder',
          'Goal Reminders',
          channelDescription: 'Reminders for specific goals',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    Log.i('Goal reminder scheduled successfully');
  }

  /// Cancel a goal-specific reminder
  Future<void> cancelGoalReminder(String goalId) async {
    final notificationId = _goalNotificationId(goalId);
    await _notifications.cancel(notificationId);
    Log.i('Goal reminder cancelled for goal: $goalId');
  }

  /// Generate a unique notification ID for a goal (based on hash)
  int _goalNotificationId(String goalId) {
    // Use hashCode but ensure it's positive and doesn't conflict with ID 0 (daily reminder)
    return (goalId.hashCode.abs() % 1000000) + 1000;
  }

  /// Get pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    await initialize();
    final pending = await _notifications.pendingNotificationRequests();
    Log.d('Pending notifications: ${pending.length}');
    for (final n in pending) {
      Log.d('  - ID: ${n.id}, Title: ${n.title}');
    }
    return pending;
  }
}

@riverpod
NotificationService notificationService(Ref ref) {
  return NotificationService();
}
