import 'package:app_settings/app_settings.dart';
import 'package:aspire/services/log_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/timezone.dart' as tz;

part 'notification_service.g.dart';

/// Top-level function to handle background FCM messages
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background FCM message: ${message.messageId}');
}

/// Android notification channel for daily reminders
const _dailyReminderChannel = AndroidNotificationChannel(
  'daily_reminder',
  'Daily Reminders',
  description: 'Daily micro-action reminders',
  importance: Importance.high,
);

/// Android notification channel for goal reminders
const _goalReminderChannel = AndroidNotificationChannel(
  'goal_reminder',
  'Goal Reminders',
  description: 'Reminders for specific goals',
  importance: Importance.high,
);

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  bool _initialized = false;

  /// Initialize the notification plugin
  Future<void> initialize() async {
    if (_initialized) return;

    Log.d('Initializing notification service...');

    // Set up local timezone (critical for scheduled notifications)
    final timezoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneName));
    Log.d('Timezone set to: $timezoneName');

    // Create Android notification channels (required for Android 8+)
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(_dailyReminderChannel);
      await androidPlugin.createNotificationChannel(_goalReminderChannel);
      Log.d('Android notification channels created');
    }

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
    Log.d('Local notifications initialized: $initialized');

    // Initialize FCM for foreground support
    await _initializeFCM();

    _initialized = true;
    Log.d('Notification service initialized successfully');
  }

  /// Initialize Firebase Cloud Messaging
  Future<void> _initializeFCM() async {
    // Enable foreground notifications on iOS
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle foreground FCM messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Log.d('Received foreground FCM message: ${message.messageId}');
    });

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Log.d('FCM notification tapped (background): ${message.messageId}');
    });

    Log.d('FCM initialized');
  }

  /// Request all notification permissions (FCM + local + exact alarms)
  Future<bool> requestPermission() async {
    await initialize();

    // Request FCM permissions first (shows iOS permission dialog)
    final fcmSettings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    final fcmGranted =
        fcmSettings.authorizationStatus == AuthorizationStatus.authorized ||
        fcmSettings.authorizationStatus == AuthorizationStatus.provisional;
    Log.d('FCM permission granted: $fcmGranted');

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

      return fcmGranted &&
          (notifGranted ?? false) &&
          (exactAlarmGranted ?? true);
    }

    // iOS permission request (uses same permission as FCM)
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
      Log.d('iOS local notification permission granted: $granted');
      return fcmGranted && (granted ?? false);
    }

    return fcmGranted;
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    await initialize();

    // Check FCM permissions
    final fcmSettings = await _fcm.getNotificationSettings();
    final fcmEnabled =
        fcmSettings.authorizationStatus == AuthorizationStatus.authorized ||
        fcmSettings.authorizationStatus == AuthorizationStatus.provisional;

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      final enabled = await androidPlugin.areNotificationsEnabled() ?? false;
      Log.d('Notifications enabled: FCM=$fcmEnabled, Local=$enabled');
      return fcmEnabled && enabled;
    }

    // iOS - FCM status is sufficient
    Log.d('iOS notifications enabled: $fcmEnabled');
    return fcmEnabled;
  }

  /// Open system notification settings for this app
  Future<void> openSettings() async {
    await AppSettings.openAppSettings(type: AppSettingsType.notification);
  }

  /// Show an immediate test notification
  Future<void> showTestNotification() async {
    await initialize();

    Log.i('Showing test notification...');
    debugPrint('Showing test notification NOW');

    await _notifications.show(
      99,
      'Test Notification',
      'If you see this, notifications are working!',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _dailyReminderChannel.id,
          _dailyReminderChannel.name,
          channelDescription: _dailyReminderChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );

    Log.i('Test notification sent!');
  }

  /// Show a scheduled test notification (fires in 5 seconds)
  Future<void> showScheduledTestNotification() async {
    await initialize();

    final scheduledTime = tz.TZDateTime.now(tz.local).add(
      const Duration(seconds: 5),
    );
    Log.i('Scheduling test notification for: $scheduledTime');
    debugPrint('Scheduling test notification for 5 seconds from now');

    await _notifications.zonedSchedule(
      98,
      'Scheduled Test',
      'This notification was scheduled 5 seconds ago!',
      scheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _dailyReminderChannel.id,
          _dailyReminderChannel.name,
          channelDescription: _dailyReminderChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    Log.i('Scheduled test notification created');
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
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
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
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
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

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) {
  return NotificationService();
}
