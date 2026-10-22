import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/text_styles.dart';

/// A clickable user avatar. Displays the user's photo when available,
/// otherwise their initials. Tapping opens the public profile page
/// (`/profile/:userId`) unless [readOnly] is true or a custom [onTap]
/// is provided.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.userId,
    this.name,
    this.photoUrl,
    this.size = 40,
    this.radius,
    this.backgroundColor,
    this.textColor,
    this.onTap,
    this.readOnly = false,
  });

  final String userId;
  final String? name;
  final String? photoUrl;
  final double size;
  final double? radius;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTap;
  final bool readOnly;

  static String initials(String? name) {
    final n = (name ?? '').trim();
    if (n.isEmpty) return '?';
    final parts = n.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.primary;
    final fgColor = textColor ?? Colors.white;
    final corner = radius ?? size / 2;

    Widget child;
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;
    if (hasPhoto) {
      child = ClipRRect(
        borderRadius: BorderRadius.circular(corner),
        child: Image.network(
          photoUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildInitials(bgColor, fgColor, corner),
        ),
      );
    } else {
      child = _buildInitials(bgColor, fgColor, corner);
    }

    return GestureDetector(
      onTap: readOnly ? null : (onTap ?? () => context.push('/profile/$userId')),
      child: child,
    );
  }

  Widget _buildInitials(Color bgColor, Color fgColor, double corner) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(corner),
      ),
      child: Text(
        initials(name),
        style: TextStyle(
          color: fgColor,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.36,
        ),
      ),
    );
  }
}

/// A tappable row containing a [UserAvatar] plus the user's name and an
/// optional subtitle. Tapping opens the public profile page.
class UserHeaderTile extends StatelessWidget {
  const UserHeaderTile({
    super.key,
    required this.userId,
    this.name,
    this.subtitle,
    this.photoUrl,
    this.avatarSize = 40,
    this.backgroundColor,
    this.trailing,
    this.onTap,
    this.readOnly = false,
  });

  final String userId;
  final String? name;
  final String? subtitle;
  final String? photoUrl;
  final double avatarSize;
  final Color? backgroundColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: readOnly ? null : (onTap ?? () => context.push('/profile/$userId')),
      child: Row(
        children: [
          UserAvatar(
            userId: userId,
            name: name,
            photoUrl: photoUrl,
            size: avatarSize,
            backgroundColor: backgroundColor,
            readOnly: true,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name ?? 'User',
                  style: AppTextStyles.title2.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
