import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../../design_system/colors/app_colors.dart';
import '../../../../../design_system/typography/text_styles.dart';
import '../../../../../design_system/spacing/spacing_scale.dart';
import '../../../../../design_system/radius/radius.dart';
import '../../../../../design_system/responsive/responsive_helpers.dart';
import '../../../../../design_system/icons/app_icons.dart';

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = context.isDesktop;
    final padding = isDesktop ? SpacingScale.s32 : SpacingScale.s16;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;

    final actions = [
      _ActionData(
        icon: Icons.person_search_rounded, iconBg: AppColors.primary,
        title: 'Book Coach', description: 'Find the perfect coach for your goals.',
        route: '/coach-discovery',
      ),
      _ActionData(
        icon: AppIcons.group, iconBg: AppColors.emerald,
        title: 'Join Community', description: 'Connect with fellow athletes.',
        route: '/community',
      ),
      _ActionData(
        icon: AppIcons.analytics, iconBg: AppColors.purple,
        title: 'Performance', description: 'Track your progress and stats.',
        route: 'performance',
      ),
      _ActionData(
        icon: AppIcons.calendar, iconBg: AppColors.orange,
        title: 'My Sessions', description: 'Manage your training schedule.',
        route: 'sessions',
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: isDesktop ? SpacingScale.s28 : SpacingScale.s24),
          Row(
            children: [
              Icon(AppIcons.menu, size: 18, color: AppColors.primary),
              const SizedBox(width: SpacingScale.s8),
              Text('Quick Actions', style: AppTextStyles.title2.copyWith(color: textColor, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: SpacingScale.s16),
          if (isDesktop)
            Row(
              children: [
                Expanded(child: _ActionCard(data: actions[0], index: 0)),
                const SizedBox(width: SpacingScale.s12),
                Expanded(child: _ActionCard(data: actions[1], index: 1)),
                const SizedBox(width: SpacingScale.s12),
                Expanded(child: _ActionCard(data: actions[2], index: 2)),
                const SizedBox(width: SpacingScale.s12),
                Expanded(child: _ActionCard(data: actions[3], index: 3)),
              ],
            )
          else
            Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _ActionCard(data: actions[0], index: 0)),
                    const SizedBox(width: SpacingScale.s10),
                    Expanded(child: _ActionCard(data: actions[1], index: 1)),
                  ],
                ),
                const SizedBox(height: SpacingScale.s10),
                Row(
                  children: [
                    Expanded(child: _ActionCard(data: actions[2], index: 2)),
                    const SizedBox(width: SpacingScale.s10),
                    Expanded(child: _ActionCard(data: actions[3], index: 3)),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ActionData {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String description;
  final String route;
  const _ActionData({
    required this.icon, required this.iconBg,
    required this.title, required this.description, required this.route,
  });
}

class _ActionCard extends StatelessWidget {
  final _ActionData data;
  final int index;
  const _ActionCard({required this.data, required this.index});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final secColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    return GestureDetector(
      onTap: () => context.push(data.route),
      child: Container(
        padding: const EdgeInsets.all(SpacingScale.s16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.card : AppColors.lightCard,
          borderRadius: AppRadius.brXl2,
          border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: data.iconBg.withValues(alpha: 0.12),
                borderRadius: AppRadius.brLg,
              ),
              child: Icon(data.icon, size: 20, color: data.iconBg),
            ),
            const SizedBox(width: SpacingScale.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(data.title, style: AppTextStyles.title3.copyWith(color: textColor, fontWeight: FontWeight.w600)),
                  const SizedBox(height: SpacingScale.s2),
                  Text(data.description, style: AppTextStyles.caption.copyWith(color: secColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: SpacingScale.s8),
            Icon(Icons.arrow_forward_rounded, size: 16, color: data.iconBg),
          ],
        ),
      ),
    ).animate(delay: (400 + index * 60).ms)
        .fadeIn(duration: 300.ms, curve: Curves.easeOut)
        .slideY(begin: 0.08, end: 0);
  }
}
