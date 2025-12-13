import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

Color lighten(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  // Increase lightness by 'amount', clamping the result between 0.0 and 1.0
  final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

  return hslLight.toColor();
}

// Custom Color Definitions
const Color primaryDarkBackground = Color(0xFF121212); // Deep Charcoal/Black
const Color accentGreen = Color(
  0xFF4CAF50,
); // Bright, positive green (adjust to match image exactly)
const Color negativeRed = Color(0xFFE57373); // Soft Red for expenses
const Color primaryWhite = Color(0xFFFFFFFF);
const Color secondaryGray = Color(0xFF8E8E93);

final ThemeData appTheme = ThemeData(
  // 1. Core Colors
  brightness: Brightness.dark,
  scaffoldBackgroundColor: primaryDarkBackground, // The main background color
  primaryColor: accentGreen, // Used for primary actions/indicators
  canvasColor: primaryDarkBackground, // Used for side panels/drawers
  // 2. Color Scheme (Recommended for modern Flutter apps)
  colorScheme: const ColorScheme.dark(
    primary: accentGreen,
    onPrimary: primaryDarkBackground,
    secondary: accentGreen, // Can use the same accent for secondary elements
    error: negativeRed,
    surface: primaryDarkBackground, // Used for Cards/Dialogs/Surfaces
    onSurface: primaryWhite,
  ),

  // 3. Typography (Mimicking SF Pro - using a system font fallback)
  fontFamily:
      'SF Pro Display', // Use a custom font if available, otherwise rely on system defaults
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      color: primaryWhite,
      fontWeight: FontWeight.w900,
      fontSize: 36,
    ), // For large amounts ($82,157)
    headlineLarge: TextStyle(
      color: primaryWhite,
      fontWeight: FontWeight.w600,
      fontSize: 24,
    ), // For transaction titles (Netflix, Inc)
    titleLarge: TextStyle(
      color: primaryWhite,
      fontWeight: FontWeight.bold,
      fontSize: 18,
    ), // For section headers
    bodyLarge: TextStyle(color: primaryWhite, fontSize: 16), // Primary text
    bodyMedium: TextStyle(color: secondaryGray, fontSize: 14), // Secondary text
    labelLarge: TextStyle(
      color: primaryWhite,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ), // Button text
    labelSmall: TextStyle(
      color: negativeRed,
      fontWeight: FontWeight.w500,
      fontSize: 14,
    ), // Negative value text
  ),

  // 4. Component Theming
  appBarTheme: const AppBarTheme(
    backgroundColor: primaryDarkBackground,
    foregroundColor: primaryWhite,
    elevation: 0, // Flat design
    centerTitle: false,
    titleTextStyle: TextStyle(
      color: primaryWhite,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: accentGreen, // Text buttons use the accent color
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: accentGreen, // The 'Create Transaction' button color
      foregroundColor: primaryWhite, // Text on the button should be dark
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Rounded corners for buttons
      ),
      elevation: 6.0,
    ),
  ),


  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: primaryDarkBackground, // Inputs use the dark background
    hintStyle: TextStyle(color: secondaryGray),
    labelStyle: TextStyle(color: secondaryGray),
    border: InputBorder.none, // Often inputs in this style are borderless
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),

  // Customizing Bottom Navigation Bar (as seen in the image)
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: secondaryGray,
    selectedItemColor: accentGreen,
    unselectedItemColor: secondaryGray,
    type: BottomNavigationBarType.fixed,
  ),
);
