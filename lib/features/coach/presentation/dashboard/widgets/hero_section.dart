import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../design_system/colors/app_colors.dart';
import '../../../../../design_system/typography/text_styles.dart';
import '../../../../../design_system/spacing/spacing_scale.dart';
import '../../../../../design_system/responsive/responsive_helpers.dart';
import '../../../../../models/coach_model.dart';

class CoachHeroSection extends ConsumerWidget {
  final String coachId;
  final CoachModel coach;

  const CoachHeroSection({
    super.key,
    required this.coachId,
    required this.coach,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;
    final isPhone = context.isPhone;
    final padH = isDesktop ? SpacingScale.s32 : (isTablet ? SpacingScale.s24 : SpacingScale.s16);
    final padT = isPhone ? 40.0 : 48.0;
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning' : (hour < 17 ? 'Good Afternoon' : 'Good Evening');

    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final cyanColor = isDark ? AppColors.cyan : AppColors.cyanDark;
    final voltColor = isDark ? AppColors.volt : AppColors.voltDark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.background : AppColors.lightSurface,
        image: const DecorationImage(
          image: AssetImage('assets/backgrounds/coach_hero_bg.jpg'),
          fit: BoxFit.cover,
          alignment: Alignment.center,
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
            Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: voltColor.withValues(alpha: isDark ? 0.12 : 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: voltColor.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: voltColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'COACH COMMAND CENTER',
                        style: TextStyle(
                          color: voltColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                if (coach.isVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: cyanColor.withValues(alpha: isDark ? 0.15 : 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: cyanColor.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_rounded, size: 13, color: cyanColor),
                        const SizedBox(width: 5),
                        Text(
                          'OFFICIAL COACH',
                          style: TextStyle(
                            color: cyanColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cyanColor.withValues(alpha: 0.12),
                    border: Border.all(color: cyanColor.withValues(alpha: 0.6), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: cyanColor.withValues(alpha: 0.2),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: coach.photoUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(31),
                          child: Image.network(coach.photoUrl!, fit: BoxFit.cover),
                        )
                      : Icon(Icons.sports_rounded, size: 30, color: cyanColor),
                ),
                const SizedBox(width: SpacingScale.s16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$greeting,',
                        style: AppTextStyles.caption.copyWith(
                          color: textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ).animate(delay: 50.ms).fadeIn(duration: 250.ms).slideY(begin: -0.04, end: 0),
                      const SizedBox(height: 2),
                      Text(
                        coach.name,
                        style: AppTextStyles.heading1.copyWith(
                          color: textPrimary,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ).animate(delay: 100.ms).fadeIn(duration: 300.ms).slideY(begin: -0.04, end: 0),
                      if (coach.specialization != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          coach.specialization!,
                          style: AppTextStyles.body.copyWith(
                            color: cyanColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ).animate(delay: 150.ms).fadeIn(duration: 250.ms).slideY(begin: -0.03, end: 0),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceElevated : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFFFFB300).withValues(alpha: 0.4)
                          : AppColors.lightBorder,
                    ),
                    boxShadow: isDark
                        ? null
                        : const [
                            BoxShadow(
                              color: Color(0x0A0F172A),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFB300)),
                      const SizedBox(width: 4),
                      Text(
                        coach.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Color(0xFFFFB300),
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Pill(
                  text: coach.isVerified ? 'Verified Coach' : 'Unverified',
                  color: coach.isVerified ? voltColor : const Color(0xFFFFB300),
                ),
                _Pill(
                  text: ' Plan',
                  color: coach.isSubscribed ? cyanColor : textSecondary,
                ),
                if (coach.hourlyRate > 0)
                  _Pill(
                    text: '₹/hr',
                    color: const Color(0xFF8B5CF6),
                  ),
              ],
            ).animate(delay: 150.ms).fadeIn(duration: 300.ms),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.card : AppColors.lightCard,
                borderRadius: BorderRadius.circular(14),
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
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: coach.isSubscribed ? voltColor : const Color(0xFFFFB300),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (coach.isSubscribed ? voltColor : const Color(0xFFFFB300))
                              .withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      coach.isSubscribed
                          ? ' coaching dispatch active & accepting athletes'
                          : 'Standard coach tier — upgrade to unlock multi-athlete sessions',
                      style: AppTextStyles.bodySm.copyWith(
                        color: textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate(delay: 200.ms).fadeIn(duration: 350.ms).slideY(begin: 0.06, end: 0),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;

  const _Pill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 0.75,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
