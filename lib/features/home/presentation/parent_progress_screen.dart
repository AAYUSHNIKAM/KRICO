import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/stats_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../services/providers.dart';
import '../../../models/player_model.dart';

class ParentProgressScreen extends ConsumerWidget {
  final String parentId;
  const ParentProgressScreen({super.key, required this.parentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playersAsync = ref.watch(parentPlayersProvider(parentId));
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
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
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Progress Reports',
                        style: AppTextStyles.headlineMedium.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                    Text('Track your children\'s growth',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.7))),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                playersAsync.when(
                  data: (players) {
                    if (players.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.child_care_rounded, size: 48, color: AppColors.textDim),
                            const SizedBox(height: 12),
                            Text('No children linked yet',
                                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      );
                    }
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: StatsCard(
                              label: 'Total Children',
                              value: players.length.toString(),
                              icon: Icons.people_rounded,
                              iconColor: AppColors.primary,
                            )),
                            const SizedBox(width: 12),
                            Expanded(child: StatsCard(
                              label: 'Combined XP',
                              value: players.fold(0, (s, p) => s + p.points).toString(),
                              icon: Icons.workspace_premium_rounded,
                              iconColor: AppColors.gold,
                              gradient: AppColors.gradientAccent,
                            )),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: StatsCard(
                              label: 'Total Wins',
                              value: players.fold(0, (s, p) => s + p.championshipWins).toString(),
                              icon: Icons.emoji_events_rounded,
                              iconColor: AppColors.accent,
                            )),
                            const SizedBox(width: 12),
                            Expanded(child: StatsCard(
                              label: 'Avg XP/Child',
                              value: players.isNotEmpty
                                  ? '${(players.fold(0, (s, p) => s + p.points) ~/ players.length)}'
                                  : '0',
                              icon: Icons.trending_up_rounded,
                              iconColor: AppColors.info,
                            )),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const SectionHeader(title: 'Individual Progress'),
                        const SizedBox(height: 12),
                        ...players.map((player) => _buildPlayerProgressCard(context, player)),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (e, _) => Container(
                    padding: const EdgeInsets.all(40),
                    child: Text('Failed to load: $e',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerProgressCard(BuildContext context, PlayerModel player) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: AppColors.gradientPrimary),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(player.name,
                        style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: player.points > 0 ? (player.points % 100) / 100 : 0,
                        minHeight: 6,
                        backgroundColor: AppColors.borderLight,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMiniStat(Icons.emoji_events_rounded, '${player.championshipWins} Wins', AppColors.gold),
              const SizedBox(width: 12),
              _buildMiniStat(Icons.stars_rounded, '${player.points} XP', AppColors.primary),
              const SizedBox(width: 12),
              _buildMiniStat(Icons.trending_up_rounded, player.level ?? 'Beginner', AppColors.success),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(label,
                style: AppTextStyles.caption.copyWith(
                    color: color, fontWeight: FontWeight.w600, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
