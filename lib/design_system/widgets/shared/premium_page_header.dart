import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../colors/app_colors.dart';
import '../../typography/text_styles.dart';
import '../../spacing/spacing_scale.dart';
import '../../radius/radius.dart';
import '../../tokens/duration_tokens.dart';

class PremiumPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String name;
  final Widget? trailing;
  final List<Widget>? pills;
  final double? progress;
  final String? progressLabel;
  final Color? progressColor;

  const PremiumPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    required this.name,
    this.trailing,
    this.pills,
    this.progress,
    this.progressLabel,
    this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1024;
    final isTablet = width >= 600 && width < 1024;

    final padH = isDesktop ? SpacingScale.s32 : (isTablet ? SpacingScale.s24 : SpacingScale.s16);
    final padT = isDesktop ? SpacingScale.s48 : (isTablet ? SpacingScale.s40 : SpacingScale.s32);

    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final secColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final barColor = progressColor ?? AppColors.emerald;

    return Container(
      padding: EdgeInsets.fromLTRB(padH, padT, padH, SpacingScale.s24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [AppColors.surface, AppColors.surface.withValues(alpha: 0.95)]
              : [AppColors.lightSurface, AppColors.lightSurface],
        ),
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.border : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (subtitle != null)
                      Text(
                        subtitle!.toUpperCase(),
                        style: AppTextStyles.captionXs.copyWith(
                          color: secColor,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 200.ms, curve: Curves.easeOut)
                          .slideY(begin: -0.04, end: 0),
                    const SizedBox(height: SpacingScale.s12),
                    Text(
                      '$title,',
                      style: AppTextStyles.title2.copyWith(color: secColor),
                    )
                        .animate(delay: 50.ms)
                        .fadeIn(duration: 250.ms, curve: Curves.easeOut)
                        .slideY(begin: -0.04, end: 0),
                    const SizedBox(height: SpacingScale.s2),
                    Text(
                      name,
                      style: AppTextStyles.heading1.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                        .animate(delay: 100.ms)
                        .fadeIn(duration: 300.ms, curve: Curves.easeOut)
                        .slideY(begin: -0.04, end: 0),
                  ],
                ),
              ),
              const SizedBox(width: SpacingScale.s16),
              if (trailing != null)
                trailing!
                    .animate(delay: 100.ms)
                    .fadeIn(duration: 300.ms)
                    .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
            ],
          ),
          if (pills != null && pills!.isNotEmpty) ...[
            const SizedBox(height: SpacingScale.s20),
            Row(
              children: [
                for (int i = 0; i < pills!.length; i++) ...[
                  if (i > 0) const SizedBox(width: SpacingScale.s8),
                  pills![i],
                ],
              ],
            ).animate(delay: 150.ms).fadeIn(duration: 300.ms, curve: Curves.easeOut),
          ],
          if (progress != null) ...[
            const SizedBox(height: SpacingScale.s24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: AppRadius.brFull,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress!),
                    duration: DurationTokens.long,
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: 6,
                      backgroundColor: isDark ? AppColors.divider : AppColors.lightDivider,
                      valueColor: AlwaysStoppedAnimation<Color>(barColor),
                    ),
                  ),
                ),
                if (progressLabel != null) ...[
                  const SizedBox(height: SpacingScale.s6),
                  Text(
                    progressLabel!,
                    style: AppTextStyles.captionXs.copyWith(
                      color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                    ),
                  ),
                ],
              ],
            )
                .animate(delay: 200.ms)
                .fadeIn(duration: 350.ms, curve: Curves.easeOut)
                .slideY(begin: 0.06, end: 0),
          ],
        ],
      ),
    );
  }
}
