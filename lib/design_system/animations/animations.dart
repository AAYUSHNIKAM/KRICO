import 'package:flutter/widgets.dart';
import '../tokens/duration_tokens.dart';
import '../tokens/curve_tokens.dart';

abstract final class AppAnimations {
  AppAnimations._();

  // Durations
  static const Duration fast = DurationTokens.fast;
  static const Duration normal = DurationTokens.normal;
  static const Duration medium = DurationTokens.medium;
  static const Duration slow = DurationTokens.slow;
  static const Duration slower = DurationTokens.slower;
  static const Duration deliberate = DurationTokens.deliberate;
  static const Duration long = DurationTokens.long;
  static const Duration xl = DurationTokens.xl;
  static const Duration xxl = DurationTokens.xxl;

  // Curves
  static const Curve fastCurve = CurveTokens.fast;
  static const Curve ease = CurveTokens.ease;
  static const Curve easeOut = CurveTokens.easeOut;
  static const Curve easeIn = CurveTokens.easeIn;
  static const Curve linear = CurveTokens.linear;
  static const Curve decelerate = CurveTokens.decelerate;
  static const Curve elasticOut = CurveTokens.elasticOut;
  static const Curve bounceOut = CurveTokens.bounceOut;
  static const Curve smooth = CurveTokens.smooth;
  static const Curve spring = CurveTokens.spring;
  static const Curve emphasis = CurveTokens.emphasis;

  // Pre-built transitions
  static const Duration pageTransition = Duration(milliseconds: 350);
  static const Curve pageCurve = Curves.easeInOutCubic;
  static const Duration dialogTransition = Duration(milliseconds: 200);
  static const Curve dialogCurve = Curves.easeOut;
  static const Duration sheetTransition = Duration(milliseconds: 300);
  static const Curve sheetCurve = Curves.easeOut;

  // Hover animation config
  static const double hoverScale = 1.01;
  static const double hoverOpacity = 0.85;
  static const double pressedScale = 0.98;
}
