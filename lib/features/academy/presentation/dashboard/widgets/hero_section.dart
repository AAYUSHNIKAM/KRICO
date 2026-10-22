import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../design_system/colors/app_colors.dart';
import '../../../../../design_system/typography/text_styles.dart';
import '../../../../../design_system/spacing/spacing_scale.dart';
import '../../../../../design_system/radius/radius.dart';
import '../../../../../design_system/responsive/responsive_helpers.dart';
import '../../../../../models/academy_model.dart';

class AcademyHeroSection extends ConsumerWidget {
  final AcademyModel academy;

  const AcademyHeroSection({
    super.key,
    required this.academy,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;
    final isPhone = context.isPhone;
    final padH = isDesktop ? SpacingScale.s32 : (isTablet ? SpacingScale.s24 : SpacingScale.s16);
    final padT = isPhone ? 38.0 : 46.0;

    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final cyanColor = isDark ? AppColors.cyan : AppColors.cyanDark;
    final voltColor = isDark ? AppColors.volt : AppColors.voltDark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.background : AppColors.lightSurface,
        image: const DecorationImage(
          image: AssetImage('assets/backgrounds/stadium_floodlights.jpg'),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.border : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(padH, padT, padH, isPhone ? 18.0 : 26.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    Colors.black.withValues(alpha: 0.65),
                    AppColors.background.withValues(alpha: 0.90),
                    AppColors.background,
                  ]
                : [
                    Colors.white.withValues(alpha: 0.60),
                    AppColors.lightBackground.withValues(alpha: 0.92),
                    AppColors.lightBackground,
                  ],
            stops: const [0.0, 0.65, 1.0],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top HUD Telemetry Row
            Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: cyanColor.withValues(alpha: isDark ? 0.12 : 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: cyanColor.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: cyanColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'ACADEMY HEADQUARTERS',
                        style: TextStyle(
                          color: cyanColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                if (academy.isVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.emerald.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.emerald.withValues(alpha: 0.45)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_rounded, size: 13, color: AppColors.emerald),
                        SizedBox(width: 5),
                        Text(
                          'CERTIFIED FACILITY',
                          style: TextStyle(
                            color: AppColors.emerald,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.hourglass_empty_rounded, size: 12, color: AppColors.warning),
                        SizedBox(width: 5),
                        Text(
                          'VERIFICATION PENDING',
                          style: TextStyle(
                            color: AppColors.warning,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ).animate().fadeIn(duration: 250.ms),
            const SizedBox(height: 16),

            // Main Academy Identity Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00E5FF), Color(0xFF0A66C2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: AppRadius.brXl,
                    boxShadow: [
                      BoxShadow(
                        color: cyanColor.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(2.5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: academy.logoUrl != null && academy.logoUrl!.isNotEmpty
                        ? Image.network(
                            academy.logoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: isDark ? const Color(0xFF141923) : AppColors.lightSurfaceSecondary,
                              child: Icon(Icons.business_rounded, size: 30, color: cyanColor),
                            ),
                          )
                        : Container(
                            color: isDark ? const Color(0xFF141923) : AppColors.lightSurfaceSecondary,
                            child: Icon(Icons.business_rounded, size: 30, color: cyanColor),
                          ),
                  ),
                ).animate(delay: 50.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 300.ms),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        academy.name,
                        style: AppTextStyles.heading1.copyWith(
                          color: textPrimary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ).animate(delay: 100.ms).fadeIn(duration: 300.ms).slideY(begin: -0.04, end: 0),
                      const SizedBox(height: 4),
                      if (academy.sports != null && academy.sports!.isNotEmpty)
                        Text(
                          academy.sports!.join(' • '),
                          style: AppTextStyles.bodySm.copyWith(
                            color: textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ).animate(delay: 150.ms).fadeIn(duration: 250.ms),
                      const SizedBox(height: 8),
                      // Athletic Tags
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          if (academy.city != null && academy.city!.isNotEmpty)
                            _Pill(
                              icon: Icons.location_on_rounded,
                              text: academy.city!,
                              color: cyanColor,
                            ),
                          _Pill(
                            icon: Icons.sports_kabaddi_rounded,
                            text: ' Disciplines',
                            color: voltColor,
                          ),
                        ],
                      ).animate(delay: 180.ms).fadeIn(duration: 250.ms),
                    ],
                  ),
                ),
              ],
            ),

            if (academy.description != null && academy.description!.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceElevated.withValues(alpha: 0.6) : AppColors.lightCard,
                  borderRadius: AppRadius.brLg,
                  border: Border.all(
                    color: isDark ? AppColors.border : AppColors.lightBorder,
                    width: isDark ? 0.5 : 1.0,
                  ),
                  boxShadow: isDark
                      ? null
                      : const [
                          BoxShadow(
                            color: Color(0x0A0F172A),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.format_quote_rounded,
                      size: 16,
                      color: cyanColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        academy.description!,
                        style: AppTextStyles.bodySm.copyWith(
                          color: textSecondary,
                          height: 1.35,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 200.ms).fadeIn(duration: 300.ms).slideY(begin: 0.04, end: 0),
            ],
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData? icon;
  final String text;
  final Color color;

  const _Pill({
    this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 0.75,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: AppTextStyles.captionXs.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
