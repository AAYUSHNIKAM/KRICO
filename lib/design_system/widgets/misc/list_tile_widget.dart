import 'package:flutter/material.dart';
import '../../colors/app_colors.dart';
import '../../typography/text_styles.dart';
import '../../radius/radius.dart';
import '../../spacing/spacing_scale.dart';
import 'avatar_widget.dart';

class AppListTile extends StatelessWidget {
  const AppListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.padding,
    this.selected = false,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = selected
        ? (isDark ? AppColors.selected : AppColors.lightSelected)
        : Colors.transparent;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final secColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.brMd,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.brMd,
          child: Padding(
            padding: padding ?? SpacingScale.listItem,
            child: Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  SizedBox(width: SpacingScale.s12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.body.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: SpacingScale.s2),
                        Text(
                          subtitle!,
                          style: AppTextStyles.caption.copyWith(color: secColor),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  SizedBox(width: SpacingScale.s12),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileTile extends StatelessWidget {
  const ProfileTile({
    super.key,
    required this.name,
    required this.subtitle,
    this.imageUrl,
    this.onTap,
    this.trailing,
    this.size = AvatarSize.md,
  });

  final String name;
  final String subtitle;
  final String? imageUrl;
  final VoidCallback? onTap;
  final Widget? trailing;
  final AvatarSize size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppListTile(
      title: name,
      subtitle: subtitle,
      onTap: onTap,
      trailing: trailing ??
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
          ),
      leading: AppAvatar(
        imageUrl: imageUrl,
        name: name,
        size: size,
      ),
    );
  }
}
