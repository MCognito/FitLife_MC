import 'package:flutter/material.dart';

class ColorStyle {
  // Dark theme colors
  static const Color darkGray = Color(0xFF1E1E1E); // AppBar Dark Gray
  static const Color mediumDarkGray =
      Color(0xFF2C2C2C); // Scaffold Background Color
  static const Color purpleButton = Color(0xFFBB86FC); // Button Purple Color
  static const Color darkBackground =
      Color(0xFF3A3A3A); // Dark Gray for TextFields
  static const Color lightGrayBorder = Color(0xFF5A5A5A); // Light Gray Border
  static const Color white24 = Colors.white24; // White for Divider

  // Light theme colors
  static const Color lightGray = Color(0xFFF5F5F5); // Light Gray for AppBar
  static const Color lightBackground =
      Color(0xFFEEEEEE); // Light Background for Scaffold
  static const Color purpleButtonLight =
      Color(0xFF6200EE); // Darker Purple for Button in Light Theme
  static const Color lightFieldBackground =
      Color(0xFFE0E0E0); // Light Gray for TextFields
  static const Color darkGrayBorder =
      Color(0xFFBDBDBD); // Dark Gray Border for Light Theme
  static const Color black12 =
      Colors.black12; // Black for Divider in Light Theme

  // Special colors for login/signup pages
  static const Color fitLifeBlue =
      Color(0xFF1C4D88); // FitLife blue color for login/signup background
  static const Color lightTextOnBlue =
      Color(0xFFF0F0F0); // Light text color for text on blue background

  // Common colors
  static const Color errorRed = Color(0xFFB00020); // Error color
  static const Color successGreen = Color(0xFF4CAF50); // Success color
}

// Theme provider to manage both light and dark themes
class AppTheme {
  static ThemeData darkTheme = ThemeData(
    fontFamily: 'Poppins',
    brightness: Brightness.dark,
    primaryColor: ColorStyle.darkGray,
    scaffoldBackgroundColor: ColorStyle.mediumDarkGray,
    cardColor: ColorStyle.darkBackground,
    dividerColor: ColorStyle.white24,
    colorScheme: const ColorScheme.dark(
      primary: ColorStyle.purpleButton,
      secondary: ColorStyle.purpleButton,
      error: ColorStyle.errorRed,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
      titleLarge: TextStyle(
        color: Colors.white,
        overflow: TextOverflow.ellipsis,
      ),
      titleMedium: TextStyle(
        color: Colors.white,
        overflow: TextOverflow.ellipsis,
      ),
      titleSmall: TextStyle(
        color: Colors.white,
        overflow: TextOverflow.ellipsis,
      ),
      bodySmall: TextStyle(
        color: Colors.white70,
        overflow: TextOverflow.ellipsis,
      ),
      labelLarge: TextStyle(
        color: Colors.white,
        overflow: TextOverflow.ellipsis,
      ),
      labelMedium: TextStyle(
        color: Colors.white,
        overflow: TextOverflow.ellipsis,
      ),
      labelSmall: TextStyle(
        color: Colors.white70,
        overflow: TextOverflow.ellipsis,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorStyle.purpleButton,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ColorStyle.darkBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ColorStyle.lightGrayBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ColorStyle.lightGrayBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ColorStyle.purpleButton, width: 2),
      ),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    primaryColor: ColorStyle.lightGray,
    scaffoldBackgroundColor: ColorStyle.lightBackground,
    cardColor: Colors.white,
    dividerColor: ColorStyle.black12,
    colorScheme: const ColorScheme.light(
      primary: ColorStyle.purpleButtonLight,
      secondary: ColorStyle.purpleButtonLight,
      error: ColorStyle.errorRed,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black54),
      titleLarge: TextStyle(
        color: Colors.black87,
        overflow: TextOverflow.ellipsis,
      ),
      titleMedium: TextStyle(
        color: Colors.black87,
        overflow: TextOverflow.ellipsis,
      ),
      titleSmall: TextStyle(
        color: Colors.black87,
        overflow: TextOverflow.ellipsis,
      ),
      bodySmall: TextStyle(
        color: Colors.black54,
        overflow: TextOverflow.ellipsis,
      ),
      labelLarge: TextStyle(
        color: Colors.black87,
        overflow: TextOverflow.ellipsis,
      ),
      labelMedium: TextStyle(
        color: Colors.black87,
        overflow: TextOverflow.ellipsis,
      ),
      labelSmall: TextStyle(
        color: Colors.black54,
        overflow: TextOverflow.ellipsis,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorStyle.purpleButtonLight,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ColorStyle.lightFieldBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ColorStyle.darkGrayBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ColorStyle.darkGrayBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
            const BorderSide(color: ColorStyle.purpleButtonLight, width: 2),
      ),
    ),
  );
}
