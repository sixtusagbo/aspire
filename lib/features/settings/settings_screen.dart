import 'package:aspire/core/theme/app_theme.dart';
import 'package:aspire/core/theme/category_colors.dart';
import 'package:aspire/core/utils/app_router.dart';
import 'package:aspire/core/utils/toast_helper.dart';
import 'package:aspire/models/user.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(displayName.value.isNotEmpty
                ? displayName.value
                : 'Add your name'),
            subtitle: Text(user?.email ?? 'Manage your account'),
            trailing: const Icon(Icons.chevron_right),
            onTap: handleEditAccount,
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

          // Custom Categories section (premium only)
          if (isPremium.value == true)
            ListTile(
              leading: Icon(
                CustomCategoryStyle.defaultIcon,
                color: CustomCategoryStyle.defaultColor,
              ),
              title: const Text('Custom Categories'),
              subtitle: Text(
                customCategories.value.isEmpty
                    ? 'Create categories when adding goals'
                    : '${customCategories.value.length} ${customCategories.value.length == 1 ? 'category' : 'categories'}',
              ),
              trailing: customCategories.value.isEmpty
                  ? null
                  : const Icon(Icons.chevron_right),
              onTap: customCategories.value.isEmpty ? null : handleManageCategories,
            ),
          if (isPremium.value == true) const Divider(),

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
      counts[name] = await widget.goalService
          .countGoalsByCustomCategory(widget.userId, name);
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
      // Update goals first
      await widget.goalService.renameCustomCategory(
        widget.userId,
        oldName,
        newName,
      );
      // Update user's category list
      await widget.userService.removeCustomCategory(widget.userId, oldName);
      await widget.userService.addCustomCategory(widget.userId, newName);

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
                  'They will be moved to "Personal".'
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
            child: Text(goalCount > 0 ? 'Move & Delete' : 'Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Move goals to Personal if any
      if (goalCount > 0) {
        await widget.goalService.moveGoalsToPersonal(widget.userId, name);
      }
      // Remove category from user
      await widget.userService.removeCustomCategory(widget.userId, name);

      setState(() {
        _categories.remove(name);
        _goalCounts.remove(name);
      });
      widget.onCategoriesChanged(_categories);
      ToastHelper.showSuccess(
        goalCount > 0 ? 'Goals moved to Personal' : 'Category deleted',
      );
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
              child: Center(child: CircularProgressIndicator()),
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
            ..._categories.map((name) => _CategoryTile(
                  name: name,
                  goalCount: _goalCounts[name] ?? 0,
                  onEdit: () => _handleEdit(name),
                  onDelete: () => _handleDelete(name),
                )),
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
