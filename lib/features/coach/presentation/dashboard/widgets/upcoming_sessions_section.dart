import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
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

class CoachUpcomingSessionsSection extends ConsumerWidget {
  final String coachId;

  const CoachUpcomingSessionsSection({super.key, required this.coachId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(coachSessionsProvider(coachId));
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
              final now = DateTime.now();
              final sessions = snap.docs
                  .map((d) {
                    final map = Map<String, dynamic>.from(d.data());
                    map['id'] = d.id;
                    map['sessionId'] = d.id;
                    return map;
                  })
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
              if (sessions.isEmpty) {
                return CoachDashboardEmptyState(
                  icon: Icons.event_busy_rounded,
                  title: 'No Upcoming Sessions',
                  subtitle: 'Create a new session to get started.',
                  actionLabel: 'Create Session',
                  onActionTap: () => context.push('/create-session'),
                  accentColor: AppColors.primary,
                );
              }
              return Column(
                children: sessions.take(5).map((d) => _SessionCard(
                  sessionData: d,
                  coachId: coachId,
                  index: sessions.indexOf(d),
                )).toList(),
              );
            },
            loading: () => const CoachDashboardSectionShimmer(height: 320),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends ConsumerWidget {
  final Map<String, dynamic> sessionData;
  final String coachId;
  final int index;

  const _SessionCard({
    required this.sessionData,
    required this.coachId,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final secColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final sport = sessionData['sport'] as String? ?? 'Session';
    final ts = sessionData['dateTime'] as Timestamp?;
    final timeStr = ts != null ? DateFormat('MMM d, h:mm a').format(ts.toDate()) : 'TBD';
    final price = (sessionData['price'] as num?)?.toDouble() ?? 0;
    final title = sessionData['title'] as String? ?? sport;
    final color = _getSportColor(sport);
    final icon = _getSportIcon(sport);

    return Container(
      margin: const EdgeInsets.only(bottom: SpacingScale.s10),
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
                colors: [color, color.withValues(alpha: 0.4)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(SpacingScale.s16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: AppRadius.brXl2,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: SpacingScale.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                        style: AppTextStyles.title3.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        )),
                      const SizedBox(height: SpacingScale.s4),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 12, color: secColor),
                          const SizedBox(width: SpacingScale.s4),
                          Text(timeStr,
                            style: AppTextStyles.caption.copyWith(color: secColor)),
                          if (price > 0) ...[
                            const SizedBox(width: SpacingScale.s10),
                            Icon(Icons.currency_rupee_rounded, size: 12, color: AppColors.emerald),
                            const SizedBox(width: SpacingScale.s2),
                            Text('${price.toInt()}',
                              style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.emerald,
                                fontWeight: FontWeight.w600,
                              )),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: SpacingScale.s8),
                PrimaryButton(
                  onPressed: () => _showSessionActions(context, ref),
                  label: 'Manage',
                  icon: Icons.more_horiz_rounded,
                  size: ButtonSize.sm,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 150 + index * 60))
      .fadeIn(duration: 300.ms)
      .slideY(begin: 0.06, end: 0);
  }

  void _showSessionActions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.surface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(SpacingScale.s20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: SpacingScale.s20),
            _actionTile(ctx, Icons.videocam_rounded, 'Start Video Analysis', () {
              Navigator.pop(ctx);
              context.push('/video-analysis');
            }),
            _actionTile(ctx, Icons.message_rounded, 'Send Message', () async {
              Navigator.pop(ctx);
              final playerId = (sessionData['playerId'] as String?) ?? '';
              if (playerId.isNotEmpty) {
                try {
                  final chatId = await ref.read(chatServiceProvider).getOrCreateDirectChat(
                    coachId,
                    playerId,
                    starterMessage: 'Hi! Reaching out regarding our upcoming ${sessionData['sport'] ?? 'training'} session.',
                    starterSenderId: coachId,
                  );
                  if (context.mounted) {
                    context.push('/chat/$chatId');
                  }
                } catch (_) {
                  if (context.mounted) context.push('/chat');
                }
              } else {
                context.push('/chat');
              }
            }),
            _actionTile(ctx, Icons.edit_calendar_rounded, 'Reschedule Session', () {
              Navigator.pop(ctx);
              _showRescheduleDialog(context, ref);
            }),
            _actionTile(ctx, Icons.cancel_outlined, 'Cancel Session', () {
              Navigator.pop(ctx);
              _confirmCancelSession(context, ref);
            }, color: AppColors.danger),
          ],
        ),
      ),
    );
  }

  Widget _actionTile(BuildContext context, IconData icon, String label, VoidCallback onTap, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.primary),
      title: Text(label,
        style: AppTextStyles.body.copyWith(
          color: color ?? (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary),
        )),
      onTap: onTap,
    );
  }

  void _showRescheduleDialog(BuildContext context, WidgetRef ref) {
    final reasons = [
      'Bad Weather / Monsoon Rain',
      'Court / Facility Unavailable',
      'Coach Emergency / Health',
      'Player Schedule Conflict',
      'Ground Maintenance',
    ];
    String selectedReason = reasons.first;
    DateTime newDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay newTime = const TimeOfDay(hour: 17, minute: 0);
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.surface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          final isDark = Theme.of(modalCtx).brightness == Brightness.dark;
          final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
          final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

          return Padding(
            padding: EdgeInsets.fromLTRB(
              SpacingScale.s20,
              SpacingScale.s20,
              SpacingScale.s20,
              SpacingScale.s24 + MediaQuery.of(modalCtx).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.border : AppColors.lightBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: SpacingScale.s16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(SpacingScale.s10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: AppRadius.brLg,
                      ),
                      child: const Icon(Icons.edit_calendar_rounded, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: SpacingScale.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Reschedule Session', style: AppTextStyles.title2.copyWith(color: textPrimary, fontWeight: FontWeight.bold)),
                          Text(sessionData['sport'] ?? 'Coaching Session', style: AppTextStyles.bodySm.copyWith(color: textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SpacingScale.s20),
                Text('Reason for Rescheduling', style: AppTextStyles.label.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                const SizedBox(height: SpacingScale.s8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.card : AppColors.lightCard,
                    borderRadius: AppRadius.brLg,
                    border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedReason,
                      dropdownColor: isDark ? AppColors.card : AppColors.lightCard,
                      items: reasons.map((r) => DropdownMenuItem(
                        value: r,
                        child: Text(r, style: AppTextStyles.body.copyWith(color: textPrimary)),
                      )).toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedReason = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: SpacingScale.s16),
                Text('New Date & Time', style: AppTextStyles.label.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                const SizedBox(height: SpacingScale.s8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today_rounded, size: 16),
                        label: Text(DateFormat('EEE, MMM d').format(newDate)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: modalCtx,
                            initialDate: newDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 90)),
                          );
                          if (picked != null) {
                            setModalState(() => newDate = picked);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: SpacingScale.s10),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.access_time_rounded, size: 16),
                        label: Text(newTime.format(modalCtx)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                        ),
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: modalCtx,
                            initialTime: newTime,
                          );
                          if (picked != null) {
                            setModalState(() => newTime = picked);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SpacingScale.s24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.brXl2),
                    ),
                    onPressed: isSaving ? null : () async {
                      setModalState(() => isSaving = true);
                      try {
                        final scheduledDateTime = DateTime(
                          newDate.year,
                          newDate.month,
                          newDate.day,
                          newTime.hour,
                          newTime.minute,
                        );
                        final sessionId = (sessionData['id'] as String?) ?? (sessionData['sessionId'] as String?);
                        if (sessionId != null && sessionId.isNotEmpty) {
                          await FirebaseFirestore.instance.collection('sessions').doc(sessionId).update({
                            'dateTime': Timestamp.fromDate(scheduledDateTime),
                            'isRescheduled': true,
                            'rescheduledReason': selectedReason,
                            'updatedAt': FieldValue.serverTimestamp(),
                          });

                          final playerId = sessionData['playerId'] as String?;
                          if (playerId != null && playerId.isNotEmpty) {
                            await ref.read(notificationServiceProvider).createNotification(
                              userId: playerId,
                              title: 'Session Rescheduled',
                              body: 'Coach rescheduled your ${sessionData['sport'] ?? 'training'} session to ${DateFormat('MMM d, h:mm a').format(scheduledDateTime)}. Reason: $selectedReason',
                              type: 'session_rescheduled',
                              refId: sessionId,
                            );
                          }
                        }
                        HapticFeedback.mediumImpact();
                        if (modalCtx.mounted) Navigator.pop(modalCtx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Session rescheduled to ${DateFormat('MMM d, h:mm a').format(DateTime(newDate.year, newDate.month, newDate.day, newTime.hour, newTime.minute))}'),
                              backgroundColor: AppColors.emerald,
                            ),
                          );
                        }
                      } catch (e) {
                        setModalState(() => isSaving = false);
                        if (modalCtx.mounted) {
                          ScaffoldMessenger.of(modalCtx).showSnackBar(
                            SnackBar(content: Text('Failed to reschedule: $e'), backgroundColor: AppColors.danger),
                          );
                        }
                      }
                    },
                    child: isSaving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                        : const Text('Confirm Reschedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmCancelSession(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surface : AppColors.lightSurface,
        title: const Text('Cancel Session'),
        content: const Text('Are you sure you want to cancel this training session? The athlete will be immediately notified.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No, Keep'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final sessionId = (sessionData['id'] as String?) ?? (sessionData['sessionId'] as String?);
                if (sessionId != null && sessionId.isNotEmpty) {
                  await FirebaseFirestore.instance.collection('sessions').doc(sessionId).update({
                    'status': 'cancelled',
                    'cancelledBy': coachId,
                    'cancelledAt': FieldValue.serverTimestamp(),
                  });

                  final playerId = sessionData['playerId'] as String?;
                  if (playerId != null && playerId.isNotEmpty) {
                    await ref.read(notificationServiceProvider).createNotification(
                      userId: playerId,
                      title: 'Session Cancelled',
                      body: 'Coach has cancelled your scheduled ${sessionData['sport'] ?? 'training'} session.',
                      type: 'session_cancelled',
                      refId: sessionId,
                    );
                  }
                }
                HapticFeedback.mediumImpact();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Session cancelled successfully'), backgroundColor: AppColors.danger),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to cancel session: $e'), backgroundColor: AppColors.danger),
                  );
                }
              }
            },
            child: const Text('Yes, Cancel', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  IconData _getSportIcon(String sport) {
    final lower = sport.toLowerCase();
    if (lower.contains('cricket')) return Icons.sports_cricket_rounded;
    if (lower.contains('swim')) return Icons.pool_rounded;
    if (lower.contains('tennis')) return Icons.sports_tennis_rounded;
    if (lower.contains('football') || lower.contains('soccer')) return Icons.sports_football_rounded;
    if (lower.contains('basketball')) return Icons.sports_basketball_rounded;
    if (lower.contains('baseball')) return Icons.sports_baseball_rounded;
    if (lower.contains('kabaddi')) return Icons.sports_kabaddi_rounded;
    if (lower.contains('hockey')) return Icons.sports_hockey_rounded;
    if (lower.contains('golf')) return Icons.golf_course_rounded;
    if (lower.contains('yoga')) return Icons.self_improvement_rounded;
    if (lower.contains('gym') || lower.contains('fitness')) return Icons.fitness_center_rounded;
    return Icons.sports_rounded;
  }

  Color _getSportColor(String sport) {
    final lower = sport.toLowerCase();
    if (lower.contains('cricket')) return AppColors.primary;
    if (lower.contains('swim')) return AppColors.emerald;
    if (lower.contains('tennis')) return AppColors.warning;
    if (lower.contains('football') || lower.contains('soccer')) return AppColors.primary;
    if (lower.contains('basketball')) return AppColors.orange;
    if (lower.contains('baseball')) return Colors.orange;
    if (lower.contains('kabaddi')) return Colors.brown;
    if (lower.contains('hockey')) return Colors.indigo;
    if (lower.contains('yoga')) return Colors.purple;
    return AppColors.primary;
  }
}
