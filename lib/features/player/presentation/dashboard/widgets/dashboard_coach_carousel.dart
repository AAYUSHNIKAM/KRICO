import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../../design_system/colors/app_colors.dart';
import '../../../../../design_system/typography/text_styles.dart';
import '../../../../../design_system/spacing/spacing_scale.dart';
import '../../../../../design_system/radius/radius.dart';
import '../../../../../design_system/responsive/responsive_helpers.dart';
import '../../../../../design_system/widgets/surfaces/app_card.dart';
import '../../../../../design_system/widgets/buttons/primary_button.dart';
import '../../../../../design_system/widgets/buttons/outline_button.dart';
import '../../../../../design_system/widgets/buttons/button_types.dart';
import '../../../../../models/coach_model.dart';
import '../../../../../services/providers.dart';
import 'dashboard_loading.dart';
import 'dashboard_empty_state.dart';
import 'dashboard_error_state.dart';

class DashboardCoachCarousel extends ConsumerWidget {
  final String playerId;

  const DashboardCoachCarousel({super.key, required this.playerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coachesAsync = ref.watch(coachesStreamProvider);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.isDesktop ? SpacingScale.s32 : SpacingScale.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: context.isDesktop ? SpacingScale.s24 : SpacingScale.s20),
          coachesAsync.when(
            data: (coaches) {
              if (coaches.isEmpty) {
                return DashboardEmptyState(
                  icon: Icons.person_search_rounded,
                  title: 'No Coaches Yet',
                  subtitle: 'Browse available coaches and book your first session.',
                  actionLabel: 'Browse Coaches',
                  onActionTap: () => context.push('/coach-discovery'),
                  accentColor: AppColors.primary,
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person_search_rounded, size: 18, color: AppColors.primary),
                      const SizedBox(width: SpacingScale.s8),
                      Text('Find a Coach', style: AppTextStyles.title2.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                        fontWeight: FontWeight.w600,
                      )),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => context.push('/coach-discovery'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s10, vertical: SpacingScale.s4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: AppRadius.brFull,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('View All', style: AppTextStyles.labelSm.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_forward_rounded, size: 12, color: AppColors.primary),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SpacingScale.s16),
                  SizedBox(
                    height: 240,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.zero,
                      itemCount: coaches.length,
                      separatorBuilder: (_, __) => const SizedBox(width: SpacingScale.s12),
                      itemBuilder: (context, i) => _CoachCard(coach: coaches[i], index: i),
                    ),
                  ),
                ],
              );
            },
            loading: () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                DashboardSectionShimmer(height: 240),
              ],
            ),
            error: (e, _) => DashboardErrorState(message: 'Could not load coaches'),
          ),
        ],
      ),
    );
  }
}

class _CoachCard extends StatelessWidget {
  final CoachModel coach;
  final int index;
  const _CoachCard({required this.coach, required this.index});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final secColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final initials = coach.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();

    return SizedBox(
      width: 240,
      child: AppCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.12),
                    AppColors.primary.withValues(alpha: 0.04),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl2)),
              ),
              child: Center(
                child: coach.photoUrl != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl2)),
                        child: Image.network(coach.photoUrl!, width: double.infinity, height: 100, fit: BoxFit.cover),
                      )
                    : Text(initials, style: AppTextStyles.heading2.copyWith(color: AppColors.primary.withValues(alpha: 0.3))),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(SpacingScale.s12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(coach.name, style: AppTextStyles.title3.copyWith(color: textColor, fontWeight: FontWeight.w600),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        if (coach.isVerified)
                          Icon(Icons.verified_rounded, size: 14, color: AppColors.primary),
                      ],
                    ),
                    const SizedBox(height: SpacingScale.s4),
                    Text(coach.specialization ?? 'Coach', style: AppTextStyles.caption.copyWith(color: secColor),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 14, color: AppColors.warning),
                        const SizedBox(width: SpacingScale.s4),
                        Text(coach.rating.toStringAsFixed(1), style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(width: SpacingScale.s10),
                        Container(width: 3, height: 3, decoration: BoxDecoration(color: secColor, shape: BoxShape.circle)),
                        const SizedBox(width: SpacingScale.s6),
                        Text('${coach.experience}y exp', style: AppTextStyles.labelSm.copyWith(color: secColor)),
                        const Spacer(),
                        Text('₹${coach.hourlyRate.toInt()}', style: AppTextStyles.labelSm.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: SpacingScale.s10),
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            onPressed: () {},
                            label: 'Book',
                            size: ButtonSize.sm,
                          ),
                        ),
                        const SizedBox(width: SpacingScale.s8),
                        Expanded(
                          child: OutlineButton(
                            onPressed: () => context.push('/coach-discovery'),
                            label: 'Profile',
                            size: ButtonSize.sm,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: (200 + index * 80).ms).fadeIn(duration: 350.ms, curve: Curves.easeOut).slideX(begin: 0.05, end: 0);
  }
}
