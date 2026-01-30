import 'package:flutter/material.dart';

ThemeData appTheme() {
  final primaryColor = const Color(0xFF116E57); // dunkelgrün-emerald
  final colorScheme = ColorScheme.fromSeed(seedColor: primaryColor);

  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFFAFBFC),
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 1,
      centerTitle: false,
      surfaceTintColor: colorScheme.primary,
    ),
    // Cards: subtle border, low elevation for a cleaner, conventional look
    cardTheme: CardThemeData(
      color: colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: BorderSide(color: colorScheme.outline.withOpacity(0.12))),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    ),
    // Buttons: simpler, less bold, more conventional spacing
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(colorScheme.primary),
        foregroundColor: MaterialStateProperty.all(colorScheme.onPrimary),
        padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 8, horizontal: 12)),
        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
        textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ),
    ),
    // Inputs: use subtle outline (not heavy filled) for a conventional form look
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.12))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.12))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: colorScheme.primary)),
    ),
    // List tiles: no colored background, simple divider separation
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      tileColor: Colors.transparent,
    ),
    // Navigation bar: slightly more geometric indicator
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      indicatorColor: colorScheme.primary.withOpacity(0.10),
      labelTextStyle: MaterialStateProperty.all(const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      height: 56,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurface.withOpacity(0.7),
      showUnselectedLabels: true,
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: Colors.grey[900]),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[900]),
      titleMedium: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(fontSize: 14, color: Colors.grey[800]),
      bodyMedium: TextStyle(fontSize: 13, color: Colors.grey[700]),
      bodySmall: TextStyle(fontSize: 11, color: Colors.grey[600]),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
