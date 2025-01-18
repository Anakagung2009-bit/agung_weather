import 'package:flutter/material.dart';

class AppTheme {
  // Definisi warna utama
  static const Color lightPrimaryColor = Color(0xFF1E88E5); // Blue 600
  static const Color darkPrimaryColor = Color(0xFF64B5F6); // Light Blue 400

  // Warna tambahan
  static const Color lightBackgroundColor = Color(0xFFF5F5F5);
  static const Color darkBackgroundColor = Color(0xFF121212);

  // TextTheme dengan font Product Sans
  static final TextTheme productSansTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'ProductSans',
      fontSize: 57,
      fontWeight: FontWeight.w400,
    ),
    displayMedium: TextStyle(
      fontFamily: 'ProductSans',
      fontSize: 45,
      fontWeight: FontWeight.w400,
    ),
    displaySmall: TextStyle(
      fontFamily: 'ProductSans',
      fontSize: 36,
      fontWeight: FontWeight.w400,
    ),
    headlineLarge: TextStyle(
      fontFamily: 'ProductSans',
      fontSize: 32,
      fontWeight: FontWeight.w400,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'ProductSans',
      fontSize: 28,
      fontWeight: FontWeight.w400,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'ProductSans',
      fontSize: 24,
      fontWeight: FontWeight.w400,
    ),
    titleLarge: TextStyle(
      fontFamily: 'ProductSans',
      fontSize: 22,
      fontWeight: FontWeight.w500,
    ),
    titleMedium: TextStyle(
      fontFamily: 'ProductSans',
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: TextStyle(
      fontFamily: 'ProductSans',
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: TextStyle(
      fontFamily: 'ProductSans',
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'ProductSans',
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    bodySmall: TextStyle(
      fontFamily: 'ProductSans',
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),
    labelLarge: TextStyle(
      fontFamily: 'ProductSans',
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: TextStyle(
      fontFamily: 'ProductSans',
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: TextStyle(
      fontFamily: 'ProductSans',
      fontSize: 11,
      fontWeight: FontWeight.w500,
    ),
  );

  // Metode untuk mendapatkan warna seed berdasarkan brightness
  static Color getSeedColor(Brightness brightness) {
    return brightness == Brightness.light
        ? lightPrimaryColor
        : darkPrimaryColor;
  }

  // Tema Light
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'ProductSans',
    useMaterial3: true,

    // Color Scheme dengan Material You
    colorScheme: ColorScheme.fromSeed(
      seedColor: lightPrimaryColor,
      brightness: Brightness.light,
    ),

    // Tema teks
    textTheme: productSansTextTheme,

    // Elevasi dan bentuk kartu
    cardTheme: CardTheme(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: lightBackgroundColor,
    ),

    // Tema tombol
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: TextStyle(fontFamily: 'ProductSans'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        textStyle: TextStyle(fontFamily: 'ProductSans'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        textStyle: TextStyle(fontFamily: 'ProductSans'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: TextStyle(fontFamily: 'ProductSans'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),

    // Tema input
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.blue.shade50,
    ),

    // Tema AppBar
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: lightPrimaryColor,
      iconTheme: IconThemeData(color: lightPrimaryColor),
    ),

    // Tema Scaffold
    scaffoldBackgroundColor: lightBackgroundColor,
  );

  // Tema Dark
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'ProductSans',
    useMaterial3: true,

    // Color Scheme dengan Material You
    colorScheme: ColorScheme.fromSeed(
      seedColor: darkPrimaryColor,
      brightness: Brightness.dark,
    ),

    // Tema teks
    textTheme: productSansTextTheme,

    // Elevasi dan bentuk kartu
    cardTheme: CardTheme(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: darkBackgroundColor,
    ),

    // Tema tombol
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: TextStyle(fontFamily: 'ProductSans'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        textStyle: TextStyle(fontFamily: 'ProductSans'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        textStyle: TextStyle(fontFamily: 'ProductSans'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: TextStyle(fontFamily: 'ProductSans'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),

    // Tema input
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.blueGrey.shade800,
    ),

    // Tema AppBar
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: darkPrimaryColor,
      iconTheme: IconThemeData(color: darkPrimaryColor),
    ),

    // Tema Scaffold
    scaffoldBackgroundColor: darkBackgroundColor,
  );

  // Method untuk membuat ColorScheme kustom
  static ColorScheme createColorScheme(Brightness brightness) {
    final seedColor = brightness == Brightness.light
        ? lightPrimaryColor
        : darkPrimaryColor;

    return ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
  }
}