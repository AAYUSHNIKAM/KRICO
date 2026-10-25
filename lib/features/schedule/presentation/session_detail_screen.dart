import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../../core/gamification/krico_xp_system.dart';
import '../data/session_qr_service.dart';
import 'widgets/session_qr_modal.dart';
import 'widgets/session_attendance_scanner_modal.dart';
import 'widgets/coach_otp_attendance_dialog.dart';
import 'widgets/session_routine_progress_form_modal.dart';
import '../../coach/presentation/widgets/review_coach_modal.dart';

class SessionDetailScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const SessionDetailScreen({super.key, required this.sessionId});

  @override
  ConsumerState<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends ConsumerState<SessionDetailScreen> {
  Map<String, dynamic>? _sessionData;
  bool _loading = true;
  bool _hasAutoPromptedReview = false;

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

        _ensureCheckoutOtpInitialized(data);

        if (!_hasAutoPromptedReview) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _checkAutoPromptReview());
        }
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _ensureCheckoutOtpInitialized(Map<String, dynamic>? data) async {
    if (data == null) return;
    final status = data['status'] as String? ?? 'booked';
    final existingCheckoutOtp = data['checkoutOtp'] as String?;
    if ((status == 'checked_in' || status == 'in_progress') && (existingCheckoutOtp == null || existingCheckoutOtp.isEmpty)) {
      final generatedPin = SessionQrService.getQuickPin('${widget.sessionId}_checkout');
      try {
        await FirebaseFirestore.instance.collection('sessions').doc(widget.sessionId).set({
          'checkoutOtp': generatedPin,
          'checkoutInitializedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        _sessionData?['checkoutOtp'] = generatedPin;
      } catch (_) {}
    }
  }

  void _checkAutoPromptReview() {
    if (!mounted || _sessionData == null) return;
    final status = _sessionData!['status'] as String? ?? '';
    if (status != 'completed') return;

    final uid = ref.read(authStateProvider).asData?.value?.uid;
    final playerId = _sessionData!['playerId'] as String? ?? '';
    final hasReviewed = _sessionData!['hasReviewed'] as bool? ?? false;

    if (uid != null && uid == playerId && !hasReviewed && !_hasAutoPromptedReview) {
      _hasAutoPromptedReview = true;
      _openReviewModal();
    }
  }

  String get _checkInPin {
    final stored = _sessionData?['checkInOtp'] as String?;
    if (stored != null && stored.isNotEmpty) return stored;
    return SessionQrService.getQuickPin(widget.sessionId);
  }

  String get _checkoutOtp {
    final stored = _sessionData?['checkoutOtp'] as String?;
    if (stored != null && stored.isNotEmpty) return stored;
    return SessionQrService.getQuickPin('${widget.sessionId}_checkout');
  }

  Future<void> _showCoachOtpCheckInDialog({required String athleteName}) async {
    final coachId = ref.read(authStateProvider).asData?.value?.uid ?? '';
    final verified = await CoachOtpAttendanceDialog.show(
      context,
      sessionId: widget.sessionId,
      coachId: coachId,
      playerName: athleteName,
      sport: _sessionData?['sport'] as String? ?? 'Training',
    );

    if (verified == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Athlete check-in verified successfully via OTP!'),
          backgroundColor: AppColors.emerald,
        ),
      );
      _loadSession();
    }
  }

  Future<void> _openProgressForm({required bool isFinalCompletion}) async {
    if (_sessionData == null) return;
    final coachId = _sessionData!['coachId'] as String? ?? '';
    final playerId = _sessionData!['playerId'] as String? ?? '';
    final playerName = _sessionData!['playerName'] as String? ?? 'Athlete';

    int playerLevel = 1;
    try {
      final pSnap = await FirebaseFirestore.instance.collection('players').doc(playerId).get();
      if (pSnap.exists) {
        playerLevel = (pSnap.data()?['level'] as num?)?.toInt() ?? 1;
      }
    } catch (_) {}

    final savedProgress = _sessionData!['savedProgress'] as Map<String, dynamic>?;

    final completed = await SessionRoutineProgressFormModal.show(
      context,
      sessionId: widget.sessionId,
      coachId: coachId,
      playerId: playerId,
      playerName: playerName,
      playerLevel: playerLevel,
      isFinalCompletion: isFinalCompletion,
      initialSavedProgress: savedProgress,
    );

    if (completed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session completed & KRICO XP awarded to athlete!'),
          backgroundColor: AppColors.emerald,
        ),
      );
      _loadSession();
    } else if (mounted) {
      _loadSession();
    }
  }

  Future<void> _showCoachCheckoutOtpDialog() async {
    final expectedOtp = _checkoutOtp;
    final textPrimary = Theme.of(context).brightness == Brightness.dark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;

    final otpController = TextEditingController();
    String? errorText;

    final verified = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return Dialog(
            backgroundColor: cardColor,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.brXl2),
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Padding(
              padding: const EdgeInsets.all(SpacingScale.s24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.volt.withValues(alpha: 0.15),
                          borderRadius: AppRadius.brLg,
                        ),
                        child: const Icon(Icons.verified_user_rounded, color: AppColors.volt, size: 22),
                      ),
                      const SizedBox(width: SpacingScale.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Verify Checkout OTP',
                              style: AppTextStyles.title3.copyWith(
                                color: textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Athlete must provide this code to finish',
                              style: AppTextStyles.caption.copyWith(color: textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SpacingScale.s20),
                  Container(
                    padding: const EdgeInsets.all(SpacingScale.s12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF131826) : const Color(0xFFF1F5F9),
                      borderRadius: AppRadius.brLg,
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.volt),
                        const SizedBox(width: SpacingScale.s8),
                        Expanded(
                          child: Text(
                            'Ask the athlete to open their session page and read their 6-digit Checkout OTP.',
                            style: TextStyle(fontSize: 12, color: textSecondary, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: SpacingScale.s20),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8,
                      color: textPrimary,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '------',
                      filled: true,
                      fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.brLg,
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(color: AppColors.volt, width: 2),
                      ),
                    ),
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: SpacingScale.s8),
                    Text(
                      errorText!,
                      style: const TextStyle(fontSize: 12, color: AppColors.danger, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: SpacingScale.s24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(dialogCtx).pop(false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: borderColor),
                            shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                          ),
                          child: Text('Cancel', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: SpacingScale.s12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final input = otpController.text.trim();
                            if (input == expectedOtp || input == SessionQrService.getQuickPin(widget.sessionId)) {
                              Navigator.of(dialogCtx).pop(true);
                            } else {
                              setDialogState(() {
                                errorText = 'Invalid checkout OTP. Please ask the athlete to refresh their screen.';
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.volt,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                          ),
                          child: const Text('Verify & Grade', style: TextStyle(fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    if (verified == true && mounted) {
      await _openProgressForm(isFinalCompletion: true);
    }
  }

  void _openReviewModal() async {
    if (_sessionData == null) return;
    final coachId = _sessionData!['coachId'] as String? ?? '';
    final coachName = _sessionData!['coachName'] as String? ?? 'Coach';
    final playerId = _sessionData!['playerId'] as String? ?? '';
    final playerName = _sessionData!['playerName'] as String? ?? 'Athlete';

    final reviewed = await ReviewCoachModal.show(
      context,
      sessionId: widget.sessionId,
      coachId: coachId,
      coachName: coachName,
      playerId: playerId,
      playerName: playerName,
    );

    if (reviewed == true && mounted) {
      _sessionData?['hasReviewed'] = true;
      setState(() {});
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
          const SnackBar(
            content: Text('Session rescheduled!'),
            backgroundColor: AppColors.success,
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
        title: Text(
          'Cancel Session',
          style: AppTextStyles.title2.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).brightness == Brightness.dark ? AppColors.textPrimary : AppColors.lightTextPrimary,
          ),
        ),
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
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(coachServiceProvider).respondToBooking(widget.sessionId, 'cancelled');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Session cancelled'), backgroundColor: AppColors.danger),
                  );
                  _loadSession();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to cancel: $e'), backgroundColor: AppColors.danger),
                  );
                }
              }
            },
            child: Text('Yes, Cancel', style: AppTextStyles.button.copyWith(color: AppColors.danger)),
          ),
        ],
      ),
    );
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
    final sport = data['sport'] as String? ?? 'Athletics & Training';
    final playerId = data['playerId'] as String? ?? '';
    final playerName = data['playerName'] as String? ?? 'Athlete';
    final coachId = data['coachId'] as String? ?? '';
    final uid = ref.watch(authStateProvider).asData?.value?.uid;
    final isCoach = uid != null && uid == coachId;
    final isPlayer = uid != null && (uid == playerId || uid == data['bookedBy']);
    final isParticipant = isCoach || isPlayer;
    final amount = (data['amount'] as num?)?.toDouble() ?? 0;
    final notes = data['notes'] as String? ?? '';
    final totalAwardedXp = (data['totalSessionXpAwarded'] as num?)?.toInt() ?? 0;
    final hasReviewed = data['hasReviewed'] as bool? ?? false;

    Color statusColor;
    String statusLabel;
    switch (status) {
      case 'completed':
        statusColor = AppColors.emerald;
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
      case 'in_progress':
        statusColor = AppColors.volt;
        statusLabel = 'In Training';
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
                                    color: (status == 'checked_in' || status == 'in_progress')
                                        ? Colors.black.withValues(alpha: 0.3)
                                        : Colors.white.withValues(alpha: 0.2),
                                    borderRadius: AppRadius.brFull,
                                  ),
                                  child: Text(
                                    statusLabel,
                                    style: AppTextStyles.labelSm.copyWith(
                                      color: (status == 'checked_in' || status == 'in_progress')
                                          ? Colors.black
                                          : Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                if (totalAwardedXp > 0) ...[
                                  const SizedBox(width: SpacingScale.s8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: SpacingScale.s10,
                                      vertical: SpacingScale.s4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.25),
                                      borderRadius: AppRadius.brFull,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.bolt_rounded, size: 14, color: AppColors.volt),
                                        const SizedBox(width: 4),
                                        Text(
                                          '+$totalAwardedXp KRICO XP',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: SpacingScale.s16),
                            Text(
                              sport,
                              style: AppTextStyles.heading2.copyWith(
                                color: (status == 'checked_in' || status == 'in_progress')
                                    ? Colors.black
                                    : Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: SpacingScale.s8),
                            if (dateTime != null) ...[
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 16,
                                    color: (status == 'checked_in' || status == 'in_progress')
                                        ? Colors.black87
                                        : Colors.white70,
                                  ),
                                  const SizedBox(width: SpacingScale.s8),
                                  Text(
                                    DateFormat('EEEE, MMMM d, yyyy').format(dateTime),
                                    style: AppTextStyles.body.copyWith(
                                      color: (status == 'checked_in' || status == 'in_progress')
                                          ? Colors.black87
                                          : Colors.white70,
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
                                      errorBuilder: (context, error, stackTrace) => Icon(
                                        Icons.access_time_rounded,
                                        size: 16,
                                        color: (status == 'checked_in' || status == 'in_progress')
                                            ? Colors.black87
                                            : Colors.white70,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: SpacingScale.s8),
                                  Text(
                                    DateFormat('hh:mm a').format(dateTime),
                                    style: AppTextStyles.body.copyWith(
                                      color: (status == 'checked_in' || status == 'in_progress')
                                          ? Colors.black87
                                          : Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (amount > 0) ...[
                              const SizedBox(height: SpacingScale.s12),
                              Text(
                                '?${amount.toInt()}',
                                style: AppTextStyles.heading2.copyWith(
                                  color: (status == 'checked_in' || status == 'in_progress')
                                      ? Colors.black
                                      : Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),


                      if (isPlayer && (status == 'confirmed' || status == 'booked' || status == 'scheduled')) ...[
                        const SizedBox(height: SpacingScale.s20),
                        _buildAthleteCheckInCard(isDark, textPrimary, textSecondary),
                      ],

                      if (isPlayer && (status == 'checked_in' || status == 'in_progress')) ...[
                        const SizedBox(height: SpacingScale.s20),
                        _buildAthleteCheckoutCard(isDark, textPrimary, textSecondary),
                      ],

                      if (isCoach && (status == 'checked_in' || status == 'in_progress')) ...[
                        const SizedBox(height: SpacingScale.s20),
                        _buildCoachTrainingControlCard(isDark, textPrimary, textSecondary),
                      ],

                      ..._attendanceBlocks(data, isDark, textSecondary, textPrimary),

                      if (status == 'completed') ...[
                        const SizedBox(height: SpacingScale.s20),
                        _buildCompletedCurriculumCard(data, isDark, textPrimary, textSecondary),
                      ],

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

                        if (status == 'completed') ...[
                          if (isPlayer) ...[
                            if (!hasReviewed) ...[
                              PrimaryButton(
                                label: 'Rate & Review Coach',
                                icon: Icons.star_rate_rounded,
                                onPressed: _openReviewModal,
                                expanded: true,
                              ),
                              const SizedBox(height: SpacingScale.s8),
                            ],
                            PrimaryButton(
                              label: 'Rebook This Coach',
                              icon: Icons.replay_rounded,
                              onPressed: () => _rebookCoach(context, coachId),
                              expanded: true,
                            ),
                          ],
                          if (isCoach) ...[
                            PrimaryButton(
                              label: 'View Athlete Progress Profile',
                              icon: Icons.assignment_ind_rounded,
                              onPressed: () => context.push('/student-progress/$playerId', extra: {'coachId': coachId}),
                              expanded: true,
                            ),
                          ],
                        ],

                        if (isCoach && (status == 'confirmed' || status == 'booked' || status == 'scheduled')) ...[
                          PrimaryButton(
                            label: 'Enter Athlete Check-In OTP',
                            icon: Icons.pin_rounded,
                            onPressed: () => _showCoachOtpCheckInDialog(athleteName: playerName),
                            expanded: true,
                          ),
                          const SizedBox(height: SpacingScale.s8),
                          PrimaryButton(
                            label: 'Show Session QR Check-In',
                            icon: Icons.qr_code_2_rounded,
                            onPressed: () => SessionQrModal.show(
                              context,
                              sessionId: widget.sessionId,
                              coachId: coachId,
                              playerId: playerId,
                              playerName: playerName,
                              sport: sport,
                              sessionTime: dateTime != null ? DateFormat('hh:mm a').format(dateTime) : 'Session',
                            ),
                            expanded: true,
                          ),
                          const SizedBox(height: SpacingScale.s8),
                          PrimaryButton(
                            label: 'Scan Athlete QR Code',
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
                        ],

                        if (isPlayer && (status == 'confirmed' || status == 'booked' || status == 'scheduled')) ...[
                          PrimaryButton(
                            label: 'Scan Attendance QR',
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
                          PrimaryButton(
                            label: 'Show My Attendance QR',
                            icon: Icons.qr_code_rounded,
                            onPressed: () => SessionQrModal.show(
                              context,
                              sessionId: widget.sessionId,
                              coachId: coachId,
                              playerId: playerId,
                              playerName: playerName,
                              sport: sport,
                              sessionTime: dateTime != null ? DateFormat('hh:mm a').format(dateTime) : 'Session',
                            ),
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
                        if (status == 'cancelled' && isPlayer) ...[
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


  Widget _buildAthleteCheckInCard(bool isDark, Color textPrimary, Color textSecondary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SpacingScale.s16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131826) : const Color(0xFFEFF6FF),
        borderRadius: AppRadius.brXl2,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pin_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: SpacingScale.s8),
              Text(
                'Your Check-In Attendance PIN',
                style: AppTextStyles.title3.copyWith(
                  color: textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingScale.s8),
          Text(
            'Share this 6-digit PIN with your coach or scan their QR code to verify your arrival.',
            style: TextStyle(fontSize: 13, color: textSecondary, height: 1.3),
          ),
          const SizedBox(height: SpacingScale.s12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: AppRadius.brLg,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _checkInPin,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 6,
                    color: AppColors.primary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 20, color: AppColors.primary),
                  tooltip: 'Copy PIN',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _checkInPin));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Check-In PIN copied to clipboard!')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAthleteCheckoutCard(bool isDark, Color textPrimary, Color textSecondary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SpacingScale.s16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF064E3B).withValues(alpha: isDark ? 0.6 : 0.2),
            const Color(0xFF065F46).withValues(alpha: isDark ? 0.4 : 0.1),
          ],
        ),
        borderRadius: AppRadius.brXl2,
        border: Border.all(color: AppColors.emerald.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.2),
                  borderRadius: AppRadius.brMd,
                ),
                child: const Icon(Icons.verified_user_rounded, color: AppColors.emerald, size: 18),
              ),
              const SizedBox(width: SpacingScale.s8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Session Checkout OTP',
                      style: AppTextStyles.title3.copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Provide to coach at the end of training',
                      style: TextStyle(fontSize: 12, color: textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingScale.s12),
          Text(
            'Your coach will enter this 6-digit code to complete the session, record your performance grades, and award your KRICO XP.',
            style: TextStyle(fontSize: 13, color: textSecondary, height: 1.4),
          ),
          const SizedBox(height: SpacingScale.s12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0B132B) : Colors.white,
              borderRadius: AppRadius.brLg,
              border: Border.all(color: AppColors.emerald.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _checkoutOtp,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 6,
                    color: AppColors.emerald,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 20, color: AppColors.emerald),
                  tooltip: 'Copy Checkout OTP',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _checkoutOtp));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Checkout OTP copied to clipboard!')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoachTrainingControlCard(bool isDark, Color textPrimary, Color textSecondary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SpacingScale.s16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1F36) : const Color(0xFFF8FAFC),
        borderRadius: AppRadius.brXl2,
        border: Border.all(color: AppColors.volt.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.volt.withValues(alpha: 0.2),
                  borderRadius: AppRadius.brMd,
                ),
                child: const Icon(Icons.sports_rounded, color: AppColors.volt, size: 18),
              ),
              const SizedBox(width: SpacingScale.s8),
              Text(
                'Training In Progress',
                style: AppTextStyles.title3.copyWith(
                  color: textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingScale.s8),
          Text(
            'Record sub-routine progress incrementally throughout the session. When finished, tap Checkout & Enter OTP to verify and award KRICO XP.',
            style: TextStyle(fontSize: 13, color: textSecondary, height: 1.4),
          ),
          const SizedBox(height: SpacingScale.s16),
          OutlinedButton.icon(
            onPressed: () => _openProgressForm(isFinalCompletion: false),
            icon: const Icon(Icons.playlist_add_check_rounded, color: AppColors.volt),
            label: const Text(
              'Save / Update Training Progress',
              style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.volt),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              side: const BorderSide(color: AppColors.volt, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
            ),
          ),
          const SizedBox(height: SpacingScale.s10),
          ElevatedButton.icon(
            onPressed: _showCoachCheckoutOtpDialog,
            icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.black),
            label: const Text(
              'Checkout & Enter Athlete OTP',
              style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black),
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: AppColors.volt,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildCompletedCurriculumCard(
    Map<String, dynamic> data,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
  ) {
    final progress = data['savedProgress'] as Map<String, dynamic>?;
    final totalXp = (data['totalSessionXpAwarded'] as num?)?.toInt() ?? 0;
    final coachNotes = progress?['coachNotes'] as String? ?? '';
    final completedSubIds = (progress?['completedSubRoutineIds'] as List<dynamic>?)?.cast<String>() ?? [];
    final metrics = (progress?['performanceMetrics'] as Map<String, dynamic>?) ?? {};

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SpacingScale.s16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl2,
        border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium_rounded, color: AppColors.emerald, size: 20),
              const SizedBox(width: SpacingScale.s8),
              Expanded(
                child: Text(
                  'Verified Training Curriculum',
                  style: AppTextStyles.title3.copyWith(
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ),
              if (totalXp > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.15),
                    borderRadius: AppRadius.brFull,
                  ),
                  child: Text(
                    '+$totalXp XP Awarded',
                    style: const TextStyle(
                      color: AppColors.emerald,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: SpacingScale.s12),
          if (completedSubIds.isNotEmpty) ...[
            Text(
              'Completed Sub-Routines (${completedSubIds.length}):',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textSecondary),
            ),
            const SizedBox(height: SpacingScale.s6),
            ...completedSubIds.map((subId) {
              final metricVal = metrics[subId]?.toString() ?? 'Completed';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.emerald),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        subId.replaceAll('sub_', '').toUpperCase(),
                        style: TextStyle(fontSize: 13, color: textPrimary, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      metricVal,
                      style: TextStyle(fontSize: 12, color: textSecondary),
                    ),
                  ],
                ),
              );
            }),
          ] else ...[
            Text(
              'Standard KRICO Session Curriculum Completed.',
              style: TextStyle(fontSize: 13, color: textSecondary),
            ),
          ],
          if (coachNotes.isNotEmpty) ...[
            const SizedBox(height: SpacingScale.s12),
            Container(
              padding: const EdgeInsets.all(SpacingScale.s10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131826) : const Color(0xFFF1F5F9),
                borderRadius: AppRadius.brMd,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: AppColors.volt),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Coach Feedback: $coachNotes',
                      style: TextStyle(fontSize: 12, color: textSecondary, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
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

  List<Widget> _attendanceBlocks(
    Map<String, dynamic> data,
    bool isDark,
    Color textSecondary,
    Color textPrimary,
  ) {
    final status = data['status'] as String? ?? 'booked';
    if (status != 'checked_in' && status != 'in_progress' && status != 'completed') return const [];
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

