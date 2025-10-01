import 'package:flutter/material.dart';
import 'package:aptimaster/core/theme/app_fonts.dart';

class AppText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Color? color;
  final FontWeight? fontWeight;
  final double? fontSize;
  final double? height;
  final TextDecoration? decoration;

  const AppText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
    this.fontWeight,
    this.fontSize,
    this.height,
    this.decoration,
  });

  // Predefined text styles
  const AppText.hero(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
    this.decoration,
  }) : style = AppFonts.hero,
       fontWeight = null,
       fontSize = null,
       height = null;

  const AppText.h1(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
    this.decoration,
  }) : style = AppFonts.h1,
       fontWeight = null,
       fontSize = null,
       height = null;

  const AppText.h2(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
    this.decoration,
  }) : style = AppFonts.h2,
       fontWeight = null,
       fontSize = null,
       height = null;

  const AppText.h3(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
    this.decoration,
  }) : style = AppFonts.h3,
       fontWeight = null,
       fontSize = null,
       height = null;

  const AppText.bodyLarge(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
    this.decoration,
  }) : style = AppFonts.bodyLarge,
       fontWeight = null,
       fontSize = null,
       height = null;

  const AppText.bodyMedium(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
    this.decoration,
  }) : style = AppFonts.bodyMedium,
       fontWeight = null,
       fontSize = null,
       height = null;

  const AppText.bodySmall(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
    this.decoration,
  }) : style = AppFonts.bodySmall,
       fontWeight = null,
       fontSize = null,
       height = null;

  const AppText.caption(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
    this.decoration,
  }) : style = AppFonts.caption,
       fontWeight = null,
       fontSize = null,
       height = null;

  const AppText.button(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
    this.decoration,
  }) : style = AppFonts.button,
       fontWeight = null,
       fontSize = null,
       height = null;

  const AppText.buttonSmall(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
    this.decoration,
  }) : style = AppFonts.buttonSmall,
       fontWeight = null,
       fontSize = null,
       height = null;

  // Custom constructor
  AppText.custom(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
    this.fontWeight,
    this.fontSize,
    this.height,
    this.decoration,
  }) : style = null;

  @override
  Widget build(BuildContext context) {
    TextStyle finalStyle;

    if (style != null) {
      finalStyle = style!.copyWith(
        color: color ?? style!.color,
        decoration: decoration ?? style!.decoration,
      );
    } else if (fontSize != null || fontWeight != null || height != null) {
      finalStyle = AppFonts.custom(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        decoration: decoration,
      );
    } else {
      finalStyle = AppFonts.bodyMedium.copyWith(
        color: color,
        decoration: decoration,
      );
    }

    return Text(
      text,
      style: finalStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

// Extension for easy access to font sizes
extension AppFontSizeExtension on BuildContext {
  double get fontXs => AppFonts.xs;
  double get fontSm => AppFonts.sm;
  double get fontMd => AppFonts.md;
  double get fontLg => AppFonts.lg;
  double get fontXl => AppFonts.xl;
  double get fontXxl => AppFonts.xxl;
}

// Extension for responsive font sizes
extension AppResponsiveFontExtension on BuildContext {
  double responsiveFontSize(double baseSize) {
    return AppFonts.responsiveFontSize(this, baseSize);
  }
}

