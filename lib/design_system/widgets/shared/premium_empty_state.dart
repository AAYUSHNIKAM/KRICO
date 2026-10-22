import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../colors/app_colors.dart';
import '../../typography/text_styles.dart';
import '../../spacing/spacing_scale.dart';
import '../../radius/radius.dart';

class PremiumEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? accentColor;

  const PremiumEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = accentColor ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(SpacingScale.s32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl2,
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: AppRadius.brXl2,
            ),
            child: Icon(icon, size: 24, color: accent),
          ),
          const SizedBox(height: SpacingScale.s16),
          Text(
            title,
            style: AppTextStyles.title2.copyWith(
              color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SpacingScale.s6),
          Text(
            subtitle,
            style: AppTextStyles.body.copyWith(
              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: SpacingScale.s20),
            ElevatedButton(
              onPressed: onAction,
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
    ).animate().fadeIn(duration: 300.ms, curve: Curves.easeOut).slideY(begin: 0.04, end: 0);
  }
}
