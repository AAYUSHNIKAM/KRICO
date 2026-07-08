import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../../design_system/colors/app_colors.dart';
import '../../../../../design_system/typography/text_styles.dart';
import '../../../../../design_system/spacing/spacing_scale.dart';
import '../../../../../design_system/radius/radius.dart';
import '../../../../../design_system/responsive/responsive_helpers.dart';
import '../../../../../design_system/widgets/misc/avatar_widget.dart';
import '../../../../../services/providers.dart';
import 'dashboard_loading.dart';
import 'dashboard_empty_state.dart';

class CommunitySection extends ConsumerWidget {
  final String playerId;

  const CommunitySection({super.key, required this.playerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;
    final padH = isDesktop ? SpacingScale.s32 : (isTablet ? SpacingScale.s24 : SpacingScale.s16);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: isDesktop ? SpacingScale.s28 : SpacingScale.s24),
          usersAsync.when(
            data: (snap) {
              final users = snap.docs.take(4).toList();
              if (users.isEmpty) {
                return DashboardEmptyState(
                  icon: Icons.people_rounded,
                  title: 'Community Feed',
                  subtitle: 'Be the first to share an update.',
                  actionLabel: 'Join Community',
                  onActionTap: () => context.push('/community'),
                  accentColor: AppColors.emerald,
                );
              }
              return _CommunityContent(users: users);
            },
            loading: () => const DashboardSectionShimmer(height: 260),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _CommunityContent extends StatelessWidget {
  final List<dynamic> users;

  const _CommunityContent({required this.users});

  int _dayOfYear() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    return now.difference(startOfYear).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final secColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    final challengeOptions = [
      '30-Day Fitness Challenge',
      'Weekend Tournament',
      '5K Run Challenge',
      'Accuracy Drill Contest',
      'Speed Record Week',
    ];
    final challenge = challengeOptions[_dayOfYear() % challengeOptions.length];
    final participants = 12 + (_dayOfYear() % 40);

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
                    color: AppColors.emerald.withValues(alpha: 0.12),
                    borderRadius: AppRadius.brLg,
                  ),
                  child: Icon(Icons.people_rounded, size: 18, color: AppColors.emerald),
                ),
                const SizedBox(width: SpacingScale.s10),
                Text('Community', style: AppTextStyles.title2.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                )),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.push('/community'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s10, vertical: SpacingScale.s4),
                    decoration: BoxDecoration(
                      color: AppColors.emerald.withValues(alpha: 0.1),
                      borderRadius: AppRadius.brFull,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Open', style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.emerald,
                          fontWeight: FontWeight.w600,
                        )),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 12, color: AppColors.emerald),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpacingScale.s16),
            _TrendingChallenge(challenge: challenge, participants: participants),
            const SizedBox(height: SpacingScale.s12),
            ...users.take(3).map<Widget>((doc) {
              final data = (doc as dynamic).data();
              final name = data['name'] as String? ?? 'Player';
              final city = data['city'] as String? ?? 'Nearby';
              final role = data['role'] as String?;
              final isPlayer = role == 'player';

              return Padding(
                padding: const EdgeInsets.only(bottom: SpacingScale.s8),
                child: Row(
                  children: [
                    AppAvatar(name: name, size: AvatarSize.sm),
                    const SizedBox(width: SpacingScale.s10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: AppTextStyles.body.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          )),
                          Text(
                            isPlayer ? '$city \u2022 Active now' : city,
                            style: AppTextStyles.captionXs.copyWith(color: secColor),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isPlayer ? AppColors.success : AppColors.textDisabled,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    ).animate(delay: 450.ms).fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }
}

class _TrendingChallenge extends StatelessWidget {
  final String challenge;
  final int participants;

  const _TrendingChallenge({required this.challenge, required this.participants});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(SpacingScale.s12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.emerald.withValues(alpha: 0.08),
            AppColors.emerald.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: AppRadius.brXl2,
        border: Border.all(
          color: AppColors.emerald.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.emerald.withValues(alpha: 0.12),
              borderRadius: AppRadius.brLg,
            ),
            child: Icon(Icons.emoji_events_rounded, size: 20, color: AppColors.emerald),
          ),
          const SizedBox(width: SpacingScale.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trending Challenge', style: AppTextStyles.captionXs.copyWith(
                  color: AppColors.emerald,
                  fontWeight: FontWeight.w600,
                )),
                const SizedBox(height: SpacingScale.s2),
                Text(challenge, style: AppTextStyles.body.copyWith(
                  color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                  fontWeight: FontWeight.w600,
                )),
                Text('$participants participants', style: AppTextStyles.captionXs.copyWith(
                  color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                )),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.emerald),
        ],
      ),
    );
  }
}
