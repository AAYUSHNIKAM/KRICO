import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/widgets/page_headers/page_hero.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../design_system/radius/radius.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../design_system/utils/extensions.dart';
import '../../../services/providers.dart';

class StudentsTab extends ConsumerWidget {
  final String coachId;
  const StudentsTab({super.key, required this.coachId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(coachPlayersProvider(coachId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final padH = context.width > 1280
        ? SpacingScale.s32
        : context.width > 600
            ? SpacingScale.s24
            : SpacingScale.s16;

    return Scaffold(
      body: Container(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: CustomScrollView(
          slivers: [
            const PageHero(
              title: 'My Students',
              subtitle: 'Manage your athletes',
              backgroundColor: AppColors.primary,
            ),
            studentsAsync.when(
              data: (docs) {
                if (docs.isEmpty) {
                  return SliverFillRemaining(
                    child: Container(
                      padding: const EdgeInsets.all(SpacingScale.s40),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                'assets/animations/sports_ball.gif',
                                width: 64,
                                height: 64,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: (isDark ? AppColors.textTertiary : AppColors.lightTextTertiary).withValues(alpha: 0.12),
                                    borderRadius: AppRadius.brXl2,
                                  ),
                                  child: Icon(Icons.people_outline_rounded,
                                      size: 32,
                                      color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
                                ),
                              ),
                            ),
                            const SizedBox(height: SpacingScale.s16),
                            Text('No students yet',
                                style: AppTextStyles.title3.copyWith(
                                  color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                                  fontWeight: FontWeight.w600,
                                )),
                            const SizedBox(height: SpacingScale.s4),
                            Text('Students will appear when they book sessions',
                                style: AppTextStyles.bodySm.copyWith(
                                  color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                                )),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final data = docs[index];
                      final name = data['name'] as String? ?? 'Unknown';
                      final level = data['level'] as String? ?? 'Beginner';
                      final points = (data['points'] as num?)?.toInt() ?? 0;
                      final sport = (data['sports'] as List<dynamic>?)?.cast<String>() ?? ['General'];
                      final rank = (data['rank'] as num?)?.toInt() ?? 0;

                      final playerId = data['playerId'] as String? ?? '';

                      return GestureDetector(
                        onTap: () => context.push(
                          '/student-progress/$playerId',
                          extra: {'coachId': coachId},
                        ),
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: padH, vertical: SpacingScale.s6),
                          padding: const EdgeInsets.all(SpacingScale.s16),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.card : AppColors.lightCard,
                            borderRadius: AppRadius.brXl3,
                            border: Border.all(
                              color: isDark ? AppColors.border : AppColors.lightBorder,
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => context.push('/profile/$playerId'),
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.purple,
                                    borderRadius: AppRadius.brLg,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: AppRadius.brLg,
                                    child: Image.asset(
                                      index % 2 == 0 ? 'assets/avatars/athlete_1.jpg' : 'assets/avatars/athlete_2.jpg',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Center(
                                        child: Text(
                                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                                          style: const TextStyle(
                                              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: SpacingScale.s16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name,
                                        style: AppTextStyles.title3.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: SpacingScale.s2),
                                    Text('${sport.join(", ")} \u2022 $level',
                                        style: AppTextStyles.body.copyWith(
                                            color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: SpacingScale.s8, vertical: SpacingScale.s2),
                                        decoration: BoxDecoration(
                                          color: AppColors.purple.withValues(alpha: 0.12),
                                          borderRadius: AppRadius.brLg,
                                        ),
                                        child: Text('#$rank',
                                            style: AppTextStyles.labelSm.copyWith(
                                                color: AppColors.purple, fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                    const SizedBox(height: SpacingScale.s4),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text('$points XP',
                                          style: AppTextStyles.bodySm.copyWith(
                                              color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary)),
                                    ),
                                    const SizedBox(height: SpacingScale.s4),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text('View progress',
                                          style: AppTextStyles.labelSm.copyWith(
                                              color: AppColors.primary, fontWeight: FontWeight.w600)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: SpacingScale.s4),
                              Icon(Icons.chevron_right_rounded,
                                  size: 20,
                                  color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: (index * 60).ms).slideY(begin: 0.1, end: 0);
                    },
                    childCount: docs.length,
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (e, _) {
                debugPrint('Students error: $e');
                return SliverFillRemaining(
                  child: Container(
                    padding: const EdgeInsets.all(SpacingScale.s40),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.danger.withValues(alpha: 0.12),
                              borderRadius: AppRadius.brXl2,
                            ),
                            child: Icon(Icons.cloud_off_rounded, size: 32, color: AppColors.danger),
                          ),
                          const SizedBox(height: SpacingScale.s16),
                          Text('Unable to load students',
                              style: AppTextStyles.title3.copyWith(
                                color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                                fontWeight: FontWeight.w600,
                              )),
                          const SizedBox(height: SpacingScale.s4),
                          Text('Please try again',
                              style: AppTextStyles.bodySm.copyWith(
                                color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                              )),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: SpacingScale.s24)),
          ],
        ),
      ),
    ),
  ),
);
  }
}
