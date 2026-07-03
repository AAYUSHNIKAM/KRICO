import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../colors/app_colors.dart';
import '../typography/text_styles.dart';
import '../radius/radius.dart';
import '../spacing/spacing_scale.dart';
import '../tokens/duration_tokens.dart';
import '../icons/app_icons.dart';
import '../widgets/buttons/icon_button_widget.dart';

class PremiumTopBar extends ConsumerStatefulWidget {
  const PremiumTopBar({
    super.key,
    this.onMenuTap,
    this.title,
  });

  final VoidCallback? onMenuTap;
  final String? title;

  @override
  ConsumerState<PremiumTopBar> createState() => _PremiumTopBarState();
}

class _PremiumTopBarState extends ConsumerState<PremiumTopBar> {
  bool _searchFocused = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(color: borderColor, width: 0.5),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s16),
          child: Row(
            children: [
              if (widget.onMenuTap != null)
                Padding(
                  padding: const EdgeInsets.only(right: SpacingScale.s12),
                  child: AppIconButton(
                    icon: AppIcons.menu,
                    onPressed: widget.onMenuTap,
                    size: 36,
                  ),
                ),
              if (widget.title != null) ...[
                Text(
                  widget.title!,
                  style: AppTextStyles.title1.copyWith(color: textColor),
                ),
                const Spacer(),
              ],
              Expanded(
                child: _buildSearchBar(isDark, textColor),
              ),
              const SizedBox(width: SpacingScale.s8),
              _buildNotificationButton(isDark),
              const SizedBox(width: SpacingScale.s4),
              _buildProfileAvatar(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark, Color textColor) {
    final bgColor = isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary;
    final hintColor = isDark ? AppColors.textTertiary : AppColors.lightTextTertiary;

    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      height: 44,
      child: AnimatedContainer(
        duration: DurationTokens.medium,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadius.brLg,
          border: Border.all(
            color: _searchFocused ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Focus(
          onFocusChange: (v) => setState(() => _searchFocused = v),
          child: TextField(
            style: AppTextStyles.body.copyWith(color: textColor),
            decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: AppTextStyles.body.copyWith(color: hintColor),
              prefixIcon: Icon(AppIcons.search, size: 18, color: hintColor),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: SpacingScale.s12,
                vertical: SpacingScale.s10,
              ),
              isDense: true,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationButton(bool isDark) {
    return Stack(
      children: [
        AppIconButton(
          icon: AppIcons.notifications,
          onPressed: () {},
          size: 36,
          outlined: true,
        ),
        Positioned(
          top: 6,
          right: 6,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.danger,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileAvatar(bool isDark) {
    return AppIconButton(
      icon: AppIcons.person,
      onPressed: () {},
      size: 36,
      backgroundColor: isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary,
    );
  }
}
