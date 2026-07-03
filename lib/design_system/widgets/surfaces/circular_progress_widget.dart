import 'package:flutter/material.dart';
import '../../colors/app_colors.dart';
import '../../typography/text_styles.dart';
import '../../tokens/duration_tokens.dart';

class AppCircularProgress extends StatelessWidget {
  const AppCircularProgress({
    super.key,
    this.value,
    this.size = 48,
    this.strokeWidth = 4,
    this.color,
    this.backgroundColor,
    this.showLabel = false,
  });

  final double? value;
  final double size;
  final double strokeWidth;
  final Color? color;
  final Color? backgroundColor;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = color ?? AppColors.primary;
    final bgColor = backgroundColor ??
        (isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: strokeWidth,
              strokeCap: StrokeCap.round,
              color: barColor,
              backgroundColor: bgColor,
            ),
          ),
          if (showLabel && value != null)
            Text(
              '${(value! * 100).round()}%',
              style: AppTextStyles.caption.copyWith(
                color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                fontSize: size * 0.22,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
