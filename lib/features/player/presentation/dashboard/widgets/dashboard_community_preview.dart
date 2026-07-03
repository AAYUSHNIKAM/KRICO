import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../../design_system/colors/app_colors.dart';
import '../../../../../design_system/typography/text_styles.dart';
import '../../../../../design_system/spacing/spacing_scale.dart';
import '../../../../../design_system/radius/radius.dart';
import '../../../../../design_system/responsive/responsive_helpers.dart';
import '../../../../../design_system/icons/app_icons.dart';
import '../../../../../design_system/widgets/surfaces/app_card.dart';
import '../../../../../design_system/widgets/misc/avatar_widget.dart';
import '../../../../../design_system/widgets/misc/badge_widget.dart';
import '../../../../../services/providers.dart';
import 'dashboard_loading.dart';
import 'dashboard_empty_state.dart';

class DashboardCommunityPreview extends ConsumerWidget {
  const DashboardCommunityPreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.isDesktop ? SpacingScale.s32 : SpacingScale.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: context.isDesktop ? SpacingScale.s28 : SpacingScale.s24),
          usersAsync.when(
            data: (snap) {
              final users = snap.docs.take(3).toList();
              if (users.isEmpty) {
                return DashboardEmptyState(
                  icon: AppIcons.group,
                  title: 'Community Feed',
                  subtitle: 'Be the first to share an update.',
                  actionLabel: 'Join Community',
                  onActionTap: () => context.push('/community'),
                  accentColor: AppColors.emerald,
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(AppIcons.group, size: 18, color: AppColors.emerald),
                      const SizedBox(width: SpacingScale.s8),
                      Text('Community', style: AppTextStyles.title2.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark ? AppColors.textPrimary : AppColors.lightTextPrimary,
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
                              Text('Open Feed', style: AppTextStyles.labelSm.copyWith(color: AppColors.emerald, fontWeight: FontWeight.w600)),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_forward_rounded, size: 12, color: AppColors.emerald),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SpacingScale.s16),
                  ...users.map<Widget>((doc) {
                    final data = doc.data();
                    final name = data['name'] as String? ?? 'User';
                    final role = data['role'] as String? ?? 'Member';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: SpacingScale.s8),
                      child: AppCard(
                        padding: const EdgeInsets.all(SpacingScale.s12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AppAvatar(name: name, size: AvatarSize.sm),
                            const SizedBox(width: SpacingScale.s12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                                      const SizedBox(width: SpacingScale.s6),
                                      AppBadge(label: role, variant: BadgeVariant.neutral, size: BadgeSize.sm),
                                    ],
                                  ),
                                  const SizedBox(height: SpacingScale.s4),
                                  Text('Joined the community', style: AppTextStyles.caption.copyWith(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? AppColors.textSecondary : AppColors.lightTextSecondary,
                                  )),
                                ],
                              ),
                            ),
                            Container(
                              width: 32, height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.emerald.withValues(alpha: 0.1),
                                borderRadius: AppRadius.brFull,
                              ),
                              child: Icon(Icons.favorite_border_rounded, size: 14, color: AppColors.emerald),
                            ),
                          ],
                        ),
                      ),
                    ).animate(delay: (450 + 100).ms).fadeIn(duration: 300.ms, curve: Curves.easeOut).slideY(begin: 0.05, end: 0);
                  }).toList(),
                ],
              );
            },
            loading: () => const DashboardSectionShimmer(height: 180),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
