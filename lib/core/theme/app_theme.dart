import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Theme inspired by Gabby Beckford's website (packslight.com)
/// Design direction: "Life Passport" - warm, bold, celebratory
class AppTheme {
  AppTheme._();

  // ============================================================
  // BRAND COLORS
  // ============================================================

  // Primary (Magenta/Pink family)
  static const Color primaryPink = Color(0xFFF82EB3); // Bright magenta
  static const Color primaryPinkDeep = Color(0xFFD9008E); // Deep magenta
  static const Color coralSunset = Color(0xFFF2295B); // Gradient end

  // Secondary (Cyan accent - used sparingly)
  static const Color accentCyan = Color(0xFF00C1CF);
  static const Color accentTeal = Color(0xFF6EC1E4);

  // Semantic
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFE53935);
  static const Color warningAmber = Color(0xFFFFA726);

  // ============================================================
  // SURFACE COLORS
  // ============================================================

  // Light theme
  static const Color lightBackground = Color(0xFFFDF8F5); // Warm off-white
  static const Color lightSurface = Colors.white;
  static const Color lightSurfaceSubtle = Color(0xFFF5F0ED); // Warm grey
  static const Color lightBorder = Color(0xFFE8E0DB); // Warm border
  static const Color lightTextPrimary = Color(0xFF2D2A28); // Warm black
  static const Color lightTextSecondary = Color(0xFF524D49); // WCAG AA compliant

  // Dark theme - deep purple-black, not cold grey
  static const Color darkBackground = Color(0xFF150114); // Deep purple-black
  static const Color darkSurface = Color(0xFF1E0A1B); // Warm dark surface
  static const Color darkSurfaceSubtle = Color(0xFF251318); // Elevated surface
  static const Color darkBorder = Color(0xFF3D2833); // Warm border
  static const Color darkTextPrimary = Color(0xFFF5F0ED); // Warm white
  static const Color darkTextSecondary = Color(0xFFD0C4C8); // WCAG AA compliant

  // ============================================================
  // DESIGN TOKENS
  // ============================================================

  // Border radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusPill = 25.0;

  // Spacing (8px base)
  static const double space1 = 4.0;
  static const double space2 = 8.0;
  static const double space3 = 12.0;
  static const double space4 = 16.0;
  static const double space5 = 20.0;
  static const double space6 = 24.0;
  static const double space8 = 32.0;
  static const double space10 = 40.0;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPink, coralSunset],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Shadows
  static List<BoxShadow> cardShadow(bool isDark) => isDark
      ? [] // Dark mode uses borders, not shadows
      : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ];

  static List<BoxShadow> buttonGlow = [
    BoxShadow(
      color: primaryPink.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // ============================================================
  // LIGHT THEME
  // ============================================================

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: primaryPink,
      secondary: accentCyan,
      tertiary: coralSunset,
      surface: lightSurface,
      error: errorRed,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: lightTextPrimary,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: lightBackground,
    appBarTheme: const AppBarTheme(
      centerTitle: false, // Left-aligned for authority
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: lightTextPrimary,
      titleTextStyle: TextStyle(
        color: lightTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    ),
    cardTheme: CardThemeData(
      color: lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
        side: BorderSide(color: lightBorder.withValues(alpha: 0.5)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusPill),
        ),
        elevation: 0,
      ),
    ),
    textTheme: const TextTheme(
      // Bold headlines that own the screen
      displayLarge: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: lightTextPrimary,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        color: lightTextPrimary,
        letterSpacing: -0.5,
      ),
      displaySmall: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: lightTextPrimary,
        letterSpacing: -0.3,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: lightTextPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: lightTextPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: lightTextPrimary,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: lightTextPrimary, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, color: lightTextPrimary, height: 1.5),
      bodySmall: TextStyle(fontSize: 12, color: lightTextSecondary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSurfaceSubtle,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide(color: lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: primaryPink, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: errorRed),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );

  // ============================================================
  // DARK THEME
  // ============================================================

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primaryPink,
      secondary: accentCyan,
      tertiary: coralSunset,
      surface: darkSurface,
      error: errorRed,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: darkTextPrimary,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: darkBackground,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: darkTextPrimary,
      titleTextStyle: TextStyle(
        color: darkTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    cardTheme: CardThemeData(
      color: darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
        side: BorderSide(color: darkBorder.withValues(alpha: 0.5)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusPill),
        ),
        elevation: 0,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: darkTextPrimary,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        color: darkTextPrimary,
        letterSpacing: -0.5,
      ),
      displaySmall: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: darkTextPrimary,
        letterSpacing: -0.3,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: darkTextPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: darkTextPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: darkTextPrimary,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: darkTextPrimary, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, color: darkTextPrimary, height: 1.5),
      bodySmall: TextStyle(fontSize: 12, color: darkTextSecondary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurfaceSubtle,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide(color: darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: primaryPink, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: errorRed),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );
}

/// Extension for easy access to theme-aware colors
extension ThemeColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get surfaceSubtle =>
      isDark ? AppTheme.darkSurfaceSubtle : AppTheme.lightSurfaceSubtle;

  Color get borderColor => isDark ? AppTheme.darkBorder : AppTheme.lightBorder;

  Color get textPrimary =>
      isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;

  Color get textSecondary =>
      isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

  Color get surface => isDark ? AppTheme.darkSurface : AppTheme.lightSurface;

  Color get background =>
      isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
}
