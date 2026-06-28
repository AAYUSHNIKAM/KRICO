import 'package:flutter/material.dart';

abstract class AppDimensions {
  AppDimensions._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;

  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  static const double avatarXs = 24.0;
  static const double avatarSm = 32.0;
  static const double avatarMd = 48.0;
  static const double avatarLg = 64.0;
  static const double avatarXl = 96.0;

  static const double cardElevation = 2.0;
  static const double cardElevationHover = 8.0;

  static EdgeInsets screenPadding({bool isMobile = true}) =>
      EdgeInsets.symmetric(
        horizontal: isMobile ? md : xl,
        vertical: md,
      );

  static EdgeInsets cardPadding = const EdgeInsets.all(md);
  static EdgeInsets cardPaddingLg = const EdgeInsets.all(lg);
}
