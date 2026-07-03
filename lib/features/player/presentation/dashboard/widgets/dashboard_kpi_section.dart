import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../design_system/colors/app_colors.dart';
import '../../../../../design_system/typography/text_styles.dart';
import '../../../../../design_system/spacing/spacing_scale.dart';
import '../../../../../design_system/radius/radius.dart';
import '../../../../../design_system/responsive/responsive_helpers.dart';
import '../../../../../design_system/icons/app_icons.dart';
import '../../../../../models/player_model.dart';
import '../../../../../services/providers.dart';
import 'dashboard_loading.dart';

class DashboardKpiSection extends ConsumerWidget {
  final String playerId;

  const DashboardKpiSection({super.key, required this.playerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerAsync = ref.watch(playerProvider(playerId));

    return playerAsync.when(
      data: (player) => _KpiContent(player: player),
      loading: () => const DashboardKpiShimmer(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _KpiContent extends StatelessWidget {
  final PlayerModel player;
  const _KpiContent({required this.player});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = context.isDesktop;
    final padding = isDesktop ? SpacingScale.s32 : SpacingScale.s16;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;

    final kpis = [
      _KpiData(
        icon: AppIcons.sports, iconBg: AppColors.primary,
        accentColor: AppColors.primary,
        label: 'Sessions', value: '${player.championshipWins + player.rank}',
        subtitle: '+3 this week', trend: '+12%', up: true,
      ),
      _KpiData(
        icon: AppIcons.timer, iconBg: AppColors.emerald,
        accentColor: AppColors.emerald,
        label: 'Hours', value: '${player.tournamentPoints ~/ 10}',
        subtitle: '${(player.tournamentPoints ~/ 10) ~/ 4}h avg', trend: '+8%', up: true,
      ),
      _KpiData(
        icon: AppIcons.trophy, iconBg: AppColors.warning,
        accentColor: AppColors.warning,
        label: 'Achievements', value: '${player.championshipWins}',
        subtitle: '${player.championshipWins + 3} goals set', trend: '+5%', up: true,
      ),
      _KpiData(
        icon: Icons.leaderboard_rounded, iconBg: AppColors.purple,
        accentColor: AppColors.purple,
        label: 'Ranking', value: '#${player.rank}',
        subtitle: player.rank <= 3 ? 'Top performer' : 'Gaining ground', trend: '+3', up: true,
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: isDesktop ? SpacingScale.s28 : SpacingScale.s20),
          Row(
            children: [
              Icon(AppIcons.analytics, size: 18, color: AppColors.primary),
              const SizedBox(width: SpacingScale.s8),
              Text('Overview', style: AppTextStyles.title2.copyWith(color: textColor, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: SpacingScale.s16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 4 : 2,
              crossAxisSpacing: SpacingScale.s12,
              mainAxisSpacing: SpacingScale.s12,
              childAspectRatio: isDesktop ? 1.3 : 1.15,
            ),
            itemCount: kpis.length,
            itemBuilder: (context, i) => _KpiCard(kpi: kpis[i], index: i),
          ),
        ],
      ),
    );
  }
}

class _KpiData {
  final IconData icon;
  final Color iconBg;
  final Color accentColor;
  final String label;
  final String value;
  final String subtitle;
  final String trend;
  final bool up;
  const _KpiData({
    required this.icon, required this.iconBg, required this.accentColor,
    required this.label, required this.value, required this.subtitle,
    required this.trend, required this.up,
  });
}

class _KpiCard extends StatelessWidget {
  final _KpiData kpi;
  final int index;
  const _KpiCard({required this.kpi, required this.index});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final terColor = isDark ? AppColors.textTertiary : AppColors.lightTextTertiary;
    final trendColor = kpi.up ? AppColors.emerald : AppColors.danger;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl2,
        border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 3, color: kpi.accentColor),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(SpacingScale.s12, SpacingScale.s12, SpacingScale.s12, SpacingScale.s12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: kpi.iconBg.withValues(alpha: 0.12),
                          borderRadius: AppRadius.brLg,
                        ),
                        child: Icon(kpi.icon, size: 18, color: kpi.iconBg),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s6, vertical: 2),
                        decoration: BoxDecoration(
                          color: trendColor.withValues(alpha: 0.1),
                          borderRadius: AppRadius.brFull,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(kpi.up ? Icons.trending_up_rounded : Icons.trending_down_rounded, size: 10, color: trendColor),
                            const SizedBox(width: 2),
                            Text(kpi.trend, style: AppTextStyles.labelSm.copyWith(color: trendColor, fontSize: 9)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(kpi.value, style: AppTextStyles.numericSm.copyWith(color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary)),
                  const SizedBox(height: SpacingScale.s2),
                  Text(kpi.label, style: AppTextStyles.caption.copyWith(color: secColor, fontWeight: FontWeight.w500)),
                  const SizedBox(height: SpacingScale.s2),
                  Text(kpi.subtitle, style: AppTextStyles.captionXs.copyWith(color: terColor)),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate(delay: (100 + index * 80).ms).fadeIn(duration: 300.ms, curve: Curves.easeOut).slideY(begin: 0.08, end: 0);
  }
}
