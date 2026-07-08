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
import '../../../../../services/providers.dart';
import 'dashboard_loading.dart';
import 'dashboard_empty_state.dart';

class PerformanceSection extends ConsumerWidget {
  final String playerId;

  const PerformanceSection({super.key, required this.playerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          metricsAsync.when(
            data: (snap) {
              final metrics = snap.docs.map((d) => d.data()).toList();
              return _PerformanceContent(metrics: metrics);
            },
            loading: () => const DashboardSectionShimmer(height: 320),
            error: (_, __) => DashboardEmptyState(
              icon: Icons.show_chart_rounded,
              title: 'Performance Data Unavailable',
              subtitle: 'Start training to see your performance trends.',
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceContent extends StatelessWidget {
  final List<Map<String, dynamic>> metrics;

  const _PerformanceContent({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final secColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    final hasData = metrics.isNotEmpty;
    final avgMetric = hasData
        ? metrics.fold(0.0, (sum, m) => sum + ((m['value'] as num?)?.toDouble() ?? 0)) / metrics.length
        : 0.0;
    final weeklyTrend = hasData ? ((metrics.last['value'] as num?)?.toDouble() ?? 0) - ((metrics.first['value'] as num?)?.toDouble() ?? 0) : 0.0;

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
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: AppRadius.brLg,
                  ),
                  child: Icon(Icons.analytics_rounded, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: SpacingScale.s10),
                Text('Performance', style: AppTextStyles.title2.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                )),
                const Spacer(),
                if (hasData)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s8, vertical: 2),
                    decoration: BoxDecoration(
                      color: (weeklyTrend >= 0 ? AppColors.emerald : AppColors.danger).withValues(alpha: 0.1),
                      borderRadius: AppRadius.brFull,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          weeklyTrend >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                          size: 12,
                          color: weeklyTrend >= 0 ? AppColors.emerald : AppColors.danger,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${weeklyTrend >= 0 ? '+' : ''}${weeklyTrend.toStringAsFixed(0)}%',
                          style: AppTextStyles.labelSm.copyWith(
                            color: weeklyTrend >= 0 ? AppColors.emerald : AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: SpacingScale.s20),
            if (hasData) ...[
              SizedBox(
                height: 200,
                child: _PerformanceChart(metrics: metrics, isDark: isDark),
              ),
              const SizedBox(height: SpacingScale.s20),
              Row(
                children: [
                  Expanded(
                    child: _ScoreBadge(
                      label: 'Avg Score',
                      value: avgMetric.toStringAsFixed(0),
                      icon: Icons.score_rounded,
                      color: AppColors.primary,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: SpacingScale.s8),
                  Expanded(
                    child: _ScoreBadge(
                      label: 'Weekly Trend',
                      value: '${weeklyTrend >= 0 ? '+' : ''}${weeklyTrend.toStringAsFixed(0)}%',
                      icon: Icons.trending_up_rounded,
                      color: weeklyTrend >= 0 ? AppColors.emerald : AppColors.danger,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ] else ...[
              SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.show_chart_rounded, size: 32, color: secColor.withValues(alpha: 0.4)),
                      const SizedBox(height: SpacingScale.s12),
                      Text('No metrics recorded yet', style: AppTextStyles.body.copyWith(color: secColor)),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: SpacingScale.s16),
            Row(
              children: [
                Expanded(
                  child: _ScoreBar(
                    label: 'Recovery',
                    value: 74,
                    color: AppColors.emerald,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: SpacingScale.s12),
                Expanded(
                  child: _ScoreBar(
                    label: 'Fatigue',
                    value: 35,
                    color: AppColors.warning,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate(delay: 200.ms).fadeIn(duration: 350.ms).slideY(begin: 0.06, end: 0);
  }
}

class _PerformanceChart extends StatelessWidget {
  final List<Map<String, dynamic>> metrics;
  final bool isDark;

  const _PerformanceChart({required this.metrics, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final recentMetrics = metrics.take(14).toList();
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
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return Text('${value.toInt()}', style: AppTextStyles.captionXs.copyWith(
                  color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                ));
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                final i = value.toInt();
                if (i < 0 || i >= days.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(days[i % 7], style: AppTextStyles.captionXs.copyWith(
                    color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                  )),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: recentMetrics.length <= 14,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 4,
                color: AppColors.primary,
                strokeWidth: 2,
                strokeColor: isDark ? AppColors.surface : AppColors.lightSurface,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.2),
                  AppColors.primary.withValues(alpha: 0.02),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) => touchedSpots.map((spot) => LineTooltipItem(
              '${spot.y.toInt()}',
              TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            )).toList(),
          ),
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _ScoreBadge({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s12, vertical: SpacingScale.s10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary,
        borderRadius: AppRadius.brLg,
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
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
                Text(value, style: AppTextStyles.label.copyWith(
                  color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                  fontWeight: FontWeight.w600,
                )),
                Text(label, style: AppTextStyles.captionXs.copyWith(
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

class _ScoreBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final bool isDark;

  const _ScoreBar({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.caption.copyWith(
              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
            )),
            Text('${value.toInt()}%', style: AppTextStyles.label.copyWith(
              color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
              fontWeight: FontWeight.w600,
            )),
          ],
        ),
        const SizedBox(height: SpacingScale.s6),
        ClipRRect(
          borderRadius: AppRadius.brFull,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value / 100),
            duration: DurationTokens.slower,
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => LinearProgressIndicator(
              value: v,
              minHeight: 5,
              backgroundColor: isDark ? AppColors.divider : AppColors.lightDivider,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
      ],
    );
  }
}
