import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

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
    return Animate(
      effects: [
        FadeEffect(duration: 500.ms),
        SlideEffect(),
      ],
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: gradient != null
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(colors: gradient!),
                  )
                : null,
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
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          color: gradient != null
                              ? Colors.white.withValues(alpha: 0.8)
                              : (isDark
                                  ? AppColors.textSecondary
                                  : AppColors.textSecondary),
                        ),
                      ),
                    ),
                    if (trend != null && trendValue != null) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: trend!
                              ? AppColors.success.withValues(alpha: 0.15)
                              : AppColors.error.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              trend! ? Icons.trending_up : Icons.trending_down,
                              size: 12,
                              color: trend!
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              trendValue!,
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 10,
                                color: trend!
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: (gradient != null
                          ? AppTextStyles.numberMetric.copyWith(
                              color: Colors.white,
                            )
                          : AppTextStyles.numberMetric.copyWith(
                              color: valueColor ?? AppColors.textPrimary,
                            )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
