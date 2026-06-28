import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/stats_card.dart';
import '../../../models/gamification_model.dart';
import '../../../models/player_model.dart';
import '../../../services/providers.dart';

class AchievementTab extends ConsumerWidget {
  final String playerId;
  final String playerName;
  const AchievementTab({super.key, required this.playerId, required this.playerName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerAsync = ref.watch(playerProvider(playerId));
    final achievementsAsync = ref.watch(playerAchievementsProvider(playerId));
    final playerPoints = playerAsync.asData?.value.points ?? 0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.surfaceDark,
              AppColors.surfaceMid,
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.gradientPrimary,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Achievements',
                              style: AppTextStyles.displaySmall.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text('Track your progress & milestones',
                              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: playerAsync.when(
                data: (player) => _buildPlayerStats(context, player),
                loading: () => _buildShimmerStats(),
                error: (e, _) => SizedBox(
                  height: 120,
                  child: Center(child: Text('Failed to load profile', style: TextStyle(color: AppColors.error))),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text('All Achievements', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w600)),
              ),
            ),
            achievementsAsync.when(
              data: (unlockedList) {
                final unlockedIds = unlockedList.map((e) => e['achievementId'] as String).toSet();
                final achievements = AchievementModel.achievements;
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final achievement = achievements[index];
                      final isUnlocked = unlockedIds.contains(achievement.id);
                      return _buildAchievementCard(context, achievement, isUnlocked, playerPoints)
                          .animate()
                          .fadeIn(delay: (index * 80).ms)
                          .slideX(begin: 0.1, end: 0);
                    },
                    childCount: achievements.length,
                  ),
                );
              },
              loading: () => SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('Failed to load achievements', style: TextStyle(color: AppColors.error))),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Shimmer.fromColors(
        baseColor: AppColors.borderLight.withValues(alpha: 0.2),
        highlightColor: AppColors.borderLight.withValues(alpha: 0.4),
        child: Row(
          children: List.generate(3, (_) => Expanded(
            child: Container(
              height: 80,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          )),
        ),
      ),
    );
  }

  Widget _buildPlayerStats(BuildContext context, PlayerModel player) {
    final points = player.points;
    final rank = player.rank;
    final level = LevelModel.getLevel(points);
    final progress = LevelModel.getProgress(points);
    final rankData = RankModel.ranks.isNotEmpty ? RankModel.ranks[rank.clamp(0, RankModel.ranks.length - 1)] : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatsCard(
                  label: 'Level',
                  value: '${level.level}',
                  icon: Icons.trending_up_rounded,
                  gradient: AppColors.gradientPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatsCard(
                  label: 'Rank',
                  value: rankData != null ? '#$rank ${rankData.title}' : 'Unranked',
                  icon: Icons.emoji_events_rounded,
                  gradient: AppColors.gradientGold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatsCard(
                  label: 'Points',
                  value: '$points',
                  icon: Icons.stars_rounded,
                  gradient: AppColors.gradientAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.15)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Progress to next level', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
                      Text('${(progress * 100).toInt()}%',
                          style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: AppColors.borderLight.withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    level.level == 6
                        ? 'Maximum level reached!'
                        : '${level.maxPoints - points} XP to Level ${level.level + 1}',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textDim),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(BuildContext context, AchievementModel achievement, bool isUnlocked, int playerPoints) {
    final canUnlock = !isUnlocked && playerPoints >= achievement.pointsRequired;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnlocked ? AppColors.primary.withValues(alpha: 0.06) : AppColors.cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUnlocked
                ? AppColors.primary.withValues(alpha: 0.25)
                : canUnlock
                    ? AppColors.accent.withValues(alpha: 0.2)
                    : AppColors.borderLight.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : canUnlock
                        ? AppColors.accent.withValues(alpha: 0.1)
                        : AppColors.borderLight.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text(achievement.icon, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(achievement.title,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isUnlocked ? AppColors.primary : AppColors.textPrimary,
                      )),
                  const SizedBox(height: 2),
                  Text(achievement.description,
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : AppColors.borderLight.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${achievement.pointsRequired} XP',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isUnlocked ? AppColors.primary : AppColors.textDim,
                        fontWeight: FontWeight.w600,
                      )),
                ),
                const SizedBox(height: 4),
                Icon(
                  isUnlocked ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
                  size: 18,
                  color: isUnlocked ? AppColors.primary : AppColors.textDim,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
