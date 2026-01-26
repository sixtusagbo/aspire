import 'dart:math';

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

        // Center confetti (top)
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _centerController,
            blastDirection: pi / 2, // down
            emissionFrequency: 0.3,
            numberOfParticles: 15,
            maxBlastForce: 20,
            minBlastForce: 10,
            gravity: 0.2,
            colors: _confettiColors,
          ),
        ),

        // Left confetti
        Align(
          alignment: Alignment.topLeft,
          child: ConfettiWidget(
            confettiController: _leftController,
            blastDirection: -pi / 4, // diagonal right-down
            emissionFrequency: 0.2,
            numberOfParticles: 20,
            maxBlastForce: 30,
            minBlastForce: 15,
            gravity: 0.15,
            colors: _confettiColors,
          ),
        ),

        // Right confetti
        Align(
          alignment: Alignment.topRight,
          child: ConfettiWidget(
            confettiController: _rightController,
            blastDirection: pi + pi / 4, // diagonal left-down
            emissionFrequency: 0.2,
            numberOfParticles: 20,
            maxBlastForce: 30,
            minBlastForce: 15,
            gravity: 0.15,
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
