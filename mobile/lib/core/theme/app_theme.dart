import 'package:flutter/material.dart';

abstract final class FieldColors {
  static const graphite = Color(0xFF182127);
  static const steel = Color(0xFF3C5A67);
  static const steelSoft = Color(0xFFE6EEF1);
  static const paper = Color(0xFFF6F7F4);
  static const surface = Color(0xFFFFFFFF);
  static const line = Color(0xFFD9E0E1);
  static const amber = Color(0xFFE39A18);
  static const amberSoft = Color(0xFFFFF1D6);
  static const compliant = Color(0xFF1F7556);
  static const compliantSoft = Color(0xFFDDF0E7);
  static const nonCompliant = Color(0xFFB43A3A);
  static const nonCompliantSoft = Color(0xFFF8E1E1);
  static const notApplicable = Color(0xFF5F6870);
  static const notApplicableSoft = Color(0xFFE9ECEE);
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: FieldColors.steel,
    brightness: Brightness.light,
    primary: FieldColors.steel,
    secondary: FieldColors.amber,
    surface: FieldColors.surface,
    error: FieldColors.nonCompliant,
  );
  const radius = BorderRadius.all(Radius.circular(12));

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: FieldColors.paper,
    fontFamily: 'Roboto',
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        fontSize: 32,
        height: 1.08,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: FieldColors.graphite,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        height: 1.15,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.35,
        color: FieldColors.graphite,
      ),
      titleLarge: TextStyle(
        fontSize: 19,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: FieldColors.graphite,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: FieldColors.graphite,
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.45),
      bodyMedium: TextStyle(fontSize: 14, height: 1.45),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: FieldColors.paper,
      foregroundColor: FieldColors.graphite,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: const CardThemeData(
      color: FieldColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: FieldColors.line),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFF0F3F2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: FieldColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: FieldColors.steel, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(44, 48),
        shape: const RoundedRectangleBorder(borderRadius: radius),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(44, 48),
        shape: const RoundedRectangleBorder(borderRadius: radius),
        side: const BorderSide(color: FieldColors.line),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: radius),
    ),
  );
}
