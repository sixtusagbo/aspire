import 'package:aspire/core/theme/app_theme.dart';
import 'package:aspire/core/widgets/celebration_overlay.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({required this.navigationShell, super.key});

  @override
  Widget build(BuildContext context) {
    return CelebrationOverlay(
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: context.surface,
            border: Border(top: BorderSide(color: context.borderColor)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: SizedBox(
                height: 72,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      isSelected: navigationShell.currentIndex == 0,
                      onTap: () => navigationShell.goBranch(0),
                    ),
                    _NavItem(
                      icon: Icons.flag_rounded,
                      label: 'Goals',
                      isSelected: navigationShell.currentIndex == 1,
                      onTap: () => navigationShell.goBranch(1),
                    ),
                    _NavItem(
                      icon: Icons.emoji_events_rounded,
                      label: 'Progress',
                      isSelected: navigationShell.currentIndex == 2,
                      onTap: () => navigationShell.goBranch(2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isSelected ? AppTheme.primaryPink : context.textSecondary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryPink.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
