import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // Hero: for splash and login titles
  static TextStyle hero({Color? color}) => GoogleFonts.lexend(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: color,
        letterSpacing: 1.2,
      );

  // Title: for app bar and main titles
  static TextStyle title({Color? color, double? fontSize}) => GoogleFonts.lexend(
        fontSize: fontSize ?? 20,
        fontWeight: FontWeight.w400,
        color: color,
        letterSpacing: 0.8,
      );

  // Heading: for section headers
  static TextStyle heading({Color? color}) => GoogleFonts.lexend(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        color: color,
        letterSpacing: 0.4,
      );

  // Body: for general content
  static TextStyle body({Color? color, double? fontSize, FontWeight? fontWeight}) =>
      GoogleFonts.lexend(
        fontSize: fontSize ?? 14,
        fontWeight: fontWeight ?? FontWeight.w400,
        color: color,
        letterSpacing: 0.1,
      );

  // Label: for small text or badges
  static TextStyle label({Color? color, double? fontSize, double? letterSpacing}) =>
      GoogleFonts.lexend(
        fontSize: fontSize ?? 10,
        color: color,
        letterSpacing: letterSpacing ?? 2.0,
        fontWeight: FontWeight.w600,
      );
}
