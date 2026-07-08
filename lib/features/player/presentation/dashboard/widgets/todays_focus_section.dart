import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../design_system/colors/app_colors.dart';
import '../../../../../design_system/typography/text_styles.dart';
import '../../../../../design_system/spacing/spacing_scale.dart';
import '../../../../../design_system/radius/radius.dart';
import '../../../../../design_system/responsive/responsive_helpers.dart';
import '../../../../../services/providers.dart';

class TodaysFocusSection extends ConsumerWidget {
  final String playerId;

  const TodaysFocusSection({super.key, required this.playerId});

  int _dayOfYear() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    return now.difference(startOfYear).inDays;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerAsync = ref.watch(playerProvider(playerId));

    return playerAsync.when(
      data: (player) {
        final sport = player.sports?.isNotEmpty == true ? player.sports!.first : 'your sport';
        return _TodaysFocusContent(sport: sport, dayOfYear: _dayOfYear());
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _TodaysFocusContent extends StatelessWidget {
  final String sport;
  final int dayOfYear;

  const _TodaysFocusContent({required this.sport, required this.dayOfYear});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;
    final padH = isDesktop ? SpacingScale.s32 : (isTablet ? SpacingScale.s24 : SpacingScale.s16);
    final secColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    final focusOptions = [
      _FocusData(
        title: 'Improve Left Foot Accuracy',
        description: 'Focus on non-dominant foot drills during training today.',
        icon: Icons.sports_soccer_rounded,
        gradientColors: [const Color(0xFF2563EB), const Color(0xFF1E40AF)],
        tips: 'Try 20 left-foot passes, 10 left-foot shots on goal.',
      ),
      _FocusData(
        title: 'Sprint Speed',
        description: 'Acceleration drills to improve your 10m sprint time.',
        icon: Icons.speed_rounded,
        gradientColors: [const Color(0xFF059669), const Color(0xFF047857)],
        tips: '5 sets of 20m sprints with 45s rest between.',
      ),
      _FocusData(
        title: 'Recovery Day',
        description: 'Active recovery \u2014 light stretching and mobility work.',
        icon: Icons.self_improvement_rounded,
        gradientColors: [const Color(0xFF7C3AED), const Color(0xFF6D28D9)],
        tips: '15 min stretching, foam rolling, light jog.',
      ),
      _FocusData(
        title: 'Warm-up Pending',
        description: 'Complete your pre-training warm-up routine.',
        icon: Icons.whatshot_rounded,
        gradientColors: [const Color(0xFFD97706), const Color(0xFFB45309)],
        tips: 'Jumping jacks, lunges, arm circles, leg swings.',
      ),
      _FocusData(
        title: 'Today\'s Goal',
        description: 'Set a personal target for today\'s training session.',
        icon: Icons.flag_rounded,
        gradientColors: [const Color(0xFFDC2626), const Color(0xFFB91C1C)],
        tips: 'Write down one thing you want to improve today.',
      ),
    ];
    final focus = focusOptions[dayOfYear % focusOptions.length];

    return Padding(
      padding: EdgeInsets.fromLTRB(padH, SpacingScale.s24, padH, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TODAY'S FOCUS",
            style: AppTextStyles.captionXs.copyWith(
              color: secColor,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ).animate().fadeIn(duration: 200.ms),
          const SizedBox(height: SpacingScale.s12),
          Container(
            decoration: BoxDecoration(
              borderRadius: AppRadius.brXl3,
              gradient: LinearGradient(
                colors: focus.gradientColors.map((c) => c.withValues(alpha: 0.9)).toList(),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: focus.gradientColors.first.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: AppRadius.brXl3,
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(SpacingScale.s24),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: AppRadius.brXl2,
                        ),
                        child: Icon(focus.icon, size: 26, color: Colors.white),
                      ),
                      const SizedBox(width: SpacingScale.s16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              focus.title,
                              style: AppTextStyles.title1.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: SpacingScale.s4),
                            Text(
                              focus.description,
                              style: AppTextStyles.body.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                            const SizedBox(height: SpacingScale.s8),
                            Row(
                              children: [
                                Icon(Icons.lightbulb_outline_rounded, size: 14, color: Colors.white.withValues(alpha: 0.7)),
                                const SizedBox(width: SpacingScale.s6),
                                Expanded(
                                  child: Text(
                                    focus.tips,
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.white.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: SpacingScale.s12),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ).animate(delay: 150.ms).fadeIn(duration: 400.ms).slideY(begin: 0.06, end: 0),
        ],
      ),
    );
  }
}

class _FocusData {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final String tips;

  const _FocusData({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.tips,
  });
}
