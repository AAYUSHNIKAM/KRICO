import 'package:flutter/material.dart';

class PremiumNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final String? badge;
  final bool bottomNavOnly;
  final String section;

  const PremiumNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.badge,
    this.bottomNavOnly = false,
    this.section = 'Workspace',
  });
}
