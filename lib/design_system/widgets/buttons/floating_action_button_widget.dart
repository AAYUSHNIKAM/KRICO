import 'package:flutter/material.dart';
import '../../colors/app_colors.dart';
import '../../radius/radius.dart';
import '../../spacing/spacing_scale.dart';

class AppFloatingActionButton extends StatelessWidget {
  const AppFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.label,
    this.color,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String? label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = color ?? AppColors.primary;
    final fgColor = AppColors.textInverse;

    if (label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.brXl2),
        icon: Icon(icon, size: 18),
        label: Text(label!, style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        )),
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.brXl2),
      child: Icon(icon, size: 22),
    );
  }
}
