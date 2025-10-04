import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IOSTypography {
  // iOS System Font Family
  static const String systemFont = '.SF UI Text';
  static const String displayFont = '.SF UI Display';
  
  // iOS Font Weights
  static const FontWeight ultraLight = FontWeight.w100;
  static const FontWeight thin = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight heavy = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  // iOS Text Styles - Large Titles
  static const TextStyle largeTitle = TextStyle(
    fontFamily: displayFont,
    fontSize: 34,
    fontWeight: regular,
    letterSpacing: 0.37,
    height: 1.12,
  );

  static const TextStyle largeTitleEmphasized = TextStyle(
    fontFamily: displayFont,
    fontSize: 34,
    fontWeight: bold,
    letterSpacing: 0.37,
    height: 1.12,
  );

  // iOS Text Styles - Titles
  static const TextStyle title1 = TextStyle(
    fontFamily: systemFont,
    fontSize: 28,
    fontWeight: regular,
    letterSpacing: 0.36,
    height: 1.14,
  );

  static const TextStyle title1Emphasized = TextStyle(
    fontFamily: systemFont,
    fontSize: 28,
    fontWeight: bold,
    letterSpacing: 0.36,
    height: 1.14,
  );

  static const TextStyle title2 = TextStyle(
    fontFamily: systemFont,
    fontSize: 22,
    fontWeight: regular,
    letterSpacing: 0.35,
    height: 1.18,
  );

  static const TextStyle title2Emphasized = TextStyle(
    fontFamily: systemFont,
    fontSize: 22,
    fontWeight: bold,
    letterSpacing: 0.35,
    height: 1.18,
  );

  static const TextStyle title3 = TextStyle(
    fontFamily: systemFont,
    fontSize: 20,
    fontWeight: regular,
    letterSpacing: 0.38,
    height: 1.20,
  );

  static const TextStyle title3Emphasized = TextStyle(
    fontFamily: systemFont,
    fontSize: 20,
    fontWeight: semibold,
    letterSpacing: 0.38,
    height: 1.20,
  );

  // iOS Text Styles - Headlines
  static const TextStyle headline = TextStyle(
    fontFamily: systemFont,
    fontSize: 17,
    fontWeight: semibold,
    letterSpacing: -0.41,
    height: 1.29,
  );

  // iOS Text Styles - Body
  static const TextStyle body = TextStyle(
    fontFamily: systemFont,
    fontSize: 17,
    fontWeight: regular,
    letterSpacing: -0.41,
    height: 1.29,
  );

  static const TextStyle bodyEmphasized = TextStyle(
    fontFamily: systemFont,
    fontSize: 17,
    fontWeight: semibold,
    letterSpacing: -0.41,
    height: 1.29,
  );

  // iOS Text Styles - Callout
  static const TextStyle callout = TextStyle(
    fontFamily: systemFont,
    fontSize: 16,
    fontWeight: regular,
    letterSpacing: -0.32,
    height: 1.31,
  );

  static const TextStyle calloutEmphasized = TextStyle(
    fontFamily: systemFont,
    fontSize: 16,
    fontWeight: semibold,
    letterSpacing: -0.32,
    height: 1.31,
  );

  // iOS Text Styles - Subheadline
  static const TextStyle subheadline = TextStyle(
    fontFamily: systemFont,
    fontSize: 15,
    fontWeight: regular,
    letterSpacing: -0.24,
    height: 1.33,
  );

  static const TextStyle subheadlineEmphasized = TextStyle(
    fontFamily: systemFont,
    fontSize: 15,
    fontWeight: semibold,
    letterSpacing: -0.24,
    height: 1.33,
  );

  // iOS Text Styles - Footnote
  static const TextStyle footnote = TextStyle(
    fontFamily: systemFont,
    fontSize: 13,
    fontWeight: regular,
    letterSpacing: -0.08,
    height: 1.38,
  );

  static const TextStyle footnoteEmphasized = TextStyle(
    fontFamily: systemFont,
    fontSize: 13,
    fontWeight: semibold,
    letterSpacing: -0.08,
    height: 1.38,
  );

  // iOS Text Styles - Caption
  static const TextStyle caption1 = TextStyle(
    fontFamily: systemFont,
    fontSize: 12,
    fontWeight: regular,
    letterSpacing: 0.0,
    height: 1.33,
  );

  static const TextStyle caption1Emphasized = TextStyle(
    fontFamily: systemFont,
    fontSize: 12,
    fontWeight: medium,
    letterSpacing: 0.0,
    height: 1.33,
  );

  static const TextStyle caption2 = TextStyle(
    fontFamily: systemFont,
    fontSize: 11,
    fontWeight: regular,
    letterSpacing: 0.07,
    height: 1.36,
  );

  static const TextStyle caption2Emphasized = TextStyle(
    fontFamily: systemFont,
    fontSize: 11,
    fontWeight: semibold,
    letterSpacing: 0.07,
    height: 1.36,
  );

  // Navigation Bar Styles
  static const TextStyle navigationTitle = TextStyle(
    fontFamily: systemFont,
    fontSize: 17,
    fontWeight: semibold,
    letterSpacing: -0.41,
    height: 1.29,
  );

  static const TextStyle navigationLargeTitle = TextStyle(
    fontFamily: displayFont,
    fontSize: 34,
    fontWeight: bold,
    letterSpacing: 0.37,
    height: 1.12,
  );

  // Tab Bar Styles
  static const TextStyle tabBarItem = TextStyle(
    fontFamily: systemFont,
    fontSize: 10,
    fontWeight: medium,
    letterSpacing: 0.12,
    height: 1.2,
  );

  // Button Styles
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: systemFont,
    fontSize: 17,
    fontWeight: semibold,
    letterSpacing: -0.41,
    height: 1.29,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: systemFont,
    fontSize: 15,
    fontWeight: semibold,
    letterSpacing: -0.24,
    height: 1.33,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: systemFont,
    fontSize: 13,
    fontWeight: semibold,
    letterSpacing: -0.08,
    height: 1.38,
  );

  // Helper method to get text style with color
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  // Helper method to get text style with custom font weight
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  // Helper method to get text style with custom size
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
}

