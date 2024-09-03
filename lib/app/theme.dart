import 'package:flutter/material.dart';

/// Brand colours shared with the web app (Tailwind emerald/slate).
abstract final class AppColors {
  static const brand = Color(0xFF059669);
  static const income = Color(0xFF047857);
  static const expense = Color(0xFFE11D48);
  static const muted = Color(0xFF64748B);
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: AppColors.brand);
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    appBarTheme:
        const AppBarTheme(centerTitle: false, scrolledUnderElevation: 0),
    cardTheme: CardTheme(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      filled: true,
      fillColor: Colors.white,
    ),
  );
}
