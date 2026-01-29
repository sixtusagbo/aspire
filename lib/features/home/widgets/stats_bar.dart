import 'dart:math';

import 'package:aspire/core/theme/app_theme.dart';
import 'package:aspire/models/user.dart';
import 'package:flutter/material.dart';

class StatsBar extends StatelessWidget {
  final AppUser user;

  const StatsBar({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
        boxShadow: context.isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        children: [
          // Level and streak row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LevelBadge(level: user.level),
              const Spacer(),
              _StreakBadge(
                currentStreak: user.currentStreak,
                longestStreak: user.longestStreak,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _XpProgressSection(xp: user.xp, level: user.level),
        ],
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final int level;

  const _LevelBadge({required this.level});

  String get _title {
    if (level >= 50) return 'Legend';
    if (level >= 30) return 'Master';
    if (level >= 20) return 'Expert';
    if (level >= 10) return 'Achiever';
    if (level >= 5) return 'Rising Star';
    return 'Dreamer';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.primaryPink.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.military_tech_rounded,
            color: AppTheme.primaryPink,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Level $level',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: context.textSecondary,
              ),
            ),
            Text(
              _title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}

class _StreakBadge extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;

  const _StreakBadge({
    required this.currentStreak,
    required this.longestStreak,
  });

  @override
  Widget build(BuildContext context) {
    const streakColor = Color(0xFF34D399);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: streakColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                color: streakColor,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                '$currentStreak Day${currentStreak == 1 ? '' : 's'}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: streakColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Text(
            'Best: $longestStreak',
            style: TextStyle(fontSize: 11, color: context.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _XpProgressSection extends StatelessWidget {
  final int xp;
  final int level;

  const _XpProgressSection({required this.xp, required this.level});

  /// XP required to reach a given level
  static int xpRequiredForLevel(int level) {
    if (level <= 1) return 0;
    return (50 * pow(level - 1, 1.5)).toInt();
  }

  int get _xpForCurrentLevel => xpRequiredForLevel(level);
  int get _xpForNextLevel => xpRequiredForLevel(level + 1);
  int get _xpProgress => xp - _xpForCurrentLevel;
  int get _xpNeeded => _xpForNextLevel - _xpForCurrentLevel;
  double get _levelProgress => _xpNeeded > 0 ? _xpProgress / _xpNeeded : 1.0;

  @override
  Widget build(BuildContext context) {
    final progress = _levelProgress.clamp(0.0, 1.0);
    final xpRemaining = _xpNeeded - _xpProgress;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'XP Progress',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: '$_xpProgress',
                    style: TextStyle(color: AppTheme.primaryPink),
                  ),
                  TextSpan(
                    text: ' / $_xpNeeded',
                    style: TextStyle(
                      color: context.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: context.borderColor,
            valueColor: AlwaysStoppedAnimation(AppTheme.primaryPink),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '$xpRemaining XP to Level ${level + 1}',
            style: TextStyle(fontSize: 11, color: context.textSecondary),
          ),
        ),
      ],
    );
  }
}
