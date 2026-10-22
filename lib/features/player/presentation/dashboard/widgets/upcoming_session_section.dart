import 'package:url_launcher/url_launcher.dart';
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
import '../../../../../services/firebase_service.dart';
import '../../../../chat/presentation/chat_detail_screen.dart';
import '../../../../schedule/presentation/widgets/session_attendance_scanner_modal.dart';
import 'dashboard_loading.dart';
import 'dashboard_empty_state.dart';

IconData _getSportIcon(String sportName) {
  switch (sportName.toLowerCase()) {
    case 'football':
    case 'soccer':
      return Icons.sports_soccer_rounded;
    case 'cricket':
      return Icons.sports_cricket_rounded;
    case 'badminton':
    case 'tennis':
      return Icons.sports_tennis_rounded;
    case 'basketball':
      return Icons.sports_basketball_rounded;
    default:
      return Icons.fitness_center_rounded;
  }
}

class UpcomingSessionSection extends ConsumerWidget {

  final String playerId;

  const UpcomingSessionSection({super.key, required this.playerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(playerSessionsProvider(playerId));
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;
    final padH = isDesktop ? SpacingScale.s32 : (isTablet ? SpacingScale.s24 : SpacingScale.s16);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: isDesktop ? SpacingScale.s28 : SpacingScale.s24),
          _buildEnrolledBatches(context, isDark),
          sessionsAsync.when(
            data: (snap) {
              final now = DateTime.now();
              final sessions = snap.docs
                  .map((d) => d.data())
                  .where((d) {
                    final status = d['status'] as String?;
                    final active = status == 'scheduled' ||
                        status == 'booked' ||
                        status == 'confirmed' ||
                        status == 'checked_in';
                    final ts = (d['dateTime'] as Timestamp?)?.toDate();
                    return active && ts != null && !ts.isBefore(now);
                  })
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
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildEnrolledBatches(BuildContext context, bool isDark) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('batches')
          .where('playerIds', arrayContains: playerId)
          .where('isActive', isEqualTo: true)
          .snapshots(),
      builder: (ctx, snap) {
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final batches = snap.data!.docs;
        return Container(
          margin: const EdgeInsets.only(bottom: SpacingScale.s16),
          padding: const EdgeInsets.all(SpacingScale.s16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131D31) : Colors.white,
            borderRadius: AppRadius.brXl2,
            border: Border.all(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.school_rounded, color: Color(0xFF00E5FF), size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Enrolled Academy Squads (' + batches.length.toString() + ')',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final doc in batches) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  doc.data()['name'] ?? 'Training Squad',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFCCFF00).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    (doc.data()['sport'] ?? 'Sport').toString().toUpperCase(),
                                    style: const TextStyle(
                                      color: Color(0xFFCCFF00),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Coach: ' + (doc.data()['coachName'] ?? 'Assigned Coach') + ' • ' + (doc.data()['schedule'] ?? 'Weekly'),
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.emerald.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'ACTIVE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: AppColors.emerald,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _UpcomingSessionCard extends ConsumerWidget {
  final Map<String, dynamic> sessionData;

  const _UpcomingSessionCard({required this.sessionData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    final status = sessionData['status'] as String? ?? 'booked';
    final (statusLabel, statusColor) = switch (status) {
      'confirmed' => ('Confirmed', AppColors.emerald),
      'checked_in' => ('In Progress', AppColors.purple),
      'booked' => ('Pending', AppColors.warning),
      _ => ('Scheduled', AppColors.primary),
    };

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
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: AppRadius.brFull,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: statusColor,
                            ),
                          ),
                          const SizedBox(width: SpacingScale.s4),
                          Text(statusLabel, style: AppTextStyles.captionXs.copyWith(
                            color: statusColor,
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
                  const _InfoRow(icon: Icons.verified_rounded, text: 'Slot Confirmed \u2022 Court access verified'),
                ],
                if (capacity > 0) ...[
                  const SizedBox(height: SpacingScale.s10),
                  _InfoRow(icon: Icons.people_rounded, text: '$capacity participants'),
                ],
                if (!isOnline) ...[
                  const SizedBox(height: SpacingScale.s10),
                  _InfoRow(icon: _getSportIcon(sport), text: 'Sport: $sport \u2022 Bring personal training gear'),
                ],
                const SizedBox(height: SpacingScale.s24),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        onPressed: () async {
                          final destination = venue != null && venue.isNotEmpty
                              ? venue
                              : (title.isNotEmpty ? title : 'Pune Sports Ground');
                          final url = Uri.parse(
                            'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(destination)}',
                          );
                          try {
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            } else if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Could not open map navigation'),
                                  backgroundColor: AppColors.warning,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Navigation error: $e'),
                                  backgroundColor: AppColors.danger,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                        label: 'Navigate',
                        icon: Icons.navigation_rounded,
                        size: ButtonSize.sm,
                      ),
                    ),
                    const SizedBox(width: SpacingScale.s10),
                    Expanded(
                      child: PrimaryButton(
                        onPressed: () async {
                          final coachId = sessionData['coachId'] as String?;
                          if (coachId == null || coachId.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No coach assigned to this session'),
                                backgroundColor: AppColors.warning,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }
                          final chatService = ref.read(chatServiceProvider);
                          final userId = ref.read(authServiceProvider).currentUser?.uid;
                          if (userId == null) return;
                          try {
                            final chatId = await chatService.createChat([userId, coachId]);
                            if (context.mounted) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ChatDetailScreen(
                                    chatId: chatId,
                                    otherUserId: coachId,
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to open chat: $e'),
                                  backgroundColor: const Color(0xFFDC2626),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                        label: 'Chat with Coach',
                        icon: Icons.chat_rounded,
                        size: ButtonSize.sm,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SpacingScale.s12),
                PrimaryButton(
                  onPressed: () {
                    final sId = sessionData['id'] as String? ?? '';
                    final pId = sessionData['playerId'] as String? ?? (ref.read(authServiceProvider).currentUser?.uid ?? '');
                    SessionAttendanceScannerModal.show(
                      context,
                      currentUserId: pId,
                      initialSessionId: sId,
                    );
                  },
                  label: 'Scan QR / Enter PIN to Check In',
                  icon: Icons.qr_code_scanner_rounded,
                  size: ButtonSize.sm,
                  expanded: true,
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
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body.copyWith(
              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
