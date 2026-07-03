import 'package:flutter/material.dart';
import '../../colors/app_colors.dart';
import '../../typography/text_styles.dart';
import '../../spacing/spacing_scale.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.actionLabel,
    this.onActionTap,
    this.illustration,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final Widget? illustration;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpacingScale.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (illustration != null)
              illustration!
            else if (icon != null)
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                ),
              ),
            SizedBox(height: SpacingScale.s20),
            Text(
              title,
              style: AppTextStyles.title2.copyWith(
                color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: SpacingScale.s6),
              Text(
                subtitle!,
                style: AppTextStyles.body.copyWith(
                  color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onActionTap != null) ...[
              SizedBox(height: SpacingScale.s20),
              ElevatedButton(
                onPressed: onActionTap,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingScale.s24,
                    vertical: SpacingScale.s10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: Text(actionLabel!, style: AppTextStyles.button),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.title,
    this.subtitle,
    this.onRetry,
    this.icon,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onRetry;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpacingScale.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon ?? Icons.error_outline_rounded,
                size: 28,
                color: AppColors.danger,
              ),
            ),
            SizedBox(height: SpacingScale.s20),
            Text(
              title,
              style: AppTextStyles.title2.copyWith(
                color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: SpacingScale.s6),
              Text(
                subtitle!,
                style: AppTextStyles.body.copyWith(
                  color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              SizedBox(height: SpacingScale.s20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingScale.s24,
                    vertical: SpacingScale.s10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
