import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTextStyles {
  AppTextStyles._();

  static const List<String> _fallbacks = ['Roboto', 'Noto Sans', 'Apple Color Emoji', 'Segoe UI Emoji', 'Noto Color Emoji', 'sans-serif'];

  static TextStyle _inter({
    required double fontSize,
    required FontWeight fontWeight,
    double letterSpacing = 0,
    double height = 1.2,
  }) {
    return GoogleFonts.inter(
      textStyle: const TextStyle(fontFamilyFallback: _fallbacks),
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static final TextStyle displayXl = _inter(
    fontSize: 56,
    fontWeight: FontWeight.w700,
    letterSpacing: -2.5,
    height: 1.05,
  );

  static final TextStyle display = _inter(
    fontSize: 44,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.8,
    height: 1.08,
  );

  static final TextStyle heading1 = _inter(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    letterSpacing: -1.2,
    height: 1.12,
  );

  static final TextStyle heading2 = _inter(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.8,
    height: 1.18,
  );

  static final TextStyle heading3 = _inter(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
    height: 1.24,
  );

  static final TextStyle title1 = _inter(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static final TextStyle title2 = _inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.35,
  );

  static final TextStyle title3 = _inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.4,
  );

  static final TextStyle bodyLg = _inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.6,
  );

  static final TextStyle body = _inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.55,
  );

  static final TextStyle bodySm = _inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );

  static final TextStyle caption = _inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.45,
  );

  static final TextStyle captionXs = _inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.3,
    height: 1.4,
  );

  static final TextStyle label = _inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.2,
  );

  static final TextStyle labelSm = _inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.2,
  );

  static final TextStyle button = _inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.2,
  );

  static final TextStyle buttonLg = _inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.2,
  );

  static final TextStyle buttonSm = _inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.2,
  );

  static final TextStyle numeric = _inter(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    letterSpacing: -1.5,
    height: 1.1,
  );

  static final TextStyle numericSm = _inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.8,
    height: 1.15,
  );

  static final TextStyle numericXs = _inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
    height: 1.2,
  );

  static final TextStyle leaderboard = _inter(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.5,
    height: 1.1,
  );

  static final TextStyle code = GoogleFonts.jetBrainsMono(
    textStyle: const TextStyle(fontFamilyFallback: _fallbacks),
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
}
