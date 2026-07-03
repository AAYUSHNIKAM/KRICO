import 'dart:ui';

abstract final class ShadowTokens {
  ShadowTokens._();

  static const List<Shadow> none = [];

  static const List<Shadow> micro = [
    Shadow(blurRadius: 1, offset: Offset(0, 0.5), color: Color(0x08000000)),
  ];

  static const List<Shadow> xxs = [
    Shadow(blurRadius: 2, offset: Offset(0, 1), color: Color(0x0A000000)),
  ];

  static const List<Shadow> xs = [
    Shadow(blurRadius: 4, offset: Offset(0, 1), color: Color(0x0D000000)),
  ];

  static const List<Shadow> sm = [
    Shadow(blurRadius: 6, offset: Offset(0, 2), color: Color(0x10000000)),
  ];

  static const List<Shadow> md = [
    Shadow(blurRadius: 12, offset: Offset(0, 4), color: Color(0x14000000)),
    Shadow(blurRadius: 4, offset: Offset(0, 2), color: Color(0x08000000)),
  ];

  static const List<Shadow> lg = [
    Shadow(blurRadius: 20, offset: Offset(0, 6), color: Color(0x18000000)),
    Shadow(blurRadius: 8, offset: Offset(0, 4), color: Color(0x0A000000)),
  ];

  static const List<Shadow> xl = [
    Shadow(blurRadius: 32, offset: Offset(0, 12), color: Color(0x1C000000)),
    Shadow(blurRadius: 12, offset: Offset(0, 6), color: Color(0x0D000000)),
  ];

  static const List<Shadow> darkMicro = [
    Shadow(blurRadius: 1, offset: Offset(0, 0.5), color: Color(0x08000000)),
  ];

  static const List<Shadow> darkXxs = [
    Shadow(blurRadius: 2, offset: Offset(0, 1), color: Color(0x14000000)),
  ];

  static const List<Shadow> darkXs = [
    Shadow(blurRadius: 4, offset: Offset(0, 1), color: Color(0x1A000000)),
  ];

  static const List<Shadow> darkSm = [
    Shadow(blurRadius: 6, offset: Offset(0, 2), color: Color(0x24000000)),
  ];

  static const List<Shadow> darkMd = [
    Shadow(blurRadius: 12, offset: Offset(0, 4), color: Color(0x30000000)),
    Shadow(blurRadius: 4, offset: Offset(0, 2), color: Color(0x1A000000)),
  ];

  static const List<Shadow> darkLg = [
    Shadow(blurRadius: 20, offset: Offset(0, 6), color: Color(0x3C000000)),
    Shadow(blurRadius: 8, offset: Offset(0, 4), color: Color(0x24000000)),
  ];

  static const List<Shadow> darkXl = [
    Shadow(blurRadius: 32, offset: Offset(0, 12), color: Color(0x44000000)),
    Shadow(blurRadius: 12, offset: Offset(0, 6), color: Color(0x30000000)),
  ];
}
