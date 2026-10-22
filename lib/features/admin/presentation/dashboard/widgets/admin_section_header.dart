import 'package:flutter/material.dart';
import '../../../../../design_system/colors/app_colors.dart';
import '../../../../../design_system/typography/text_styles.dart';
import '../../../../../design_system/spacing/spacing_scale.dart';
import '../../../../../design_system/radius/radius.dart';

class AdminSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showViewAll;
  final VoidCallback? onViewAll;

  const AdminSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showViewAll = false,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitleText = subtitle;
    return Row(
      children: [
        Text(
          title,
          style: AppTextStyles.title2.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
          ),
        ),
        if (subtitleText != null) ...[
          SizedBox(width: SpacingScale.s8),
          Text(
            subtitleText,
            style: AppTextStyles.bodySm.copyWith(
              color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
            ),
          ),
        ],
        const Spacer(),
        if (showViewAll)
          GestureDetector(
            onTap: onViewAll,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: SpacingScale.s12, vertical: SpacingScale.s6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: AppRadius.brXl2,
              ),
              child: Text(
                'View All',
                style: AppTextStyles.label.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ),
      ],
    );
  }
}
