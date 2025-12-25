import 'package:flutter/material.dart';

class AppTheme {
  // Gradient Colors
  static const List<Color> gradientColors = [
    Color(0xFF121D5C), // Dark blue
    Color(0xFF434288), // Medium blue-purple
    Color(0xFF706BB5), // Light purple
    Color(0xFF9E96E6), // Lavender
  ];

  static const List<double> gradientStops = [0.0, 0.33, 0.66, 1.0];

  // Glassmorphism Colors
  static Color glassBackground = Colors.white.withOpacity(0.15);
  static Color glassBorder = Colors.white.withOpacity(0.2);
  static Color glassIconBackground = Colors.white.withOpacity(0.2);

  // Text Colors
  static const Color textPrimary = Colors.white;
  static Color textSecondary = Colors.white.withOpacity(0.8);
  static Color textTertiary = Colors.white.withOpacity(0.6);

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border Radius
  static const double radiusS = 12.0;
  static const double radiusM = 16.0;
  static const double radiusL = 20.0;
  static const double radiusXL = 24.0;

  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // Font Family
  static const String fontFamily = 'Zen Antique';

  // Typography
  static TextStyle get headlineLarge => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w300,
    letterSpacing: 1.2,
    color: textPrimary,
    height: 1.2,
  );

  static TextStyle get headlineMedium => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w300,
    letterSpacing: 1.0,
    color: textPrimary,
    height: 1.3,
  );

  static TextStyle get titleLarge => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    height: 1.4,
  );

  static TextStyle get titleMedium => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    height: 1.4,
  );

  static TextStyle get bodyLarge => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.5,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w300,
    color: textSecondary,
    height: 1.5,
  );

  static TextStyle get bodySmall => TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w300,
    color: textTertiary,
    height: 1.5,
  );

  // Theme Data
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: gradientColors[0],
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: TextTheme(
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
        ),
      ),
      buttonTheme: const ButtonThemeData(buttonColor: Colors.transparent),
    );
  }

  // Gradient Decoration
  static BoxDecoration get gradientDecoration => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: gradientColors,
      stops: gradientStops,
    ),
  );

  // Glass Card Decoration
  static BoxDecoration get glassCardDecoration => BoxDecoration(
    color: glassBackground,
    borderRadius: BorderRadius.circular(radiusL),
    border: Border.all(color: glassBorder, width: 1),
    boxShadow: cardShadow,
  );
}
