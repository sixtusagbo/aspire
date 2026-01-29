import 'package:aspire/core/utils/app_router.dart';
import 'package:aspire/core/utils/toast_helper.dart';
import 'package:aspire/services/auth_service.dart';
import 'package:aspire/services/goal_service.dart';
import 'package:aspire/services/notification_service.dart';
import 'package:aspire/services/revenue_cat_service.dart';
import 'package:aspire/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);
    final userService = ref.read(userServiceProvider);
    final notificationService = ref.read(notificationServiceProvider);
    final revenueCatService = ref.read(revenueCatServiceProvider);
    final userId = authService.currentUser?.uid;
    final notificationsEnabled = useState<bool?>(null);
    final reminderEnabled = useState<bool>(false);
    final reminderTime = useState<TimeOfDay>(
      const TimeOfDay(hour: 9, minute: 0),
    );
    final isPremium = useState<bool?>(null);
    final appVersion = useState<String>('');
    final isDeleting = useState<bool>(false);

    // Load settings on mount
    useEffect(() {
      _loadSettings(
        notificationService,
        userService,
        userId,
        notificationsEnabled,
        reminderEnabled,
        reminderTime,
      );
      revenueCatService.isPremium().then((value) => isPremium.value = value);
      PackageInfo.fromPlatform().then((info) {
        appVersion.value = '${info.version} (${info.buildNumber})';
      });
      return null;
    }, []);

    Future<void> handleSignOut() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Sign Out'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      try {
        final authService = ref.read(authServiceProvider);
        final revenueCatService = ref.read(revenueCatServiceProvider);
        await revenueCatService.logout();
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

      // Save to Firebase
      if (userId != null) {
        await userService.updateUser(userId, {'dailyReminderEnabled': value});
      }

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

        // Save to Firebase
        if (userId != null) {
          await userService.updateUser(userId, {
            'reminderHour': picked.hour,
            'reminderMinute': picked.minute,
          });
        }

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

    Future<void> handleManageSubscription() async {
      try {
        await revenueCatService.showManageSubscriptions();
      } catch (e) {
        ToastHelper.showError('Could not open subscription settings');
      }
    }

    Future<void> handleDeleteAccount() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'This will permanently delete your account and all your data '
            '(goals, actions, progress). This action cannot be undone.\n\n'
            'Are you sure you want to delete your account?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      isDeleting.value = true;
      try {
        final authService = ref.read(authServiceProvider);
        final goalService = ref.read(goalServiceProvider);
        final userService = ref.read(userServiceProvider);
        final userId = authService.currentUser?.uid;

        if (userId == null) {
          throw Exception('No user signed in');
        }

        // Delete all user data from Firestore
        await goalService.deleteAllUserData(userId);
        await userService.deleteUser(userId);

        // Logout from RevenueCat
        await revenueCatService.logout();

        // Delete Firebase Auth account
        await authService.deleteAccount();

        if (context.mounted) {
          context.go(AppRoutes.signIn);
        }
        ToastHelper.showSuccess('Account deleted');
      } catch (e) {
        ToastHelper.showError('Failed to delete account: $e');
      } finally {
        isDeleting.value = false;
      }
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

          // Test notification button
          ListTile(
            leading: const SizedBox(width: 24),
            title: const Text('Test Notification'),
            subtitle: const Text('Send a test notification now'),
            trailing: const Icon(Icons.send),
            onTap: () async {
              await notificationService.showTestNotification();
              ToastHelper.showSuccess('Test notification sent!');
            },
          ),

          const Divider(),
          ListTile(
            leading: Icon(
              isPremium.value == true
                  ? Icons.workspace_premium
                  : Icons.workspace_premium_outlined,
              color: isPremium.value == true
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            title: const Text('Premium'),
            subtitle: Text(
              isPremium.value == null
                  ? 'Checking...'
                  : isPremium.value!
                      ? 'You have premium access'
                      : 'Upgrade to unlock unlimited goals',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.paywall),
          ),
          if (isPremium.value == true)
            ListTile(
              leading: const SizedBox(width: 24),
              title: const Text('Manage Subscription'),
              subtitle: const Text('View or cancel in app store'),
              trailing: const Icon(Icons.chevron_right),
              onTap: handleManageSubscription,
            ),
          const Divider(),

          // About section
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: Text(
              appVersion.value.isEmpty
                  ? 'Loading...'
                  : 'Version ${appVersion.value}',
            ),
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            onTap: handleSignOut,
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red),
            ),
            subtitle: const Text('Permanently delete all data'),
            trailing: isDeleting.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            onTap: isDeleting.value ? null : handleDeleteAccount,
          ),
        ],
      ),
    );
  }

  Future<void> _loadSettings(
    NotificationService notificationService,
    UserService userService,
    String? userId,
    ValueNotifier<bool?> notificationsEnabled,
    ValueNotifier<bool> reminderEnabled,
    ValueNotifier<TimeOfDay> reminderTime,
  ) async {
    // Check notification permission
    final enabled = await notificationService.areNotificationsEnabled();
    notificationsEnabled.value = enabled;

    // Load from Firebase
    if (userId != null) {
      final user = await userService.getUser(userId);
      if (user != null) {
        reminderEnabled.value = user.dailyReminderEnabled;
        reminderTime.value = TimeOfDay(
          hour: user.reminderHour,
          minute: user.reminderMinute,
        );
      }
    }
  }
}
