import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

/// Shows a Duolingo-style streak celebration dialog with animated fire
class StreakCelebrationDialog extends StatelessWidget {
  final int streak;

  const StreakCelebrationDialog({super.key, required this.streak});

  /// Show the dialog with a nice scale+fade transition
  static Future<void> show(BuildContext context, int streak) {
    HapticFeedback.heavyImpact();
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 500),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.elasticOut,
          ),
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeIn,
            ),
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return StreakCelebrationDialog(streak: streak);
      },
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

    return Center(
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Lottie fire animation
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Lottie.asset(
                    'assets/animations/fire.json',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 8),

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
                const SizedBox(height: 16),

                // Next milestone
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                const SizedBox(height: 12),

                // Tap to dismiss hint
                Text(
                  'Tap anywhere to continue',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
