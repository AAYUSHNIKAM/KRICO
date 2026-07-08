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
import '../../../../../design_system/widgets/buttons/primary_button.dart';
import '../../../../../design_system/widgets/buttons/button_types.dart';
import '../../../../../services/providers.dart';
import 'dashboard_loading.dart';
import 'dashboard_empty_state.dart';

class UpcomingSessionSection extends ConsumerWidget {
  final String playerId;

  const UpcomingSessionSection({super.key, required this.playerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(playerSessionsProvider(playerId));
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;
    final padH = isDesktop ? SpacingScale.s32 : (isTablet ? SpacingScale.s24 : SpacingScale.s16);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: isDesktop ? SpacingScale.s28 : SpacingScale.s24),
          sessionsAsync.when(
            data: (snap) {
              final sessions = snap.docs
                  .map((d) => d.data())
                  .where((d) => d['status'] == 'scheduled' || d['status'] == 'booked')
                  .toList()
                ..sort((a, b) {
                  final aTime = (a['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now();
                  final bTime = (b['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now();
                  return aTime.compareTo(bTime);
                });
              final upcoming = sessions.isNotEmpty ? sessions.first : null;
              if (upcoming == null) {
                return DashboardEmptyState(
                  icon: Icons.calendar_month_rounded,
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
    final price = (sessionData['price'] as num?)?.toDouble() ?? 0;
    final capacity = (sessionData['capacity'] as int?) ?? 0;
    final isOnline = sessionData['isOnline'] as bool? ?? false;
    final countdownStr = dateTime != null ? _formatCountdown(dateTime) : '';

    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.brXl3,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColors.surfaceElevated, AppColors.card]
              : [AppColors.lightSurface, AppColors.lightCard],
        ),
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.lightBorder,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.emerald],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(SpacingScale.s24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s10, vertical: SpacingScale.s4),
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withValues(alpha: 0.1),
                        borderRadius: AppRadius.brFull,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.emerald,
                            ),
                          ),
                          const SizedBox(width: SpacingScale.s4),
                          Text('Confirmed', style: AppTextStyles.captionXs.copyWith(
                            color: AppColors.emerald,
                            fontWeight: FontWeight.w600,
                          )),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (countdownStr.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s10, vertical: SpacingScale.s4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: AppRadius.brFull,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.schedule_rounded, size: 10, color: AppColors.primary),
                            const SizedBox(width: SpacingScale.s4),
                            Text(countdownStr, style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            )),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: SpacingScale.s20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: AppRadius.brXl2,
                      ),
                      child: Icon(Icons.sports_soccer_rounded, size: 28, color: AppColors.primary),
                    ),
                    const SizedBox(width: SpacingScale.s16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: AppTextStyles.title1.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w700,
                          )),
                          const SizedBox(height: SpacingScale.s4),
                          Row(
                            children: [
                              Text(sport, style: AppTextStyles.body.copyWith(color: secColor)),
                              if (price > 0) ...[
                                const SizedBox(width: SpacingScale.s12),
                                Text('\u20B9${price.toInt()}', style: AppTextStyles.label.copyWith(
                                  color: AppColors.emerald,
                                  fontWeight: FontWeight.w600,
                                )),
                              ],
                            ],
                          ),
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
                if (venue != null && venue.isNotEmpty) ...[
                  const SizedBox(height: SpacingScale.s10),
                  _InfoRow(icon: Icons.location_on_rounded, text: venue),
                ],
                if (!isOnline && venue != null && venue.isNotEmpty) ...[
                  const SizedBox(height: SpacingScale.s10),
                  _InfoRow(icon: Icons.wb_sunny_rounded, text: 'Weather: 28\u00B0C, Clear'),
                ],
                if (capacity > 0) ...[
                  const SizedBox(height: SpacingScale.s10),
                  _InfoRow(icon: Icons.people_rounded, text: '$capacity participants'),
                ],
                if (!isOnline) ...[
                  const SizedBox(height: SpacingScale.s10),
                  _InfoRow(icon: Icons.sports_tennis_rounded, text: 'Equipment: Bring your own gear'),
                ],
                const SizedBox(height: SpacingScale.s24),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        onPressed: () {},
                        label: 'Navigate',
                        icon: Icons.navigation_rounded,
                        size: ButtonSize.sm,
                      ),
                    ),
                    const SizedBox(width: SpacingScale.s10),
                    Expanded(
                      child: PrimaryButton(
                        onPressed: () {},
                        label: 'Chat with Coach',
                        icon: Icons.chat_rounded,
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
    ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.06, end: 0);
  }

  String _formatCountdown(DateTime target) {
    final now = DateTime.now();
    final diff = target.difference(now);
    if (diff.isNegative) return 'Started';
    if (diff.inDays > 0) return '${diff.inDays}d ${diff.inHours % 24}h';
    if (diff.inHours > 0) return '${diff.inHours}h ${diff.inMinutes % 60}m';
    return '${diff.inMinutes}m';
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
        Text(text, style: AppTextStyles.body.copyWith(
          color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
        )),
      ],
    );
  }
}
