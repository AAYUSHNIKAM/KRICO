import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../design_system/colors/app_colors.dart';
import '../../../../../design_system/typography/text_styles.dart';
import '../../../../../design_system/spacing/spacing_scale.dart';
import '../../../../../design_system/radius/radius.dart';
import '../../../../../design_system/responsive/responsive_helpers.dart';
import '../../../../../design_system/icons/app_icons.dart';
import '../../../../../design_system/widgets/surfaces/app_card.dart';
import '../../../../../services/providers.dart';
import 'dashboard_loading.dart';
import 'dashboard_error_state.dart';

class DashboardPerformanceSection extends ConsumerWidget {
  final String playerId;

  const DashboardPerformanceSection({super.key, required this.playerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(playerMetricsProvider(playerId));

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.isDesktop ? SpacingScale.s32 : SpacingScale.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: context.isDesktop ? SpacingScale.s28 : SpacingScale.s20),
          metricsAsync.when(
            data: (snap) {
              final metrics = snap.docs.map((d) => d.data()).toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(AppIcons.analytics, size: 18, color: AppColors.primary),
                      const SizedBox(width: SpacingScale.s8),
                      Text('Performance', style: AppTextStyles.title2.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                        fontWeight: FontWeight.w600,
                      )),
                    ],
                  ),
                  const SizedBox(height: SpacingScale.s16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _PerformanceChart(metrics: metrics),
                      ),
                      if (context.isDesktop) const SizedBox(width: SpacingScale.s16),
                      if (context.isDesktop)
                        const Expanded(
                          flex: 2,
                          child: _ScoreCard(),
                        ),
                    ],
                  ),
                ],
              );
            },
            loading: () => const DashboardSectionShimmer(height: 320),
            error: (_, __) => DashboardErrorState(message: 'Could not load performance data'),
          ),
        ],
      ),
    );
  }
}

class _PerformanceChart extends StatelessWidget {
  final List<Map<String, dynamic>> metrics;
  const _PerformanceChart({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final secColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final hasData = metrics.isNotEmpty;

    return AppCard(
      padding: const EdgeInsets.all(SpacingScale.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Performance Trend', style: AppTextStyles.title3.copyWith(color: textColor, fontWeight: FontWeight.w600)),
              const Spacer(),
              if (hasData)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.1),
                    borderRadius: AppRadius.brFull,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.trending_up_rounded, size: 12, color: AppColors.emerald),
                      const SizedBox(width: 2),
                      Text('+8%', style: AppTextStyles.labelSm.copyWith(color: AppColors.emerald)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: SpacingScale.s20),
          if (hasData) ...[
            SizedBox(
              height: 280,
              child: LineChart(
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
                          return Text('${value.toInt()}', style: AppTextStyles.captionXs.copyWith(color: secColor));
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
                            child: Text(days[i], style: AppTextStyles.captionXs.copyWith(color: secColor)),
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
                      spots: List.generate(metrics.length.clamp(0, 7), (i) => FlSpot(i.toDouble(), (metrics[i]['value'] as num?)?.toDouble() ?? 0)),
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: metrics.length <= 14,
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
              ),
            ),
          ] else ...[
            SizedBox(
              height: 280,
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
        ],
      ),
    ).animate(delay: 200.ms).fadeIn(duration: 350.ms, curve: Curves.easeOut).slideY(begin: 0.06, end: 0);
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;

    return AppCard(
      padding: const EdgeInsets.all(SpacingScale.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(AppIcons.analytics, size: 18, color: AppColors.primary),
              const SizedBox(width: SpacingScale.s8),
              Text('Training Scores', style: AppTextStyles.title3.copyWith(color: textColor, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: SpacingScale.s24),
          _ScoreRow(label: 'Training Score', value: 85, color: AppColors.primary),
          const SizedBox(height: SpacingScale.s20),
          _ScoreRow(label: 'Recovery Score', value: 72, color: AppColors.emerald),
          const SizedBox(height: SpacingScale.s20),
          _ScoreRow(label: 'Average Rating', value: 4.8, color: AppColors.purple, isDecimal: true),
          const SizedBox(height: SpacingScale.s20),
          _ScoreRow(label: 'Improvement', value: 12, color: AppColors.orange, suffix: '%'),
          const SizedBox(height: SpacingScale.s16),
          Row(
            children: [
              Icon(Icons.trending_up_rounded, size: 14, color: AppColors.emerald),
              const SizedBox(width: SpacingScale.s6),
              Text('Better than last week', style: AppTextStyles.caption.copyWith(color: AppColors.emerald, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    ).animate(delay: 250.ms).fadeIn(duration: 350.ms, curve: Curves.easeOut).slideY(begin: 0.06, end: 0);
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final bool isDecimal;
  final String? suffix;

  const _ScoreRow({
    required this.label,
    required this.value,
    required this.color,
    this.isDecimal = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final secColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final displayValue = isDecimal ? value.toStringAsFixed(1) : value.toInt().toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.body.copyWith(color: secColor)),
            Text('$displayValue${suffix ?? ''}', style: AppTextStyles.title3.copyWith(color: textColor, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: SpacingScale.s8),
        ClipRRect(
          borderRadius: AppRadius.brFull,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: isDecimal ? value / 5 : value / 100),
            duration: const Duration(milliseconds: 600),
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
