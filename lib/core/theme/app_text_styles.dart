import 'package:flutter/material.dart';
import '../../design_system/typography/text_styles.dart' as ds;

/// Backwards compatibility layer mapping to design_system text styles.
abstract class AppTextStyles {
  static TextStyle get displayLarge => ds.AppTextStyles.display;
  static TextStyle get displayMedium => ds.AppTextStyles.heading1;
  static TextStyle get displaySmall => ds.AppTextStyles.heading2;

  static TextStyle get headlineLarge => ds.AppTextStyles.heading2;
  static TextStyle get headlineMedium => ds.AppTextStyles.heading3;
  static TextStyle get headlineSmall => ds.AppTextStyles.title1;

  static TextStyle get titleLarge => ds.AppTextStyles.title1;
  static TextStyle get titleMedium => ds.AppTextStyles.title2;
  static TextStyle get titleSmall => ds.AppTextStyles.title3;

  static TextStyle get bodyLarge => ds.AppTextStyles.bodyLg;
  static TextStyle get bodyMedium => ds.AppTextStyles.body;
  static TextStyle get bodySmall => ds.AppTextStyles.bodySm;

  static TextStyle get labelLarge => ds.AppTextStyles.button;
  static TextStyle get labelMedium => ds.AppTextStyles.label;
  static TextStyle get labelSmall => ds.AppTextStyles.caption;

  static TextStyle get caption => ds.AppTextStyles.caption;
  static TextStyle get button => ds.AppTextStyles.button;
}
