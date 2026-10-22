import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Semantic color scheme providing theme-aware tokens for both Dark & Light modes.
@immutable
class AppColorScheme extends ThemeExtension<AppColorScheme> {
  const AppColorScheme({
    required this.background,
    required this.surface,
    required this.surfaceSecondary,
    required this.surfaceElevated,
    required this.card,
    required this.border,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.primary,
    required this.primaryHover,
    required this.success,
    required this.warning,
    required this.danger,
    required this.accentVolt,
    required this.accentCyan,
    required this.heroCtaBackground,
    required this.heroCtaForeground,
    required this.cardBorderSubtle,
    required this.glassSurface,
    required this.gold,
    required this.silver,
    required this.bronze,
    required this.shimmerBase,
    required this.shimmerHighlight,
  });

  final Color background;
  final Color surface;
  final Color surfaceSecondary;
  final Color surfaceElevated;
  final Color card;
  final Color border;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;
  final Color primary;
  final Color primaryHover;
  final Color success;
  final Color warning;
  final Color danger;
  final Color accentVolt;
  final Color accentCyan;
  final Color heroCtaBackground;
  final Color heroCtaForeground;
  final Color cardBorderSubtle;
  final Color glassSurface;
  final Color gold;
  final Color silver;
  final Color bronze;
  final Color shimmerBase;
  final Color shimmerHighlight;

  static const dark = AppColorScheme(
    background: AppColors.background,
    surface: AppColors.surface,
    surfaceSecondary: AppColors.surfaceSecondary,
    surfaceElevated: AppColors.surfaceElevated,
    card: AppColors.card,
    border: AppColors.border,
    divider: AppColors.divider,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textTertiary: AppColors.textTertiary,
    textDisabled: AppColors.textDisabled,
    primary: AppColors.primary,
    primaryHover: AppColors.primaryHover,
    success: AppColors.success,
    warning: AppColors.warning,
    danger: AppColors.danger,
    accentVolt: Color(0xFFCCFF00),
    accentCyan: Color(0xFF00E5FF),
    heroCtaBackground: Color(0xFFCCFF00),
    heroCtaForeground: Color(0xFF090A0F),
    cardBorderSubtle: Color(0x14FFFFFF),
    glassSurface: AppColors.glass,
    gold: AppColors.gold,
    silver: AppColors.silver,
    bronze: AppColors.bronze,
    shimmerBase: AppColors.shimmerBase,
    shimmerHighlight: AppColors.shimmerHighlight,
  );

  static const light = AppColorScheme(
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    surfaceSecondary: AppColors.lightSurfaceSecondary,
    surfaceElevated: AppColors.lightSurfaceElevated,
    card: AppColors.lightCard,
    border: AppColors.lightBorder,
    divider: AppColors.lightDivider,
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    textTertiary: AppColors.lightTextTertiary,
    textDisabled: AppColors.lightTextDisabled,
    primary: AppColors.primary,
    primaryHover: AppColors.primaryHover,
    success: AppColors.success,
    warning: AppColors.warning,
    danger: AppColors.danger,
    accentVolt: Color(0xFF4D7C0F),
    accentCyan: Color(0xFF0284C7),
    heroCtaBackground: Color(0xFF0F172A),
    heroCtaForeground: Color(0xFFFFFFFF),
    cardBorderSubtle: AppColors.lightBorder,
    glassSurface: AppColors.lightGlass,
    gold: AppColors.gold,
    silver: AppColors.silver,
    bronze: AppColors.bronze,
    shimmerBase: AppColors.lightShimmerBase,
    shimmerHighlight: AppColors.lightShimmerHighlight,
  );

  @override
  AppColorScheme copyWith({
    Color? background,
    Color? surface,
    Color? surfaceSecondary,
    Color? surfaceElevated,
    Color? card,
    Color? border,
    Color? divider,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? primary,
    Color? primaryHover,
    Color? success,
    Color? warning,
    Color? danger,
    Color? accentVolt,
    Color? accentCyan,
    Color? heroCtaBackground,
    Color? heroCtaForeground,
    Color? cardBorderSubtle,
    Color? glassSurface,
    Color? gold,
    Color? silver,
    Color? bronze,
    Color? shimmerBase,
    Color? shimmerHighlight,
  }) {
    return AppColorScheme(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      card: card ?? this.card,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textDisabled: textDisabled ?? this.textDisabled,
      primary: primary ?? this.primary,
      primaryHover: primaryHover ?? this.primaryHover,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      accentVolt: accentVolt ?? this.accentVolt,
      accentCyan: accentCyan ?? this.accentCyan,
      heroCtaBackground: heroCtaBackground ?? this.heroCtaBackground,
      heroCtaForeground: heroCtaForeground ?? this.heroCtaForeground,
      cardBorderSubtle: cardBorderSubtle ?? this.cardBorderSubtle,
      glassSurface: glassSurface ?? this.glassSurface,
      gold: gold ?? this.gold,
      silver: silver ?? this.silver,
      bronze: bronze ?? this.bronze,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
    );
  }

  @override
  AppColorScheme lerp(ThemeExtension<AppColorScheme>? other, double t) {
    if (other is! AppColorScheme) return this;
    return AppColorScheme(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSecondary: Color.lerp(surfaceSecondary, other.surfaceSecondary, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      card: Color.lerp(card, other.card, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryHover: Color.lerp(primaryHover, other.primaryHover, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      accentVolt: Color.lerp(accentVolt, other.accentVolt, t)!,
      accentCyan: Color.lerp(accentCyan, other.accentCyan, t)!,
      heroCtaBackground: Color.lerp(heroCtaBackground, other.heroCtaBackground, t)!,
      heroCtaForeground: Color.lerp(heroCtaForeground, other.heroCtaForeground, t)!,
      cardBorderSubtle: Color.lerp(cardBorderSubtle, other.cardBorderSubtle, t)!,
      glassSurface: Color.lerp(glassSurface, other.glassSurface, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      silver: Color.lerp(silver, other.silver, t)!,
      bronze: Color.lerp(bronze, other.bronze, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
    );
  }
}
