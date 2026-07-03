import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../tokens/spacing_tokens.dart';

abstract final class AppTextStyles {
  AppTextStyles._();

  static TextStyle get displayXl => GoogleFonts.inter(
        fontSize: 56,
        fontWeight: FontWeight.w700,
        letterSpacing: -2.5,
        height: 1.05,
      );

  static TextStyle get display => GoogleFonts.inter(
        fontSize: 44,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.8,
        height: 1.08,
      );

  static TextStyle get heading1 => GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        letterSpacing: -1.2,
        height: 1.12,
      );

  static TextStyle get heading2 => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.8,
        height: 1.18,
      );

  static TextStyle get heading3 => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        height: 1.24,
      );

  static TextStyle get title1 => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.2,
        height: 1.3,
      );

  static TextStyle get title2 => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.35,
      );

  static TextStyle get title3 => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.4,
      );

  static TextStyle get bodyLg => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.6,
      );

  static TextStyle get body => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.55,
      );

  static TextStyle get bodySm => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.5,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        height: 1.45,
      );

  static TextStyle get captionXs => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
        height: 1.4,
      );

  static TextStyle get label => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        height: 1.2,
      );

  static TextStyle get labelSm => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.2,
      );

  static TextStyle get button => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        height: 1.2,
      );

  static TextStyle get buttonLg => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        height: 1.2,
      );

  static TextStyle get buttonSm => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        height: 1.2,
      );

  static TextStyle get numeric => GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        letterSpacing: -1.5,
        height: 1.1,
      );

  static TextStyle get numericSm => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.8,
        height: 1.15,
      );

  static TextStyle get numericXs => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        height: 1.2,
      );

  static TextStyle get leaderboard => GoogleFonts.inter(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.5,
        height: 1.1,
      );

  static TextStyle get code => GoogleFonts.jetBrainsMono(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );
}
