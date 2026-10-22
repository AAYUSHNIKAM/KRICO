import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../design_system/widgets/page_headers/page_hero.dart';
import '../../../design_system/radius/radius.dart';
import '../../../models/gamification_model.dart';
import '../../../models/player_model.dart';
import '../../../services/providers.dart';

class AchievementTab extends ConsumerWidget {
  final String playerId;
  final String playerName;
  const AchievementTab({super.key, required this.playerId, required this.playerName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final playerAsync = ref.watch(playerProvider(playerId));
    final achievementsAsync = ref.watch(playerAchievementsProvider(playerId));
    final playerPoints = playerAsync.asData?.value.points ?? 0;

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          PageHero(
            title: 'Achievements',
            subtitle: 'Track your progress & milestones',
            expandedHeight: 200,
          ),
          SliverToBoxAdapter(
            child: playerAsync.when(
              data: (player) => _buildPlayerStats(context, player),
              loading: () => _buildShimmerStats(context),
              error: (e, _) => SizedBox(
                height: 120,
                child: Center(child: Text('Failed to load profile', style: TextStyle(color: AppColors.danger))),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(SpacingScale.s20, SpacingScale.s16, SpacingScale.s20, SpacingScale.s8),
              child: Text('All Achievements', style: AppTextStyles.title1.copyWith(fontWeight: FontWeight.w600)),
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
                        .animate(delay: (index * 80).ms)
                        .fadeIn(duration: 350.ms)
                        .slideX(begin: 0.1, end: 0);
                  },
                  childCount: achievements.length,
                ),
              );
            },
            loading: () => SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Failed to load achievements', style: TextStyle(color: AppColors.danger))),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildShimmerStats(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.fromLTRB(SpacingScale.s20, SpacingScale.s16, SpacingScale.s20, SpacingScale.s8),
      child: Shimmer.fromColors(
        baseColor: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.2),
        highlightColor: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.4),
        child: Row(
          children: List.generate(3, (_) => Expanded(
            child: Container(
              height: 80,
              margin: EdgeInsets.symmetric(horizontal: SpacingScale.s4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.brXl3,
              ),
            ),
          )),
        ),
      ),
    );
  }

  Widget _buildPlayerStats(BuildContext context, PlayerModel player) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final points = player.points;
    final rank = player.rank;
    final level = LevelModel.getLevel(points);
    final progress = LevelModel.getProgress(points);
    final rankData = RankModel.ranks.isNotEmpty ? RankModel.ranks[rank.clamp(0, RankModel.ranks.length - 1)] : null;

    return Padding(
      padding: EdgeInsets.fromLTRB(SpacingScale.s20, 0, SpacingScale.s20, SpacingScale.s8),
      child: Column(
        children: [
          SizedBox(height: SpacingScale.s16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(SpacingScale.s12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.card : AppColors.lightCard,
                    borderRadius: AppRadius.brXl2,
                    border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder, width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.trending_up_rounded, size: 20, color: AppColors.primary),
                      SizedBox(height: SpacingScale.s8),
                      Text('${level.level}', style: AppTextStyles.numericSm.copyWith(color: AppColors.primary)),
                      Text('Level', style: AppTextStyles.caption.copyWith(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
                    ],
                  ),
                ),
              ),
              SizedBox(width: SpacingScale.s12),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(SpacingScale.s12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.card : AppColors.lightCard,
                    borderRadius: AppRadius.brXl2,
                    border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder, width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.emoji_events_rounded, size: 20, color: AppColors.purple),
                      SizedBox(height: SpacingScale.s8),
                      Text(rankData != null ? '#$rank ${rankData.title}' : 'Unranked', style: AppTextStyles.numericSm.copyWith(color: AppColors.purple)),
                      Text('Rank', style: AppTextStyles.caption.copyWith(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
                    ],
                  ),
                ),
              ),
              SizedBox(width: SpacingScale.s12),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(SpacingScale.s12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.card : AppColors.lightCard,
                    borderRadius: AppRadius.brXl2,
                    border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder, width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.stars_rounded, size: 20, color: AppColors.gold),
                      SizedBox(height: SpacingScale.s8),
                      Text('$points', style: AppTextStyles.numericSm.copyWith(color: AppColors.gold)),
                      Text('Points', style: AppTextStyles.caption.copyWith(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: SpacingScale.s20),
          Container(
            padding: EdgeInsets.all(SpacingScale.s16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.card : AppColors.lightCard,
              borderRadius: AppRadius.brXl3,
              border: Border.all(color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.15), width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Progress to next level', style: AppTextStyles.label.copyWith(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
                    Text('${(progress * 100).toInt()}%',
                        style: AppTextStyles.label.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ],
                ),
                SizedBox(height: SpacingScale.s10),
                ClipRRect(
                  borderRadius: AppRadius.brSm,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: SpacingScale.s8),
                Text(
                  level.level == 6
                      ? 'Maximum level reached!'
                      : '${level.maxPoints - points} XP to Level ${level.level + 1}',
                  style: AppTextStyles.caption.copyWith(color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(BuildContext context, AchievementModel achievement, bool isUnlocked, int playerPoints) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canUnlock = !isUnlocked && playerPoints >= achievement.pointsRequired;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: SpacingScale.s20, vertical: 5),
      padding: EdgeInsets.all(SpacingScale.s16),
      decoration: BoxDecoration(
        color: isUnlocked ? AppColors.primary.withValues(alpha: 0.06) : (isDark ? AppColors.card : AppColors.lightCard),
        borderRadius: AppRadius.brXl3,
        border: Border.all(
          color: isUnlocked
              ? AppColors.primary.withValues(alpha: 0.25)
              : canUnlock
                  ? AppColors.purple.withValues(alpha: 0.2)
                  : (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.1),
          width: 0.5,
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
                      ? AppColors.purple.withValues(alpha: 0.1)
                      : (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.15),
              borderRadius: AppRadius.brMd,
            ),
            child: Center(child: Text(achievement.icon, style: TextStyle(fontSize: 24))),
          ),
          SizedBox(width: SpacingScale.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(achievement.title,
                    style: AppTextStyles.title2.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isUnlocked ? AppColors.primary : (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary),
                    )),
                SizedBox(height: SpacingScale.s2),
                Text(achievement.description,
                    style: AppTextStyles.caption.copyWith(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
              ],
            ),
          ),
          SizedBox(width: SpacingScale.s12),
          Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: SpacingScale.s8, vertical: SpacingScale.s4),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.2),
                  borderRadius: AppRadius.brSm,
                ),
                child: Text('${achievement.pointsRequired} XP',
                    style: AppTextStyles.labelSm.copyWith(
                      color: isUnlocked ? AppColors.primary : (isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
                      fontWeight: FontWeight.w600,
                    )),
              ),
              SizedBox(height: SpacingScale.s4),
              Icon(
                isUnlocked ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
                size: 18,
                color: isUnlocked ? AppColors.primary : (isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
