import 'package:aspire/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Primary action button with gradient background and glow effect.
/// Pill-shaped, bold, celebratory - matches the "Life Passport" design direction.
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double height;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 56,
  });

  bool get _isEnabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: _isEnabled ? AppTheme.primaryGradient : null,
        color: _isEnabled ? null : Theme.of(context).disabledColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        boxShadow: _isEnabled ? AppTheme.buttonGlow : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator.adaptive(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(
                        Colors.white,
                      ),
                    ),
                  )
                : Text(
                    text,
                    style: TextStyle(
                      color: _isEnabled ? Colors.white : Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
