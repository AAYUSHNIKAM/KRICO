

enum DeviceType { phone, phoneLarge, tablet, laptop, desktop, ultraWide }

enum ScreenSize { xs, sm, md, lg, xl, xxl }

abstract final class Breakpoints {
  Breakpoints._();

  static const double phoneXs = 320;
  static const double phoneSm = 360;
  static const double phoneMd = 375;
  static const double phoneLg = 390;
  static const double phoneXl = 412;
  static const double tabletSm = 600;
  static const double tabletMd = 768;
  static const double tabletLg = 834;
  static const double laptop = 1024;
  static const double desktop = 1280;
  static const double desktopLg = 1440;
  static const double ultraWide = 1920;

  static DeviceType fromWidth(double width) {
    if (width < tabletSm) return DeviceType.phone;
    if (width < laptop) return DeviceType.tablet;
    if (width < desktop) return DeviceType.laptop;
    if (width < ultraWide) return DeviceType.desktop;
    return DeviceType.ultraWide;
  }

  static ScreenSize sizeFromWidth(double width) {
    if (width < phoneSm) return ScreenSize.xs;
    if (width < phoneXl) return ScreenSize.sm;
    if (width < tabletSm) return ScreenSize.md;
    if (width < laptop) return ScreenSize.lg;
    if (width < ultraWide) return ScreenSize.xl;
    return ScreenSize.xxl;
  }

  static bool isPhone(double width) => width < tabletSm;
  static bool isTablet(double width) => width >= tabletSm && width < laptop;
  static bool isDesktop(double width) => width >= laptop;
  static bool isUltraWide(double width) => width >= ultraWide;

  static double of(double width, {double? phone, double? tablet, double? desktop}) {
    if (isPhone(width)) return phone ?? tablet ?? desktop ?? 0;
    if (isTablet(width)) return tablet ?? desktop ?? 0;
    return desktop ?? 0;
  }
}
