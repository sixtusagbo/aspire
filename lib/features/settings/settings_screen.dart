import 'package:aspire/core/theme/app_theme.dart';
import 'package:aspire/core/theme/category_colors.dart';
import 'package:aspire/core/theme/theme_provider.dart';
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
import 'package:url_launcher/url_launcher.dart';

const _termsOfServiceUrl = 'https://aspire.sixtusagbo.dev/terms';
const _privacyPolicyUrl = 'https://aspire.sixtusagbo.dev/privacy';

// Gabby Beckford's social links
const _gabbyInstagram = 'https://www.instagram.com/packslight/';
const _gabbyTikTok = 'https://www.tiktok.com/@packslight';
const _gabbyTwitter = 'https://x.com/packslight';
const _gabbyWebsite = 'https://www.packslight.com/';

Future<void> _launchUrl(String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    ToastHelper.showError('Could not open link');
  }
}

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
    final customCategories = useState<List<String>>([]);

    // Load settings on mount
    useEffect(() {
      _loadSettings(
        notificationService,
        userService,
        userId,
        notificationsEnabled,
        reminderEnabled,
        reminderTime,
        customCategories,
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
        // Already enabled, open settings to disable
        await notificationService.openSettings();
        // Recheck after returning from settings
        final stillEnabled = await notificationService
            .areNotificationsEnabled();
        notificationsEnabled.value = stillEnabled;

        // Auto-disable reminder if notifications were turned off
        if (!stillEnabled && reminderEnabled.value) {
          reminderEnabled.value = false;
          await notificationService.cancelAll();
          if (userId != null) {
            await userService.updateUser(userId, {
              'dailyReminderEnabled': false,
            });
          }
        }
        return;
      }

      final granted = await notificationService.requestPermission();
      notificationsEnabled.value = granted;

      if (granted) {
        ToastHelper.showSuccess('Notifications enabled!');
      } else {
        // Permission denied - open settings so user can enable manually
        await notificationService.openSettings();
        // Recheck after returning from settings
        notificationsEnabled.value = await notificationService
            .areNotificationsEnabled();
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

    Future<void> handleManageCategories() async {
      final goalService = ref.read(goalServiceProvider);
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => _ManageCategoriesSheet(
          userId: userId!,
          categories: customCategories.value,
          userService: userService,
          goalService: goalService,
          onCategoriesChanged: (newList) {
            customCategories.value = newList;
          },
        ),
      );
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

      // Show non-dismissible full-screen loading overlay
      if (context.mounted) {
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => const PopScope(
            canPop: false,
            child: Scaffold(
              backgroundColor: Colors.black87,
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator.adaptive(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Deleting account...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }

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
        // Dismiss loading overlay on error
        if (context.mounted) Navigator.of(context).pop();
        ToastHelper.showError('Failed to delete account: $e');
      } finally {
        isDeleting.value = false;
      }
    }

    final user = authService.currentUser;
    final displayName = useState(user?.displayName ?? '');

    Future<void> handleEditAccount() async {
      final controller = TextEditingController(text: displayName.value);
      final result = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Profile',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                user?.email ?? '',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                autofocus: true,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, controller.text),
                  child: const Text('Save'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );

      if (result != null && result.isNotEmpty && result != displayName.value) {
        try {
          // Update Firebase Auth
          await user?.updateDisplayName(result);
          // Update Firestore
          if (userId != null) {
            await userService.updateUser(userId, {'name': result});
          }
          displayName.value = result;
          ToastHelper.showSuccess('Name updated');
        } catch (e) {
          ToastHelper.showError('Failed to update name');
        }
      }
    }

    final initial = displayName.value.isNotEmpty
        ? displayName.value[0].toUpperCase()
        : (user?.email?.isNotEmpty == true
              ? user!.email![0].toUpperCase()
              : '?');

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 8),

          // Profile header
          GestureDetector(
            onTap: handleEditAccount,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                border: Border.all(color: context.borderColor),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.primaryPink.withValues(
                      alpha: 0.15,
                    ),
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryPink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName.value.isNotEmpty
                              ? displayName.value
                              : 'Add your name',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: context.textSecondary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Premium
          _SettingsGroup(
            children: [
              _SettingsTile(
                icon: isPremium.value == true
                    ? Icons.workspace_premium
                    : Icons.workspace_premium_outlined,
                iconColor: isPremium.value == true
                    ? AppTheme.primaryPink
                    : null,
                title: 'Premium',
                subtitle: isPremium.value == null
                    ? 'Checking...'
                    : isPremium.value!
                    ? 'You have premium access'
                    : 'Upgrade to unlock unlimited goals',
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () => context.push(AppRoutes.paywall),
              ),
              if (isPremium.value == true) ...[
                _SettingsTile(
                  icon: Icons.credit_card_outlined,
                  title: 'Manage Subscription',
                  subtitle: 'View or cancel in Play Store',
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: handleManageSubscription,
                ),
              ],
              if (isPremium.value == true)
                _SettingsTile(
                  icon: CustomCategoryStyle.defaultIcon,
                  iconColor: CustomCategoryStyle.defaultColor,
                  title: 'Custom Categories',
                  subtitle: customCategories.value.isEmpty
                      ? 'Create categories when adding goals'
                      : '${customCategories.value.length} '
                            '${customCategories.value.length == 1 ? 'category' : 'categories'}',
                  trailing: customCategories.value.isEmpty
                      ? null
                      : const Icon(Icons.chevron_right, size: 20),
                  onTap: customCategories.value.isEmpty
                      ? null
                      : handleManageCategories,
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Appearance
          _AppearanceTile(ref: ref),
          const SizedBox(height: 20),

          // Notifications
          _SettingsGroup(
            children: [
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: notificationsEnabled.value == null
                    ? 'Checking...'
                    : notificationsEnabled.value!
                    ? 'Enabled'
                    : 'Tap to enable',
                trailing: notificationsEnabled.value == null
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 2,
                        ),
                      )
                    : Switch.adaptive(
                        value: notificationsEnabled.value!,
                        onChanged: (_) => handleNotificationToggle(),
                      ),
                onTap: handleNotificationToggle,
              ),
              _SettingsTile(
                icon: Icons.alarm_outlined,
                title: 'Daily Reminder',
                subtitle: notificationsEnabled.value != true
                    ? 'Enable notifications first'
                    : 'Get a nudge to complete your actions',
                trailing: Switch.adaptive(
                  value:
                      notificationsEnabled.value == true &&
                      reminderEnabled.value,
                  onChanged: notificationsEnabled.value == true
                      ? handleReminderToggle
                      : null,
                ),
              ),
              if (reminderEnabled.value)
                _SettingsTile(
                  icon: Icons.schedule_outlined,
                  title: 'Reminder Time',
                  subtitle: formatTime(reminderTime.value),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: handleTimeChange,
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Follow Gabby
          _SettingsGroup(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.favorite_outline,
                      size: 20,
                      color: context.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Follow Gabby Beckford',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                child: Row(
                  children: [
                    _SocialButton(
                      assetPath: 'assets/images/instagram.png',
                      label: 'Instagram',
                      onTap: () => _launchUrl(_gabbyInstagram),
                    ),
                    _SocialButton(
                      assetPath: 'assets/images/tiktok.png',
                      label: 'TikTok',
                      onTap: () => _launchUrl(_gabbyTikTok),
                    ),
                    Builder(
                      builder: (context) {
                        final isDark =
                            Theme.of(context).brightness == Brightness.dark;
                        return _SocialButton(
                          assetPath: 'assets/images/twitterX.png',
                          label: 'X',
                          onTap: () => _launchUrl(_gabbyTwitter),
                          assetBackground: isDark ? Colors.white : null,
                        );
                      },
                    ),
                    _SocialButton(
                      icon: Icons.language,
                      label: 'Website',
                      onTap: () => _launchUrl(_gabbyWebsite),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // About
          _SettingsGroup(
            children: [
              _SettingsTile(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                trailing: const Icon(Icons.open_in_new, size: 16),
                onTap: () => _launchUrl(_termsOfServiceUrl),
              ),
              _SettingsTile(
                icon: Icons.shield_outlined,
                title: 'Privacy Policy',
                trailing: const Icon(Icons.open_in_new, size: 16),
                onTap: () => _launchUrl(_privacyPolicyUrl),
              ),
              _SettingsTile(
                icon: Icons.info_outline,
                title: 'Version',
                subtitle: appVersion.value.isEmpty
                    ? 'Loading...'
                    : appVersion.value,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Account actions
          _SettingsGroup(
            children: [
              _SettingsTile(
                icon: Icons.logout,
                title: 'Sign Out',
                onTap: handleSignOut,
              ),
              _SettingsTile(
                icon: Icons.delete_forever,
                iconColor: AppTheme.errorRed,
                title: 'Delete Account',
                titleColor: AppTheme.errorRed,
                trailing: isDeleting.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 2,
                        ),
                      )
                    : null,
                onTap: isDeleting.value ? null : handleDeleteAccount,
              ),
            ],
          ),
          const SizedBox(height: 32),
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
    ValueNotifier<List<String>> customCategories,
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
        customCategories.value = user.customCategories;
      }
    }
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;

  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppTheme.radiusLarge);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: context.borderColor),
      ),
      child: Material(
        color: context.surface,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i < children.length - 1)
                Divider(
                  height: 1,
                  indent: 52,
                  color: context.borderColor,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final Color? titleColor;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    this.iconColor,
    required this.title,
    this.titleColor,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 22, color: iconColor ?? context.textSecondary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: titleColor,
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
      ),
    );
  }
}

class _AppearanceTile extends StatelessWidget {
  final WidgetRef ref;

  const _AppearanceTile({required this.ref});

  static const _modes = [
    (ThemeMode.light, 'Light', Icons.light_mode_outlined),
    (ThemeMode.dark, 'Dark', Icons.dark_mode_outlined),
    (ThemeMode.system, 'Auto', Icons.brightness_auto),
  ];

  @override
  Widget build(BuildContext context) {
    final currentMode = ref.watch(themeProvider);
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.palette_outlined,
                size: 22,
                color: context.textSecondary,
              ),
              const SizedBox(width: 14),
              const Text(
                'App Theme',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: context.surfaceSubtle,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.borderColor),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: _modes.map((entry) {
                final (mode, label, icon) = entry;
                final isSelected = mode == currentMode;
                return Expanded(
                  child: _ThemeOption(
                    label: label,
                    icon: icon,
                    isSelected: isSelected,
                    color: primary,
                    onTap: () =>
                        ref.read(themeProvider.notifier).setThemeMode(mode),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : context.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.white : context.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManageCategoriesSheet extends StatefulWidget {
  final String userId;
  final List<String> categories;
  final UserService userService;
  final GoalService goalService;
  final ValueChanged<List<String>> onCategoriesChanged;

  const _ManageCategoriesSheet({
    required this.userId,
    required this.categories,
    required this.userService,
    required this.goalService,
    required this.onCategoriesChanged,
  });

  @override
  State<_ManageCategoriesSheet> createState() => _ManageCategoriesSheetState();
}

class _ManageCategoriesSheetState extends State<_ManageCategoriesSheet> {
  late List<String> _categories;
  Map<String, int> _goalCounts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _categories = List.from(widget.categories);
    _loadGoalCounts();
  }

  Future<void> _loadGoalCounts() async {
    final counts = <String, int>{};
    for (final name in _categories) {
      counts[name] = await widget.goalService.countGoalsByCustomCategory(
        widget.userId,
        name,
      );
    }
    if (mounted) {
      setState(() {
        _goalCounts = counts;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleEdit(String oldName) async {
    final controller = TextEditingController(text: oldName);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Category'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Category name',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              Navigator.pop(context, value.trim());
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty && value != oldName) {
                Navigator.pop(context, value);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newName != null && newName != oldName) {
      // Update goals and user's category list
      await widget.goalService.renameCustomCategory(
        widget.userId,
        oldName,
        newName,
      );
      await widget.userService.renameCustomCategory(
        widget.userId,
        oldName,
        newName,
      );

      setState(() {
        final index = _categories.indexOf(oldName);
        if (index != -1) {
          _categories[index] = newName;
          _goalCounts[newName] = _goalCounts.remove(oldName) ?? 0;
        }
      });
      widget.onCategoriesChanged(_categories);
      ToastHelper.showSuccess('Category renamed');
    }
  }

  Future<void> _handleDelete(String name) async {
    final goalCount = _goalCounts[name] ?? 0;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          goalCount > 0
              ? '$goalCount ${goalCount == 1 ? 'goal uses' : 'goals use'} this category.\n\n'
                    '${goalCount == 1 ? 'That goal' : 'Those goals'} will keep displaying "$name" but you won\'t be able to assign new goals to this category anymore.'
              : 'Remove "$name" from your custom categories?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Just remove category from user's list - goals keep their customCategoryName
      await widget.userService.removeCustomCategory(widget.userId, name);

      setState(() {
        _categories.remove(name);
        _goalCounts.remove(name);
      });
      widget.onCategoriesChanged(_categories);
      ToastHelper.showSuccess('Category deleted');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CustomCategoryStyle.defaultIcon,
                color: CustomCategoryStyle.defaultColor,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Custom Categories',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Tap to edit, or delete categories',
            style: TextStyle(color: context.textSecondary),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator.adaptive()),
            )
          else if (_categories.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No custom categories',
                  style: TextStyle(color: context.textSecondary),
                ),
              ),
            )
          else
            ..._categories.map(
              (name) => _CategoryTile(
                name: name,
                goalCount: _goalCounts[name] ?? 0,
                onEdit: () => _handleEdit(name),
                onDelete: () => _handleDelete(name),
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String name;
  final int goalCount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryTile({
    required this.name,
    required this.goalCount,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: context.surfaceSubtle,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.borderColor),
        ),
        child: Row(
          children: [
            Icon(
              CustomCategoryStyle.defaultIcon,
              color: CustomCategoryStyle.defaultColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  if (goalCount > 0)
                    Text(
                      '$goalCount ${goalCount == 1 ? 'goal' : 'goals'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit category',
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Delete category',
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData? icon;
  final String? assetPath;
  final String label;
  final VoidCallback onTap;
  final Color? assetBackground;

  const _SocialButton({
    this.icon,
    this.assetPath,
    required this.label,
    required this.onTap,
    this.assetBackground,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              if (assetPath != null && assetBackground != null)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: assetBackground,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(assetPath!, width: 24, height: 24),
                )
              else if (assetPath != null)
                Image.asset(assetPath!, width: 24, height: 24)
              else
                Icon(icon, color: AppTheme.primaryPink),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: context.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
