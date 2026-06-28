import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../models/gamification_model.dart';
import '../../../models/player_model.dart';
import '../../../services/providers.dart';

class PerformanceTab extends ConsumerStatefulWidget {
  final String playerId;
  final String playerName;

  const PerformanceTab({
    super.key,
    required this.playerId,
    required this.playerName,
  });

  @override
  ConsumerState<PerformanceTab> createState() => _PerformanceTabState();
}

class _PerformanceTabState extends ConsumerState<PerformanceTab> {
  String _selectedMetric = 'Speed';
  final _metricColors = {
    'Speed': AppColors.primary,
    'Stamina': AppColors.success,
    'Technique': AppColors.accent,
    'Strength': AppColors.warning,
    'Agility': AppColors.secondary,
  };

  void _showLogMetricSheet() {
    final valueCtrl = TextEditingController();
    String selectedMetric = 'Speed';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.55,
        decoration: BoxDecoration(
          color: Theme.of(ctx).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: StatefulBuilder(
            builder: (ctx, setDialogState) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textDim,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Log New Session', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text('Record your latest training metric', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 20),
                Text('Metric Type', style: AppTextStyles.labelLarge),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _metricColors.keys.map((m) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(m, style: AppTextStyles.labelMedium.copyWith(
                          color: selectedMetric == m ? Colors.white : AppColors.textSecondary,
                          fontWeight: selectedMetric == m ? FontWeight.w600 : FontWeight.w400,
                        )),
                        selected: selectedMetric == m,
                        selectedColor: _metricColors[m],
                        backgroundColor: _metricColors[m]!.withValues(alpha: 0.08),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        side: BorderSide.none,
                        onSelected: (_) => setDialogState(() => selectedMetric = m),
                      ),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: valueCtrl,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        style: AppTextStyles.headlineLarge.copyWith(fontWeight: FontWeight.w700),
                        decoration: InputDecoration(
                          labelText: 'Value',
                          hintText: '0',
                          labelStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Theme.of(ctx).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(_getUnit(selectedMetric), style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Spacer(),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: valueCtrl,
                  builder: (_, val, __) {
                    final valid = double.tryParse(val.text) != null;
                    return GradientButton(
                      onPressed: valid ? () async {
                        await ref.read(playerServiceProvider).logMetric(
                          playerId: widget.playerId,
                          metric: selectedMetric.toLowerCase(),
                          value: double.parse(val.text),
                          unit: _getUnit(selectedMetric),
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$selectedMetric logged!'), backgroundColor: AppColors.success),
                          );
                        }
                      } : null,
                      height: 50,
                      child: Text('Log $selectedMetric', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getUnit(String metric) {
    return switch (metric) {
      'Speed' => 'km/h',
      'Stamina' => '%',
      'Technique' => '%',
      'Strength' => 'kg',
      'Agility' => 'sec',
      _ => 'units',
    };
  }

  @override
  Widget build(BuildContext context) {
    final playerAsync = ref.watch(playerProvider(widget.playerId));
    final metricsAsync = ref.watch(playerMetricsProvider(widget.playerId));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).brightness == Brightness.dark
                          ? AppColors.primaryDark
                          : AppColors.primary,
                      Theme.of(context).brightness == Brightness.dark
                          ? AppColors.surfaceDark
                          : AppColors.surfaceLight,
                    ],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Performance', style: AppTextStyles.headlineMedium.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(widget.playerName, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                playerAsync.when(
                  data: (player) => _buildStatsRow(player),
                  loading: () => _buildShimmerStats(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 16),
                metricsAsync.when(
                  data: (snap) {
                    final docs = snap.docs;
                    if (docs.isEmpty) return _buildEmptyState();
                    return _buildChartSection(docs);
                  },
                  loading: () => _buildShimmerChart(),
                  error: (e, _) => _buildErrorState(e),
                ),
                const SizedBox(height: 16),
                metricsAsync.when(
                  data: (snap) => _buildRecentSessions(snap.docs),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 16),
                GradientButton(
                  onPressed: _showLogMetricSheet,
                  gradient: AppColors.gradientPrimary,
                  height: 52,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text('Log New Session', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(PlayerModel player) {
    final level = LevelModel.getLevel(player.points);
    final progress = LevelModel.getProgress(player.points);
    return Row(
      children: [
        Expanded(child: _MiniStatCard(label: 'Level', value: '${level.level}', sub: level.title, color: AppColors.primary)),
        const SizedBox(width: 8),
        Expanded(child: _MiniStatCard(label: 'XP', value: '${player.points}', sub: '${(progress * 100).toInt()}% to next', color: AppColors.accent)),
        const SizedBox(width: 8),
        Expanded(child: _MiniStatCard(label: 'Rank', value: '#${player.rank}', sub: '${player.championshipWins} wins', color: AppColors.gold)),
      ],
    );
  }

  Widget _buildShimmerStats() => Row(
    children: List.generate(3, (_) => Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary.withValues(alpha: 0.3))),
      ),
    )),
  );

  Widget _buildChartSection(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    final filtered = docs
        .where((d) => d.data()['metric'] == _selectedMetric.toLowerCase())
        .toList()
      ..sort((a, b) {
        final aTime = (a.data()['loggedAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
        final bTime = (b.data()['loggedAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
        return aTime.compareTo(bTime);
      });

    final values = filtered.map((d) => (d.data()['value'] as num?)?.toDouble() ?? 0).toList();
    final unit = filtered.isNotEmpty ? (filtered.first.data()['unit'] as String? ?? '') : '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('$_selectedMetric Over Time', style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('Best: ${values.isEmpty ? '-' : values.reduce((a, b) => a > b ? a : b).toStringAsFixed(1)} $unit',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontSize: 9)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: values.length < 2
                ? Center(
                    child: Text('Need at least 2 data points for a chart',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textDim)),
                  )
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: _calcInterval(values),
                        getDrawingHorizontalLine: (v) => FlLine(
                          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 20,
                            interval: (values.length / 3).ceilToDouble().clamp(1, double.infinity),
                            getTitlesWidget: (v, _) {
                              final idx = v.toInt();
                              if (idx < 0 || idx >= filtered.length) return const SizedBox.shrink();
                              final date = (filtered[idx].data()['loggedAt'] as Timestamp?)?.toDate();
                              if (date == null) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text('${date.day}/${date.month}',
                                    style: AppTextStyles.labelSmall.copyWith(fontSize: 8, color: AppColors.textDim)),
                              );
                            },
                          ),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      minY: (values.reduce((a, b) => a < b ? a : b) * 0.9),
                      maxY: (values.reduce((a, b) => a > b ? a : b) * 1.1),
                      lineBarsData: [
                        LineChartBarData(
                          spots: values.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                          isCurved: true,
                          color: _metricColors[_selectedMetric] ?? AppColors.primary,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: values.length < 10),
                          belowBarData: BarAreaData(
                            show: true,
                            color: (_metricColors[_selectedMetric] ?? AppColors.primary).withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
                            '${s.y.toStringAsFixed(1)} $unit',
                            TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                          )).toList(),
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _metricColors.keys.map((m) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(m, style: AppTextStyles.labelSmall.copyWith(
                    color: _selectedMetric == m ? Colors.white : AppColors.textSecondary,
                    fontWeight: _selectedMetric == m ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 11,
                  )),
                  selected: _selectedMetric == m,
                  selectedColor: _metricColors[m],
                  backgroundColor: _metricColors[m]!.withValues(alpha: 0.08),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: BorderSide.none,
                  onSelected: (v) => setState(() => _selectedMetric = m),
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }

  double _calcInterval(List<double> values) {
    final range = (values.reduce((a, b) => a > b ? a : b) - values.reduce((a, b) => a < b ? a : b));
    if (range == 0) return 10;
    return (range / 4).ceilToDouble().clamp(1, double.infinity);
  }

  Widget _buildRecentSessions(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    if (docs.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history_rounded, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text('Recent Sessions', style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('${docs.length} total', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          ...docs.take(5).map((doc) {
            final d = doc.data();
            final metric = d['metric'] as String? ?? '';
            final value = (d['value'] as num?)?.toDouble() ?? 0;
            final unit = d['unit'] as String? ?? '';
            final time = (d['loggedAt'] as Timestamp?)?.toDate();
            final color = _metricColors.entries
                .firstWhere((e) => e.key.toLowerCase() == metric,
                    orElse: () => MapEntry('', AppColors.primary))
                .value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.fitness_center_rounded, size: 18, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(metric[0].toUpperCase() + metric.substring(1),
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
                        if (time != null)
                          Text(_formatTime(time),
                              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Text('$value $unit', style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w700, color: color)),
                ],
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildEmptyState() => Container(
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.3)),
    ),
    child: Column(
      children: [
        Icon(Icons.trending_up_rounded, size: 56, color: AppColors.textDim),
        const SizedBox(height: 16),
        Text('No Performance Data Yet',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Text('Start logging your sessions to track progress',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textDim)),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _showLogMetricSheet,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Log First Session'),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    ),
  ).animate().fadeIn(duration: 600.ms);

  Widget _buildShimmerChart() => Container(
    height: 200,
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary.withValues(alpha: 0.3))),
  );

  Widget _buildErrorState(Object e) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
    ),
    child: Column(
      children: [
        Icon(Icons.error_outline_rounded, size: 40, color: AppColors.error),
        const SizedBox(height: 8),
        Text('Failed to load metrics', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
      ],
    ),
  );

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label, value, sub;
  final Color color;

  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w700, color: color)),
          Text(sub, style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textDim, fontSize: 9)),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}
