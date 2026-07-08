import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../design_system/colors/app_colors.dart';
import '../../../../../design_system/typography/text_styles.dart';
import '../../../../../design_system/spacing/spacing_scale.dart';
import '../../../../../design_system/radius/radius.dart';
import '../../../../../design_system/responsive/responsive_helpers.dart';
import '../../../../../design_system/tokens/duration_tokens.dart';
import '../../../../../models/gamification_model.dart';
import '../../../../../services/providers.dart';
import 'dashboard_loading.dart';

class PlayerProgressionSection extends ConsumerWidget {
  final String playerId;

  const PlayerProgressionSection({super.key, required this.playerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerAsync = ref.watch(playerProvider(playerId));
    final metricsAsync = ref.watch(playerMetricsProvider(playerId));
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
              return metricsAsync.when(
                data: (snap) {
                  final metrics = snap.docs.map((d) => d.data()).toList();
                  return _ProgressionContent(
                    playerPoints: player.points,
                    playerRank: player.rank,
                    metrics: metrics,
                  );
                },
                loading: () => const DashboardSectionShimmer(height: 200),
                error: (_, __) => _ProgressionContent(
                  playerPoints: player.points,
                  playerRank: player.rank,
                  metrics: const [],
                ),
              );
            },
            loading: () => const DashboardSectionShimmer(height: 200),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _ProgressionContent extends StatelessWidget {
  final int playerPoints;
  final int playerRank;
  final List<Map<String, dynamic>> metrics;

  const _ProgressionContent({
    required this.playerPoints,
    required this.playerRank,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final rankModel = RankModel.ranks.firstWhere(
      (r) => r.rank == playerRank,
      orElse: () => RankModel.ranks.first,
    );
    final weeklyXp = metrics.fold<int>(
      0, (sum, m) => sum + ((m['value'] as num?)?.toInt() ?? 0),
    );
    final monthlyXp = weeklyXp * 4;
    final nextRank = playerRank < RankModel.ranks.length
        ? RankModel.ranks[playerRank]
        : RankModel.ranks.last;
    final personalBest = metrics.isEmpty
        ? 0
        : metrics.map((m) => (m['value'] as num?)?.toDouble() ?? 0).reduce(
            (a, b) => a > b ? a : b,
          );
    final avgMetric = metrics.isEmpty
        ? 0.0
        : metrics.fold(0.0, (sum, m) => sum + ((m['value'] as num?)?.toDouble() ?? 0)) /
            metrics.length;
    final consistency = metrics.isEmpty ? 0.0 : (avgMetric / 100).clamp(0.0, 1.0);

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
                  child: Icon(Icons.trending_up_rounded, size: 18, color: AppColors.purple),
                ),
                const SizedBox(width: SpacingScale.s10),
                Text('Progression', style: AppTextStyles.title2.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                )),
              ],
            ),
            const SizedBox(height: SpacingScale.s20),
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    label: 'Weekly XP',
                    value: '$weeklyXp',
                    icon: Icons.stars_rounded,
                    color: AppColors.warning,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: SpacingScale.s12),
                Expanded(
                  child: _MiniStat(
                    label: 'Monthly XP',
                    value: '$monthlyXp',
                    icon: Icons.auto_awesome_rounded,
                    color: AppColors.emerald,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpacingScale.s12),
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    label: 'Current Rank',
                    value: '#$playerRank ${rankModel.title}',
                    icon: Icons.leaderboard_rounded,
                    color: AppColors.primary,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: SpacingScale.s12),
                Expanded(
                  child: _MiniStat(
                    label: 'Next Rank',
                    value: '#${nextRank.rank} ${nextRank.title}',
                    icon: Icons.arrow_upward_rounded,
                    color: AppColors.purple,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpacingScale.s12),
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    label: 'Personal Best',
                    value: personalBest.toStringAsFixed(0),
                    icon: Icons.emoji_events_rounded,
                    color: AppColors.warning,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: SpacingScale.s12),
                Expanded(
                  child: _MiniStat(
                    label: 'Consistency',
                    value: '${(consistency * 100).toInt()}%',
                    icon: Icons.show_chart_rounded,
                    color: consistency > 0.6 ? AppColors.emerald : AppColors.warning,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            if (metrics.length >= 4) ...[
              const SizedBox(height: SpacingScale.s20),
              SizedBox(
                height: 80,
                child: _MiniChart(metrics: metrics, isDark: isDark),
              ),
            ],
          ],
        ),
      ),
    ).animate(delay: 250.ms).fadeIn(duration: 400.ms).slideY(begin: 0.06, end: 0);
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
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
              color: color.withValues(alpha: 0.12),
              borderRadius: AppRadius.brMd,
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: SpacingScale.s8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyles.label.copyWith(
                    color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  label,
                  style: AppTextStyles.captionXs.copyWith(
                    color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniChart extends StatelessWidget {
  final List<Map<String, dynamic>> metrics;
  final bool isDark;

  const _MiniChart({required this.metrics, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final recentMetrics = metrics.take(7).toList().reversed.toList();
    final spots = List.generate(recentMetrics.length, (i) {
      return FlSpot(i.toDouble(), (recentMetrics[i]['value'] as num?)?.toDouble() ?? 0);
    });

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (value) => FlLine(
            color: isDark ? AppColors.divider : AppColors.lightDivider,
            strokeWidth: 0.5,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.emerald,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.emerald.withValues(alpha: 0.2),
                  AppColors.emerald.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(enabled: false),
      ),
      duration: DurationTokens.long,
    );
  }
}
