import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../design_system/colors/app_colors.dart';
import '../../../../../design_system/typography/text_styles.dart';
import '../../../../../design_system/spacing/spacing_scale.dart';
import '../../../../../design_system/radius/radius.dart';
import '../../../../../design_system/responsive/responsive_helpers.dart';
import '../../../../../services/providers.dart';
import 'dashboard_loading.dart';

class CoachStatsSection extends ConsumerWidget {
  final String coachId;

  const CoachStatsSection({super.key, required this.coachId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(coachStatsProvider(coachId));
    final monthlyAsync = ref.watch(coachMonthlyEarningsProvider(coachId));
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;
    final padH = isDesktop ? SpacingScale.s32 : (isTablet ? SpacingScale.s24 : SpacingScale.s16);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: isDesktop ? SpacingScale.s28 : SpacingScale.s24),
          statsAsync.when(
            data: (stats) {
              final totalSessions = stats['totalSessions'] as int? ?? 0;
              final totalStudents = stats['totalStudents'] as int? ?? 0;
              final monthlyData = monthlyAsync.asData?.value;
              final monthlyEarnings = monthlyData?['monthlyEarnings'] ?? 0;
              return _StatsContent(
                totalSessions: totalSessions,
                totalStudents: totalStudents,
                monthlyEarnings: monthlyEarnings,
              );
            },
            loading: () => const CoachDashboardKpiShimmer(),
            error: (_, _) => const CoachDashboardSectionShimmer(height: 160),
          ),
        ],
      ),
    );
  }
}

class _StatsContent extends StatelessWidget {
  final int totalSessions;
  final int totalStudents;
  final int monthlyEarnings;

  const _StatsContent({
    required this.totalSessions,
    required this.totalStudents,
    required this.monthlyEarnings,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = context.isDesktop;

    if (isDesktop) {
      return Row(
        children: [
          Expanded(child: _StatCard(
            label: 'Total Sessions',
            value: '$totalSessions',
            icon: Icons.schedule_rounded,
            iconColor: AppColors.primary,
            isDark: isDark,
          )),
          const SizedBox(width: SpacingScale.s12),
          Expanded(child: _StatCard(
            label: 'Students',
            value: '$totalStudents',
            icon: Icons.people_rounded,
            iconColor: AppColors.emerald,
            isDark: isDark,
          )),
          const SizedBox(width: SpacingScale.s12),
          Expanded(child: _StatCard(
            label: 'Monthly Earnings',
            value: '\u20B9$monthlyEarnings',
            icon: Icons.account_balance_wallet_rounded,
            iconColor: AppColors.warning,
            isDark: isDark,
          )),
          const SizedBox(width: SpacingScale.s12),
          Expanded(child: _StatCard(
            label: 'Active Now',
            value: 'Online',
            icon: Icons.circle_rounded,
            iconColor: AppColors.success,
            isDark: isDark,
          )),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _StatCard(
              label: 'Total Sessions',
              value: '$totalSessions',
              icon: Icons.schedule_rounded,
              iconColor: AppColors.primary,
              isDark: isDark,
            )),
            const SizedBox(width: SpacingScale.s12),
            Expanded(child: _StatCard(
              label: 'Students',
              value: '$totalStudents',
              icon: Icons.people_rounded,
              iconColor: AppColors.emerald,
              isDark: isDark,
            )),
          ],
        ),
        const SizedBox(height: SpacingScale.s12),
        Row(
          children: [
            Expanded(child: _StatCard(
              label: 'Monthly Earnings',
              value: '\u20B9$monthlyEarnings',
              icon: Icons.account_balance_wallet_rounded,
              iconColor: AppColors.warning,
              isDark: isDark,
            )),
            const SizedBox(width: SpacingScale.s12),
            Expanded(child: _StatCard(
              label: 'Rating',
              value: '4.8',
              icon: Icons.star_rounded,
              iconColor: AppColors.orange,
              isDark: isDark,
            )),
          ],
        ),
      ],
    ).animate(delay: 100.ms).fadeIn(duration: 350.ms, curve: Curves.easeOut).slideY(begin: 0.06, end: 0);
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final bool isDark;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SpacingScale.s16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl3,
        border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [iconColor, iconColor.withValues(alpha: 0.4)],
              ),
            ),
          ),
          const SizedBox(height: SpacingScale.s12),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: AppRadius.brLg,
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: SpacingScale.s12),
          Text(
            value,
            style: AppTextStyles.numericSm.copyWith(
              color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: SpacingScale.s2),
          Text(
            label,
            style: AppTextStyles.bodySm.copyWith(
              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    ).animate(delay: 150.ms).fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }
}
