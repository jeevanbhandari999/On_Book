import 'package:flutter/material.dart';

// Enhanced Design System for Payment Proof Notifications
// Following Material Design 3 principles with consistent spacing, typography, and colors

// Enhanced Color System for Light and Dark themes

// Enhanced Typography System following Material Design 3
class AppTypographySystem {
  AppTypographySystem._();

  // Font Families
  static const String primaryFontFamily = 'Quicksand';
  static const String displayFontFamily = 'Quicksand';

  // Typography Scale
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
    height: 1.3,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.15,
    height: 1.4,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.15,
    height: 1.4,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.25,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.4,
    height: 1.3,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
    height: 1.3,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 10,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
    height: 1.2,
  );
}
