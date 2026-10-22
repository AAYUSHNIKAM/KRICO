import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../design_system/colors/app_colors.dart';
import '../../../../../design_system/typography/text_styles.dart';
import '../../../../../design_system/spacing/spacing_scale.dart';
import '../../../../../design_system/radius/radius.dart';
import '../../../../../design_system/responsive/responsive_helpers.dart';
import '../../../../../services/providers.dart';
import '../../../../../models/academy_model.dart';
import 'dashboard_loading.dart';

class AcademyStatsSection extends ConsumerWidget {
  final AcademyModel academy;

  const AcademyStatsSection({super.key, required this.academy});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCoachesAsync = ref.watch(activeCoachesCountProvider(academy.academyId));
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;
    final padH = isDesktop ? SpacingScale.s32 : (isTablet ? SpacingScale.s24 : SpacingScale.s16);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: isDesktop ? SpacingScale.s28 : SpacingScale.s24),
          activeCoachesAsync.when(
            data: (activeCoaches) => _StatsContent(
              academy: academy,
              activeCoaches: activeCoaches,
            ),
            loading: () => const AcademyDashboardKpiShimmer(),
            error: (_, _) => const AcademyDashboardSectionShimmer(height: 160),
          ),
        ],
      ),
    );
  }
}

class _StatsContent extends StatelessWidget {
  final AcademyModel academy;
  final int activeCoaches;

  const _StatsContent({
    required this.academy,
    required this.activeCoaches,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = context.isDesktop;

    if (isDesktop) {
      return Row(
        children: [
          Expanded(child: _StatCard(
            label: 'Total Students',
            value: academy.totalStudents.toString(),
            icon: Icons.people_rounded,
            iconColor: AppColors.primary,
            isDark: isDark,
          )),
          const SizedBox(width: SpacingScale.s12),
          Expanded(child: _StatCard(
            label: 'Active Coaches',
            value: '$activeCoaches',
            icon: Icons.sports_rounded,
            iconColor: AppColors.emerald,
            isDark: isDark,
          )),
          const SizedBox(width: SpacingScale.s12),
          Expanded(child: _StatCard(
            label: 'Reputation Points',
            value: academy.reputationPoints.toString(),
            icon: Icons.workspace_premium_rounded,
            iconColor: AppColors.warning,
            isDark: isDark,
          )),
          const SizedBox(width: SpacingScale.s12),
          Expanded(child: _StatCard(
            label: 'Placements',
            value: academy.coachPlacements.toString(),
            icon: Icons.work_rounded,
            iconColor: AppColors.purple,
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
              label: 'Total Students',
              value: academy.totalStudents.toString(),
              icon: Icons.people_rounded,
              iconColor: AppColors.primary,
              isDark: isDark,
            )),
            const SizedBox(width: SpacingScale.s12),
            Expanded(child: _StatCard(
              label: 'Active Coaches',
              value: '$activeCoaches',
              icon: Icons.sports_rounded,
              iconColor: AppColors.emerald,
              isDark: isDark,
            )),
          ],
        ),
        const SizedBox(height: SpacingScale.s12),
        Row(
          children: [
            Expanded(child: _StatCard(
              label: 'Reputation Points',
              value: academy.reputationPoints.toString(),
              icon: Icons.workspace_premium_rounded,
              iconColor: AppColors.warning,
              isDark: isDark,
            )),
            const SizedBox(width: SpacingScale.s12),
            Expanded(child: _StatCard(
              label: 'Placements',
              value: academy.coachPlacements.toString(),
              icon: Icons.work_rounded,
              iconColor: AppColors.purple,
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
