import 'package:flutter/material.dart';
import '../../colors/app_colors.dart';

enum AvatarSize { xs, sm, md, lg, xl }

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = AvatarSize.md,
    this.onTap,
    this.border,
    this.online,
  });

  final String? imageUrl;
  final String? name;
  final AvatarSize size;
  final VoidCallback? onTap;
  final bool? border;
  final bool? online;

  double get _dimension => switch (size) {
        AvatarSize.xs => 24,
        AvatarSize.sm => 32,
        AvatarSize.md => 44,
        AvatarSize.lg => 56,
        AvatarSize.xl => 72,
      };

  double get _fontSize => switch (size) {
        AvatarSize.xs => 10,
        AvatarSize.sm => 12,
        AvatarSize.md => 16,
        AvatarSize.lg => 20,
        AvatarSize.xl => 28,
      };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget avatar;
    if (imageUrl != null) {
      avatar = Container(
        width: _dimension,
        height: _dimension,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: border == true
              ? Border.all(
                  color: isDark ? AppColors.border : AppColors.lightBorder,
                  width: 1.5,
                )
              : null,
        ),
        child: ClipOval(
          child: Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildInitials(isDark),
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return Container(
                color: isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary,
              );
            },
          ),
        ),
      );
    } else {
      avatar = _buildInitials(isDark);
    }

    final widget = SizedBox(
      width: _dimension,
      height: _dimension,
      child: Stack(
        children: [
          avatar,
          if (online != null)
            Positioned(
              right: 1,
              bottom: 1,
              child: Container(
                width: _dimension * 0.28,
                height: _dimension * 0.28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: online! ? AppColors.success : AppColors.textDisabled,
                  border: Border.all(
                    color: isDark ? AppColors.card : AppColors.lightCard,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: widget);
    }
    return widget;
  }

  Widget _buildInitials(bool isDark) {
    final initials = _getInitials();
    return Container(
      width: _dimension,
      height: _dimension,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary,
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: _fontSize,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
          ),
        ),
      ),
    );
  }

  String _getInitials() {
    if (name == null || name!.isEmpty) return '?';
    final parts = name!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name![0].toUpperCase();
  }
}
