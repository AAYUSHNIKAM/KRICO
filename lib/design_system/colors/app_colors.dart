import 'package:flutter/material.dart';

abstract final class AppColors {
  AppColors._();

  // Semantic Dark Colors (Cyber-Athletic Obsidian)
  static const background = Color(0xFF090A0F);
  static const surface = Color(0xFF10131B);
  static const surfaceSecondary = Color(0xFF161A24);
  static const surfaceElevated = Color(0xFF1C2230);
  static const card = Color(0xFF131722);
  static const divider = Color(0xFF222736);

  // Brand Colors (Cyber-Athletic Volt Hybrid)
  static const primary = volt;
  static const primaryHover = voltLight;
  static const primaryLight = voltDark;
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
  static const volt = Color(0xFFCCFF00);
  static const voltLight = Color(0xFFD4FF33);
  static const voltDark = Color(0xFF4D7C0F);
  static const voltGlow = Color(0x33CCFF00);
  static const cyan = Color(0xFF00E5FF);
  static const cyanLight = Color(0xFF33EBFF);
  static const cyanDark = Color(0xFF0284C7);
  static const cyanGlow = Color(0x3300E5FF);

  // Hero Action Tokens
  static const midnightObsidian = Color(0xFF090A0F);
  static const pitchSlate = Color(0xFF0F172A);
  static const voltHover = Color(0xFFD4FF33);
  static const heroDarkCta = Color(0xFFCCFF00);
  static const heroDarkCtaText = Color(0xFF090A0F);
  static const heroLightCta = Color(0xFF0F172A);
  static const heroLightCtaText = Color(0xFFFFFFFF);

  // Text Colors (Dark Mode)
  static const textPrimary = Color(0xFFF8FAFC);
  static const textSecondary = Color(0xFF94A3B8);
  static const textTertiary = Color(0xFF64748B);
  static const textDisabled = Color(0xFF475569);
  static const textInverse = Color(0xFF090A0F);

  // Border Colors (Dark Mode)
  static const border = Color(0xFF222736);
  static const borderHover = Color(0xFF353C52);
  static const borderFocus = Color(0xFFCCFF00);

  // Interactive States
  static const hover = Color(0x0DFFFFFF);
  static const pressed = Color(0x1AFFFFFF);
  static const focus = Color(0x33CCFF00);
  static const selected = Color(0x1ACCFF00);

  // Misc
  static const glass = Color(0x0DFFFFFF);
  static const overlay = Color(0x99000000);
  static const shimmerBase = Color(0xFF131722);
  static const shimmerHighlight = Color(0xFF1E2333);

  // Semantic Light Colors (Crisp Athletic Porcelain)
  static const lightBackground = Color(0xFFF8FAFC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceSecondary = Color(0xFFF1F5F9);
  static const lightSurfaceElevated = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightDivider = Color(0xFFE2E8F0);

  static const lightTextPrimary = Color(0xFF0F172A);
  static const lightTextSecondary = Color(0xFF475569);
  static const lightTextTertiary = Color(0xFF64748B);
  static const lightTextDisabled = Color(0xFF94A3B8);

  static const lightBorder = Color(0xFFE2E8F0);
  static const lightBorderHover = Color(0xFFCBD5E1);
  static const lightBorderFocus = Color(0xFF0F172A);

  static const lightHover = Color(0x080F172A);
  static const lightPressed = Color(0x140F172A);
  static const lightFocus = Color(0x330F172A);
  static const lightSelected = Color(0x0F0F172A);

  static const lightGlass = Color(0xCCFFFFFF);
  static const lightOverlay = Color(0x660F172A);
  static const lightShimmerBase = Color(0xFFE2E8F0);
  static const lightShimmerHighlight = Color(0xFFF1F5F9);

  // Leaderboard / Medal Colors
  static const gold = Color(0xFFF59E0B);
  static const silver = Color(0xFF94A3B8);
  static const bronze = Color(0xFFD97706);
}
