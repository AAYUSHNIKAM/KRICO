import 'package:flutter/material.dart';
import '../tokens/spacing_tokens.dart';

abstract final class SpacingScale {
  SpacingScale._();

  static const double s2 = SpacingTokens.xxs;
  static const double s4 = SpacingTokens.xs;
  static const double s6 = SpacingTokens.sm;
  static const double s8 = SpacingTokens.md;
  static const double s10 = SpacingTokens.lg;
  static const double s12 = SpacingTokens.xl;
  static const double s16 = SpacingTokens.xl2;
  static const double s20 = SpacingTokens.xl3;
  static const double s24 = SpacingTokens.xl4;
  static const double s28 = SpacingTokens.xl5;
  static const double s32 = SpacingTokens.xl6;
  static const double s40 = SpacingTokens.xl7;
  static const double s48 = SpacingTokens.xl8;
  static const double s56 = SpacingTokens.xl9;
  static const double s64 = SpacingTokens.xl10;
  static const double s72 = SpacingTokens.xl11;
  static const double s80 = SpacingTokens.xl12;

  static const EdgeInsets zero = EdgeInsets.zero;
  static EdgeInsets all(double value) => EdgeInsets.all(value);
  static EdgeInsets symmetric({double? h, double? v}) =>
      EdgeInsets.symmetric(horizontal: h ?? 0, vertical: v ?? 0);
  static EdgeInsets only({double? l, double? t, double? r, double? b}) =>
      EdgeInsets.only(left: l ?? 0, top: t ?? 0, right: r ?? 0, bottom: b ?? 0);

  // Horizontal insets
  static EdgeInsets h(double value) => EdgeInsets.symmetric(horizontal: value);
  static EdgeInsets v(double value) => EdgeInsets.symmetric(vertical: value);

  // Common presets
  static const EdgeInsets screenH = EdgeInsets.symmetric(horizontal: s16);
  static const EdgeInsets screenV = EdgeInsets.symmetric(vertical: s16);
  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: s16, vertical: s16);
  static const EdgeInsets card = EdgeInsets.all(s16);
  static const EdgeInsets cardCompact = EdgeInsets.all(s12);
  static const EdgeInsets cardLoose = EdgeInsets.all(s20);
  static const EdgeInsets section = EdgeInsets.symmetric(horizontal: s16, vertical: s12);
  static const EdgeInsets listItem = EdgeInsets.symmetric(horizontal: s16, vertical: s12);
  static const EdgeInsets input = EdgeInsets.symmetric(horizontal: s12, vertical: s10);
}
