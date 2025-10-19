import 'package:flutter/material.dart';
import 'package:app/core/theme/app_typography.dart';

// App-wide text style aliases mapping to the typography system.
// These are used by the theme to keep a stable API across the app.
class AppTextStyles {
  AppTextStyles._();

  // Display / Headlines
  static const TextStyle h1 = AppTypographySystem.displayLarge;
  static const TextStyle h2 = AppTypographySystem.displayMedium;
  static const TextStyle h3 = AppTypographySystem.displaySmall;
  static const TextStyle h4 = AppTypographySystem.headlineLarge;
  static const TextStyle h5 = AppTypographySystem.headlineMedium;
  static const TextStyle h6 = AppTypographySystem.headlineSmall;

  // Body
  static const TextStyle bodyLarge = AppTypographySystem.bodyLarge;
  static const TextStyle bodyMedium = AppTypographySystem.bodyMedium;
  static const TextStyle bodySmall = AppTypographySystem.bodySmall;

  // Labels
  static const TextStyle labelLarge = AppTypographySystem.labelLarge;
  static const TextStyle labelMedium = AppTypographySystem.labelMedium;
  static const TextStyle labelSmall = AppTypographySystem.labelSmall;

  // Buttons
  static const TextStyle button = AppTypographySystem.labelLarge;
}
