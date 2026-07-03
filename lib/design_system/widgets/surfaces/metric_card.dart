import 'package:flutter/material.dart';
import '../../colors/app_colors.dart';
import '../../typography/text_styles.dart';
import '../../radius/radius.dart';
import '../../spacing/spacing_scale.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.color,
    this.onTap,
  });

  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = color ?? (isDark ? AppColors.surface : AppColors.lightSurface);
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final secColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.brXl2,
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.brXl2,
          child: Padding(
            padding: SpacingScale.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: AppColors.primary),
                  SizedBox(height: SpacingScale.s10),
                ],
                Text(
                  value,
                  style: AppTextStyles.numericSm.copyWith(color: textColor),
                ),
                SizedBox(height: SpacingScale.s4),
                Text(
                  title,
                  style: AppTextStyles.bodySm.copyWith(color: secColor),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: SpacingScale.s2),
                  Text(
                    subtitle!,
                    style: AppTextStyles.captionXs.copyWith(
                      color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
