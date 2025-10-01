import 'package:flutter/material.dart';

class AppFonts {
  // Font Family
  static const String fontFamily = 'Inter';

  // Font Sizes
  static const double xs = 12.0; // Extra Small - Captions, labels
  static const double sm = 14.0; // Small - Body text, descriptions
  static const double md = 16.0; // Medium - Default text, buttons
  static const double lg = 18.0; // Large - Subheadings, important text
  static const double xl = 24.0; // Extra Large - Headings, titles
  static const double xxl = 32.0; // Extra Extra Large - Main titles, hero text

  // Font Weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Predefined Text Styles
  static const TextStyle hero = TextStyle(
    fontSize: xxl,
    fontWeight: bold,
    fontFamily: fontFamily,
    height: 1.2,
  );

  static const TextStyle h1 = TextStyle(
    fontSize: xl,
    fontWeight: bold,
    fontFamily: fontFamily,
    height: 1.3,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: lg,
    fontWeight: semiBold,
    fontFamily: fontFamily,
    height: 1.4,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: md,
    fontWeight: semiBold,
    fontFamily: fontFamily,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: md,
    fontWeight: regular,
    fontFamily: fontFamily,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: sm,
    fontWeight: regular,
    fontFamily: fontFamily,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: xs,
    fontWeight: regular,
    fontFamily: fontFamily,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: xs,
    fontWeight: medium,
    fontFamily: fontFamily,
    height: 1.3,
  );

  static const TextStyle button = TextStyle(
    fontSize: md,
    fontWeight: semiBold,
    fontFamily: fontFamily,
    height: 1.2,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: sm,
    fontWeight: medium,
    fontFamily: fontFamily,
    height: 1.2,
  );

  // Helper methods for custom styles
  static TextStyle custom({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontSize: fontSize ?? md,
      fontWeight: fontWeight ?? regular,
      fontFamily: fontFamily,
      color: color,
      height: height ?? 1.5,
      decoration: decoration,
    );
  }

  // Responsive font sizes based on screen size
  static double responsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) {
      return baseSize * 0.9; // Mobile
    } else if (screenWidth < 900) {
      return baseSize; // Tablet
    } else {
      return baseSize * 1.1; // Desktop
    }
  }

  // Get font size by name
  static double getFontSize(String sizeName) {
    switch (sizeName.toLowerCase()) {
      case 'xs':
        return xs;
      case 'sm':
        return sm;
      case 'md':
        return md;
      case 'lg':
        return lg;
      case 'xl':
        return xl;
      case 'xxl':
        return xxl;
      default:
        return md;
    }
  }

  // Get font weight by name
  static FontWeight getFontWeight(String weightName) {
    switch (weightName.toLowerCase()) {
      case 'light':
        return light;
      case 'regular':
        return regular;
      case 'medium':
        return medium;
      case 'semibold':
      case 'semi_bold':
        return semiBold;
      case 'bold':
        return bold;
      default:
        return regular;
    }
  }
}

