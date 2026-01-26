import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shows a Duolingo-style streak celebration dialog
class StreakCelebrationDialog extends StatelessWidget {
  final int streak;

  const StreakCelebrationDialog({super.key, required this.streak});

  /// Show the dialog
  static Future<void> show(BuildContext context, int streak) {
    HapticFeedback.heavyImpact();
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => StreakCelebrationDialog(streak: streak),
    );
  }

  int get _nextMilestone {
    const milestones = [7, 14, 30, 60, 100, 365];
    for (final m in milestones) {
      if (m > streak) return m;
    }
    return streak + 100; // Beyond 365, show next 100
  }

  String get _message {
    if (streak == 7) return "One week strong!";
    if (streak == 14) return "Two weeks of consistency!";
    if (streak == 30) return "A whole month!";
    if (streak == 60) return "Two months of dedication!";
    if (streak == 100) return "Triple digits!";
    if (streak == 365) return "A full year!";
    return "You're on fire!";
  }

  @override
  Widget build(BuildContext context) {
    const streakColor = Color(0xFFFF6B35); // Warm orange

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fire icon with glow effect
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: streakColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '🔥',
                  style: TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Streak count
            Text(
              '$streak Day Streak!',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: streakColor,
              ),
            ),
            const SizedBox(height: 8),

            // Message
            Text(
              _message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Next milestone
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.flag_rounded,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Next milestone: $_nextMilestone days',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Continue button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: streakColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Keep it up!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
