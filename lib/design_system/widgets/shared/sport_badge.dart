import 'package:flutter/material.dart';
import '../../colors/app_colors.dart';
import '../../typography/text_styles.dart';
import '../../spacing/spacing_scale.dart';
import '../../radius/radius.dart';

enum SportBadgeType {
  volt,
  cyan,
  success,
  warning,
  danger,
  neutral,
}

class SportBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final SportBadgeType type;
  final bool isLive;

  const SportBadge({
    super.key,
    required this.label,
    this.icon,
    this.type = SportBadgeType.neutral,
    this.isLive = false,
  });

  const SportBadge.live({
    super.key,
    required this.label,
    this.icon,
  })  : type = SportBadgeType.danger,
        isLive = true;

  const SportBadge.verified({
    super.key,
    this.label = 'VERIFIED',
    this.icon = Icons.verified_rounded,
  })  : type = SportBadgeType.cyan,
        isLive = false;

  const SportBadge.pro({
    super.key,
    this.label = 'PRO',
    this.icon = Icons.bolt_rounded,
  })  : type = SportBadgeType.volt,
        isLive = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color primaryColor = switch (type) {
      SportBadgeType.volt => isDark ? AppColors.volt : AppColors.voltDark,
      SportBadgeType.cyan => isDark ? AppColors.cyan : AppColors.cyanDark,
      SportBadgeType.success => isDark ? AppColors.successLight : AppColors.success,
      SportBadgeType.warning => isDark ? AppColors.warningLight : AppColors.warning,
      SportBadgeType.danger => isDark ? AppColors.dangerLight : AppColors.danger,
      SportBadgeType.neutral => isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
    };

    final Color bgColor = isDark
        ? primaryColor.withValues(alpha: 0.12)
        : primaryColor.withValues(alpha: 0.08);

    final Color borderColor = isDark
        ? primaryColor.withValues(alpha: 0.3)
        : primaryColor.withValues(alpha: 0.25);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingScale.s8,
        vertical: SpacingScale.s4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.brFull,
        border: Border.all(color: borderColor, width: 0.75),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLive) ...[
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: SpacingScale.s4),
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ] else if (icon != null) ...[
            Icon(icon, size: 12, color: primaryColor),
            const SizedBox(width: SpacingScale.s4),
          ],
          Text(
            label,
            style: AppTextStyles.captionXs.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
