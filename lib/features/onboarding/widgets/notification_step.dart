import 'package:aspire/core/theme/app_theme.dart';
import 'package:aspire/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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

  Future<void> _requestPermission() async {
    setState(() => _isRequesting = true);

    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.requestPermission();

    setState(() => _isRequesting = false);
    widget.onNext();
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
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.shade100,
            ),
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

          const Spacer(),

          // Enable button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isRequesting ? null : _requestPermission,
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
                  : const Text(
                      'Enable Notifications',
                      style: TextStyle(
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
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
