import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../design_system/colors/app_colors.dart';
import '../../../../../design_system/typography/text_styles.dart';
import '../../../../../design_system/spacing/spacing_scale.dart';
import '../../../../../design_system/radius/radius.dart';
import '../../../../../design_system/responsive/responsive_helpers.dart';
import '../../../../../models/gamification_model.dart';
import '../../../../../services/providers.dart';
import 'package:go_router/go_router.dart';
import 'dashboard_loading.dart';

class AchievementsSection extends ConsumerWidget {
  final String playerId;

  const AchievementsSection({super.key, required this.playerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(playerAchievementsProvider(playerId));
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;
    final padH = isDesktop ? SpacingScale.s32 : (isTablet ? SpacingScale.s24 : SpacingScale.s16);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: isDesktop ? SpacingScale.s28 : SpacingScale.s24),
          achievementsAsync.when(
            data: (unlockedList) {
              final unlockedIds = unlockedList.map((e) => e['achievementId'] as String).toSet();
              return _AchievementsContent(playerId: playerId, unlockedIds: unlockedIds);
            },
            loading: () => const DashboardSectionShimmer(height: 160),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _AchievementsContent extends StatelessWidget {
  final String playerId;
  final Set<String> unlockedIds;

  const _AchievementsContent({required this.playerId, required this.unlockedIds});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final secColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

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
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: AppRadius.brLg,
                  ),
                  child: const Icon(Icons.emoji_events_rounded, size: 18, color: AppColors.warning),
                ),
                const SizedBox(width: SpacingScale.s10),
                Expanded(
                  child: Text('Achievements',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.title2.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => context.push('/player-certificates/$playerId'),
                  borderRadius: AppRadius.brFull,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.12),
                      borderRadius: AppRadius.brFull,
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.workspace_premium_rounded, size: 12, color: AppColors.gold),
                        const SizedBox(width: 4),
                        Text(
                          'Trophy Room & PDF',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(Icons.arrow_forward_ios_rounded, size: 9, color: AppColors.gold),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: SpacingScale.s8),
                Text('${unlockedIds.length}/${AchievementModel.achievements.length}', style: AppTextStyles.label.copyWith(
                  color: secColor,
                  fontWeight: FontWeight.w500,
                )),
              ],
            ),
            const SizedBox(height: SpacingScale.s16),
            SizedBox(
              height: 114,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemCount: AchievementModel.achievements.length,
                separatorBuilder: (_, _) => const SizedBox(width: SpacingScale.s12),
                itemBuilder: (context, i) {
                  final achievement = AchievementModel.achievements[i];
                  final isUnlocked = unlockedIds.contains(achievement.id);
                  return _AchievementBadge(
                    achievement: achievement,
                    isUnlocked: isUnlocked,
                    index: i,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: 500.ms).fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }
}

class _AchievementBadge extends StatelessWidget {
  final AchievementModel achievement;
  final bool isUnlocked;
  final int index;

  const _AchievementBadge({
    required this.achievement,
    required this.isUnlocked,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;

    return SizedBox(
      width: 80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? AppColors.emerald.withValues(alpha: 0.12)
                  : (isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary),
              borderRadius: AppRadius.brXl2,
              border: isUnlocked
                  ? Border.all(color: AppColors.emerald.withValues(alpha: 0.3), width: 1.5)
                  : null,
            ),
            child: Center(
              child: Text(achievement.icon, style: TextStyle(fontSize: isUnlocked ? 24 : 20)),
            ),
          ),
          const SizedBox(height: SpacingScale.s6),
          Text(achievement.title, style: AppTextStyles.captionXs.copyWith(
            color: isUnlocked ? textColor : (isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
            fontWeight: isUnlocked ? FontWeight.w600 : FontWeight.w400,
          ), maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
        ],
      ),
    ).animate(delay: (500 + index * 60).ms).fadeIn(duration: 300.ms, curve: Curves.easeOut).slideY(begin: 0.06, end: 0);
  }
}
