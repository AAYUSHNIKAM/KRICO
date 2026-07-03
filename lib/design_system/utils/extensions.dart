import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../spacing/spacing_scale.dart';
import '../tokens/spacing_tokens.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get width => mediaQuery.size.width;
  double get height => mediaQuery.size.height;
  bool get isDark => theme.brightness == Brightness.dark;

  Color get primaryColor => AppColors.primary;
  Color get surfaceColor => isDark ? AppColors.surface : AppColors.lightSurface;
  Color get cardColor => isDark ? AppColors.card : AppColors.lightCard;
  Color get textPrimaryColor => isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
  Color get textSecondaryColor => isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
  Color get textTertiaryColor => isDark ? AppColors.textTertiary : AppColors.lightTextTertiary;
  Color get borderColor => isDark ? AppColors.border : AppColors.lightBorder;
  Color get dividerColor => isDark ? AppColors.divider : AppColors.lightDivider;
}

extension WidgetPadding on Widget {
  Widget paddingAll(double value) => Padding(padding: EdgeInsets.all(value), child: this);
  Widget paddingH(double value) => Padding(padding: EdgeInsets.symmetric(horizontal: value), child: this);
  Widget paddingV(double value) => Padding(padding: EdgeInsets.symmetric(vertical: value), child: this);
  Widget paddingOnly({double? l, double? t, double? r, double? b}) =>
      Padding(
        padding: EdgeInsets.only(
          left: l ?? 0,
          top: t ?? 0,
          right: r ?? 0,
          bottom: b ?? 0,
        ),
        child: this,
      );

  Widget paddingStandard() =>
      Padding(padding: const EdgeInsets.all(SpacingTokens.xl2), child: this);

  Widget paddingScreen() =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xl2),
        child: this,
      );
}

extension WidgetSliver on Widget {
  Widget sliver() => SliverToBoxAdapter(child: this);
}
