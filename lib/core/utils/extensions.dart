import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1200;
  bool get isDesktop => screenWidth >= 1200;
  bool get isDarkMode => theme.brightness == Brightness.dark;
  ScaffoldMessengerState get showSnackBar => ScaffoldMessenger.of(this);
  NavigatorState get navigator => Navigator.of(this);
}

extension StringExtensions on String {
  String get capitalize => '${this[0].toUpperCase()}${substring(1)}';
  String get titleCase => split(' ').map((w) => w.capitalize).join(' ');
  String get initials => split(' ').where((w) => w.isNotEmpty).map((w) => w[0]).take(2).join().toUpperCase();
  bool get isValidEmail => RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(this);
  bool get isValidPhone => RegExp(r'^[0-9]{10,15}$').hasMatch(this);
  String truncate(int maxLength) => length > maxLength ? '${substring(0, maxLength)}...' : this;
  String get toTitleCase => replaceAll(RegExp(r'[_-]'), ' ').titleCase;
}

extension DateTimeExtensions on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    return isAfter(weekStart) && isBefore(weekEnd);
  }

  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }
}

extension NumberExtensions on num {
  String get formatCompact {
    if (this >= 10000000) return '${(this / 10000000).toStringAsFixed(1)}Cr';
    if (this >= 100000) return '${(this / 100000).toStringAsFixed(1)}L';
    if (this >= 1000) return '${(this / 1000).toStringAsFixed(1)}K';
    return toString();
  }

  Duration get seconds => Duration(seconds: toInt());
  Duration get minutes => Duration(minutes: toInt());
  Duration get hours => Duration(hours: toInt());
  Duration get days => Duration(days: toInt());
}

extension WidgetExtensions on Widget {
  Padding paddingAll(double value) => Padding(padding: EdgeInsets.all(value), child: this);
  Padding paddingSymmetric({double horizontal = 0, double vertical = 0}) =>
      Padding(padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical), child: this);
  Padding paddingOnly({double left = 0, double top = 0, double right = 0, double bottom = 0}) =>
      Padding(padding: EdgeInsets.only(left: left, top: top, right: right, bottom: bottom), child: this);
  Center get center => Center(child: this);
  Expanded expanded({int flex = 1}) => Expanded(flex: flex, child: this);
  SliverToBoxAdapter get sliver => SliverToBoxAdapter(child: this);
}
