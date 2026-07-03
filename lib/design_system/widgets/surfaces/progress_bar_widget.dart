import 'package:flutter/material.dart';
import '../../colors/app_colors.dart';
import '../../radius/radius.dart';
import '../../spacing/spacing_scale.dart';
import '../../typography/text_styles.dart';
import '../../tokens/duration_tokens.dart';

class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.value,
    this.max = 1.0,
    this.height = 6,
    this.color,
    this.backgroundColor,
    this.showLabel = false,
    this.animated = true,
  });

  final double value;
  final double max;
  final double height;
  final Color? color;
  final Color? backgroundColor;
  final bool showLabel;
  final bool animated;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = (value / max).clamp(0.0, 1.0);
    final barColor = color ?? AppColors.primary;
    final bgColor = backgroundColor ??
        (isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: SpacingScale.s4),
            child: Row(
              children: [
                Text(
                  '${(progress * 100).round()}%',
                  style: AppTextStyles.captionXs.copyWith(
                    color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: SizedBox(
            height: height,
            child: Stack(
              children: [
                Container(color: bgColor),
                AnimatedFractionallySizedBox(
                  duration: animated ? DurationTokens.slow : Duration.zero,
                  curve: Curves.easeOut,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(height / 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
