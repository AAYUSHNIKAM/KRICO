import 'dart:ui';
import 'package:flutter/material.dart';
import '../tokens/elevation_tokens.dart';
import '../tokens/shadow_tokens.dart';

abstract final class AppElevation {
  AppElevation._();

  static const double none = ElevationTokens.none;
  static const double micro = ElevationTokens.micro;
  static const double xxs = ElevationTokens.xxs;
  static const double xs = ElevationTokens.xs;
  static const double sm = ElevationTokens.sm;
  static const double md = ElevationTokens.md;
  static const double lg = ElevationTokens.lg;
  static const double xl = ElevationTokens.xl;
  static const double xl2 = ElevationTokens.xl2;

  static List<Shadow> shadows(double elevation, {bool isDark = true}) {
    if (elevation <= 0) return ShadowTokens.none;
    if (elevation <= 0.5) return isDark ? ShadowTokens.darkMicro : ShadowTokens.micro;
    if (elevation <= 1) return isDark ? ShadowTokens.darkXxs : ShadowTokens.xxs;
    if (elevation <= 2) return isDark ? ShadowTokens.darkXs : ShadowTokens.xs;
    if (elevation <= 4) return isDark ? ShadowTokens.darkSm : ShadowTokens.sm;
    if (elevation <= 8) return isDark ? ShadowTokens.darkMd : ShadowTokens.md;
    if (elevation <= 12) return isDark ? ShadowTokens.darkLg : ShadowTokens.lg;
    if (elevation <= 16) return isDark ? ShadowTokens.darkXl : ShadowTokens.xl;
    return isDark ? ShadowTokens.darkXl : ShadowTokens.xl;
  }
}
