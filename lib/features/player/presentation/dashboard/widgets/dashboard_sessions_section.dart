import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../design_system/colors/app_colors.dart';
import '../../../../../design_system/typography/text_styles.dart';
import '../../../../../design_system/spacing/spacing_scale.dart';
import '../../../../../design_system/radius/radius.dart';
import '../../../../../design_system/icons/app_icons.dart';
import '../../../../../design_system/responsive/responsive_helpers.dart';
import '../../../../../design_system/widgets/buttons/primary_button.dart';
import '../../../../../design_system/widgets/buttons/outline_button.dart';
import '../../../../../design_system/widgets/buttons/button_types.dart';
import '../../../../../services/providers.dart';
import 'dashboard_loading.dart';
import 'dashboard_empty_state.dart';

class DashboardSessionsSection extends ConsumerWidget {
  final String playerId;

  const DashboardSessionsSection({super.key, required this.playerId});

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
              final sessions = snap.docs
                  .map((d) => d.data())
                  .where((d) => d['status'] == 'scheduled' || d['status'] == 'upcoming')
                  .toList()
                ..sort((a, b) {
                  final aTime = (a['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now();
                  final bTime = (b['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now();
                  return aTime.compareTo(bTime);
                });
              final upcoming = sessions.isNotEmpty ? sessions.first : null;
              if (upcoming == null) {
                return DashboardEmptyState(
                  icon: AppIcons.calendar,
                  title: 'No Upcoming Sessions',
                  subtitle: 'Book a session with a coach to get started.',
                  actionLabel: 'Find a Coach',
                );
              }
              return _UpcomingSessionCard(sessionData: upcoming);
            },
            loading: () => const DashboardSectionShimmer(height: 320),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _UpcomingSessionCard extends StatelessWidget {
  final Map<String, dynamic> sessionData;
  const _UpcomingSessionCard({required this.sessionData});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final secColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final dateTime = (sessionData['dateTime'] as Timestamp?)?.toDate();
    final sport = sessionData['sport'] as String? ?? 'Training';
    final venue = sessionData['venue'] as String?;
    final title = sessionData['title'] as String? ?? sport;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl2,
        border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 3, color: AppColors.primary),
          Padding(
            padding: const EdgeInsets.all(SpacingScale.s20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(AppIcons.schedule, size: 18, color: AppColors.primary),
                    const SizedBox(width: SpacingScale.s8),
                    Text('Upcoming Session', style: AppTextStyles.title2.copyWith(color: textColor, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s8, vertical: SpacingScale.s4),
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withValues(alpha: 0.1),
                        borderRadius: AppRadius.brFull,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.emerald)),
                          const SizedBox(width: SpacingScale.s4),
                          Text('Confirmed', style: AppTextStyles.captionXs.copyWith(color: AppColors.emerald, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SpacingScale.s20),
                Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: AppRadius.brLg,
                      ),
                      child: Icon(AppIcons.sports, size: 24, color: AppColors.primary),
                    ),
                    const SizedBox(width: SpacingScale.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: AppTextStyles.title3.copyWith(color: textColor, fontWeight: FontWeight.w600)),
                          const SizedBox(height: SpacingScale.s2),
                          Text(sport, style: AppTextStyles.caption.copyWith(color: secColor)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SpacingScale.s20),
                if (dateTime != null) ...[
                  _InfoRow(icon: Icons.calendar_month_rounded, text: DateFormat('EEEE, MMMM d').format(dateTime)),
                  const SizedBox(height: SpacingScale.s10),
                  _InfoRow(icon: Icons.access_time_rounded, text: DateFormat('h:mm a').format(dateTime)),
                ],
                if (venue != null) ...[
                  const SizedBox(height: SpacingScale.s10),
                  _InfoRow(icon: Icons.location_on_rounded, text: venue),
                ],
                const SizedBox(height: SpacingScale.s24),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        onPressed: () {},
                        label: 'View Details',
                        size: ButtonSize.sm,
                      ),
                    ),
                    const SizedBox(width: SpacingScale.s10),
                    Expanded(
                      child: OutlineButton(
                        onPressed: () {},
                        label: 'Reschedule',
                        size: ButtonSize.sm,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: 300.ms).fadeIn(duration: 350.ms, curve: Curves.easeOut).slideY(begin: 0.06, end: 0);
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, size: 14, color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
        const SizedBox(width: SpacingScale.s8),
        Text(text, style: AppTextStyles.body.copyWith(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
      ],
    );
  }
}
