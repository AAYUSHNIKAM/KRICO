import 'package:flutter/material.dart';
import '../../colors/app_colors.dart';
import '../../typography/text_styles.dart';
import '../../radius/radius.dart';
import '../../spacing/spacing_scale.dart';

enum BadgeVariant { primary, success, warning, danger, info, neutral }
enum BadgeSize { sm, md }

class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.variant = BadgeVariant.neutral,
    this.size = BadgeSize.sm,
    this.dot = false,
    this.outlined = false,
  });

  final String label;
  final BadgeVariant variant;
  final BadgeSize size;
  final bool dot;
  final bool outlined;

  Color _bgColor(bool isDark) => switch (variant) {
        BadgeVariant.primary => AppColors.primary.withValues(alpha: 0.12),
        BadgeVariant.success => AppColors.success.withValues(alpha: 0.12),
        BadgeVariant.warning => AppColors.warning.withValues(alpha: 0.12),
        BadgeVariant.danger => AppColors.danger.withValues(alpha: 0.12),
        BadgeVariant.info => AppColors.primary.withValues(alpha: 0.12),
        BadgeVariant.neutral => isDark
            ? AppColors.surfaceSecondary
            : AppColors.lightSurfaceSecondary,
      };

  Color _fgColor(bool isDark) => switch (variant) {
        BadgeVariant.primary => AppColors.primary,
        BadgeVariant.success => AppColors.success,
        BadgeVariant.warning => AppColors.warning,
        BadgeVariant.danger => AppColors.danger,
        BadgeVariant.info => AppColors.primary,
        BadgeVariant.neutral => isDark
            ? AppColors.textSecondary
            : AppColors.lightTextSecondary,
      };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = outlined ? Colors.transparent : _bgColor(isDark);
    final fgColor = _fgColor(isDark);
    final hPad = size == BadgeSize.sm ? SpacingScale.s6 : SpacingScale.s8;
    final vPad = size == BadgeSize.sm ? 2.0 : 4.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.brFull,
        border: outlined
            ? Border.all(color: fgColor.withValues(alpha: 0.3), width: 0.5)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: fgColor,
              ),
            ),
            SizedBox(width: SpacingScale.s4),
          ],
          Text(
            label,
            style: (size == BadgeSize.sm ? AppTextStyles.labelSm : AppTextStyles.label)
                .copyWith(color: fgColor),
          ),
        ],
      ),
    );
  }
}

class NotificationBadge extends StatelessWidget {
  const NotificationBadge({
    super.key,
    required this.count,
    this.color,
    this.size = 18,
  });

  final int count;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? AppColors.danger,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: TextStyle(
            fontSize: size * 0.5,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            height: 1,
          ),
        ),
      ),
    );
  }
}
