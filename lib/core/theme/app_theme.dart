import 'package:flutter/material.dart';

enum AppThemeType { mikuDark, mikuLight, sakuraMiku }

class AppTheme {
  static ThemeData getTheme(AppThemeType type) {
    switch (type) {
      case AppThemeType.mikuDark:
        return darkTheme;
      case AppThemeType.mikuLight:
        return lightTheme;
      case AppThemeType.sakuraMiku:
        return sakuraTheme;
    }
  }

  // Miku Dark (Original)
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF39C5BB), // Miku Cyan
      brightness: Brightness.dark,
      background: const Color(0xFF121212),
      surface: const Color(0xFF1E1E1E),
      primary: const Color(0xFF39C5BB),
      secondary: const Color(0xFFE4007F), // Miku Pink
    ),
    scaffoldBackgroundColor: const Color(0xFF101010),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF101010),
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFF39C5BB)),
      titleTextStyle: TextStyle(
        color: Color(0xFF39C5BB),
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
    // ... other theme properties can be copied or extended
  );

  // Neon Mode (Replaces Light)
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark, 
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF00FFCC), // Neon Cyan
      brightness: Brightness.dark,
      background: const Color(0xFF0F0F1A), // Deep Cyber Blue
      surface: const Color(0xFF191929),
      primary: const Color(0xFF00FFCC),
      secondary: const Color(0xFFFF00CC), // Neon Magenta
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF050510),
    
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
      titleMedium: TextStyle(color: Color(0xFF00FFCC), fontWeight: FontWeight.bold, shadows: [Shadow(color: Color(0xFF00FFCC), blurRadius: 5)]),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF050510),
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFF00FFCC)),
      titleTextStyle: TextStyle(
        color: Color(0xFF00FFCC),
        fontSize: 22,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
        shadows: [Shadow(color: Color(0xFF00FFCC), blurRadius: 8)],
      ),
    ),
    iconTheme: const IconThemeData(color: Color(0xFF00FFCC)),
    listTileTheme: const ListTileThemeData(
       textColor: Colors.white,
       iconColor: Color(0xFF00FFCC),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF00FFCC),
      foregroundColor: Colors.black,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: const Color(0xFF00FFCC),
      inactiveTrackColor: Colors.white10,
      thumbColor: const Color(0xFFFF00CC),
      overlayColor: const Color(0xFFFF00CC).withOpacity(0.2),
    )
  );

  // Sakura Miku (Pink Mode)
  static final ThemeData sakuraTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark, // Sakura Miku usually works well with dark/soft pink
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFFF9CC9), // Sakura Pink
      brightness: Brightness.dark,
      background: const Color(0xFF2D0019), // Dark Pinkish BG
      surface: const Color(0xFF4A0028),
      primary: const Color(0xFFFF9CC9),
      secondary: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF200010),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF200010),
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFFFF9CC9)),
      titleTextStyle: TextStyle(
        color: Color(0xFFFF9CC9),
        fontSize: 22,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    ),
    iconTheme: const IconThemeData(color: Color(0xFFFF9CC9)),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFFF9CC9),
      foregroundColor: Colors.white,
    ),
  );
}
