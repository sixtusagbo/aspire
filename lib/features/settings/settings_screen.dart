import 'package:aspire/core/utils/app_router.dart';
import 'package:aspire/core/utils/toast_helper.dart';
import 'package:aspire/services/auth_service.dart';
import 'package:aspire/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationService = ref.read(notificationServiceProvider);
    final notificationsEnabled = useState<bool?>(null);

    // Check notification status on load
    useEffect(() {
      notificationService.areNotificationsEnabled().then((enabled) {
        notificationsEnabled.value = enabled;
      });
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Account'),
            subtitle: Text('Manage your account'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            subtitle: Text(
              notificationsEnabled.value == null
                  ? 'Checking...'
                  : notificationsEnabled.value!
                      ? 'Enabled'
                      : 'Tap to enable daily reminders',
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
        ],
      ),
    );
  }
}
