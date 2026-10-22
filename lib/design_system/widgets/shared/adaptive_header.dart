import 'package:flutter/material.dart';
import '../../colors/app_colors.dart';
import '../../typography/text_styles.dart';
import '../../spacing/spacing_scale.dart';
import '../../radius/radius.dart';

class AdaptiveHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBack;
  final EdgeInsetsGeometry? padding;

  const AdaptiveHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.showBackButton = false,
    this.onBack,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final canPop = Navigator.canPop(context);

    return Padding(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: SpacingScale.s16,
            vertical: SpacingScale.s12,
          ),
      child: Row(
        children: [
          if (showBackButton && canPop)
            Padding(
              padding: const EdgeInsets.only(right: SpacingScale.s12),
              child: IconButton.filledTonal(
                icon: const Icon(Icons.arrow_back_rounded, size: 20),
                onPressed: onBack ?? () => Navigator.of(context).pop(),
                style: IconButton.styleFrom(
                  backgroundColor: isDark
                      ? AppColors.surfaceElevated
                      : AppColors.lightSurfaceSecondary,
                  foregroundColor: textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.brLg,
                    side: BorderSide(
                      color: isDark ? AppColors.border : AppColors.lightBorder,
                      width: 0.5,
                    ),
                  ),
                ),
              ),
            )
          else if (leading != null)
            Padding(
              padding: const EdgeInsets.only(right: SpacingScale.s12),
              child: leading!,
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTextStyles.title1.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: SpacingScale.s2),
                  Text(
                    subtitle!,
                    style: AppTextStyles.captionXs.copyWith(
                      color: textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (actions != null && actions!.isNotEmpty)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: actions!,
            ),
        ],
      ),
    );
  }
}
