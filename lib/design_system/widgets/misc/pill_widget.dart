import 'package:flutter/material.dart';
import '../../colors/app_colors.dart';
import '../../typography/text_styles.dart';
import '../../radius/radius.dart';
import '../../spacing/spacing_scale.dart';

class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    this.onTap,
    this.selected = false,
    this.color,
    this.removable = false,
    this.onRemoved,
  });

  final String label;
  final VoidCallback? onTap;
  final bool selected;
  final Color? color;
  final bool removable;
  final VoidCallback? onRemoved;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = color ?? AppColors.primary;
    final bgColor = selected
        ? accentColor.withValues(alpha: 0.12)
        : (isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary);
    final fgColor = selected
        ? accentColor
        : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary);
    final borderColor = selected
        ? accentColor.withValues(alpha: 0.3)
        : (isDark ? AppColors.border : AppColors.lightBorder);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingScale.s10,
          vertical: SpacingScale.s4,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadius.brFull,
          border: Border.all(color: borderColor, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.labelSm.copyWith(color: fgColor),
            ),
            if (removable) ...[
              SizedBox(width: SpacingScale.s4),
              GestureDetector(
                onTap: onRemoved,
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: fgColor.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AppTag extends StatelessWidget {
  const AppTag({
    super.key,
    required this.label,
    this.color,
    this.onTap,
  });

  final String label;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accentColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingScale.s8,
          vertical: SpacingScale.s2,
        ),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.08),
          borderRadius: AppRadius.brSm,
        ),
        child: Text(
          label,
          style: AppTextStyles.captionXs.copyWith(
            color: accentColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
