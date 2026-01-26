import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shows a Duolingo-style streak celebration dialog with animated fire
class StreakCelebrationDialog extends StatefulWidget {
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

  @override
  State<StreakCelebrationDialog> createState() =>
      _StreakCelebrationDialogState();
}

class _StreakCelebrationDialogState extends State<StreakCelebrationDialog>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _glowController;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for the fire emoji
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    // Glow animation for the background
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _glowAnimation = Tween<double>(begin: 0.15, end: 0.35).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  int get _nextMilestone {
    const milestones = [7, 14, 30, 60, 100, 365];
    for (final m in milestones) {
      if (m > widget.streak) return m;
    }
    return widget.streak + 100; // Beyond 365, show next 100
  }

  String get _message {
    if (widget.streak == 7) return "One week strong!";
    if (widget.streak == 14) return "Two weeks of consistency!";
    if (widget.streak == 30) return "A whole month!";
    if (widget.streak == 60) return "Two months of dedication!";
    if (widget.streak == 100) return "Triple digits!";
    if (widget.streak == 365) return "A full year!";
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
            // Animated fire icon with pulsing glow
            AnimatedBuilder(
              animation: Listenable.merge([_pulseAnimation, _glowAnimation]),
              builder: (context, child) {
                return Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        streakColor.withValues(alpha: _glowAnimation.value),
                        streakColor.withValues(alpha: _glowAnimation.value * 0.3),
                        Colors.transparent,
                      ],
                      stops: const [0.3, 0.6, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: streakColor.withValues(
                          alpha: _glowAnimation.value * 0.5,
                        ),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Transform.scale(
                      scale: _pulseAnimation.value,
                      child: const Text(
                        '🔥',
                        style: TextStyle(fontSize: 48),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Streak count
            Text(
              '${widget.streak} Day Streak!',
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
