import 'dart:math';

import 'package:aspire/services/log_service.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

enum CelebrationType {
  /// Small burst for completing a single action
  actionComplete,

  /// Medium celebration for completing all daily actions
  dailyComplete,

  /// Big celebration for streak milestones (7, 30, 100 days)
  streakMilestone,

  /// Full-screen celebration for completing a goal
  goalComplete,

  /// Big celebration for leveling up
  levelUp,
}

class CelebrationOverlay extends StatefulWidget {
  final Widget child;

  const CelebrationOverlay({super.key, required this.child});

  static CelebrationOverlayState? of(BuildContext context) {
    return context.findAncestorStateOfType<CelebrationOverlayState>();
  }

  @override
  State<CelebrationOverlay> createState() => CelebrationOverlayState();
}

class CelebrationOverlayState extends State<CelebrationOverlay> {
  late ConfettiController _centerController;
  late ConfettiController _leftController;
  late ConfettiController _rightController;

  @override
  void initState() {
    super.initState();
    _centerController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
    _leftController = ConfettiController(duration: const Duration(seconds: 2));
    _rightController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _centerController.dispose();
    _leftController.dispose();
    _rightController.dispose();
    super.dispose();
  }

  void celebrate(CelebrationType type) {
    // Respect reduced motion accessibility setting
    if (MediaQuery.of(context).disableAnimations) {
      Log.i('Celebration skipped (reduced motion): ${type.name}');
      return;
    }

    Log.i('Celebration triggered: ${type.name}');
    switch (type) {
      case CelebrationType.actionComplete:
        _centerController.play();
      case CelebrationType.dailyComplete:
        _centerController.play();
        Future.delayed(const Duration(milliseconds: 200), () {
          _leftController.play();
          _rightController.play();
        });
      case CelebrationType.streakMilestone:
      case CelebrationType.goalComplete:
      case CelebrationType.levelUp:
        _centerController.play();
        _leftController.play();
        _rightController.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,

        // Center confetti (top) - blast downward
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _centerController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.02,
              numberOfParticles: 50,
              maxBlastForce: 60,
              minBlastForce: 30,
              gravity: 0.2,
              minimumSize: const Size(15, 8),
              maximumSize: const Size(25, 15),
              colors: _confettiColors,
            ),
          ),
        ),

        // Left confetti
        Positioned(
          top: 0,
          left: 0,
          child: ConfettiWidget(
            confettiController: _leftController,
            blastDirection: -pi / 4, // diagonal right-down
            emissionFrequency: 0.02,
            numberOfParticles: 60,
            maxBlastForce: 80,
            minBlastForce: 40,
            gravity: 0.15,
            minimumSize: const Size(15, 8),
            maximumSize: const Size(25, 15),
            colors: _confettiColors,
          ),
        ),

        // Right confetti
        Positioned(
          top: 0,
          right: 0,
          child: ConfettiWidget(
            confettiController: _rightController,
            blastDirection: pi + pi / 4, // diagonal left-down
            emissionFrequency: 0.02,
            numberOfParticles: 60,
            maxBlastForce: 80,
            minBlastForce: 40,
            gravity: 0.15,
            minimumSize: const Size(15, 8),
            maximumSize: const Size(25, 15),
            colors: _confettiColors,
          ),
        ),
      ],
    );
  }

  List<Color> get _confettiColors => const [
    Color(0xFFEC4899), // Pink
    Color(0xFF8B5CF6), // Purple
    Color(0xFFF59E0B), // Gold
    Color(0xFF10B981), // Green
    Color(0xFF3B82F6), // Blue
    Color(0xFFF472B6), // Light pink
  ];
}
