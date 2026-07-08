import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../design_system/colors/app_colors.dart';
import '../../../../../design_system/typography/text_styles.dart';
import '../../../../../design_system/spacing/spacing_scale.dart';
import '../../../../../design_system/radius/radius.dart';
import '../../../../../design_system/responsive/responsive_helpers.dart';
import '../../../../../services/providers.dart';

class InsightsSection extends ConsumerWidget {
  final String playerId;

  const InsightsSection({super.key, required this.playerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerAsync = ref.watch(playerProvider(playerId));
    final sessionsAsync = ref.watch(playerSessionsProvider(playerId));
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;
    final padH = isDesktop ? SpacingScale.s32 : (isTablet ? SpacingScale.s24 : SpacingScale.s16);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: isDesktop ? SpacingScale.s28 : SpacingScale.s24),
          playerAsync.when(
            data: (player) {
              return sessionsAsync.when(
                data: (snap) {
                  final sessions = snap.docs.map((d) => d.data()).toList();
                  return _InsightsContent(playerPoints: player.points, sessions: sessions);
                },
                loading: () => const _InsightsFallback(),
                error: (_, __) => const _InsightsFallback(),
              );
            },
            loading: () => const _InsightsFallback(),
            error: (_, __) => const _InsightsFallback(),
          ),
        ],
      ),
    );
  }
}

class _InsightsContent extends StatelessWidget {
  final int playerPoints;
  final List<Map<String, dynamic>> sessions;

  const _InsightsContent({required this.playerPoints, required this.sessions});

  int _dayOfYear() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    return now.difference(startOfYear).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final completedSessions = sessions.where((s) => s['status'] == 'completed').length;
    final totalSessions = sessions.length;
    final completionRate = totalSessions > 0 ? (completedSessions / totalSessions * 100).toInt() : 0;
    final hasRecentActivity = totalSessions > 0;

    final insights = [
      _InsightData(
        icon: Icons.auto_awesome_rounded,
        color: AppColors.purple,
        title: 'Consistency Score',
        value: '$completionRate%',
        subtitle: '$completedSessions/$totalSessions sessions completed',
      ),
      _InsightData(
        icon: Icons.trending_up_rounded,
        color: AppColors.emerald,
        title: 'Weekly Activity',
        value: hasRecentActivity ? '${(totalSessions / 4).toInt()}/wk' : '0/wk',
        subtitle: hasRecentActivity ? 'Above average engagement' : 'Start training this week',
      ),
      _InsightData(
        icon: Icons.lightbulb_rounded,
        color: AppColors.warning,
        title: 'AI Tip',
        value: 'Keep Going!',
        subtitle: _tips[_dayOfYear() % _tips.length],
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl3,
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(SpacingScale.s24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.purple.withValues(alpha: 0.12),
                    borderRadius: AppRadius.brLg,
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, size: 18, color: AppColors.purple),
                ),
                const SizedBox(width: SpacingScale.s10),
                Text('AI Insights', style: AppTextStyles.title2.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                )),
              ],
            ),
            const SizedBox(height: SpacingScale.s16),
            ...insights.map((insight) => Padding(
              padding: const EdgeInsets.only(bottom: SpacingScale.s10),
              child: _InsightTile(data: insight, isDark: isDark),
            )),
          ],
        ),
      ),
    ).animate(delay: 400.ms).fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }
}

class _InsightData {
  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final String subtitle;

  const _InsightData({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.subtitle,
  });
}

class _InsightTile extends StatelessWidget {
  final _InsightData data;
  final bool isDark;

  const _InsightTile({required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final secColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    return Container(
      padding: const EdgeInsets.all(SpacingScale.s12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary,
        borderRadius: AppRadius.brLg,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              borderRadius: AppRadius.brMd,
            ),
            child: Icon(data.icon, size: 16, color: data.color),
          ),
          const SizedBox(width: SpacingScale.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(data.title, style: AppTextStyles.caption.copyWith(
                        color: secColor,
                      )),
                    ),
                    if (data.value.isNotEmpty)
                      Text(data.value, style: AppTextStyles.labelSm.copyWith(
                        color: data.color,
                        fontWeight: FontWeight.w600,
                      )),
                  ],
                ),
                const SizedBox(height: 2),
                Text(data.subtitle, style: AppTextStyles.captionXs.copyWith(
                  color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightsFallback extends StatelessWidget {
  const _InsightsFallback();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final secColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl3,
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(SpacingScale.s24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.purple.withValues(alpha: 0.12),
                    borderRadius: AppRadius.brLg,
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, size: 18, color: AppColors.purple),
                ),
                const SizedBox(width: SpacingScale.s10),
                Text('AI Insights', style: AppTextStyles.title2.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                )),
              ],
            ),
            const SizedBox(height: SpacingScale.s16),
            Icon(Icons.analytics_outlined, size: 40, color: secColor.withValues(alpha: 0.3)),
            const SizedBox(height: SpacingScale.s12),
            Text('Complete your profile and start training to receive personalized AI insights.',
              style: AppTextStyles.body.copyWith(color: secColor),
            ),
          ],
        ),
      ),
    );
  }
}

const List<String> _tips = [
  'Consistency matters more than intensity. Train regularly.',
  'Rest days are essential for muscle recovery and growth.',
  'Stay hydrated before, during, and after training.',
  'Track your progress to identify patterns and improvements.',
  'Warm up properly to reduce risk of injury.',
  'Quality over quantity — focus on proper form.',
  'Set small weekly goals to build momentum.',
  'Sleep 7-9 hours for optimal performance and recovery.',
  'Review your session recordings to spot improvement areas.',
  'Mix cardio and strength training for balanced fitness.',
  'Listen to your body — pain is a signal, not a challenge.',
  'Celebrate small wins to stay motivated long-term.',
];
