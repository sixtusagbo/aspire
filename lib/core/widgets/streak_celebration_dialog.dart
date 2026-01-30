import 'package:aspire/core/theme/app_theme.dart';
import 'package:aspire/services/share_service.dart';
import 'package:flutter/material.dart';

/// Shows a Duolingo-style streak celebration dialog with animated fire
class StreakCelebrationDialog extends StatefulWidget {
  final int streak;

  const StreakCelebrationDialog({super.key, required this.streak});

  /// Show the dialog
  static Future<void> show(BuildContext context, int streak) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StreakCelebrationDialog(streak: streak),
    );
  }

  @override
  State<StreakCelebrationDialog> createState() =>
      _StreakCelebrationDialogState();
}

class _StreakCelebrationDialogState extends State<StreakCelebrationDialog>
    with TickerProviderStateMixin {
  AnimationController? _pulseController;
  AnimationController? _glowController;
  Animation<double>? _pulseAnimation;
  Animation<double>? _glowAnimation;
  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.of(context).disableAnimations;

    if (!_reduceMotion && _pulseController == null) {
      // Pulse animation for the fire emoji
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
      _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
      );
      _pulseController!.repeat(reverse: true);

      // Glow animation for the background
      _glowController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1000),
      );
      _glowAnimation = Tween<double>(begin: 0.2, end: 0.5).animate(
        CurvedAnimation(parent: _glowController!, curve: Curves.easeInOut),
      );
      _glowController!.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    _glowController?.dispose();
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

    return Center(
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Fire emoji with optional pulsing glow animation
                if (_reduceMotion)
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          streakColor.withValues(alpha: 0.35),
                          streakColor.withValues(alpha: 0.1),
                          Colors.transparent,
                        ],
                        stops: const [0.3, 0.6, 1.0],
                      ),
                    ),
                    child: const Center(
                      child: Text('🔥', style: TextStyle(fontSize: 48)),
                    ),
                  )
                else
                  AnimatedBuilder(
                    animation:
                        Listenable.merge([_pulseAnimation!, _glowAnimation!]),
                    builder: (context, child) {
                      return Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              streakColor.withValues(
                                  alpha: _glowAnimation!.value),
                              streakColor.withValues(
                                alpha: _glowAnimation!.value * 0.3,
                              ),
                              Colors.transparent,
                            ],
                            stops: const [0.3, 0.6, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: streakColor.withValues(
                                alpha: _glowAnimation!.value * 0.6,
                              ),
                              blurRadius: 25,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Transform.scale(
                            scale: _pulseAnimation!.value,
                            child: const Text(
                              '🔥',
                              style: TextStyle(fontSize: 48),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 12),

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
                    color: context.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Next milestone
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: context.surfaceSubtle,
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
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Continue',
                        style: TextStyle(color: context.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ShareService.shareStreak(widget.streak);
                      },
                      icon: const Icon(Icons.share, size: 18),
                      label: const Text('Share'),
                      style: FilledButton.styleFrom(
                        backgroundColor: streakColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
