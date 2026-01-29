import 'package:aspire/core/theme/app_theme.dart';
import 'package:aspire/core/widgets/gradient_button.dart';
import 'package:flutter/material.dart';

class WelcomeStep extends StatelessWidget {
  final VoidCallback onNext;

  const WelcomeStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),

          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryPink.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(
              Icons.rocket_launch_rounded,
              size: 64,
              color: AppTheme.primaryPink,
            ),
          ),
          const SizedBox(height: 40),

          // Title
          Text(
            'From Dreaming\nto Doing',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Subtitle
          Text(
            'Turn your big dreams into daily micro-actions.\n'
            'Whether it\'s traveling the world, landing that\n'
            'six-figure salary, or achieving financial freedom.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const Spacer(),

          // CTA
          GradientButton(
            text: "Let's Go",
            onPressed: onNext,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
