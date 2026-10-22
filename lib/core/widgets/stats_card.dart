import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/text_styles.dart';
import '../../design_system/radius/radius.dart';
import '../../design_system/spacing/spacing_scale.dart';

class StatsCard extends StatelessWidget {
  const StatsCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
    this.gradient,
    this.valueColor,
    this.onTap,
    this.trend,
    this.trendValue,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final List<Color>? gradient;
  final Color? valueColor;
  final VoidCallback? onTap;
  final bool? trend;
  final String? trendValue;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final secColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final surfaceColor = isDark ? AppColors.surface : AppColors.lightSurface;

    return Animate(
      effects: [
        FadeEffect(duration: 500.ms),
        SlideEffect(),
      ],
      child: Container(
        padding: const EdgeInsets.all(SpacingScale.s16),
        decoration: gradient != null
            ? BoxDecoration(
                borderRadius: AppRadius.brXl2,
                gradient: LinearGradient(colors: gradient!),
              )
            : BoxDecoration(
                color: surfaceColor,
                borderRadius: AppRadius.brXl2,
                border: Border.all(
                  color: isDark ? AppColors.border : AppColors.lightBorder,
                  width: 0.5,
                ),
              ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 18,
                    color: gradient != null
                        ? Colors.white.withValues(alpha: 0.9)
                        : (iconColor ?? AppColors.primary),
                  ),
                  const SizedBox(width: SpacingScale.s8),
                ],
                Expanded(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.captionXs.copyWith(
                      color: gradient != null
                          ? Colors.white.withValues(alpha: 0.8)
                          : secColor,
                    ),
                  ),
                ),
                if (trend != null && trendValue != null) ...[
                  const SizedBox(width: SpacingScale.s4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: SpacingScale.s6, vertical: 2),
                    decoration: BoxDecoration(
                      color: trend!
                          ? AppColors.success.withValues(alpha: 0.15)
                          : AppColors.danger.withValues(alpha: 0.15),
                      borderRadius: AppRadius.brSm,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          trend! ? Icons.trending_up : Icons.trending_down,
                          size: 12,
                          color: trend!
                              ? AppColors.success
                              : AppColors.danger,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          trendValue!,
                          style: AppTextStyles.captionXs.copyWith(
                            fontSize: 10,
                            color: trend!
                                ? AppColors.success
                                : AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: SpacingScale.s8),
            Text(
              value,
              style: AppTextStyles.numeric.copyWith(
                color: gradient != null
                    ? Colors.white
                    : (valueColor ?? textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
