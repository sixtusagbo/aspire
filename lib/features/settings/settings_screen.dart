import 'package:aspire/core/utils/app_router.dart';
import 'package:aspire/core/utils/toast_helper.dart';
import 'package:aspire/services/auth_service.dart';
import 'package:aspire/services/log_service.dart';
import 'package:aspire/services/notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  static const _reminderHourKey = 'reminder_hour';
  static const _reminderMinuteKey = 'reminder_minute';
  static const _reminderEnabledKey = 'reminder_enabled';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationService = ref.read(notificationServiceProvider);
    final notificationsEnabled = useState<bool?>(null);
    final reminderEnabled = useState<bool>(false);
    final reminderTime = useState<TimeOfDay>(const TimeOfDay(hour: 9, minute: 0));

    // Load settings on mount
    useEffect(() {
      _loadSettings(
        notificationService,
        notificationsEnabled,
        reminderEnabled,
        reminderTime,
      );
      return null;
    }, []);

    Future<void> handleSignOut() async {
      try {
        final authService = ref.read(authServiceProvider);
        await authService.signOut();
        if (context.mounted) {
          context.go(AppRoutes.signIn);
        }
      } catch (e) {
        ToastHelper.showError('Failed to sign out');
      }
    }

    Future<void> handleNotificationToggle() async {
      if (notificationsEnabled.value == true) {
        // Already enabled, can't disable from app
        ToastHelper.showInfo('Disable notifications in system settings');
        return;
      }

      final granted = await notificationService.requestPermission();
      notificationsEnabled.value = granted;

      if (granted) {
        ToastHelper.showSuccess('Notifications enabled!');
      } else {
        ToastHelper.showWarning('Permission denied');
      }
    }

    Future<void> handleReminderToggle(bool value) async {
      if (value && notificationsEnabled.value != true) {
        // Need to request permission first
        final granted = await notificationService.requestPermission();
        notificationsEnabled.value = granted;
        if (!granted) {
          ToastHelper.showWarning('Enable notifications first');
          return;
        }
      }

      reminderEnabled.value = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_reminderEnabledKey, value);

      if (value) {
        // Schedule the reminder
        await notificationService.scheduleDailyReminder(
          hour: reminderTime.value.hour,
          minute: reminderTime.value.minute,
        );
        ToastHelper.showSuccess('Daily reminder set!');
      } else {
        // Cancel reminders
        await notificationService.cancelAll();
        ToastHelper.showInfo('Daily reminder disabled');
      }
    }

    Future<void> handleTimeChange() async {
      final picked = await showTimePicker(
        context: context,
        initialTime: reminderTime.value,
      );

      if (picked != null) {
        reminderTime.value = picked;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_reminderHourKey, picked.hour);
        await prefs.setInt(_reminderMinuteKey, picked.minute);

        if (reminderEnabled.value) {
          // Reschedule with new time
          await notificationService.scheduleDailyReminder(
            hour: picked.hour,
            minute: picked.minute,
          );
          ToastHelper.showSuccess('Reminder time updated!');
        }
      }
    }

    String formatTime(TimeOfDay time) {
      final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
      final minute = time.minute.toString().padLeft(2, '0');
      final period = time.period == DayPeriod.am ? 'AM' : 'PM';
      return '$hour:$minute $period';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Account'),
            subtitle: Text('Manage your account'),
          ),
          const Divider(),

          // Notifications section
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            subtitle: Text(
              notificationsEnabled.value == null
                  ? 'Checking...'
                  : notificationsEnabled.value!
                      ? 'Enabled'
                      : 'Tap to enable',
            ),
            trailing: notificationsEnabled.value == null
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Switch(
                    value: notificationsEnabled.value!,
                    onChanged: (_) => handleNotificationToggle(),
                  ),
            onTap: handleNotificationToggle,
          ),

          // Daily reminder toggle
          ListTile(
            leading: const SizedBox(width: 24), // Indent
            title: const Text('Daily Reminder'),
            subtitle: const Text('Get a nudge to complete your actions'),
            trailing: Switch(
              value: reminderEnabled.value,
              onChanged: handleReminderToggle,
            ),
          ),

          // Reminder time (only show if reminder enabled)
          if (reminderEnabled.value)
            ListTile(
              leading: const SizedBox(width: 24), // Indent
              title: const Text('Reminder Time'),
              subtitle: Text(formatTime(reminderTime.value)),
              trailing: const Icon(Icons.chevron_right),
              onTap: handleTimeChange,
            ),

          const Divider(),
          const ListTile(
            leading: Icon(Icons.workspace_premium_outlined),
            title: Text('Premium'),
            subtitle: Text('Upgrade to unlock unlimited goals'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            onTap: handleSignOut,
          ),

          // Debug section (only in debug mode)
          if (kDebugMode) ...[
            const Divider(height: 32),
            _DebugSection(ref: ref),
          ],
        ],
      ),
    );
  }

  Future<void> _loadSettings(
    NotificationService notificationService,
    ValueNotifier<bool?> notificationsEnabled,
    ValueNotifier<bool> reminderEnabled,
    ValueNotifier<TimeOfDay> reminderTime,
  ) async {
    // Check notification permission
    final enabled = await notificationService.areNotificationsEnabled();
    notificationsEnabled.value = enabled;

    // Load saved preferences
    final prefs = await SharedPreferences.getInstance();
    reminderEnabled.value = prefs.getBool(_reminderEnabledKey) ?? false;
    final hour = prefs.getInt(_reminderHourKey) ?? 9;
    final minute = prefs.getInt(_reminderMinuteKey) ?? 0;
    reminderTime.value = TimeOfDay(hour: hour, minute: minute);
  }
}

/// Debug section for testing notifications
class _DebugSection extends StatelessWidget {
  final WidgetRef ref;

  const _DebugSection({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'DEBUG: Test Notifications',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showTestNotification(context),
                icon: const Icon(Icons.notifications, size: 16),
                label: const Text('Test Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade100,
                  foregroundColor: Colors.blue.shade900,
                  elevation: 0,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _checkPendingNotifications(context),
                icon: const Icon(Icons.schedule, size: 16),
                label: const Text('Check Pending'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade100,
                  foregroundColor: Colors.green.shade900,
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _showTestNotification(BuildContext context) async {
    final notificationService = ref.read(notificationServiceProvider);
    try {
      await notificationService.showTestNotification();
      ToastHelper.showSuccess('Test notification sent!');
    } catch (e) {
      Log.e('Failed to show test notification', error: e);
      ToastHelper.showError('Failed: $e');
    }
  }

  Future<void> _checkPendingNotifications(BuildContext context) async {
    final notificationService = ref.read(notificationServiceProvider);
    try {
      final pending = await notificationService.getPendingNotifications();
      if (pending.isEmpty) {
        ToastHelper.showInfo('No pending notifications');
      } else {
        ToastHelper.showSuccess('${pending.length} pending notification(s)');
      }
    } catch (e) {
      Log.e('Failed to check notifications', error: e);
      ToastHelper.showError('Failed: $e');
    }
  }
}