class IOSSpacing {
  // iOS Standard Spacing Values (8pt grid system)
  static const double xs = 2.0;    // Extra small
  static const double sm = 4.0;    // Small
  static const double md = 8.0;    // Medium (base unit)
  static const double lg = 12.0;   // Large
  static const double xl = 16.0;   // Extra large
  static const double xxl = 20.0;  // 2X large
  static const double xxxl = 24.0; // 3X large
  static const double huge = 32.0; // Huge
  static const double massive = 40.0; // Massive

  // Semantic Spacing
  static const double cardPadding = xl;           // 16px
  static const double sectionSpacing = xxxl;     // 24px
  static const double elementSpacing = lg;       // 12px
  static const double itemSpacing = md;          // 8px
  static const double screenPadding = xxl;       // 20px
  static const double buttonHeight = 44.0;       // iOS standard button height
  static const double listItemHeight = 44.0;     // iOS standard list item height
  static const double navigationBarHeight = 44.0; // iOS navigation bar height
  static const double tabBarHeight = 49.0;       // iOS tab bar height

  // Border Radius
  static const double radiusSmall = 6.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;
  static const double radiusXXLarge = 20.0;
  static const double radiusHuge = 24.0;

  // Shadow Values
  static const double shadowBlurSmall = 4.0;
  static const double shadowBlurMedium = 8.0;
  static const double shadowBlurLarge = 12.0;
  static const double shadowBlurXLarge = 16.0;

  static const Offset shadowOffsetSmall = Offset(0, 1);
  static const Offset shadowOffsetMedium = Offset(0, 2);
  static const Offset shadowOffsetLarge = Offset(0, 4);
  static const Offset shadowOffsetXLarge = Offset(0, 8);
}

class IOSConstants {
  // Minimum touch target size (iOS HIG)
  static const double minTouchTarget = 44.0;
  
  // Safe area insets
  static const double statusBarHeight = 44.0;
  static const double homeIndicatorHeight = 34.0;
  
  // Animation durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  
  // Animation curves
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve spring = Curves.elasticOut;
}
