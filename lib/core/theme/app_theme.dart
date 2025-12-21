import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF39C5BB), // Miku Cyan
      brightness: Brightness.dark,
      background: const Color(0xFF121212), // Dark Background
      surface: const Color(0xFF1E1E1E), // Slightly lighter surface
      primary: const Color(0xFF39C5BB), // Miku Cyan
      secondary: const Color(0xFFE4007F), // Miku Pink
    ),
    scaffoldBackgroundColor: const Color(0xFF101010), // Slightly darker
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF101010),
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFF39C5BB)), // Miku Cyan Icons
      titleTextStyle: TextStyle(
        color: Color(0xFF39C5BB), // Miku Cyan Title
        fontSize: 22,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    ),
    iconTheme: const IconThemeData(color: Color(0xFF39C5BB)),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF39C5BB),
      foregroundColor: Colors.white,
    ),
    searchBarTheme: SearchBarThemeData(
      backgroundColor: MaterialStateProperty.all(const Color(0xFF1E1E1E)),
      textStyle: MaterialStateProperty.all(const TextStyle(color: Colors.white)),
      elevation: MaterialStateProperty.all(0),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: Colors.white,
      textColor: Colors.white,
    ),
  );
}
