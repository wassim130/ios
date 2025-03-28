import 'package:flutter/material.dart';

// Light Theme Colors
final Color lightPrimaryColor = Color(0xFF3498db);
final Color lightSecondaryColor = Color(0xFFF5F5F5);
final Color lightBackgroundColor = Colors.white;

// Dark Theme Colors
final Color darkPrimaryColor = Color(0xFF2C3E50);
final Color darkSecondaryColor = Color(0xFF34495E);
final Color darkBackgroundColor = Color(0xFF1E272E);

// Modify your existing myTheme to support dark mode
final ThemeData myTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 183, 77, 58),
    brightness: Brightness.light,
  ),
  useMaterial3: true,
  primarySwatch: Colors.deepPurple,
  fontFamily: 'Poppins',
  canvasColor: lightBackgroundColor,
  textTheme: TextTheme(
    headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(fontSize: 16),
  ),
);

// Dark theme based on your existing myTheme
final ThemeData myDarkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 183, 77, 58),
    brightness: Brightness.dark,
  ),
  useMaterial3: true,
  primarySwatch: Colors.deepPurple,
  fontFamily: 'Poppins',
  canvasColor: darkBackgroundColor,
  textTheme: TextTheme(
    headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white
    ),
    bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.white
    ),
  ),
);