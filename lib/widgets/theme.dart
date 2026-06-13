import 'package:flutter/material.dart';

/// Centralized UI design tokens and brand styling guidelines.
class IrmaTheme {
  // Brand Color Palette (Section 3 of ui_design_system.md)
  static const Color darkEspresso = Color(0xFF1F160F); // Brown 100
  static const Color earthyBrown = Color(0xFF4B3425);  // Brown 80
  static const Color mediumBrown = Color(0xFF926247);  // Brown 60
  static const Color lightTan = Color(0xFFE8DDD9);     // Brown 20
  static const Color lightWarmGray = Color(0xFFF7F4F2); // Brown 10

  static const Color sageGreen = Color(0xFF9BB068);     // Green 50
  static const Color lightGreen = Color(0xFFCFD9B5);    // Green 30
  static const Color lightSageTint = Color(0xFFF2F5EB); // Green 10

  static const Color empathyOrange = Color(0xFFFE814B); // Orange 40
  static const Color lightOrangeTint = Color(0xFFFFF0EB); // Orange 10

  static const Color zenYellow = Color(0xFFFFCE5C);     // Yellow 40
  static const Color lightYellowTint = Color(0xFFFFF4E0); // Yellow 10

  static const Color gentlePurple = Color(0xFF7152FF);  // Purple 40
  static const Color lightPurple = Color(0xFFCBC2FF);   // Purple 20
  static const Color lightPurpleTint = Color(0xFFEDEBFF); // Purple 10

  static const Color gray10 = Color(0xFFF2F5F8);
  static const Color gray20 = Color(0xFFDDE1E6);
  static const Color gray30 = Color(0xFFC1C6CD);
  static const Color gray60 = Color(0xFF697077);
  static const Color gray100 = Color(0xFF121619);

  /// Standard Box Decoration for Cards
  static BoxDecoration cardDecoration({
    Color color = Colors.white,
    double radius = 32.0,
    Color? borderColor,
    double borderWidth = 1.0,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: borderColor != null
          ? Border.all(color: borderColor, width: borderWidth)
          : Border.all(color: gray20, width: borderWidth),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// App-wide theme configuration
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Urbanist',
      scaffoldBackgroundColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: sageGreen,
        secondary: earthyBrown,
        surface: Colors.white,
        onSurface: darkEspresso,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Urbanist', fontSize: 48, fontWeight: FontWeight.w700, color: earthyBrown),
        headlineLarge: TextStyle(fontFamily: 'Urbanist', fontSize: 28, fontWeight: FontWeight.w700, color: earthyBrown),
        titleLarge: TextStyle(fontFamily: 'Urbanist', fontSize: 20, fontWeight: FontWeight.w700, color: darkEspresso),
        bodyLarge: TextStyle(fontFamily: 'Urbanist', fontSize: 16, fontWeight: FontWeight.w500, color: darkEspresso),
        bodyMedium: TextStyle(fontFamily: 'Urbanist', fontSize: 14, fontWeight: FontWeight.w500, color: gray60),
        labelLarge: TextStyle(fontFamily: 'Urbanist', fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
      ),
    );
  }
}
