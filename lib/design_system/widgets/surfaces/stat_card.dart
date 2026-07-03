import 'package:flutter/material.dart';
import '../../colors/app_colors.dart';
import '../../typography/text_styles.dart';
import '../../radius/radius.dart';
import '../../tokens/radius_tokens.dart';
import '../../spacing/spacing_scale.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.trend,
    this.trendValue,
    this.trendUp = true,
    this.onTap,
    this.color,
  });

  final String label;
  final String value;
  final IconData? icon;
  final bool? trend;
  final String? trendValue;
  final bool trendUp;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = color ?? (isDark ? AppColors.card : AppColors.lightCard);
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
                Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 16, color: secColor),
                      SizedBox(width: SpacingScale.s6),
                    ],
                    Expanded(
                      child: Text(
                        label,
                        style: AppTextStyles.caption.copyWith(color: secColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (trend != null && trendValue != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SpacingScale.s6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: (trendUp
                                  ? AppColors.success
                                  : AppColors.danger)
                              .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(RadiusTokens.sm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              trendUp
                                  ? Icons.trending_up_rounded
                                  : Icons.trending_down_rounded,
                              size: 12,
                              color: trendUp
                                  ? AppColors.success
                                  : AppColors.danger,
                            ),
                            SizedBox(width: 2),
                            Text(
                              trendValue!,
                              style: AppTextStyles.captionXs.copyWith(
                                color: trendUp
                                    ? AppColors.success
                                    : AppColors.danger,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                SizedBox(height: SpacingScale.s8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: AppTextStyles.numeric.copyWith(color: textColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
