import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color.fromARGB(255, 7, 194, 172);

  static const Color primaryDark = Color(0xff00030F);
  static const Color primaryLight = Color(0xFFE7EBFF);

  // Secondary Accent Colors
  // Adds energy + uniqueness without overpowering
  static const Color secondary = Color.fromARGB(
    255,
    255,
    255,
    255,
  ); // Soft Violet
  static const Color secondaryDark = Color(0xff00030F);
  static const Color secondaryLight = Color(0xFFF2E9FF);

  // Neutral Colors (consistent with modern design systems)
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF555555);
  static const Color grey800 = Color(0xFF2E2E2E);
  static const Color grey900 = Color(0xFF1A1A1A);

  // Status Colors (consistent with M3)
  static const Color success = Color(0xFF00C853); // Green A700
  static const Color warning = Color(0xFFFFB300); // Amber 600
  static const Color error = Color(0xFFD32F2F); // Red 700
  static const Color info = Color(0xFF0288D1); // Light Blue 700

  // Backgrounds (for light/dark modes)
  static const Color backgroundLight = Color(0xFFF9FAFB);
  static const Color backgroundDark = Color(0xFF0D1117);

  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1C1F26);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF616161);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  // Borders / Dividers
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF2A2A2A);

  // Shadows & Overlays
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);
}

// import 'package:flutter/material.dart';

// class AppColors {
//   // ── Primary ────────────────────────────────────────────────────────────────
//   // Deep teal-blue — trustworthy, modern, booking-app feel (think Airbnb/Booking.com energy)
//   static const Color primary = Color(0xFF0EA5E9); // Sky Blue 500
//   static const Color primaryDark = Color(
//     0xFF0C0F1A,
//   ); // Near-black with blue tint
//   static const Color primaryLight = Color(0xFFEFF8FF); // Very soft sky tint

//   // ── Secondary ──────────────────────────────────────────────────────────────
//   // Warm violet — adds personality, pairs well with sky blue
//   static const Color secondary = Color(0xFF7C3AED); // Violet 600
//   static const Color secondaryDark = Color(0xFF0C0F1A);
//   static const Color secondaryLight = Color(0xFFF5F0FF);

//   // ── Accent ─────────────────────────────────────────────────────────────────
//   // Soft emerald — for success states, CTAs, energy
//   static const Color accent = Color(0xFF10B981); // Emerald 500

//   // ── Neutrals ───────────────────────────────────────────────────────────────
//   static const Color white = Color(0xFFFFFFFF);
//   static const Color black = Color(0xFF000000);
//   static const Color grey50 = Color(0xFFF8FAFC);
//   static const Color grey100 = Color(0xFFF1F5F9);
//   static const Color grey200 = Color(0xFFE2E8F0);
//   static const Color grey300 = Color(0xFFCBD5E1);
//   static const Color grey400 = Color(0xFF94A3B8);
//   static const Color grey500 = Color(0xFF64748B);
//   static const Color grey600 = Color(0xFF475569);
//   static const Color grey700 = Color(0xFF334155);
//   static const Color grey800 = Color(0xFF1E293B);
//   static const Color grey900 = Color(0xFF0F172A);

//   // ── Status ─────────────────────────────────────────────────────────────────
//   static const Color success = Color(0xFF10B981); // Emerald 500
//   static const Color warning = Color(0xFFF59E0B); // Amber 500
//   static const Color error = Color(0xFFEF4444); // Red 500
//   static const Color info = Color(0xFF0EA5E9); // Sky 500

//   // ── Backgrounds ────────────────────────────────────────────────────────────
//   static const Color backgroundLight = Color(0xFFF8FAFC);
//   static const Color backgroundDark = Color(0xFF0C0F1A);

//   static const Color surfaceLight = Color(0xFFFFFFFF);
//   static const Color surfaceDark = Color(0xFF151929);

//   // ── Text ───────────────────────────────────────────────────────────────────
//   static const Color textPrimaryLight = Color(0xFF0F172A);
//   static const Color textSecondaryLight = Color(0xFF475569);
//   static const Color textPrimaryDark = Color(0xFFF1F5F9);
//   static const Color textSecondaryDark = Color(0xFF94A3B8);

//   // ── Borders ────────────────────────────────────────────────────────────────
//   static const Color borderLight = Color(0xFFE2E8F0);
//   static const Color borderDark = Color(0xFF1E293B);

//   // ── Shadows ────────────────────────────────────────────────────────────────
//   static const Color shadowLight = Color(0x1A0EA5E9); // blue-tinted shadow
//   static const Color shadowDark = Color(0x33000000);
// }
