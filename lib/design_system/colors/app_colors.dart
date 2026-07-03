import 'package:flutter/material.dart';

abstract final class AppColors {
  AppColors._();

  // Semantic Dark Colors
  static const background = Color(0xFF09090B);
  static const surface = Color(0xFF111113);
  static const surfaceSecondary = Color(0xFF18181B);
  static const surfaceElevated = Color(0xFF1E1E21);
  static const card = Color(0xFF161618);
  static const divider = Color(0xFF27272A);

  // Brand Colors
  static const primary = Color(0xFF2563EB);
  static const primaryHover = Color(0xFF3B82F6);
  static const primaryLight = Color(0xFF1E40AF);
  static const success = Color(0xFF16A34A);
  static const successLight = Color(0xFF22C55E);
  static const warning = Color(0xFFD97706);
  static const warningLight = Color(0xFFF59E0B);
  static const danger = Color(0xFFDC2626);
  static const dangerLight = Color(0xFFEF4444);
  static const purple = Color(0xFF7C3AED);
  static const purpleLight = Color(0xFF8B5CF6);
  static const orange = Color(0xFFEA580C);
  static const orangeLight = Color(0xFFF97316);
  static const emerald = Color(0xFF059669);
  static const emeraldLight = Color(0xFF10B981);

  // Text Colors
  static const textPrimary = Color(0xFFF4F4F5);
  static const textSecondary = Color(0xFFA1A1AA);
  static const textTertiary = Color(0xFF71717A);
  static const textDisabled = Color(0xFF52525B);
  static const textInverse = Color(0xFF09090B);

  // Border Colors
  static const border = Color(0xFF27272A);
  static const borderHover = Color(0xFF3F3F46);
  static const borderFocus = Color(0xFF52525B);

  // Interactive States
  static const hover = Color(0x0DFFFFFF);
  static const pressed = Color(0x1AFFFFFF);
  static const focus = Color(0x332563EB);
  static const selected = Color(0x1A2563EB);

  // Misc
  static const glass = Color(0x08FFFFFF);
  static const overlay = Color(0x99000000);
  static const shimmerBase = Color(0xFF1C1C1F);
  static const shimmerHighlight = Color(0xFF2A2A2E);

  // Semantic Light Colors
  static const lightBackground = Color(0xFFFAFAFA);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceSecondary = Color(0xFFF4F4F5);
  static const lightSurfaceElevated = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightDivider = Color(0xFFE4E4E7);

  static const lightTextPrimary = Color(0xFF18181B);
  static const lightTextSecondary = Color(0xFF71717A);
  static const lightTextTertiary = Color(0xFFA1A1AA);
  static const lightTextDisabled = Color(0xFFD4D4D8);

  static const lightBorder = Color(0xFFE4E4E7);
  static const lightBorderHover = Color(0xFFD4D4D8);
  static const lightBorderFocus = Color(0xFFA1A1AA);

  static const lightHover = Color(0x0A000000);
  static const lightPressed = Color(0x14000000);
  static const lightFocus = Color(0x332563EB);
  static const lightSelected = Color(0x1A2563EB);

  static const lightGlass = Color(0x08000000);
  static const lightOverlay = Color(0x66000000);
  static const lightShimmerBase = Color(0xFFE4E4E7);
  static const lightShimmerHighlight = Color(0xFFF4F4F5);

  // Leaderboard / Medal Colors
  static const gold = Color(0xFFD4A017);
  static const silver = Color(0xFFA8A8A8);
  static const bronze = Color(0xFFCD7F32);
}
