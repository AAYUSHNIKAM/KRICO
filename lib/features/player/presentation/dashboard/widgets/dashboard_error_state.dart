import 'package:flutter/material.dart';
import '../../../../../design_system/colors/app_colors.dart';
import '../../../../../design_system/typography/text_styles.dart';
import '../../../../../design_system/spacing/spacing_scale.dart';
import '../../../../../design_system/radius/radius.dart';
import '../../../../../design_system/widgets/buttons/outline_button.dart';

class DashboardErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const DashboardErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(SpacingScale.s24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl2,
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.1),
              borderRadius: AppRadius.brXl2,
            ),
            child: const Icon(Icons.error_outline_rounded, size: 22, color: AppColors.danger),
          ),
          const SizedBox(height: SpacingScale.s12),
          Text(
            message,
            style: AppTextStyles.body.copyWith(
              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: SpacingScale.s16),
            OutlineButton(
              onPressed: onRetry,
              label: 'Retry',
            ),
          ],
        ],
      ),
    );
  }
}
