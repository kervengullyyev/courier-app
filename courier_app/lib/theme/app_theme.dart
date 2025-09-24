// ============================================================================
// APP THEME - CENTRALIZED STYLING
// ============================================================================
// Centralized theme and styling system for consistent UI across the app
// ============================================================================

import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF0065F8);
  static const Color primaryColor50 = Color(0xFFE3F2FD);
  static const Color primaryColor700 = Color(0xFF1976D2);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardBackgroundColor = Colors.white;
  static const Color textPrimaryColor = Colors.black;
  static const Color textSecondaryColor = Color(0xFF666666);
  static const Color borderColor = Color(0xFFE0E0E0);
  
  // Font Sizes
  static const double fontSizeXSmall = 10.0;
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 14.0;
  static const double fontSizeXLarge = 16.0;
  static const double fontSizeXXLarge = 18.0;
  static const double fontSizeTitle = 22.0;
  static const double fontSizeHeader = 24.0;
  static const double fontSizePrice = 24.0;
  
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
      fontSize: fontSizeLarge,
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
    fontSize: fontSizeTitle,
    color: textPrimaryColor,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle sectionTitleStyle = TextStyle(
    fontSize: fontSizeLarge,
    fontWeight: FontWeight.w500,
    color: textSecondaryColor,
  );
  
  static const TextStyle buttonTextStyle = TextStyle(
    color: Colors.white,
    fontSize: fontSizeXLarge,
    fontWeight: FontWeight.w600,
  );
  
  static const TextStyle priceTextStyle = TextStyle(
    fontSize: fontSizePrice,
    fontWeight: FontWeight.w800,
    color: textPrimaryColor,
  );
  
  // Additional text styles using font size constants
  static const TextStyle xSmallTextStyle = TextStyle(
    fontSize: fontSizeXSmall,
    color: textSecondaryColor,
  );
  
  static const TextStyle smallTextStyle = TextStyle(
    fontSize: fontSizeSmall,
    color: textSecondaryColor,
  );
  
  static const TextStyle mediumTextStyle = TextStyle(
    fontSize: fontSizeMedium,
    color: textPrimaryColor,
  );
  
  static const TextStyle largeTextStyle = TextStyle(
    fontSize: fontSizeLarge,
    color: textPrimaryColor,
    fontWeight: FontWeight.w500,
  );
  
  static const TextStyle xLargeTextStyle = TextStyle(
    fontSize: fontSizeXLarge,
    color: textPrimaryColor,
    fontWeight: FontWeight.w600,
  );
  
  static const TextStyle xxLargeTextStyle = TextStyle(
    fontSize: fontSizeXXLarge,
    color: textPrimaryColor,
    fontWeight: FontWeight.w600,
  );
  
  // Label text style
  static const TextStyle labelTextStyle = TextStyle(
    fontSize: fontSizeLarge,
    color: textSecondaryColor,
    fontWeight: FontWeight.w500,
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
