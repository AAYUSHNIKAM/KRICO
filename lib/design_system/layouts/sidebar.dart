import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../typography/text_styles.dart';
import '../radius/radius.dart';
import '../spacing/spacing_scale.dart';

class SidebarTile extends StatelessWidget {
  const SidebarTile({
    super.key,
    required this.icon,
    required this.label,
    this.selected = false,
    this.onTap,
    this.trailing,
    this.badge,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? trailing;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = selected
        ? (isDark ? AppColors.selected : AppColors.lightSelected)
        : Colors.transparent;
    final fgColor = selected
        ? AppColors.primary
        : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary);
    final textColor = selected
        ? (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary)
        : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s8, vertical: 2),
      child: Material(
        color: bgColor,
        borderRadius: AppRadius.brMd,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.brMd,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingScale.s10,
              vertical: SpacingScale.s8,
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: fgColor),
                SizedBox(width: SpacingScale.s12),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.body.copyWith(
                      color: textColor,
                      fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingScale.s6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: AppRadius.brFull,
                    ),
                    child: Text(
                      badge!,
                      style: AppTextStyles.captionXs.copyWith(color: AppColors.primary),
                    ),
                  ),
                ?trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DesktopSidebar extends StatelessWidget {
  const DesktopSidebar({
    super.key,
    required this.children,
    this.header,
    this.footer,
    this.width = 240,
    this.title,
    this.logo,
  });

  final List<Widget> children;
  final Widget? header;
  final Widget? footer;
  final double width;
  final String? title;
  final Widget? logo;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        border: Border(
          right: BorderSide(
            color: isDark ? AppColors.border : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          if (header != null || title != null)
            Container(
              padding: const EdgeInsets.all(SpacingScale.s16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.border : AppColors.lightBorder,
                    width: 0.5,
                  ),
                ),
              ),
              child: header ??
                  Row(
                    children: [
                      if (logo != null) ...[logo!, SizedBox(width: SpacingScale.s10)],
                      Text(
                        title ?? '',
                        style: AppTextStyles.title2.copyWith(
                          color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: SpacingScale.s8),
              children: children,
            ),
          ),
          if (footer != null)
            Container(
              padding: const EdgeInsets.all(SpacingScale.s12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.border : AppColors.lightBorder,
                    width: 0.5,
                  ),
                ),
              ),
              child: footer,
            ),
        ],
      ),
    );
  }
}
