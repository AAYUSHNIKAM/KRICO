import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../design_system/colors/app_colors.dart';
import '../../../../../design_system/typography/text_styles.dart';
import '../../../../../design_system/spacing/spacing_scale.dart';
import '../../../../../design_system/radius/radius.dart';
import '../../../../../design_system/responsive/responsive_helpers.dart';
import '../../../../../design_system/icons/app_icons.dart';
import '../../../../../services/providers.dart';
import 'dashboard_loading.dart';
import 'dashboard_empty_state.dart';

class DashboardActivityTimeline extends ConsumerWidget {
  final String playerId;

  const DashboardActivityTimeline({super.key, required this.playerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(playerSessionsProvider(playerId));

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.isDesktop ? SpacingScale.s32 : SpacingScale.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: context.isDesktop ? SpacingScale.s28 : SpacingScale.s24),
          sessionsAsync.when(
            data: (snap) {
              final docs = snap.docs.toList()
                ..sort((a, b) {
                  final aTime = (a.data()['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now();
                  final bTime = (b.data()['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now();
                  return bTime.compareTo(aTime);
                });
              final recent = docs.take(10).toList();
              if (recent.isEmpty) {
                return DashboardEmptyState(
                  icon: AppIcons.history,
                  title: 'No Activity Yet',
                  subtitle: 'Your recent activity will appear here.',
                  accentColor: AppColors.primary,
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(AppIcons.history, size: 18, color: AppColors.primary),
                      const SizedBox(width: SpacingScale.s8),
                      Text('Recent Activity', style: AppTextStyles.title2.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                        fontWeight: FontWeight.w600,
                      )),
                    ],
                  ),
                  const SizedBox(height: SpacingScale.s16),
                  ...List.generate(recent.length, (i) {
                    final doc = recent[i];
                    final data = doc.data();
                    final dateTime = (data['dateTime'] as Timestamp?)?.toDate();
                    final sport = data['sport'] as String? ?? 'Training';
                    final status = data['status'] as String? ?? 'completed';
                    final title = data['title'] as String? ?? sport;
                    final isCompleted = status == 'completed';
                    return _TimelineItem(
                      icon: isCompleted ? Icons.check_circle_rounded : Icons.schedule_rounded,
                      iconColor: isCompleted ? AppColors.emerald : AppColors.warning,
                      title: title,
                      subtitle: sport,
                      time: dateTime != null ? DateFormat('MMM d, h:mm a').format(dateTime) : '',
                      isLast: i == recent.length - 1,
                      index: i,
                    );
                  }),
                ],
              );
            },
            loading: () => const DashboardSectionShimmer(height: 220),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;
  final bool isLast;
  final int index;

  const _TimelineItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isLast,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final secColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 14, color: iconColor),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: isDark ? AppColors.divider : AppColors.lightDivider,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: SpacingScale.s12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : SpacingScale.s20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.body.copyWith(color: textColor, fontWeight: FontWeight.w600)),
                  const SizedBox(height: SpacingScale.s4),
                  Row(
                    children: [
                      Text(subtitle, style: AppTextStyles.caption.copyWith(color: secColor)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary,
                          borderRadius: AppRadius.brFull,
                        ),
                        child: Text(time, style: AppTextStyles.captionXs.copyWith(color: secColor)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate(delay: (550 + index * 40).ms).fadeIn(duration: 300.ms, curve: Curves.easeOut).slideY(begin: 0.05, end: 0);
  }
}
