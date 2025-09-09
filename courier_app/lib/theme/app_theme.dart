// ============================================================================
// APP THEME - CENTRALIZED STYLING
// ============================================================================
// Centralized theme and styling system for consistent UI across the app
// ============================================================================

import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Colors.blue;
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardBackgroundColor = Colors.white;
  static const Color textPrimaryColor = Colors.black;
  static const Color textSecondaryColor = Color(0xFF666666);
  static const Color borderColor = Color(0xFFE0E0E0);
  
  // Spacing
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  // Border radius
  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 24.0;
  
  // Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.grey.withOpacity(0.1),
      spreadRadius: 1,
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get bottomShadow => [
    BoxShadow(
      color: Colors.grey.withOpacity(0.1),
      spreadRadius: 1,
      blurRadius: 4,
      offset: const Offset(0, -8),
    ),
  ];
  
  // Decorations
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: cardBackgroundColor,
    borderRadius: BorderRadius.circular(defaultBorderRadius),
    boxShadow: cardShadow,
  );
  
  static BoxDecoration get buttonDecoration => BoxDecoration(
    color: primaryColor,
    borderRadius: BorderRadius.circular(largeBorderRadius),
  );
  
  // Input decorations
  static InputDecoration get inputDecoration => InputDecoration(
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(smallBorderRadius),
      borderSide: BorderSide(color: borderColor, width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(smallBorderRadius),
      borderSide: const BorderSide(color: primaryColor, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: 12),
  );
  
  static InputDecoration get hintInputDecoration => InputDecoration(
    hintStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Color(0xFF999999),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(smallBorderRadius),
      borderSide: BorderSide(color: borderColor, width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(smallBorderRadius),
      borderSide: const BorderSide(color: primaryColor, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: 12),
  );
  
  // Text styles
  static const TextStyle headerStyle = TextStyle(
    fontSize: 22,
    color: textPrimaryColor,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle sectionTitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textSecondaryColor,
  );
  
  static const TextStyle buttonTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
  
  static const TextStyle priceTextStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: textPrimaryColor,
  );
  
  // Container styles
  static Container get sectionContainer => Container(
    margin: const EdgeInsets.fromLTRB(defaultPadding, 2, defaultPadding, 4),
    padding: const EdgeInsets.all(defaultPadding),
    decoration: cardDecoration,
  );
  
  static Container get bottomContainer => Container(
    padding: const EdgeInsets.fromLTRB(defaultPadding, smallPadding, defaultPadding, smallPadding),
    decoration: BoxDecoration(
      color: cardBackgroundColor,
      boxShadow: bottomShadow,
    ),
  );
}
