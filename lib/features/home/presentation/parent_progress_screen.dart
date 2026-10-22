import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/radius/radius.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../design_system/widgets/page_headers/page_hero.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../services/providers.dart';
import '../../../models/player_model.dart';

class ParentProgressScreen extends ConsumerWidget {
  final String parentId;
  const ParentProgressScreen({super.key, required this.parentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final playersAsync = ref.watch(parentPlayersProvider(parentId));
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: CustomScrollView(
            slivers: [
          PageHero(
            title: 'Progress Reports',
            subtitle: "Track your children's growth",
            backgroundColor: AppColors.primary,
            expandedHeight: 120,
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              SpacingScale.s16,
              SpacingScale.s16,
              SpacingScale.s16,
              SpacingScale.s32,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                playersAsync.when(
                  data: (players) {
                    if (players.isEmpty) {
                      return Container(
                        padding: EdgeInsets.all(SpacingScale.s40),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.card : AppColors.lightCard,
                          borderRadius: AppRadius.brXl3,
                          border: Border.all(
                            color: isDark
                                ? AppColors.border
                                : AppColors.lightBorder,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.child_care_rounded,
                                size: 48,
                                color: isDark
                                    ? AppColors.textTertiary
                                    : AppColors.lightTextTertiary),
                            SizedBox(height: SpacingScale.s12),
                            Text('No children linked yet',
                                style: AppTextStyles.bodyLg.copyWith(
                                    color: isDark
                                        ? AppColors.textSecondary
                                        : AppColors.lightTextSecondary)),
                          ],
                        ),
                      ).animate().fadeIn(duration: 300.ms);
                    }
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                label: 'Total Children',
                                value: players.length.toString(),
                                icon: Icons.people_rounded,
                                color: AppColors.primary,
                                isDark: isDark,
                              ),
                            ),
                            SizedBox(width: SpacingScale.s12),
                            Expanded(
                              child: _buildStatCard(
                                label: 'Combined XP',
                                value: players
                                    .fold(0, (s, p) => s + p.points)
                                    .toString(),
                                icon: Icons.workspace_premium_rounded,
                                color: AppColors.gold,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ).animate().fadeIn(duration: 300.ms, delay: 50.ms)
                            .slideY(begin: 0.05, end: 0, duration: 300.ms),
                        SizedBox(height: SpacingScale.s12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                label: 'Total Wins',
                                value: players
                                    .fold(
                                        0, (s, p) => s + p.championshipWins)
                                    .toString(),
                                icon: Icons.emoji_events_rounded,
                                color: AppColors.warning,
                                isDark: isDark,
                              ),
                            ),
                            SizedBox(width: SpacingScale.s12),
                            Expanded(
                              child: _buildStatCard(
                                label: 'Avg XP/Child',
                                value: players.isNotEmpty
                                    ? '${(players.fold(0, (s, p) => s + p.points) ~/ players.length)}'
                                    : '0',
                                icon: Icons.trending_up_rounded,
                                color: AppColors.primary,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ).animate().fadeIn(duration: 300.ms, delay: 100.ms)
                            .slideY(begin: 0.05, end: 0, duration: 300.ms),
                        SizedBox(height: SpacingScale.s24),
                        Row(
                          children: [
                            Text('Individual Progress',
                                style: AppTextStyles.title2.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.textPrimary
                                        : AppColors.lightTextPrimary)),
                          ],
                        ),
                        SizedBox(height: SpacingScale.s12),
                        ...players
                            .asMap()
                            .entries
                            .map(
                              (entry) => _buildPlayerProgressCard(
                                      context, entry.value, isDark)
                                  .animate()
                                  .fadeIn(
                                      duration: 300.ms,
                                      delay: Duration(
                                          milliseconds: 150 + entry.key * 50))
                                  .slideY(
                                      begin: 0.05,
                                      end: 0,
                                      duration: 300.ms),
                            ),
                      ],
                    );
                  },
                  loading: () => Center(
                    child: Padding(
                      padding: EdgeInsets.all(SpacingScale.s40),
                      child: const CircularProgressIndicator(),
                    ),
                  ),
                  error: (e, _) => Container(
                    padding: EdgeInsets.all(SpacingScale.s40),
                    child: Text('Failed to load: $e',
                        style: AppTextStyles.body.copyWith(
                            color: AppColors.danger)),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    ),
  ),
);
}

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: SpacingScale.s12),
      padding: EdgeInsets.all(SpacingScale.s16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl3,
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppRadius.brLg,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          SizedBox(height: SpacingScale.s10),
          Text(value,
              style: AppTextStyles.numericSm.copyWith(
                  color: isDark
                      ? AppColors.textPrimary
                      : AppColors.lightTextPrimary)),
          SizedBox(height: SpacingScale.s2),
          Text(label,
              style: AppTextStyles.labelSm.copyWith(
                  color: isDark
                      ? AppColors.textTertiary
                      : AppColors.lightTextTertiary)),
        ],
      ),
    );
  }

  Widget _buildPlayerProgressCard(
      BuildContext context, PlayerModel player, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: SpacingScale.s12),
      padding: EdgeInsets.all(SpacingScale.s16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl3,
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.primary : AppColors.primary,
                  borderRadius: AppRadius.brLg,
                ),
                child: Center(
                  child: Text(
                    player.name.isNotEmpty
                        ? player.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              SizedBox(width: SpacingScale.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(player.name,
                        style: AppTextStyles.title3
                            .copyWith(fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary)),
                    SizedBox(height: SpacingScale.s4),
                    ClipRRect(
                      borderRadius: AppRadius.brSm,
                      child: LinearProgressIndicator(
                        value: player.points > 0
                            ? (player.points % 100) / 100
                            : 0,
                        minHeight: 6,
                        backgroundColor: isDark
                            ? AppColors.border
                            : AppColors.lightBorder,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: SpacingScale.s12),
          Row(
            children: [
              _buildMiniStat(
                  Icons.emoji_events_rounded,
                  '${player.championshipWins} Wins',
                  AppColors.gold,
                  isDark),
              SizedBox(width: SpacingScale.s12),
              _buildMiniStat(Icons.stars_rounded, '${player.points} XP',
                  AppColors.primary, isDark),
              SizedBox(width: SpacingScale.s12),
              _buildMiniStat(
                  Icons.trending_up_rounded,
                  player.level ?? 'Beginner',
                  AppColors.success,
                  isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(
      IconData icon, String label, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: SpacingScale.s8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: AppRadius.brLg,
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            SizedBox(height: SpacingScale.s4),
            Text(label,
                style: AppTextStyles.labelSm
                    .copyWith(color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
