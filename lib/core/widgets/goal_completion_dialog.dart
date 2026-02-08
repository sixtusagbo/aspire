import 'package:aspire/core/theme/app_theme.dart';
import 'package:aspire/services/share_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

/// Shows a celebration dialog when a goal is completed
class GoalCompletionDialog extends StatefulWidget {
  final String goalTitle;

  const GoalCompletionDialog({super.key, required this.goalTitle});

  /// Show the dialog
  static Future<void> show(BuildContext context, String goalTitle) {
    AudioPlayer().play(AssetSource('sounds/goal_complete.mp3'));
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => GoalCompletionDialog(goalTitle: goalTitle),
    );
  }

  @override
  State<GoalCompletionDialog> createState() => _GoalCompletionDialogState();
}

class _GoalCompletionDialogState extends State<GoalCompletionDialog>
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
      // Pulse animation for the trophy emoji
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
      );
      _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
        CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
      );
      _pulseController!.repeat(reverse: true);

      // Glow animation for the background
      _glowController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
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

  @override
  Widget build(BuildContext context) {
    const accentColor = AppTheme.primaryPink;

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
              // Trophy emoji with optional pulsing glow animation
              if (_reduceMotion)
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accentColor.withValues(alpha: 0.35),
                        accentColor.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                      stops: const [0.3, 0.6, 1.0],
                    ),
                  ),
                  child: const Center(
                    child: Text('\u{1F3C6}', style: TextStyle(fontSize: 48)),
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
                            accentColor.withValues(alpha: _glowAnimation!.value),
                            accentColor.withValues(
                              alpha: _glowAnimation!.value * 0.3,
                            ),
                            Colors.transparent,
                          ],
                          stops: const [0.3, 0.6, 1.0],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(
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
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 8),

              // Goal title
              Text(
                widget.goalTitle,
                style: TextStyle(fontSize: 16, color: context.textSecondary),
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
                    style: FilledButton.styleFrom(backgroundColor: accentColor),
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
