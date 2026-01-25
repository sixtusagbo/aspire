import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({required this.navigationShell, super.key});

  // Light mode colors
  static const _lightBg = Colors.white;
  static const _lightBorder = Color(0xFFF3F4F6); // gray-100

  // Dark mode colors
  static const _darkBg = Color(0xFF1F2937);
  static const _darkBorder = Color(0xFF374151);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? _darkBg : _lightBg,
          border: Border(
            top: BorderSide(
              color: isDark ? _darkBorder : _lightBorder,
            ),
          ),
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
                    isDark: isDark,
                    onTap: () => navigationShell.goBranch(0),
                  ),
                  _NavItem(
                    icon: Icons.flag_rounded,
                    label: 'Goals',
                    isSelected: navigationShell.currentIndex == 1,
                    isDark: isDark,
                    onTap: () => navigationShell.goBranch(1),
                  ),
                  _NavItem(
                    icon: Icons.emoji_events_rounded,
                    label: 'Progress',
                    isSelected: navigationShell.currentIndex == 2,
                    isDark: isDark,
                    onTap: () => navigationShell.goBranch(2),
                  ),
                ],
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
  final bool isDark;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  static const _primaryColor = Color(0xFF8B5CF6);
  static const _lightInactive = Color(0xFF6B7280); // gray-500
  static const _darkInactive = Color(0xFF9CA3AF); // gray-400

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? _primaryColor
        : (isDark ? _darkInactive : _lightInactive);

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
                    ? _primaryColor.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Icon(
                icon,
                size: 24,
                color: color,
              ),
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
