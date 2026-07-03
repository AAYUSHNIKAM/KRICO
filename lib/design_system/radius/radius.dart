import 'package:flutter/material.dart';
import '../tokens/radius_tokens.dart';

abstract final class AppRadius {
  AppRadius._();

  static const double none = RadiusTokens.none;
  static const double sm = RadiusTokens.sm;
  static const double md = RadiusTokens.md;
  static const double lg = RadiusTokens.lg;
  static const double xl = RadiusTokens.xl;
  static const double xl2 = RadiusTokens.xl2;
  static const double xl3 = RadiusTokens.xl3;
  static const double xl4 = RadiusTokens.xl4;
  static const double xl5 = RadiusTokens.xl5;
  static const double full = RadiusTokens.full;

  static BorderRadius br(double radius) => BorderRadius.circular(radius);
  static BorderRadius get brNone => BorderRadius.zero;
  static BorderRadius get brSm => BorderRadius.circular(sm);
  static BorderRadius get brMd => BorderRadius.circular(md);
  static BorderRadius get brLg => BorderRadius.circular(lg);
  static BorderRadius get brXl => BorderRadius.circular(xl);
  static BorderRadius get brXl2 => BorderRadius.circular(xl2);
  static BorderRadius get brXl3 => BorderRadius.circular(xl3);
  static BorderRadius get brXl4 => BorderRadius.circular(xl4);
  static BorderRadius get brXl5 => BorderRadius.circular(xl5);
  static BorderRadius get brFull => BorderRadius.circular(full);

  static BorderRadius top(double r) => BorderRadius.vertical(top: Radius.circular(r));
  static BorderRadius bottom(double r) => BorderRadius.vertical(bottom: Radius.circular(r));
  static BorderRadius left(double r) => BorderRadius.horizontal(left: Radius.circular(r));
  static BorderRadius right(double r) => BorderRadius.horizontal(right: Radius.circular(r));
}
