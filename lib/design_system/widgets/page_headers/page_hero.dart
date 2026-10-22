import 'package:flutter/material.dart';
import '../../colors/app_colors.dart';
import '../../responsive/responsive_helpers.dart';
import '../../spacing/spacing_scale.dart';
import '../../typography/text_styles.dart';

/// Shared page header sliver.
///
/// - **Desktop / tablet**: renders the tall gradient/solid hero with the page
///   title (and optional subtitle / extra content).
/// - **Phone**: renders nothing by default ([showPhoneHeader] == false) because
///   the [PremiumShell]'s slim AppBar already shows the page title; when
///   [showPhoneHeader] is true (pushed routes without a shell) it renders a
///   slim surface-toned pinned header with the title and an automatic back
///   button.
class PageHero extends StatelessWidget {
  const PageHero({
    super.key,
    required this.title,
    this.subtitle,
    this.expandedHeight = 180,
    this.stretch = true,
    this.backgroundColor,
    this.gradientColors,
    this.heroExtra,
    this.actions,
    this.phoneActions,
    this.titleColor,
    this.subtitleColor,
    this.showPhoneHeader = false,
    this.phoneTitle,
  });

  final String title;
  final String? subtitle;
  final double expandedHeight;
  final bool stretch;
  final Color? backgroundColor;
  final List<Color>? gradientColors;
  final List<Widget>? heroExtra;
  final List<Widget>? actions;
  final List<Widget>? phoneActions;
  final Color? titleColor;
  final Color? subtitleColor;
  final bool showPhoneHeader;
  final String? phoneTitle;

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      if (!showPhoneHeader) return const SliverToBoxAdapter(child: SizedBox.shrink());
      return _buildPhoneHeader(context);
    }
    return _buildHero(context);
  }

  Widget _buildPhoneHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SliverAppBar(
      pinned: true,
      toolbarHeight: 72,
      backgroundColor: isDark ? AppColors.surface : AppColors.lightSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: Border(
        bottom: BorderSide(
          color: isDark ? AppColors.border : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      title: Text(
        phoneTitle ?? title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.title1.copyWith(
          color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: phoneActions,
    );
  }

  Widget _buildHero(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      stretch: stretch,
      actions: actions,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            gradient: gradientColors != null
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors!,
                  )
                : (backgroundColor != null
                    ? null
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          isDark ? AppColors.surface : AppColors.lightSurface,
                        ],
                      )),
          ),
          padding: EdgeInsets.fromLTRB(
            SpacingScale.s20,
            60,
            SpacingScale.s20,
            SpacingScale.s20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                title,
                style: AppTextStyles.heading2.copyWith(
                  color: titleColor ?? Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: SpacingScale.s4),
                Text(
                  subtitle!,
                  style: AppTextStyles.body.copyWith(
                      color: subtitleColor ?? Colors.white70),
                ),
              ],
              if (heroExtra != null) ...heroExtra!,
            ],
          ),
        ),
      ),
    );
  }
}
