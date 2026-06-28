import 'package:flutter/material.dart';

abstract class AppColors {
  AppColors._();

  static const primary = Color(0xFF3B82F6);
  static const primaryDark = Color(0xFF2563EB);
  static const primaryLight = Color(0xFF60A5FA);

  static const secondary = Color(0xFF14B8A6);
  static const secondaryLight = Color(0xFF2DD4BF);

  static const accent = Color(0xFFF59E0B);
  static const accentLight = Color(0xFFFBBF24);

  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  static const gold = Color(0xFFFFD700);
  static const silver = Color(0xFFC0C0C0);
  static const bronze = Color(0xFFCD7F32);

  static const surfaceDark = Color(0xFF0F172A);
  static const surfaceMid = Color(0xFF1E293B);
  static const cardDark = Color(0xFF1E293B);
  static const cardMid = Color(0xFF334155);

  static const surfaceLight = Color(0xFFF8FAFC);
  static const cardLight = Color(0xFFFFFFFF);

  static const textPrimary = Color(0xFFF8FAFC);
  static const textSecondary = Color(0xFF94A3B8);
  static const textDim = Color(0xFF64748B);

  static const borderLight = Color(0xFF334155);
  static const borderMid = Color(0xFF475569);

  static const shimmerBase = Color(0xFF1E293B);
  static const shimmerHighlight = Color(0xFF334155);

  static const gradientPrimary = [Color(0xFF3B82F6), Color(0xFF2563EB)];
  static const gradientSecondary = [Color(0xFF14B8A6), Color(0xFF0D9488)];
  static const gradientAccent = [Color(0xFFF59E0B), Color(0xFFD97706)];
  static const gradientGold = [Color(0xFFFFD700), Color(0xFFFFA500)];
  static const gradientDark = [Color(0xFF0F172A), Color(0xFF1E293B)];
  static const gradientCard = [Color(0xFF1E293B), Color(0xFF334155)];
  static const gradientPremium = [Color(0xFF667EEA), Color(0xFF764BA2)];
}
