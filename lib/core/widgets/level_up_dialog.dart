import 'package:aspire/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Shows a level up celebration dialog
class LevelUpDialog extends StatefulWidget {
  final int newLevel;

  const LevelUpDialog({super.key, required this.newLevel});

  /// Show the dialog
  static Future<void> show(BuildContext context, int newLevel) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => LevelUpDialog(newLevel: newLevel),
    );
  }

  @override
  State<LevelUpDialog> createState() => _LevelUpDialogState();
}

class _LevelUpDialogState extends State<LevelUpDialog>
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
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
      _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
        CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
      );
      _pulseController!.repeat(reverse: true);

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

  String get _title {
    final level = widget.newLevel;
    if (level >= 50) return 'Legend';
    if (level >= 30) return 'Master';
    if (level >= 20) return 'Expert';
    if (level >= 10) return 'Achiever';
    if (level >= 5) return 'Rising Star';
    return 'Dreamer';
  }

  String get _message {
    final level = widget.newLevel;
    if (level == 5) return "You're a Rising Star now!";
    if (level == 10) return "You've become an Achiever!";
    if (level == 20) return "Expert status unlocked!";
    if (level == 30) return "You've reached Master level!";
    if (level == 50) return "Legendary achievement!";
    return "Keep crushing your goals!";
  }

  @override
  Widget build(BuildContext context) {
    final levelColor = AppTheme.primaryPink;

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
                // Medal icon with optional animation
                if (_reduceMotion)
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          levelColor.withValues(alpha: 0.35),
                          levelColor.withValues(alpha: 0.1),
                          Colors.transparent,
                        ],
                        stops: const [0.3, 0.6, 1.0],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.military_tech_rounded,
                        size: 56,
                        color: levelColor,
                      ),
                    ),
                  )
                else
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _pulseAnimation!,
                      _glowAnimation!,
                    ]),
                    builder: (context, child) {
                      return Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              levelColor.withValues(
                                alpha: _glowAnimation!.value,
                              ),
                              levelColor.withValues(
                                alpha: _glowAnimation!.value * 0.3,
                              ),
                              Colors.transparent,
                            ],
                            stops: const [0.3, 0.6, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: levelColor.withValues(
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
                            child: Icon(
                              Icons.military_tech_rounded,
                              size: 56,
                              color: levelColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 12),

                // Level up text
                Text(
                  'Level ${widget.newLevel}!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: levelColor,
                  ),
                ),
                const SizedBox(height: 4),

                // Title
                Text(
                  _title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                // Message
                Text(
                  _message,
                  style: TextStyle(fontSize: 16, color: context.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Continue button
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: levelColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Awesome!'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
