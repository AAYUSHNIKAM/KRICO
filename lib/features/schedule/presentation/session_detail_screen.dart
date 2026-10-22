import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../design_system/radius/radius.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../design_system/widgets/buttons/primary_button.dart';
import '../../../design_system/widgets/buttons/outline_button.dart';
import '../../../services/providers.dart';
import '../../../providers/auth_provider.dart';
import 'widgets/session_qr_modal.dart';
import 'widgets/session_attendance_scanner_modal.dart';

class SessionDetailScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const SessionDetailScreen({super.key, required this.sessionId});

  @override
  ConsumerState<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends ConsumerState<SessionDetailScreen> {
  Map<String, dynamic>? _sessionData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    try {
      final data = await ref
          .read(coachServiceProvider)
          .getSessionById(widget.sessionId);
      if (mounted) {
        setState(() {
          _sessionData = data;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.background : AppColors.lightBackground;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    if (_loading) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.surface : AppColors.lightSurface,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_sessionData == null) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.surface : AppColors.lightSurface,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 64,
                color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
              ),
              const SizedBox(height: SpacingScale.s16),
              Text(
                'Session not found',
                style: AppTextStyles.title2.copyWith(color: textPrimary),
              ),
            ],
          ),
        ),
      );
    }

    final data = _sessionData!;
    final dateTime = (data['dateTime'] as Timestamp?)?.toDate();
    final status = data['status'] as String? ?? 'booked';
    final sport = data['sport'] as String? ?? 'General';
    final playerId = data['playerId'] as String? ?? '';
    final coachId = data['coachId'] as String? ?? '';
    final uid = ref.watch(authStateProvider).asData?.value?.uid;
    final isCoach = uid != null && uid == coachId;
    final isParticipant = uid != null && (isCoach || uid == playerId || uid == data['bookedBy']);
    final amount = (data['amount'] as num?)?.toDouble() ?? 0;
    final notes = data['notes'] as String? ?? '';

    Color statusColor;
    String statusLabel;
    switch (status) {
      case 'completed':
        statusColor = AppColors.success;
        statusLabel = 'Completed';
      case 'cancelled':
        statusColor = AppColors.danger;
        statusLabel = 'Cancelled';
      case 'rejected':
        statusColor = AppColors.danger;
        statusLabel = 'Declined';
      case 'confirmed':
        statusColor = AppColors.primary;
        statusLabel = 'Confirmed';
      case 'checked_in':
        statusColor = AppColors.purple;
        statusLabel = 'Checked In';
      case 'booked':
      case 'pending':
        statusColor = AppColors.warning;
        statusLabel = 'Awaiting coach confirmation';
      case 'scheduled':
        statusColor = AppColors.primary;
        statusLabel = 'Scheduled';
      default:
        statusColor = AppColors.warning;
        statusLabel = 'Status unavailable';
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surface : AppColors.lightSurface,
        elevation: 0,
        title: Text(
          'Session Details',
          style: AppTextStyles.title2.copyWith(
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(SpacingScale.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(SpacingScale.s20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          statusColor,
                          statusColor.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: AppRadius.brXl3,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: SpacingScale.s12,
                                vertical: SpacingScale.s4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: AppRadius.brFull,
                              ),
                              child: Text(
                                statusLabel,
                                style: AppTextStyles.labelSm.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: SpacingScale.s16),
                        Text(
                          sport,
                          style: AppTextStyles.heading2.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: SpacingScale.s8),
                        if (dateTime != null) ...[
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 16,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: SpacingScale.s8),
                              Text(
                                DateFormat('EEEE, MMMM d, yyyy').format(dateTime),
                                style: AppTextStyles.body.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: SpacingScale.s4),
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.asset(
                                  'assets/animations/stopwatch.gif',
                                  width: 16,
                                  height: 16,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => const Icon(
                                    Icons.access_time_rounded,
                                    size: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                              const SizedBox(width: SpacingScale.s8),
                              Text(
                                DateFormat('hh:mm a').format(dateTime),
                                style: AppTextStyles.body.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (amount > 0) ...[
                          const SizedBox(height: SpacingScale.s12),
                          Text(
                            '₹${amount.toInt()}',
                            style: AppTextStyles.heading2.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  ..._attendanceBlocks(data, isDark, textSecondary, textPrimary),
                  if (playerId.isNotEmpty) ...[
                    const SizedBox(height: SpacingScale.s20),
                    Text(
                      'Player',
                      style: AppTextStyles.title2.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: SpacingScale.s8),
                    _PlayerInfoCard(
                      playerId: playerId,
                      isDark: isDark,
                      textSecondary: textSecondary,
                    ),
                  ],
                  if (coachId.isNotEmpty) ...[
                    const SizedBox(height: SpacingScale.s20),
                    Text(
                      'Coach',
                      style: AppTextStyles.title2.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: SpacingScale.s8),
                    _CoachInfoCard(
                      coachId: coachId,
                      isDark: isDark,
                      textSecondary: textSecondary,
                    ),
                  ],
                  if (notes.isNotEmpty) ...[
                    const SizedBox(height: SpacingScale.s20),
                    Text(
                      'Notes',
                      style: AppTextStyles.title2.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: SpacingScale.s8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(SpacingScale.s16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.card : AppColors.lightCard,
                        borderRadius: AppRadius.brXl2,
                        border: Border.all(
                          color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        notes,
                        style: AppTextStyles.body.copyWith(
                          color: textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: SpacingScale.s24),
                  if (isParticipant) ...[
                    Text(
                      'Actions',
                      style: AppTextStyles.title2.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: SpacingScale.s12),
                    // Action buttons when completed: review & rebook
                    if (status == 'completed') ...[
                      if (!isCoach) ...[
                        PrimaryButton(
                          label: 'Rate & Review Coach',
                          icon: Icons.star_rate_rounded,
                          onPressed: () => _openReviewModal(context, coachId),
                          expanded: true,
                        ),
                        const SizedBox(height: SpacingScale.s8),
                        PrimaryButton(
                          label: 'Rebook This Coach',
                          icon: Icons.replay_rounded,
                          onPressed: () => _rebookCoach(context, coachId),
                          expanded: true,
                        ),
                      ],
                      if (isCoach) ...[
                        PrimaryButton(
                          label: 'Add Athlete Progress Notes',
                          icon: Icons.edit_note_rounded,
                          onPressed: () => context.push('/student-progress/$playerId', extra: {'coachId': coachId}),
                          expanded: true,
                        ),
                      ],
                    ],
                    // Action buttons when confirmed/checked_in
                    if (isCoach && (status == 'confirmed' || status == 'booked')) ...[
                      PrimaryButton(
                        label: 'Show Session QR Check-In',
                        icon: Icons.qr_code_2_rounded,
                        onPressed: () => SessionQrModal.show(
                          context,
                          sessionId: widget.sessionId,
                          coachId: coachId,
                          playerId: playerId,
                          playerName: data['playerName'] as String? ?? 'Athlete',
                          sport: sport,
                          sessionTime: dateTime != null ? DateFormat('hh:mm a').format(dateTime) : 'Session',
                        ),
                        expanded: true,
                      ),
                      const SizedBox(height: SpacingScale.s8),
                      PrimaryButton(
                        label: 'Check In Player',
                        icon: Icons.login_rounded,
                        onPressed: _checkInPlayer,
                        expanded: true,
                      ),
                      const SizedBox(height: SpacingScale.s8),
                      PrimaryButton(
                        label: 'Mark as Completed',
                        icon: Icons.check_circle_rounded,
                        onPressed: () => _updateStatus('completed'),
                        expanded: true,
                      ),
                    ],
                    if (!isCoach && (status == 'confirmed' || status == 'booked' || status == 'scheduled')) ...[
                      PrimaryButton(
                        label: 'Scan QR / Enter PIN to Check In',
                        icon: Icons.qr_code_scanner_rounded,
                        onPressed: () async {
                          final verified = await SessionAttendanceScannerModal.show(
                            context,
                            currentUserId: uid,
                            initialSessionId: widget.sessionId,
                          );
                          if (verified == true && mounted) {
                            _loadSession();
                          }
                        },
                        expanded: true,
                      ),
                      const SizedBox(height: SpacingScale.s8),
                    ],
                    if (isCoach && status == 'checked_in') ...[
                      PrimaryButton(
                        label: 'Check Out & Complete',
                        icon: Icons.logout_rounded,
                        onPressed: _checkOutPlayer,
                        expanded: true,
                      ),
                    ],
                    if (isCoach && (status == 'confirmed' || status == 'booked' || status == 'pending')) ...[
                      const SizedBox(height: SpacingScale.s8),
                      PrimaryButton(
                        label: 'Reschedule',
                        icon: Icons.date_range_rounded,
                        onPressed: _rescheduleSession,
                        expanded: true,
                      ),
                    ],
                    if (status == 'confirmed' || status == 'booked' || status == 'pending') ...[
                      const SizedBox(height: SpacingScale.s8),
                      OutlineButton(
                        label: 'Cancel Session',
                        icon: Icons.cancel_rounded,
                        color: AppColors.dangerLight,
                        onPressed: () => _confirmCancel(context),
                        expanded: true,
                      ),
                    ],
                    if (status == 'cancelled' && !isCoach) ...[
                      PrimaryButton(
                        label: 'Book Another Coach',
                        icon: Icons.search_rounded,
                        onPressed: () => context.push('/coach-discovery'),
                        expanded: true,
                      ),
                    ],
                  ],
                  const SizedBox(height: SpacingScale.s32),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  ),
);
}

  Future<void> _rebookCoach(BuildContext context, String coachId) async {
    try {
      final coach = await ref.read(coachProvider(coachId).future);
      if (context.mounted) {
        context.push('/booking', extra: coach);
      }
    } catch (_) {
      if (context.mounted) {
        context.push('/coach/$coachId');
      }
    }
  }

  void _openReviewModal(BuildContext context, String coachId) async {
    try {
      final coach = await ref.read(coachProvider(coachId).future);
      if (!context.mounted) return;
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _SessionReviewComposer(coachId: coachId, coachName: coach.name),
      );
    } catch (_) {
      if (!context.mounted) return;
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _SessionReviewComposer(coachId: coachId, coachName: 'Coach'),
      );
    }
  }

  List<Widget> _attendanceBlocks(
    Map<String, dynamic> data,
    bool isDark,
    Color textSecondary,
    Color textPrimary,
  ) {
    final status = data['status'] as String? ?? 'booked';
    if (status != 'checked_in' && status != 'completed') return const [];
    final checkedInAt = (data['checkedInAt'] as Timestamp?)?.toDate();
    if (checkedInAt == null) return const [];
    final checkedOutAt = (data['checkedOutAt'] as Timestamp?)?.toDate();

    return [
      const SizedBox(height: SpacingScale.s20),
      Text(
        'Attendance',
        style: AppTextStyles.title2.copyWith(
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
      const SizedBox(height: SpacingScale.s8),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(SpacingScale.s16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.card : AppColors.lightCard,
          borderRadius: AppRadius.brXl2,
          border: Border.all(
            color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          children: [
            _AttendanceRow(
              icon: Icons.login_rounded,
              label: 'Checked in',
              time: DateFormat('hh:mm a').format(checkedInAt),
              isDark: isDark,
              textSecondary: textSecondary,
            ),
            if (checkedOutAt != null) ...[
              Divider(height: SpacingScale.s24, color: isDark ? AppColors.border : AppColors.lightBorder),
              _AttendanceRow(
                icon: Icons.logout_rounded,
                label: 'Checked out',
                time: DateFormat('hh:mm a').format(checkedOutAt),
                isDark: isDark,
                textSecondary: textSecondary,
              ),
            ],
          ],
        ),
      ),
    ];
  }

  Future<void> _checkInPlayer() async {
    try {
      await ref.read(coachServiceProvider).checkInSession(widget.sessionId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Player checked in!'),
            backgroundColor: AppColors.purple,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
          ),
        );
        _loadSession();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to check in: $e'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
          ),
        );
      }
    }
  }

  Future<void> _checkOutPlayer() async {
    try {
      await ref.read(coachServiceProvider).checkOutSession(widget.sessionId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Session completed. Attendance recorded!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
          ),
        );
        _loadSession();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to check out: $e'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
          ),
        );
      }
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      await ref.read(coachServiceProvider).respondToBooking(widget.sessionId, newStatus);
      if (newStatus == 'completed' && _sessionData != null) {
        final playerId = _sessionData!['playerId'] as String? ?? '';
        if (playerId.isNotEmpty) {
          try {
            await ref.read(playerServiceProvider).addPoints(playerId, 50);
          } catch (_) {}
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newStatus == 'completed' ? 'Session completed! Athlete awarded +50 XP' : 'Session updated'),
            backgroundColor: newStatus == 'completed' ? AppColors.success : AppColors.warning,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
          ),
        );
        _loadSession();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
          ),
        );
      }
    }
  }

  Future<void> _rescheduleSession() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (time == null || !mounted) return;

    final newDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    try {
      await ref.read(coachServiceProvider).rescheduleSession(widget.sessionId, newDateTime);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Session rescheduled!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
          ),
        );
        _loadSession();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reschedule: $e'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
          ),
        );
      }
    }
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.card : AppColors.lightCard,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.brXl2),
        title: Text('Cancel Session', style: AppTextStyles.title2.copyWith(fontWeight: FontWeight.w700, color: Theme.of(context).brightness == Brightness.dark ? AppColors.textPrimary : AppColors.lightTextPrimary)),
        content: Text(
          'Are you sure you want to cancel this session? This action cannot be undone.',
          style: AppTextStyles.body.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Keep Session', style: AppTextStyles.button),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _updateStatus('cancelled');
            },
            child: Text('Yes, Cancel', style: AppTextStyles.button.copyWith(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;
  final bool isDark;
  final Color textSecondary;

  const _AttendanceRow({
    required this.icon,
    required this.label,
    required this.time,
    required this.isDark,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: SpacingScale.s12),
        Text(label, style: AppTextStyles.body.copyWith(color: textSecondary)),
        const Spacer(),
        Text(
          time,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }
}

class _PlayerInfoCard extends ConsumerWidget {
  final String playerId;
  final bool isDark;
  final Color textSecondary;

  const _PlayerInfoCard({required this.playerId, required this.isDark, required this.textSecondary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerAsync = ref.watch(playerProvider(playerId));
    final player = playerAsync.asData?.value;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SpacingScale.s16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl2,
        border: Border.all(color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.push('/profile/$playerId'),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: AppRadius.brFull,
              ),
              child: ClipRRect(
                borderRadius: AppRadius.brFull,
                child: Image.asset(
                  'assets/avatars/athlete_1.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Text(
                      player?.name.isNotEmpty == true ? player!.name[0].toUpperCase() : 'P',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: SpacingScale.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(player?.name ?? 'Player', style: AppTextStyles.title3.copyWith(fontWeight: FontWeight.w600, color: textPrimary)),
                Text(player?.level ?? 'Athlete', style: AppTextStyles.caption.copyWith(color: textSecondary)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary, size: 20),
            onPressed: () => context.push('/chat'),
          ),
        ],
      ),
    );
  }
}

class _CoachInfoCard extends ConsumerWidget {
  final String coachId;
  final bool isDark;
  final Color textSecondary;

  const _CoachInfoCard({required this.coachId, required this.isDark, required this.textSecondary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coachAsync = ref.watch(coachProvider(coachId));
    final coach = coachAsync.asData?.value;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SpacingScale.s16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl2,
        border: Border.all(color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.push('/coach/$coachId'),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: AppRadius.brFull,
              ),
              child: ClipRRect(
                borderRadius: AppRadius.brFull,
                child: Image.asset(
                  'assets/avatars/coach_1.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Text(
                      coach?.name.isNotEmpty == true ? coach!.name[0].toUpperCase() : 'C',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: SpacingScale.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(coach?.name ?? 'Coach', style: AppTextStyles.title3.copyWith(fontWeight: FontWeight.w600, color: textPrimary)),
                Text(coach?.specialization ?? 'Specialist', style: AppTextStyles.caption.copyWith(color: textSecondary)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary, size: 20),
            onPressed: () => context.push('/chat'),
          ),
        ],
      ),
    );
  }
}

