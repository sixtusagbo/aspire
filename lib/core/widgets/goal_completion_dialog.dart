import 'package:aspire/core/theme/app_theme.dart';
import 'package:aspire/services/share_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shows a celebration dialog when a goal is completed
class GoalCompletionDialog extends StatefulWidget {
  final String goalTitle;

  const GoalCompletionDialog({super.key, required this.goalTitle});

  /// Show the dialog with a nice scale+fade transition
  static Future<void> show(BuildContext context, String goalTitle) {
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
        return GoalCompletionDialog(goalTitle: goalTitle);
      },
    );
  }

  @override
  State<GoalCompletionDialog> createState() => _GoalCompletionDialogState();
}

class _GoalCompletionDialogState extends State<GoalCompletionDialog>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _glowController;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for the trophy emoji
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
    _glowAnimation = Tween<double>(begin: 0.2, end: 0.5).animate(
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

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFBFA35A);

    return Center(
      child: Material(
        color: Colors.transparent,
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
              // Animated trophy emoji with pulsing glow
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
                          goldColor.withValues(alpha: _glowAnimation.value),
                          goldColor.withValues(
                            alpha: _glowAnimation.value * 0.3,
                          ),
                          Colors.transparent,
                        ],
                        stops: const [0.3, 0.6, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: goldColor.withValues(
                            alpha: _glowAnimation.value * 0.6,
                          ),
                          blurRadius: 25,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Transform.scale(
                        scale: _pulseAnimation.value,
                        child: const Text(
                          '\u{1F3C6}',
                          style: TextStyle(fontSize: 48),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Congratulations text
              const Text(
                'Goal Completed!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: goldColor,
                ),
              ),
              const SizedBox(height: 8),

              // Goal title
              Text(
                widget.goalTitle,
                style: TextStyle(
                  fontSize: 16,
                  color: context.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Motivational message
              Text(
                'You turned your dream into reality!',
                style: TextStyle(
                  fontSize: 14,
                  color: context.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
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
                      ShareService.shareGoalCompletion(widget.goalTitle);
                    },
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('Share'),
                    style: FilledButton.styleFrom(
                      backgroundColor: goldColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
