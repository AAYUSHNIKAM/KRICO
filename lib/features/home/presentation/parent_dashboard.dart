import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/stats_card.dart';
import '../../../models/user_model.dart';
import '../../../services/providers.dart';

class ParentDashboard extends ConsumerStatefulWidget {
  const ParentDashboard({super.key, required this.userModel});

  final UserModel userModel;

  @override
  ConsumerState<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends ConsumerState<ParentDashboard> {
  final _speedCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _distanceCtrl = TextEditingController();
  final _accuracyCtrl = TextEditingController();
  bool _isLogging = false;

  @override
  void dispose() {
    _speedCtrl.dispose();
    _durationCtrl.dispose();
    _distanceCtrl.dispose();
    _accuracyCtrl.dispose();
    super.dispose();
  }

  Future<void> _logSession() async {
    setState(() => _isLogging = true);
    try {
      final players = await ref.read(parentPlayersProvider(widget.userModel.uid).future);
      if (players.isNotEmpty) {
        final playerId = players.first.playerId;
        final playerService = ref.read(playerServiceProvider);

        if (_speedCtrl.text.isNotEmpty) {
          await playerService.logMetric(
            playerId: playerId,
            metric: 'speed',
            value: double.tryParse(_speedCtrl.text) ?? 0,
            unit: 'km/h',
          );
        }
        if (_durationCtrl.text.isNotEmpty) {
          await playerService.logMetric(
            playerId: playerId,
            metric: 'duration',
            value: double.tryParse(_durationCtrl.text) ?? 0,
            unit: 'min',
          );
        }
        if (_distanceCtrl.text.isNotEmpty) {
          await playerService.logMetric(
            playerId: playerId,
            metric: 'distance',
            value: double.tryParse(_distanceCtrl.text) ?? 0,
            unit: 'm',
          );
        }
        if (_accuracyCtrl.text.isNotEmpty) {
          await playerService.logMetric(
            playerId: playerId,
            metric: 'accuracy',
            value: double.tryParse(_accuracyCtrl.text) ?? 0,
            unit: '%',
          );
        }

        _speedCtrl.clear();
        _durationCtrl.clear();
        _distanceCtrl.clear();
        _accuracyCtrl.clear();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session logged successfully'), backgroundColor: AppColors.success),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to log session: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLogging = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final playersAsync = ref.watch(parentPlayersProvider(widget.userModel.uid));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.gradientPrimary,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Welcome back,', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
                            const SizedBox(height: 4),
                            Text(widget.userModel.name, style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.notifications_rounded, color: Colors.white),
                        ),
                      ],
                    ),
                    const Spacer(),
                    playersAsync.when(
                      data: (players) {
                        final totalWins = players.fold<int>(0, (s, p) => s + p.championshipWins);
                        final totalXP = players.fold<int>(0, (s, p) => s + p.points);
                        return Row(
                          children: [
                            _buildLevelBadge('$totalWins Wins'),
                            const SizedBox(width: 12),
                            _buildLevelBadge('${players.length} Players'),
                            const Spacer(),
                            Text('$totalXP XP',
                                style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                          ],
                        );
                      },
                      loading: () => const SizedBox(height: 24),
                      error: (_, __) => const SizedBox(height: 24),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                playersAsync.when(
                  data: (players) {
                    final totalWins = players.fold<int>(0, (s, p) => s + p.championshipWins);
                    final totalPoints = players.fold<int>(0, (s, p) => s + p.tournamentPoints);
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: StatsCard(
                              label: 'Championship Wins',
                              value: totalWins.toString(),
                              icon: Icons.emoji_events_rounded,
                              iconColor: AppColors.gold,
                              gradient: AppColors.gradientAccent,
                            )),
                            const SizedBox(width: 12),
                            Expanded(child: StatsCard(
                              label: 'Tournament Points',
                              value: totalPoints.toString(),
                              icon: Icons.workspace_premium_rounded,
                              iconColor: AppColors.secondary,
                            )),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: StatsCard(
                              label: 'Active Players',
                              value: players.length.toString(),
                              icon: Icons.people_rounded,
                              iconColor: AppColors.success,
                            )),
                            const SizedBox(width: 12),
                            Expanded(child: StatsCard(
                              label: 'Avg XP',
                              value: players.isNotEmpty ? '${(totalPoints ~/ players.length)}' : '0',
                              icon: Icons.trending_up_rounded,
                              iconColor: AppColors.info,
                            )),
                          ],
                        ),
                      ],
                    );
                  },
                  loading: () => const Row(
                    children: [
                      Expanded(child: SizedBox(height: 80, child: Center(child: CircularProgressIndicator()))),
                    ],
                  ),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('Failed to load data: $e', style: TextStyle(color: AppColors.error)),
                  ),
                ),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Student Progress', actionLabel: 'See All'),
                const SizedBox(height: 12),
                playersAsync.when(
                  data: (players) {
                    if (players.isEmpty) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline_rounded, color: theme.colorScheme.onSurfaceVariant),
                              const SizedBox(width: 12),
                              Text('No students added yet', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: players.map((player) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 44, height: 44,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: player.avatarUrl != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(player.avatarUrl!, fit: BoxFit.cover),
                                        )
                                      : Center(
                                          child: Text(
                                            player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                                            style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(player.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 6),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: player.points > 0 ? (player.points % 100) / 100 : 0.0,
                                          minHeight: 6,
                                          backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.3),
                                          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text('${player.points} XP \u2022 ${player.level ?? 'Beginner'}',
                                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                                    ],
                                  ),
                                ),
                                Text('${player.championshipWins}',
                                    style: theme.textTheme.labelLarge?.copyWith(color: AppColors.gold, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                      )).toList(),
                    );
                  },
                  loading: () => const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Row(
                        children: [
                          SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                          SizedBox(width: 12),
                          Text('Loading students...'),
                        ],
                      ),
                    ),
                  ),
                  error: (e, _) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('Error loading students: $e', style: TextStyle(color: AppColors.error)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Quick Actions'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildQuickAction(context, 'Track Metrics', Icons.biotech_rounded, AppColors.primary, () {
                      context.go('/player');
                    })),
                    const SizedBox(width: 12),
                    Expanded(child: _buildQuickAction(context, 'Find Coach', Icons.search_rounded, AppColors.secondary, () {
                      context.go('/coach-discovery');
                    })),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildQuickAction(context, 'Book Venue', Icons.stadium_rounded, AppColors.success, () {
                      context.go('/venues');
                    })),
                    Expanded(child: _buildQuickAction(context, 'View Reports', Icons.bar_chart_rounded, AppColors.info, () {
                      context.go('/player');
                    })),
                  ],
                ),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Smart Input Panel', actionLabel: 'Add Now'),
                const SizedBox(height: 12),
                _buildSmartInputPanel(context, theme),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Text(text, style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildQuickAction(BuildContext context, String label, IconData icon, Color color, VoidCallback? onTap) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(label, style: theme.textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmartInputPanel(BuildContext context, ThemeData theme) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome_rounded, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text('Quick Metrics Entry', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildMetricField(context, 'Speed (km/h)', _speedCtrl)),
                const SizedBox(width: 8),
                Expanded(child: _buildMetricField(context, 'Duration (min)', _durationCtrl)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildMetricField(context, 'Distance (m)', _distanceCtrl)),
                const SizedBox(width: 8),
                Expanded(child: _buildMetricField(context, 'Accuracy (%)', _accuracyCtrl)),
              ],
            ),
            const SizedBox(height: 16),
            GradientButton(
              onPressed: _isLogging ? null : _logSession,
              isLoading: _isLogging,
              height: 44,
              child: const Text('Log Session', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricField(BuildContext context, String label, TextEditingController controller) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: theme.textTheme.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
