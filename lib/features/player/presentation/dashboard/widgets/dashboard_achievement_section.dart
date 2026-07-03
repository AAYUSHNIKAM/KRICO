import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../design_system/colors/app_colors.dart';
import '../../../../../design_system/typography/text_styles.dart';
import '../../../../../design_system/spacing/spacing_scale.dart';
import '../../../../../design_system/radius/radius.dart';
import '../../../../../design_system/responsive/responsive_helpers.dart';
import '../../../../../design_system/icons/app_icons.dart';
import '../../../../../models/gamification_model.dart';
import '../../../../../services/providers.dart';
import 'dashboard_loading.dart';

class DashboardAchievementSection extends ConsumerWidget {
  final String playerId;

  const DashboardAchievementSection({super.key, required this.playerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(playerAchievementsProvider(playerId));

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.isDesktop ? SpacingScale.s32 : SpacingScale.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: context.isDesktop ? SpacingScale.s24 : SpacingScale.s20),
          achievementsAsync.when(
            data: (unlockedList) {
              final unlockedIds = unlockedList.map((e) => e['achievementId'] as String).toSet();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(AppIcons.trophy, size: 18, color: AppColors.warning),
                      const SizedBox(width: SpacingScale.s8),
                      Text('Achievements', style: AppTextStyles.title2.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                        fontWeight: FontWeight.w600,
                      )),
                      const Spacer(),
                      Text('${unlockedIds.length}/${AchievementModel.achievements.length}', style: AppTextStyles.labelSm.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: SpacingScale.s16),
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.zero,
                      itemCount: AchievementModel.achievements.length,
                      separatorBuilder: (_, __) => const SizedBox(width: SpacingScale.s12),
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
              );
            },
            loading: () => const DashboardSectionShimmer(height: 140),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
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
    final secColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    return SizedBox(
      width: 96,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 60, height: 60,
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
              child: Text(achievement.icon, style: TextStyle(fontSize: isUnlocked ? 28 : 22, color: isUnlocked ? null : (isDark ? AppColors.textTertiary : AppColors.lightTextTertiary))),
            ),
          ),
          const SizedBox(height: SpacingScale.s8),
          Text(achievement.title, style: AppTextStyles.captionXs.copyWith(
            color: isUnlocked ? textColor : secColor,
            fontWeight: isUnlocked ? FontWeight.w600 : FontWeight.w400,
          ), maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
        ],
      ),
    ).animate(delay: (500 + index * 60).ms).fadeIn(duration: 300.ms, curve: Curves.easeOut).slideY(begin: 0.06, end: 0);
  }
}
