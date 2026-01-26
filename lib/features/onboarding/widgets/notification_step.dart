import 'package:aspire/core/theme/app_theme.dart';
import 'package:aspire/services/log_service.dart';
import 'package:aspire/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const NotificationStep({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  ConsumerState<NotificationStep> createState() => _NotificationStepState();
}

class _NotificationStepState extends ConsumerState<NotificationStep> {
  bool _isRequesting = false;
  bool _reminderEnabled = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);

  Future<void> _enableNotifications() async {
    setState(() => _isRequesting = true);

    try {
      final notificationService = ref.read(notificationServiceProvider);
      final granted = await notificationService.requestPermission();

      if (granted && _reminderEnabled) {
        // Schedule the daily reminder
        await notificationService.scheduleDailyReminder(
          hour: _reminderTime.hour,
          minute: _reminderTime.minute,
        );

        // Save preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('daily_reminder_enabled', true);
        await prefs.setInt('daily_reminder_hour', _reminderTime.hour);
        await prefs.setInt('daily_reminder_minute', _reminderTime.minute);

        Log.i('Daily reminder scheduled for ${_reminderTime.hour}:${_reminderTime.minute.toString().padLeft(2, '0')}');
      }
    } catch (e, stack) {
      Log.e('Error setting up notifications', error: e, stackTrace: stack);
    }

    setState(() => _isRequesting = false);
    widget.onNext();
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppTheme.primaryPink),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _reminderTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Back button
          IconButton(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(backgroundColor: Colors.grey.shade100),
          ),
          const SizedBox(height: 32),

          // Illustration
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryPink.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_active_rounded,
                size: 56,
                color: AppTheme.primaryPink,
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Title
          Text(
            'Stay on track with\nreminders',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Get gentle nudges to complete your daily micro-actions and keep your streak going.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          // Reminder toggle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.alarm_rounded,
                      color: AppTheme.primaryPink,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Daily Reminder',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Switch.adaptive(
                      value: _reminderEnabled,
                      onChanged: (value) {
                        setState(() => _reminderEnabled = value);
                      },
                      activeTrackColor: AppTheme.primaryPink,
                    ),
                  ],
                ),
                if (_reminderEnabled) ...[
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _selectTime,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _reminderTime.format(context),
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Spacer(),

          // Enable button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isRequesting ? null : _enableNotifications,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isRequesting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _reminderEnabled ? 'Enable Notifications' : 'Continue',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),

          // Skip option
          Center(
            child: TextButton(
              onPressed: _isRequesting ? null : widget.onNext,
              child: Text(
                'Maybe later',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
