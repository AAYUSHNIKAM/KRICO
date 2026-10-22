import 'package:flutter/material.dart';
import 'breakpoints.dart';
import '../tokens/spacing_tokens.dart';

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  double get screenShortestSide => MediaQuery.sizeOf(this).shortestSide;
  bool get isPhone => Breakpoints.isPhone(screenWidth);
  bool get isTablet => Breakpoints.isTablet(screenWidth);
  bool get isDesktop => Breakpoints.isDesktop(screenWidth);
  bool get isUltraWide => Breakpoints.isUltraWide(screenWidth);
  bool get isLandscape => MediaQuery.orientationOf(this) == Orientation.landscape;
  bool get isPortrait => MediaQuery.orientationOf(this) == Orientation.portrait;
  DeviceType get deviceType => Breakpoints.fromWidth(screenWidth);

  double responsiveValue<T>({T? phone, T? tablet, T? desktop}) {
    if (isPhone) return (phone ?? tablet ?? desktop ?? 0) as double;
    if (isTablet) return (tablet ?? desktop ?? 0) as double;
    return (desktop ?? 0) as double;
  }

  EdgeInsets responsivePadding({
    EdgeInsets? phone,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    if (isPhone) return phone ?? const EdgeInsets.all(SpacingTokens.xl2);
    if (isTablet) return tablet ?? const EdgeInsets.all(SpacingTokens.xl4);
    return desktop ?? const EdgeInsets.all(SpacingTokens.xl6);
  }

  EdgeInsets responsiveScreenPadding() {
    if (isPhone) return const EdgeInsets.symmetric(horizontal: SpacingTokens.xl2);
    if (isTablet) return const EdgeInsets.symmetric(horizontal: SpacingTokens.xl4);
    return const EdgeInsets.symmetric(horizontal: SpacingTokens.xl6);
  }

  double responsiveSpacing(double phone, {double? tablet, double? desktop}) {
    if (isPhone) return phone;
    if (isTablet) return tablet ?? phone * 1.5;
    return desktop ?? phone * 2;
  }

  double get gridColumns => isPhone ? 4 : (isTablet ? 8 : 12);
  double get gridGutter => responsiveSpacing(SpacingTokens.xl2);
  double get contentMaxWidth => isDesktop ? (isUltraWide ? 1440 : 1200) : double.infinity;
}

extension ResponsiveNum on num {
  double w(BuildContext context) => context.screenWidth * (this / 100);
  double h(BuildContext context) => context.screenHeight * (this / 100);
}

extension ResponsiveSizing on double {
  double scale(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return this * (width / 375);
  }
}