class _SessionReviewComposer extends ConsumerStatefulWidget {
  final String coachId;
  final String coachName;

  const _SessionReviewComposer({required this.coachId, required this.coachName});

  @override
  ConsumerState<_SessionReviewComposer> createState() => _SessionReviewComposerState();
}

class _SessionReviewComposerState extends ConsumerState<_SessionReviewComposer> {
  final _commentCtrl = TextEditingController();
  double _rating = 5.0;
  bool _submitting = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    setState(() => _submitting = true);
    try {
      await ref.read(reviewServiceProvider).addReview(
        coachId: widget.coachId,
        playerId: user.uid,
        playerName: (user.displayName?.trim().isNotEmpty ?? false) ? user.displayName!.trim() : 'Athlete',
        playerPhotoUrl: user.photoURL,
        rating: _rating,
        comment: _commentCtrl.text.trim().isNotEmpty ? _commentCtrl.text.trim() : 'Great coaching session!',
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/animations/success_check.gif',
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(child: Text('Review submitted! Thank you!')),
            ],
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit review: $e'), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.top(24),
      ),
      padding: EdgeInsets.fromLTRB(SpacingScale.s20, SpacingScale.s20, SpacingScale.s20, MediaQuery.of(context).viewInsets.bottom + SpacingScale.s20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Review ${widget.coachName}', style: AppTextStyles.title2.copyWith(fontWeight: FontWeight.w700, color: textPrimary)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: SpacingScale.s12),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starValue = index + 1.0;
                return IconButton(
                  icon: Icon(
                    starValue <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 36,
                    color: starValue <= _rating ? AppColors.gold : AppColors.textTertiary,
                  ),
                  onPressed: () => setState(() => _rating = starValue),
                );
              }),
            ),
          ),
          const SizedBox(height: SpacingScale.s12),
          TextField(
            controller: _commentCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Share feedback about your coaching experience, drills, and improvements...',
              filled: true,
              fillColor: isDark ? AppColors.surface : AppColors.lightSurface,
              border: OutlineInputBorder(borderRadius: AppRadius.brXl2),
            ),
          ),
          const SizedBox(height: SpacingScale.s16),
          PrimaryButton(
            label: _submitting ? 'Submitting...' : 'Submit Review',
            icon: Icons.send_rounded,
            onPressed: _submitting ? null : _submitReview,
            expanded: true,
          ),
        ],
      ),
    );
  }
}
