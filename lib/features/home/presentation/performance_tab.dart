import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../design_system/radius/radius.dart';
import '../../../design_system/tokens/duration_tokens.dart';
import '../../../models/certificate_model.dart';
import '../../../models/gamification_model.dart';
import '../../../models/player_model.dart';
import '../../../services/providers.dart';
import 'package:go_router/go_router.dart';

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
  bool _hovered = false;
  bool _emptyHovered = false;

  final Map<String, Color> _metricColors = {
    'Speed': const Color(0xFF00E5FF),     // Electric Cyan
    'Stamina': const Color(0xFF00E676),   // Neon Green
    'Technique': const Color(0xFFB388FF), // Cyber Violet
    'Strength': const Color(0xFFFF9100), // Electric Orange
    'Agility': const Color(0xFFCCFF00),   // Electric Volt
  };

  final Map<String, IconData> _metricIcons = {
    'Speed': Icons.speed_rounded,
    'Stamina': Icons.favorite_rounded,
    'Technique': Icons.auto_awesome_rounded,
    'Strength': Icons.fitness_center_rounded,
    'Agility': Icons.flash_on_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final playerAsync = ref.watch(playerProvider(widget.playerId));
    final metricsAsync = ref.watch(playerMetricsProvider(widget.playerId));

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverHeader(isDark),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: SpacingScale.s16, vertical: SpacingScale.s16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                playerAsync.when(
                  data: (player) => _buildStatsRow(player, isDark),
                  loading: () => _buildShimmerStats(isDark),
                  error: (_, _) => const SizedBox.shrink(),
                ),
                SizedBox(height: SpacingScale.s12),
                _buildCertificatesBanner(playerAsync.asData?.value, isDark),
                SizedBox(height: SpacingScale.s20),
                metricsAsync.when(
                  data: (snap) {
                    final docs = snap.docs;
                    if (docs.isEmpty) return _buildEmptyState(isDark);
                    return _buildChartSection(docs, isDark);
                  },
                  loading: () => _buildShimmerChart(isDark),
                  error: (e, _) => _buildErrorState(e, isDark),
                ),
                SizedBox(height: SpacingScale.s20),
                metricsAsync.when(
                  data: (snap) => _buildRecentSessions(snap.docs, isDark),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
                SizedBox(height: SpacingScale.s24),
                _buildLogSessionButton(isDark),
                SizedBox(height: SpacingScale.s32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader(bool isDark) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: isDark ? AppColors.surface : AppColors.primary,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/backgrounds/stadium_floodlights.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: const Color(0xFF0F172A),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.35),
                    const Color(0xFF0F172A).withValues(alpha: 0.85),
                    (isDark ? AppColors.background : AppColors.lightBackground),
                  ],
                  stops: const [0.0, 0.65, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 18,
              left: SpacingScale.s16,
              right: SpacingScale.s16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCFF00).withValues(alpha: 0.15),
                      borderRadius: AppRadius.brFull,
                      border: Border.all(
                        color: const Color(0xFFCCFF00).withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFCCFF00),
                            boxShadow: [
                              BoxShadow(color: Color(0xFFCCFF00), blurRadius: 6),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'LIVE BIOMETRIC TELEMETRY',
                          style: TextStyle(
                            color: Color(0xFFCCFF00),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Performance Engine',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.verified_user_rounded, color: Color(0xFF00E5FF), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'ATHLETE: ${widget.playerName.toUpperCase()}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(PlayerModel player, bool isDark) {
    final level = LevelModel.getLevel(player.points);
    final progress = LevelModel.getProgress(player.points);
    return Row(
      children: [
        Expanded(
          child: _TelemetryStatCard(
            label: 'ATHLETE LEVEL',
            value: '${level.level}',
            sub: level.title,
            accentColor: const Color(0xFF00E5FF),
            icon: Icons.shield_rounded,
            isDark: isDark,
          ),
        ),
        SizedBox(width: SpacingScale.s10),
        Expanded(
          child: _TelemetryStatCard(
            label: 'TOTAL XP',
            value: '${player.points}',
            sub: '${(progress * 100).toInt()}% to Next',
            accentColor: const Color(0xFFCCFF00),
            icon: Icons.bolt_rounded,
            progress: progress,
            isDark: isDark,
          ),
        ),
        SizedBox(width: SpacingScale.s10),
        Expanded(
          child: _TelemetryStatCard(
            label: 'LEADERBOARD',
            value: '#${player.rank}',
            sub: '${player.championshipWins} Titles',
            accentColor: const Color(0xFFFFD700),
            icon: Icons.emoji_events_rounded,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildCertificatesBanner(PlayerModel? player, bool isDark) {
    final points = player?.points ?? 0;
    final highestTier = CertificateRegistry.getTierByXp(points);
    final nextTier = CertificateRegistry.getNextTier(points);

    return InkWell(
      onTap: () => context.push('/player-certificates/${widget.playerId}'),
      borderRadius: AppRadius.brXl3,
      child: Container(
        padding: const EdgeInsets.all(SpacingScale.s16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1E1B4B),
                    const Color(0xFF0F172A),
                  ]
                : [
                    const Color(0xFFEEF2FF),
                    const Color(0xFFF8FAFC),
                  ],
          ),
          borderRadius: AppRadius.brXl3,
          border: Border.all(
            color: (highestTier?.borderColor ?? AppColors.gold).withValues(alpha: 0.5),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: (highestTier?.primaryColor ?? AppColors.gold).withValues(alpha: isDark ? 0.15 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (highestTier?.primaryColor ?? AppColors.gold).withValues(alpha: 0.15),
                borderRadius: AppRadius.brXl,
                border: Border.all(
                  color: (highestTier?.borderColor ?? AppColors.gold).withValues(alpha: 0.4),
                ),
              ),
              child: Center(
                child: Text(
                  highestTier?.crestBadge ?? '📜',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: SpacingScale.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (highestTier?.primaryColor ?? AppColors.gold).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'OFFICIAL ACCREDITATION',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                                color: highestTier?.primaryColor ?? AppColors.gold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.picture_as_pdf_rounded, size: 12, color: AppColors.primary),
                          const SizedBox(width: 3),
                          Text(
                            'PDF Export',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    highestTier != null ? '${highestTier.title} Credential' : 'Trophy Room & Certificates',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    nextTier != null
                        ? 'Next Milestone: ${nextTier.title} (${nextTier.requiredXp - points} XP away)'
                        : 'Grand Master Laureate reached (Maximum Prestige)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: SpacingScale.s8),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs, bool isDark) {
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
    final activeColor = _metricColors[_selectedMetric] ?? AppColors.primary;

    return Container(
      padding: EdgeInsets.all(SpacingScale.s16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131D31) : Colors.white,
        borderRadius: AppRadius.brXl3,
        border: Border.all(
          color: activeColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: activeColor.withValues(alpha: isDark ? 0.08 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: activeColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _metricIcons[_selectedMetric] ?? Icons.insights_rounded,
                  color: activeColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_selectedMetric Telemetry',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.lightTextPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Historical workout progression',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: activeColor.withValues(alpha: 0.15),
                  borderRadius: AppRadius.brSm,
                  border: Border.all(color: activeColor.withValues(alpha: 0.4), width: 1),
                ),
                child: Text(
                  'Peak: ${values.isEmpty ? '-' : values.reduce((a, b) => a > b ? a : b).toStringAsFixed(1)} $unit',
                  style: TextStyle(
                    color: activeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: SpacingScale.s16),
          // Metric Pill Selector
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: _metricColors.keys.map((metricName) {
                final isSelected = _selectedMetric == metricName;
                final color = _metricColors[metricName]!;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => setState(() => _selectedMetric = metricName),
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: DurationTokens.fast,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? color : color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? color : color.withValues(alpha: 0.2),
                          width: 1,
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 3))]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _metricIcons[metricName] ?? Icons.bolt_rounded,
                            size: 14,
                            color: isSelected ? (color == const Color(0xFFCCFF00) ? Colors.black : Colors.white) : color,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            metricName,
                            style: TextStyle(
                              color: isSelected
                                  ? (color == const Color(0xFFCCFF00) ? Colors.black : Colors.white)
                                  : (isDark ? Colors.white70 : AppColors.lightTextSecondary),
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: SpacingScale.s20),
          // Telemetry Line Chart
          SizedBox(
            height: 160,
            child: values.length < 2
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.query_stats_rounded, size: 36, color: activeColor.withValues(alpha: 0.4)),
                        const SizedBox(height: 8),
                        Text(
                          'Record at least 2 sessions to unlock telemetry chart',
                          style: TextStyle(
                            color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: _calcInterval(values),
                        getDrawingHorizontalLine: (v) => FlLine(
                          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
                          strokeWidth: 1,
                          dashArray: [4, 4],
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                            interval: (values.length / 3).ceilToDouble().clamp(1, double.infinity),
                            getTitlesWidget: (v, _) {
                              final idx = v.toInt();
                              if (idx < 0 || idx >= filtered.length) return const SizedBox.shrink();
                              final date = (filtered[idx].data()['loggedAt'] as Timestamp?)?.toDate();
                              if (date == null) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  '${date.day}/${date.month}',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minY: (values.reduce((a, b) => a < b ? a : b) * 0.9),
                      maxY: (values.reduce((a, b) => a > b ? a : b) * 1.1),
                      lineBarsData: [
                        LineChartBarData(
                          spots: values.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                          isCurved: true,
                          curveSmoothness: 0.35,
                          color: activeColor,
                          barWidth: 3.5,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: values.length < 10,
                            getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                              radius: 4,
                              color: activeColor,
                              strokeWidth: 2,
                              strokeColor: isDark ? const Color(0xFF131D31) : Colors.white,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                activeColor.withValues(alpha: 0.28),
                                activeColor.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
                            '${s.y.toStringAsFixed(1)} $unit',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          )).toList(),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    ).animate(delay: 150.ms).fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0);
  }

  double _calcInterval(List<double> values) {
    final range = (values.reduce((a, b) => a > b ? a : b) - values.reduce((a, b) => a < b ? a : b));
    if (range == 0) return 10;
    return (range / 4).ceilToDouble().clamp(1, double.infinity);
  }

  Widget _buildRecentSessions(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs, bool isDark) {
    if (docs.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.all(SpacingScale.s16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131D31) : Colors.white,
        borderRadius: AppRadius.brXl3,
        border: Border.all(
          color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.history_rounded, size: 16, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              Text(
                'Recent Performance Logs',
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                  borderRadius: AppRadius.brFull,
                ),
                child: Text(
                  '${docs.length} logged',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: SpacingScale.s12),
          ...docs.take(5).map((doc) {
            final d = doc.data();
            final metric = d['metric'] as String? ?? '';
            final value = (d['value'] as num?)?.toDouble() ?? 0;
            final unit = d['unit'] as String? ?? '';
            final time = (d['loggedAt'] as Timestamp?)?.toDate();
            final color = _metricColors.entries
                .firstWhere(
                  (e) => e.key.toLowerCase() == metric.toLowerCase(),
                  orElse: () => const MapEntry('', AppColors.primary),
                )
                .value;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.6) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _metricIcons[metric[0].toUpperCase() + metric.substring(1).toLowerCase()] ?? Icons.fitness_center_rounded,
                      size: 20,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          metric.isEmpty ? 'Workout' : metric[0].toUpperCase() + metric.substring(1),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : AppColors.lightTextPrimary,
                          ),
                        ),
                        if (time != null)
                          Text(
                            _formatTime(time),
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$value $unit',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    ).animate(delay: 250.ms).fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildLogSessionButton(bool isDark) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.bolt_rounded, color: Color(0xFFCCFF00)),
                  SizedBox(width: 8),
                  Text('Telemetry session logger ready'),
                ],
              ),
              backgroundColor: const Color(0xFF0F172A),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        },
        borderRadius: AppRadius.brXl2,
        child: AnimatedContainer(
          duration: DurationTokens.fast,
          height: 52,
          padding: EdgeInsets.symmetric(horizontal: SpacingScale.s24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFCCFF00),
                Color(0xFF99E600),
              ],
            ),
            borderRadius: AppRadius.brXl2,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFCCFF00).withValues(alpha: _hovered ? 0.45 : 0.25),
                blurRadius: _hovered ? 20 : 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline_rounded, color: Colors.black, size: 20),
              SizedBox(width: 8),
              Text(
                'LOG NEW ATHLETIC SESSION',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: EdgeInsets.all(SpacingScale.s32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131D31) : Colors.white,
        borderRadius: AppRadius.brXl3,
        border: Border.all(
          color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFCCFF00).withValues(alpha: 0.12),
            ),
            child: const Icon(Icons.insights_rounded, size: 48, color: Color(0xFFCCFF00)),
          ),
          SizedBox(height: SpacingScale.s16),
          Text(
            'Zero Telemetry Logged Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: SpacingScale.s8),
          Text(
            'Record speed, stamina, technique or strength drills to activate your AI telemetry radar.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
            ),
          ),
          SizedBox(height: SpacingScale.s20),
          MouseRegion(
            onEnter: (_) => setState(() => _emptyHovered = true),
            onExit: (_) => setState(() => _emptyHovered = false),
            child: AnimatedContainer(
              duration: DurationTokens.fast,
              padding: EdgeInsets.symmetric(horizontal: SpacingScale.s24, vertical: SpacingScale.s12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFCCFF00), Color(0xFF99E600)],
                ),
                borderRadius: AppRadius.brXl2,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFCCFF00).withValues(alpha: _emptyHovered ? 0.45 : 0.25),
                    blurRadius: _emptyHovered ? 20 : 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt_rounded, size: 18, color: Colors.black),
                  SizedBox(width: 8),
                  Text(
                    'Log First Session',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.06, end: 0);
  }

  Widget _buildShimmerStats(bool isDark) {
    return Row(
      children: List.generate(
        3,
        (_) => Expanded(
          child: Container(
            margin: EdgeInsets.only(right: SpacingScale.s8),
            height: 90,
            decoration: BoxDecoration(
              color: isDark ? AppColors.card : AppColors.lightCard,
              borderRadius: AppRadius.brXl3,
            ),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerChart(bool isDark) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl3,
      ),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildErrorState(Object e, bool isDark) {
    return Container(
      padding: EdgeInsets.all(SpacingScale.s24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl3,
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline_rounded, size: 40, color: AppColors.danger),
          SizedBox(height: SpacingScale.s8),
          Text('Failed to load metrics', style: AppTextStyles.body.copyWith(color: AppColors.danger)),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _TelemetryStatCard extends StatelessWidget {
  final String label, value, sub;
  final Color accentColor;
  final IconData icon;
  final double? progress;
  final bool isDark;

  const _TelemetryStatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.accentColor,
    required this.icon,
    this.progress,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131D31) : Colors.white,
        borderRadius: AppRadius.brXl3,
        border: Border.all(
          color: accentColor.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: accentColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 17,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 4),
          if (progress != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress!.clamp(0.0, 1.0),
                backgroundColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            sub,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
            ),
          ),
        ],
      ),
    ).animate(delay: 100.ms).fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }
}
