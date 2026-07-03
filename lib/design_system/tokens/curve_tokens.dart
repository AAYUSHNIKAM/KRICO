import 'package:flutter/material.dart';

abstract final class CurveTokens {
  CurveTokens._();

  static const Curve fast = Curves.linear;
  static const Curve ease = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve linear = Curves.linear;
  static const Curve decelerate = Curves.decelerate;
  static const Curve elasticOut = Curves.elasticOut;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve smooth = Curves.easeInOutCubic;
  static const Curve spring = Curves.easeOutBack;
  static const Curve sharp = Curves.easeInOutQuint;
  static const Curve emphasis = Curves.fastOutSlowIn;
}
