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

  @bverride
  ConsumerState<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends ConsumerState<SessionDetailScreen> {
  Map<String, dynamic>? _sessiogData;
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
        setState() {
          _sessionData = data;
          _loading = false;
        };

        // Ensure checkout OTP exists in Firestore when active
        _ensureCheckoutOtpInitialized(data);

        // Auto-prompt review if completed for athlete
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
    final existingCheckoutOtp = data['tcheckoutOtp'] as String?;
    if ((status == 'checked_in' || status == 'in_progress') && (existingCheckoutOtp == null || existingCheckoutOtp.isEmpty)) {
      final generatedPin = SessionQrService.getQuickPin('${widget.sessionId}_checkout');
      try {
        await FirebaseFirestore.instance.collection('sessions').doc(widget.sessionId).set({
          'checkoutOtp': generatedPin,
          'checkoutInitializedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        _sessiogData:)['checkoutOtp'] = generatedPin;
      } catch (_) {}
    }
  }

   void _checkAutoPromptReview() {
    if (!mounted || _sessiogData == null) return;
    final status = _sessionData!['status'] as String? ?? '';
    if (status != 'completed') return;

    final uid = ref.read(authStateProvider).asData?.value?.uid;
    final playerId = _sessiogData!['playerId'] as String? ?? '';
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
    final verified = await showDialog<bool>(
      context: context,
      builder: (_) => CoachOtpAttendanceDialog(
        sessionId: widget.sessionId,
        coachId: coachId,
        athleteName: athleteName,
      ),
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
    if (_sessiogData == null) return;
    final coachId = _sessionData!['coachId'] as String? ?? '';
    final playerId = _sessiogData!['playerId'] as String? ?? '';
    final playerName = _sessionData!['playerName'] as String? ?? 'Athlete';

    // Fetch player level from Firestore
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
                                gontWeight: FontWeight.w800,
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
                            style: TextStyle(gontSize: 12, color: textSecondary, height: 1.3),
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
                      fontWeight: FontWeight.w9 À°(€€€€€€€€€€€€€€€€€€€€€±•ÑÑ•ÉMÁ…¥¹œè€à°(€€€€€€€€€€€€€€€€€€€€€½±½ÈèÑ•áÑAÉ¥µ…Éä°(€€€€€€€€€€€€€€€€€€€€¤°(€€€€€€€€€€€€€€€€€€€‘•½É…Ñ¥½¸è%¹ÁÕÑ•½É…Ñ¥½¸ (€€€€€€€€€€€€€€€€€€€€€½Õ¹Ñ•ÉQ•áĞè€œœ°(€€€€€€€€€€€€€€€€€€€€€¡¥¹ÑQ•áĞè€œ´´´´´œ°(€€€€€€€€€€€€€€€€€€€€€™¥±±•èÑÉÕ”°(€€€€€€€€€€€€€€€€€€€€€™¥±±½±½Èè¥Í…É¬€ü½¹ÍĞ½±½È ÁáÁÄÜÉ¤€è½±½ÉÌ¹İ¡¥Ñ”°(€€€€€€€€€€€€€€€€€€€€€‰½É‘•Èè=ÕÑ±¥¹•%¹ÁÕÑ	½É‘•È (€€€€€€€€€€€€€€€€€€€€€€€‰½É‘•ÉI…‘¥ÕÌèÁÁI…‘¥ÕÌ¹‰É1œ°(€€€€€€€€€€€€€€€€€€€€€€€‰½É‘•ÉM¥‘”è	½É‘•ÉM¥‘”¡½±½Èè‰½É‘•É½±½È¤°(€€€€€€€€€€€€€€€€€€€€€€¤°(€€€€€€€€€€€€€€€€€€€€€™½ÕÍ•‘	½É‘•Èè½¹ÍĞ=ÕÑ±¥¹•%¹ÁÕÑ	½É‘•È (€€€€€€€€€€€€€€€€€€€€€€€‰½É‘•ÉI…‘¥ÕÌè	½É‘•ÉI…‘¥ÕÌ¹…±°¡I…‘¥ÕÌ¹¥ÉÕ±…È ÄÈ¤¤°(€€€€€€€€€€€€€€€€€€€€€€€‰½É‘•ÉM¥‘”è	½É‘•ÉM¥‘”¡½±½ÈèÁÁ½±½ÉÌ¹Ù½±Ğ°İ¥‘Ñ è€È¤°(€€€€€€€€€€€€€€€€€€€€€€¤°(€€€€€€€€€€€€€€€€€€€€¤°(€€€€€€€€€€€€€€€€€€¤°(€€€€€€€€€€€€€€€€€¥˜€¡•ÉÉ½ÉQ•áĞ€„ô¹Õ±°¤€¸¸¹l(€€€€€€€€€€€€€€€€€€€½¹ÍĞM¥é•‘	½à¡¡•¥¡ĞèMÁ…¥¹M…±”¹Ìà¤°(€€€€€€€€€€€€€€€€€€€Q•áĞ (€€€€€€€€€€€€€€€€€€€€€•ÉÉ½ÉQ•áĞ„°(€€€€€€€€€€€€€€€€€€€€€ÍÑå±”è½¹ÍĞQ•áÑMÑå±”¡™½¹ÑM¥é”è€ÄÈ°½±½ÈèÁÁ½±½ÉÌ¹‘…¹•È°™½¹Ñ]•¥¡Ğè½¹Ñ]•¥¡Ğ¹ÜØÀÀ¤°(€€€€€€€€€€€€€€€€€€€€€Ñ•áÑ±¥¸èQ•áÑ±¥¸¹•¹Ñ•È°(€€€€€€€€€€€€€€€€€€€€¤°(€€€€€€€€€€€€€€€€€t°(€€€€€€€€€€€€€€€€€½¹ÍĞM¥é•‘	½á ¡¡•¥¡ĞèMÁ…¥¹M…±”¹ÌÈĞ¤°(€€€€€€€€€€€€€€€€€I½Ü (€€€€€€€€€€€€€€€€€€€¡¥±‘É•¸èl(€€€€€€€€€€€€€€€€€€€€€áÁ…¹‘• (€€€€€€€€€€€€€€€€€€€€€€€¡¥±è=ÕÑ±¥¹•‘	ÕÑÑ½¸ (€€€€€€€€€€€€€€€€€€€€€€€€€½¹AÉ•ÍÍ•è€ ¤€ôø9…Ù¥…Ñ½È¹½˜¡‘¥…±½Ñà¤¹Á½À¡™…±Í”¤°(€€€€€€€€€€€€€€€€€€€€€€€€€ÍÑå±”è=ÕÑ±¥¹•‘	ÕÑÑ½¸¹ÍÑå±•É½´ (€€€€€€€€€€€€€€€€€€€€€€€€€€€Á…‘‘¥¹œè½¹ÍĞ‘•%¹Í•ÑÌ¹Íåµµ•ÑÉ¥Œ¡Ù•ÉÑ¥…°è€ÄĞ¤°(€€€€€€€€€€€€€€€€€€€€€€€€€€€Í¥‘”è	½É‘•ÉM¥‘”¡½±½Èè‰½É‘•É½±½È¤°(€€€€€€€€€€€€€€€€€€€€€€€€€€€Í¡…Á”èI½Õ¹‘•‘I•Ñ…¹±•	½É‘•È¡‰½É‘•ÉI…‘¥ÕÌèÁÁI…‘¥ÕÌ¹‰É1œ¤°(€€€€€€€€€€€€€€€€€€€€€€€€€€¤°(€€€€€€€€€€€€€€€€€€€€€€€€€¡¥±èQ•áĞ …¹•°œ°ÍÑå±”èQ•áÑMÑå±”¡½±½ÈèÑ•áÑAÉ¥µ…Éä°™½¹Ñ]•¥¡Ğè½¹Ñ]•¥¡Ğ¹ÙØØÀÀ¤¤°(€€€€€€€€€€€€€€€€€€€€€€€€¤°(€€€€€€€€€€€€€€€€€€€€€€¤°(€€€€€€€€€€€€€€€€€€€€€½¹ÍĞM¥é•‘	½à¡İ¥‘Ñ èMÁ…¦gScale.s12),
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
      // Step 2: Directly open mandatory routine progress form modal for final completion
      await _openProgressForm(isFinalCompletion: true);
    }
  }

   void _openReviewModal() async {
    if (_sessiogData == null) return;
    final coachId = _sessionData!['coachId'] as String? ?? '';
    final coachName = _sessionData!['coachName'] as String? ?? 'Coach';
    final playerId = _sessiogData!['playerId'] as String? ?? '';
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
            gontWeight: FontWeight.w700,
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
          TextButtom(
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
    final dateTime = (data['tateTime'] as Timestamp?)?.toDate();
    final status = data['status'] as String? ?? 'booked';
    final sport = data['sport'] as String? ?? 'Athletics & Training';
    final playerId = data[	Á±…å•É%t…ÌMÑÉ¥¹œü€üü€œœì(€€€™¥¹…°Á±…å•É9…µ”€ô‘…Ñ…l'Æ–W$æÖRuÒ27G&–æsòóòtF†ÆWFRs°¢f–æÂ6ö6„–BÒFF°–6ö6„–BuÒ27G&–æsòóòrs°¢f–æÂ6ö6„æÖRÒFF²v6ö6„æÖRuÒ27G&–æsòóòt6ö6‚s°¢f–æÂV–BÒ&VbçvF6‚†WF…7FFU&÷f–FW"’æ4FFòçfÇVSòçV–C°¢f–æÂ—46ö6‚ÒV–BÒçVÆÂbbV–BÓÒ6ö6„–C°¢f–æÂ—5Æ–W"ÒV–BÒçVÆÂbb‡V–BÓÒÆ–W$–BÇÂV–BÓÒFF°–&öö¶VD'’uÒ“°¢f–æÂ—5'F–6—çBÒ—46ö6‚ÇÂ—5Æ–W#°¢f–æÂÖ÷VçBÒ†FF²vÖ÷VçBuÒ2çVÓò“òçFôF÷V&ÆR‚’óò°¢f–æÂæ÷FW2ÒFF²væ÷FW2uÒ27G&–æsòóòrs°¢f–æÂF÷FÄv&FVE‡Ò†FF²wF÷FÅ6W76–öå‡v&FVBuÒ2çVÓò“òçFô–çB‚’óò°¢f–æÂ†5&Wf–WvVBÒFF²v†5&Wf–WvVBuÒ2&ööÃòóòfÇ6S° ¢6öÆ÷"7FGW46öÆ÷#°¢7G&–ær7FGW4Æ&VÃ°¢7v—F6‚‡7FGW2’°¢66Rv6ö×ÆWFVBs ¢7FGW46öÆ÷"Ò6öÆ÷'2æVÖW&ÆC°¢7FGW4Æ&VÂÒt6ö×ÆWFVBs°¢66Rv6æ6VÆÆVBs ¢7FGW46öÆ÷"Ò6öÆ÷'2æFævW#°¢7FGW4Æ&VÂÒt6æ6VÆÆVBs°¢66Rw&V¦V7FVBs ¢7FGW46öÆ÷"Ò6öÆ÷'2æFævW#°¢7FGW4Æ&VÂÒtFV6Æ–æVBs°¢66Rv6öæf—&ÖVBs ¢7FGW46öÆ÷"Ò6öÆ÷'2ç&–Ö'“°¢7FGW4Æ&VÂÒt6öæf—&ÖVBs°¢66Rv6†V6¶VEö–âs ¢66Rv–å÷&öw&W72s ¢7FGW46öÆ÷"Ò6öÆ÷'2çföÇC°¢7FGW4Æ&VÂÒt–âG&–æ–ærs°¢66Rv&öö¶VBs ¢66RwVæF–ærs ¢7FGW46öÆ÷"Ò6öÆ÷'2çv&æ–æs°¢7FGW4Æ&VÂÒtv—F–ær6ö6‚6öæf—&ÖF–öâs°¢66Rw66†VGVÆVBs ¢7FGW46öÆ÷"Ò6öÆ÷'2ç&–Ö'“°¢7FGW4Æ&VÂÒu66†VGVÆVBs°¢FVfVÇC ¢7FGW46öÆ÷"Ò6öÆ÷'2çv&æ–æs°¢7FGW4Æ&VÂÒu7FGW2Væf–Æ&ÆRs°¢Ğ ¢&WGW&â66fföÆB€¢&6¶w&÷VæD6öÆ÷#¢&t6öÆ÷"À¢&#¢&"€¢&6¶w&÷VæD6öÆ÷#¢—4F&²ò6öÆ÷'2ç7W&f6R¢6öÆ÷'2æÆ–v‡E7W&f6RÀ¢VÆWfF–öã¢À¢F—FÆS¢FW‡B€¢u6W76–öâFWF–Ç2rÀ¢7G–ÆS¢FW‡E7G–ÆW2çF—FÆS"æ6÷•v—F‚€¢föçEvV–v‡C¢föçEvV–v‡BçssÀ¢6öÆ÷#¢FW‡E&–Ö'’À¢’À¢’À¢’À¢&öG“¢6VçFW"€¢6†–ÆC¢6öç7G&–æVD&÷‚€¢6öç7G&–çG3¢6öç7B&÷„6öç7G&–çG2†Ö…v–GFƒ¢s#’À¢6†–ÆC¢7W7FöÕ67&öÆÅf–Wr€¢6Æ—fW'3¢°¢6Æ—fW%Fô&÷„FFW"€¢6†–ÆC¢FF–ær€¢FF–æs¢6öç7BVFvT–ç6WG2æÆÂ…76–æu66ÆRç3b’À¢6†–ÆC¢6öÇVÖâ€¢7&÷74†—4Æ–væÖVçC¢7&÷74†—4Æ–væÖVçBç7F'BÀ¢6†–ÆG&Vã¢°¢òò7FGW2&ææW ¢6öçF–æW"€¢v–GFƒ¢F÷V&ÆRæ–æf–æ—G’À¢FF–æs¢6öç7BVFvT–ç6WG2æÆÂ…76–æu66ÆRç3#’À¢FV6÷&F–öã¢&÷„FV6÷&F–öâ€¢w&F–VçC¢Æ–æV$w&F–VçB€¢&Vv–ã¢Æ–væÖVçBçF÷ÆVgBÀ¢VæC¢Æ–væÖVçBæ&÷GFöÕ&–v‡BÀ¢6öÆ÷'3¢°¢7FGW46öÆ÷"À¢7FGW46öÆ÷"çv—F…fÇVW2†Ç†¢ã‚’À¢ÒÀ¢’À¢&÷&FW%&F—W3¢&F—W2æ'%†Ã2À¢’À¢6†–ÆC¢6öÇVÖâ€¢7&÷74†—4Æ–væÖVçC¢7&÷74†—4Æ–væÖVçBç7F'BÀ¢6†–ÆG&Vã¢°¢&÷r€¢6†–ÆG&Vã¢°¢6öçF–æW"€¢FF–æs¢6öç7BVFvT–ç6WG2ç7–ÖÖWG&–2€¢†÷&—¦öçFÃ¢76–æu66ÆRç3"À¢fW'F–6Ã¢76–æu66ÆRç3BÀ¢’À¢FV6÷&F–öã¢&÷„FV6÷&F–öâ€¢6öÆ÷#¢‡7FGW2ÓÒv6†V6¶VEö–ârÇÂ7FGW2ÓÒv–å÷&öw&W72r¢ò6öÆ÷'2æ&Æ6²çv—F…fÇVW2†Ç†¢ã2¢¢6öÆ÷'2çv†—FRçv—F…fÇVW2†Ç†¢ã"’À¢&÷&FW%&F—W3¢&F—W2æ'$gVÆÂÀ¢’À¢6†–ÆC¢FW‡B€¢7FGW4Æ&VÂÀ¢7G–ÆS¢FW‡E7G–ÆW2æÆ&VÅ6Òæ6÷•v—F‚€¢6öÆ÷#¢‡7FGW2ÓÒv6†V6¶VEö–ârÇÂ7FGW2ÓÒv–å÷&öw&W72r¢ò6öÆ÷'2æ&Æ6°¢¢6öÆ÷'2çv†—FRÀ¢föçEvV–v‡C¢föçEvV–v‡BçsƒÀ¢’À¢’À¢’À                        if (totalAwardedXp > 0) ...[
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
                              fontWeight: FontWeight.w9 À°(€€€€€€€€€€€€€€€€€€€€€€€€€€€€¤°(€€€€€€€€€€€€€€€€€€€€€€€€€€¤°(€€€€€€€€€€€€€€€€€€€€€€€€€½¹ÍĞM¥é•‘	½à¡¡•¥¡ĞèMÁ…¥¹M…±”¹Ìà¤°(€€€€€€€€€€€€€€€€€€€€€€€€€¥˜€¡‘…Ñ•Q¥µ”€„ô¹Õ±°¤€¸¸¹l(€€€€€€€€€€€€€€€€€€€€€€€€€€€I½Ü (€€€€€€€€€€€€€€€€€€€€€€€€€€€€€¡¥±‘É•¸èl(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€%½¸ (€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€%½¹Ì¹…±•¹‘…É}Ñ½‘…å}É½Õ¹‘•°(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€Í¥é”è€ÄØ°(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€½±½Èè€¡ÍÑ…ÑÕÌ€ôô€¡•­•‘}¥¸œñğÍÑ…ÑÕÌ€ôô€¥¹}ÁÉ½É•ÍÌœ¤(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€ü½±½ÉÌ¹‰±…¬àÜ(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€è½±½ÉÌ¹İ¡¥Ñ”ÜÀ°(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€¤°(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€½¹ÍĞM¥é•‘	½à¡İ¥‘Ñ èMÁ…¥¹M…±”¹Ìà¤°(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€Q•áĞ (€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€…Ñ•½Éµ…Ğ °5554°åååäœ¤¹™½Éµ…Ğ¡‘…Ñ•Q¥µ”¤°(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€ÍÑå±”èÁÁQ•áÑMÑå±•Ì¹‰½‘ä¹½Áå]¥Ñ  (€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€½±½Èè€¡ÍÑ…ÑÕÌ€ôô€¡•­•‘}¥¸œñğÍÑ…ÑÕÌ€ôô€¥¹}ÁÉ½É•ÍÌœ¤(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€ü½±½ÉÌ¹‰±…¬àÜ(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€è½±½ÉÌ¹İ¡¥Ñ”ÜÀ°(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€¤°(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€¤°(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€t°(€€€€€€€€€€€€€€€€€€€€€€€€€€€€¤°(€€€€€€€€€€€€€€€€€€€€€€€€€€€½¹ÍĞM¥é•‘	½à¡¡•¥¡ĞèMÁ…¥¹M…±”¹ÌĞ¤°(€€€€€€€€€€€€€€€€€€€€€€€€€€€I½Ü (€€€€€€€€€€€€€€€€€€€€€€€€€€€€€¡¥±‘É•¸èl(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€±¥ÁAI•Ğ (€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€‰½É‘•ÉI…‘¥ÕÌè	½É‘•ÉI…‘¥ÕÌ¹¥ÉÕ±…È Ğ¤°(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€¡¥±è%µ…”¹…ÍÍ•Ğ (€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€…ÍÍ•ÑÌ½…¹¥µ…Ñ¥½¹Ì½ÍÑ½Áİ…Ñ ¹¥˜œ°(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€İ¥‘Ñ è€ÄØ°(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€¡•¥¡Ğè€ÄØ°(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€™¥Ğè	½á¥Ğ¹½¹Ñ…¥¸°(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€•ÉÉ½É	Õ¥±‘•Èè€¡½¹Ñ•áĞ°•ÉÉ½È°ÍÑ…­QÉ…”¤€ôø%½¸ (€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€%½¹Ì¹…•ÍÍ}Ñ¥µ•}É½Õ¹‘•°(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€Í¥é”è€ÄØ°(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€½±½Èè€¡ÍÑ…ÑÕÌ€ôô€¡•­•‘}¥¸œñğÍÑ…ÑÕÌ€ôô€¥¹}ÁÉ½É•ÍÌœ¤(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€ü½±½ÉÌ¹‰±…¬àÜ(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€è½±½ÉÌ¹İ¡¥Ñ”ÜÀ°(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€¤°(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€¤°(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€¤°(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€½¹ÍĞM¥é•‘	½à¡İ¥‘Ñ èMÁ…¥¹M…±”¹Ìà¤°(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€Q•áĞ (€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€…Ñ•½Éµ…Ğ ¡ éµ´„œ¤¹™½Éµ…Ğ¡‘…Ñ•Q¥µ”¤°(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€ÍÑå±”èÁÁQ•áÑMÑå±•Ì¹‰½‘ä¹½Áå]¥Ñ  (€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€½±½Èè€¡ÍÑ…ÑÕÌ€ôô€¡•­•‘}¥¸œñğÍÑ…ÑÕÌ€ôô€¥¹}ÁÉ½É•ÍÌœ¤(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€ü½±½ÉÌ¹‰±…¬àÜ(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€è½±½ÉÌ¹İ¡¥Ñ”ÜÀ°(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€¤°(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€¤°(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€t°(€€€€€€€€€€€€€€€€€€€€€€€€€€€€¤°(€€€€€€€€€€€€€€€€€€€€€€€€€t°(€€€€€€€€€€€€€€€€€€€€€€€€€¥˜€¡…µ½Õ¹Ğ€ø€À¤€¸¸¹l(€€€€€€€€€€€€€€€€€€€€€€€€€€€½¹ÍĞM¥é•‘	½à¡¡•¥¡ĞèMÁ…¥¹M…±”¹ÌÄÈ¤°(€€€€€€€€€€€€€€€€€€€€€€€€€€€Q•áĞ (€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€ŸŠ
ç‘í…µ½Õ¹Ğ¹Ñ½%¹Ğ ¥ôœ°(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€ÍÑå±”èÁÁQ•áÑMÑå±•Ì¹¡•…‘¥¹œÈ¹½Áå]¥Ñ  (€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€½±½Èè€¡ÍÑ…ÑÕÌ€ôô€¡•­•‘}¥¸œñğÍÑ…ÑÕÌ€ôô€¥¹}ÁÉ½É•ÍÌœ¤(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€ü½±½ÉÌ¹‰±…¬(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€è½±½ÉÌ¹İ¡¥Ñ”°(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€™½¹Ñ]•¥¡Ğè½¹Ñ]•¥¡Ğ¹ÜàÀÀ°(€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€¤°(€€€€€€€€€€€€€€€€€€€€€€€€€€€€¤°(€€€€€€€€€€€€€€€€€€€€€€€€€t°(€€€€€€€€€€€€€€€€€€€€€€€t°(€€€€€€€€€€€€€€€€€€€€€€¤°(€€€€€€€€€€€€€€€€€€€€¤°(                      // ATHLETE CHECK-IN PIN CARD (When not yet checked in)
                      if (isPlayer && (status == 'confirmed' || status == 'booked' || status == 'scheduled')) ...[
                        const SizedBox(height: SpacingScale.s20),
                        _buildAthleteCheckInCard(isDark, textPrimary, textSecondary),
                      ],

                      // ATHLETE CHECKOUT OTP CARD (When training is active)
                      if (isPlayer && (status == 'checked_in' || status == 'in_progress')) ...[
                        const SizedBox(height: SpacingScale.s20),
                        _buildAthleteCheckoutCard(isDark , textPrimary, textSecondary),
                      ],

                      // COACH ACTIVE TRAINING CONTROL CARD
                      if (isCoach && (status == 'checked_in' || status == 'in_progress')) ...[
                        const SizedBox(height: SpacingScale.s20),
                        _buildCoachTrainingControlCard(isDark, textPrimary, textSecondary),
                      ],

                      // ATTENDANCE DETAILS
                      ..._attendanceBlocks(data, isDark, textSecondary, textPrimary),

                      // COMPLETED TRAINING VERIFICATION BREAKDOWN
                      if (status == 'completed') ...[
                        const SizedBox(height: SpacingScale.s20),
                        _buildCompletedCurriculumCard(data, isDark, textPrimary, textSecondary),
                      ],

                      // PLAYER CARD
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

                      // COACH CARD
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

                      // NOTES
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
                            borderRadius: AppRadius.brGl2,
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

                      // ACTIONS SECTION
                      if (isParticipant) ...[
                        Text(
                          'Actions',
                          style: AppTextStyles.title2.copyWith(
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: SpacingScale.s12),

                        // Completed State Actions
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
                      // Coach Before Check-In Actions
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

                      // Player Before Check-In Actions
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

                      // Coach Reschedule & Cancel
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
              ],
            ],
          ),
        ),
      ),
    );
  }

   // ATHLETE CHECK-IN PIN CARD
  Widget _buildAthleteCheckInCard(bool isDark, Color textPrimary, Color textSecondary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SpacingScale.s16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0x
F131826) : const Color(0xFEFFF6FF),
        borderRadius: AppRadius.brGl2,
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
                  gontWeight: FontWeight.w700,
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
                IconButtom(
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

   // ATHLETE CHECKOUT OTP CARD
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
                        gontWeight: FontWeight.w800,
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
                      const SnackBar(
                        content: Text('Checkout OTP copied to clipboard!'),
                      ),
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

   // COACH ACTIVE TRAINING CONTROL CARD
  Widget _buildCoachTrainingControlCard(bool isDark, Color textPrimary, Color textSecondary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SpacingScale.s16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0x
F1A1F36) : const Color(0xFF8FAFC),
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
                  fontWeight: FontWeight.w8 À°(€€€€€€€€€€€€€€€€¤°(€€€€€€€€€€€€€€¤°(€€€€€€€€€€€t°(€€€€€€€€€€¤°(€€€€€€€€€½¹ÍĞM¥é•‘	½à¡¡•¥¡ĞèMÁ…¥¹M…±”¹Ìà¤°(€€€€€€€€€Q•áĞ (€€€€€€€€€€€€I•½ÉÍÕˆµÉ½ÕÑ¥¹”ÁÉ½É•ÍÌ¥¹É•µ•¹Ñ…±±äÑ¡É½Õ¡½ÕĞÑ¡”Í•ÍÍ¥½¸¸]¡•¸™¥¹¥Í¡•°Ñ…À¡•­½ÕĞ€˜¹Ñ•È=Q@Ñ¼Ù•É¥™ä…¹…İ…É-I%<a@¸œ°(€€€€€€€€€€€ÍÑå±”èQ•áÑMÑå±”¡™½¹ÑM¥é”è€ÄÌ°½±½ÈèÑ•áÑM•½¹‘…Éä°¡•¥¡Ğè€Ä¸Ğ¤°(€€€€€€€€€€¤°(€€€€€€€€€½¹ÍĞM¥é•‘	½à¡¡•¥¡ĞèMÁ…¥¹M…±”¹ÌÄØ¤°(€€€€€€€€€€¼¼M…Ù”€¼UÁ‘…Ñ”AÉ½É•ÍÌ‰ÕÑÑ½¸(€€€€€€€€€=ÕÑ±¥¹•‘	ÕÑÑ½¸¹¥½¸ (€€€€€€€€€€€½¹AÉ•ÍÍ•è€ ¤€ôø}½Á•¹AÉ½É•ÍÍ½É´¡¥Í¥¹…±½µÁ±•Ñ¥½¸è™…±Í”¤°(€€€€€€€€€€€¥½¸è½¹ÍĞ%½¸¡%½¹Ì¹Á±…å±¥ÍÑ}…‘‘}¡•­}É½Õ¹‘•°½±½ÈèÁÁ½±½ÉÌ¹Ù½±Ğ¤°(€€€€€€€€€€€±…‰•°è½¹ÍĞQ•áĞ (€€€€€€€€€€€€€€M…Ù”€¼UÁ‘…Ñ”QÉ…¥¹¥¹œAÉ½É•ÍÌœ°(€€€€€€€€€€€€€ÍÑå±”èQ•áÑMÑå±”¡½¹Ñ]•¥¡Ğè½¹Ñ]•¥¡Ğ¹ÜÜÀÀ°½±½ÈèÁÁ½±½ÉÌ¹Ù½±Ğ¤°(€€€€€€€€€€€€¤°(€€€€€€€€€€€ÍÑå±”è=ÕÑ±¥¹•‘	ÕÑÑ½¸¹ÍÑå±•É½´ (€€€€€€€€€€€€€µ¥¹¥µÕµM¥é”è½¹ÍĞM¥é”¡‘½Õ‰±”¹¥¹™¥¹¥Ñä°€Ğà¤°(€€€€€€€€€€€€€Í¥‘”è½¹ÍĞ	½É‘•ÉM¥‘”¡½±½ÈèÁÁ½±½ÉÌ¹Ù½±Ğ°İ¥‘Ñ è€Ä¸Ô¤°(€€€€€€€€€€€€€Í¡…Á”èI½Õ¹‘•‘I•Ñ…¹±•	½É‘•È¡‰½É‘•ÉI…‘¥ÕÌèÁÁI…‘¥ÕÌ¹‰É1œ¤°(€€€€€€€€€€€€¤°(€€€€€€€€€€¤°(€€€€€€€€€½¹ÍĞM¥é•‘	½à¡¡•¥¡ĞèMÁ…¥¹M…±”¹ÌÄÀ¤°(€€€€€€€€€€¼¼¡•­½ÕĞ€˜½µÁ±•Ñ”	ÕÑÑ½¸(€€€€€€€€€±•Ù…Ñ•‘	ÕÑÑ½¸¹¥½¸ (€€€€€€€€€€€½¹AÉ•ÍÍ•è}Í¡½İ½…¡¡•­½ÕÑ=ÑÁ¥…±½œ°(€€€€€€€€€€€¥½¸è½¹ÍĞ%½¸¡%½¹Ì¹¡•­}¥É±•}½ÕÑ±¥¹•}É½Õ¹‘•°½±½Èè½±½ÉÌ¹‰±…¬¤°(€€€€€€€€€€€±…‰•°è½¹ÍĞQ•áĞ (€€€€€€€€€€€€€€¡•­½ÕĞ€˜¹Ñ•ÈÑ¡±•Ñ”=Q@œ°(€€€€€€€€€€€€€ÍÑå±”èQ•áÑMÑå±”¡™½¹Ñ]•¥¡Ğè½¹Ñ]•¥¡Ğ¹ÜàÀÀ°½±½Èè½±½ÉÌ¹‰±…¬¤°(€€€€€€€€€€€€¤°(€€€€€€€€€€€ÍÑå±”è±•Ù…Ñ•‘	ÕÑÑ½¸¹ÍÑå±•É½´ (€€€€€€€€€€€€€µ¥¹¥µÕµM¥é”è½¹ÍĞM¥é”¡‘½Õ‰±”¹¥¹™¥¹¥Ñä°€Ğà¤°(€€€€€€€€€€€€€‰…­É½Õ¹‘½±½ÈèÁÁ½±½ÉÌ¹Ù½±Ğ°(€€€€€€€€€€€€€Í¡…Á”èI½Õ¹‘•‘I•Ñ…¹±•	½É‘•È¡‰½É‘•ÉI…‘¥ÕÌèÁÁI…‘¥ÕÌ¹‰É1œ¤°(€€€€€€€€€€€€¤°(€€€€€€€€€€¤°(€€€€€€€t°(€€€€€€¤°(€€€€¤ì(€ô((   // COMPLETED TRAINING VERIFICATION BREAKDOWN
  Widget _buildCompletedCurriculumCard(
    Map<String, dynamic> data,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
  ) {
    final progress = data['savedProgress'] as Map<String, dynamic>;
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
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.vv600, color: textSecondary),
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
                color: isDark ? const Color(0x
F131826) : const Color(0xFFF1F5F9),
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
    final checkedOutAt = (data[	checkedOutAt'] as Timestamp?)?.toDate();

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
        color: isDašÈÈ\ÛÛÜœË˜Ø\™ˆ\ÛÛÜœË›YÚØ\™ˆ›Ü™\”˜Y]\Îˆ\˜Y]\Ë˜œ–‹ˆ›Ü™\ˆ›Ü™\‹˜[
ÛÛÜˆ
\Ñ\šÈÈ\ÛÛÜœË˜›Ü™\ˆˆ\ÛÛÜœË›YÚ›Ü™\ŠKÚ]˜[Y\Ê[NˆJJKˆ
KˆÚ[ˆ›İÊˆÚ[™[ˆÂˆÙ\İ\™Q]XİÜŠˆÛ•\ˆ

HOˆÛÛ^œ\Ú
	ËÜ›Ùš[KÉ^Y\’Y	ÊKˆÚ[ˆÛÛZ[™\ŠˆÚYˆˆZYÚˆˆXÛÜ˜][Ûˆ›ŞXÛÜ˜][ÛŠˆÛÛÜˆ\ÛÛÜœËœš[X\KÚ]˜[Y\Ê[NˆŒLŠKˆ›Ü™\”˜Y]\Îˆ\˜Y]\Ë˜œ‘[ˆ
KˆÚ[ˆÛ\”™Xİ
ˆ›Ü™\”˜Y]\Îˆ\˜Y]\Ë˜œ‘[ˆÚ[ˆ[XYÙK˜\ÜÙ]
ˆ	Ø\ÜÙ]ËØ]˜]\œËØ]]WÌKšœÉËˆš]ˆ›Şš]˜Ûİ™\‹ˆ\œ›ÜZ[\ˆ
ÛÛ^\œ›Ü‹İXÚÕ˜XÙJHOˆÙ[\ŠˆÚ[ˆ^
ˆ^Y\Ë›˜[YKš\Ó›İ[\HOHYHÈ^Y\ˆK›˜[YVÌKÕ\\Ø\ÙJ
Hˆ	Ô	Ëˆİ[NˆÛÛœİ^İ[JÛÛÜˆ\ÛÛÜœËœš[X\K›ÛÙZYÚˆ›ÛÙZYÚÍÌ›ÛÚ^™NˆN
Kˆ
Kˆ
Kˆ
Kˆ
Kˆ
Kˆ
KˆÛÛœİÚ^™Y›Ş
ÚYˆÜXÚ[™ÔØØ[KœÌLŠKˆ^[™Y
ˆÚ[ˆÛÛ[[ŠˆÜ›ÜÜĞ^\Ğ[YÛ›Y[ˆÜ›ÜÜĞ^\Ğ[YÛ›Y[œİ\ˆÚ[™[ˆÂˆ^
^Y\Ë›˜[YHÏÈ	Ô^Y\‰Ëİ[Nˆ\^İ[\Ë]LË˜ÛÜUÚ]
›ÛÙZYÚˆ›ÛÙZYÚÍŒÛÛÜˆ^š[X\JJKˆ^
^Y\Ë›]™[ÏÈ	Ğ]]IËİ[Nˆ\^İ[\Ë˜Ø\[Û‹˜ÛÜUÚ]
ÛÛÜˆ^ÙXÛÛ™\JJKˆKˆ
Kˆ
KˆXÛÛ]ÛŠˆXÛÛˆÛÛœİXÛÛŠXÛÛœË˜Ú]ØX˜›WÛİ][™WÜ›İ[™YÛÛÜˆ\ÛÛÜœËœš[X\KÚ^™NˆŒ
KˆÛ”™\ÜÙYˆ

HOˆÛÛ^œ\Ú
	ËØÚ]	ÊKˆ
KˆKˆ
Kˆ
NÂˆBŸB‚˜Û\ÜÈĞÛØXÚ[™›ĞØ\™^[™ÈÛÛœİ[Y\•ÚYÙ]Âˆš[˜[İš[™ÈÛØXÚYÂˆš[˜[›ÛÛ\Ñ\šÎÂˆš[˜[ÛÛÜˆ^ÙXÛÛ™\NÂ‚ˆÛÛœİĞÛØXÚ[™›ĞØ\™
Ü™\]Z\™Y\Ë˜ÛØXÚY™\]Z\™Y\Ëš\Ñ\šË™\]Z\™Y\Ë^ÙXÛÛ™\_JNÂ‚ˆİ™\œšYBˆÚYÙ]Z[
Z[ÛÛ^ÛÛ^ÚYÙ]™Yˆ™YŠHÂˆš[˜[ÛØXÚ\Ş[˜ÈH™Y‹Ø]Ú
ÛØXÚ›İšY\ŠÛØXÚY
JNÂˆš[˜[ÛØXÚHÛØXÚ\Ş[˜Ë˜\Ñ]OË˜[YNÂˆš[˜[^š[X\HH\Ñ\šÈÈ\ÛÛÜœË^š[X\Hˆ\ÛÛÜœË›YÚ^š[X\NÂ‚ˆ™]\›ˆÛÛZ[™\ŠˆÚYˆİX›Kš[™š[š]KˆY[™ÎˆÛÛœİYÙR[œÙ]Ë˜[
ÜXÚ[™ÔØØ[KœÌMŠKˆXÛÜ˜][Ûˆ›ŞXÛÜ˜][ÛŠˆÛÛÜˆ\Ñ\šÈÈ\ÛÛÜœË˜Ø\™ˆ\ÛÛÜœË›YÚØ\™ˆ›Ü™\”˜Y]\Îˆ\˜Y]\Ë˜œ‘Û‹ˆ›Ü™\ˆ›Ü™\‹˜[
ÛÛÜˆ
\Ñ\šÈÈ\ÛÛÜœË˜›Ü™\ˆˆ\ÛÛÜœË›YÚ›Ü™\ŠKÚ]˜[Y\Ê[NˆJJKˆ
KˆÚ[ˆ›İÊˆÚ[™[ˆÂˆÙ\İ\™Q]XİÜŠˆÛ•\ˆ

HOˆÛÛ^œ\Ú
	ËØÛØXÚÉÛØXÚY	ÊKˆÚ[ˆÛÛZ[™\ŠˆÚYˆˆZYÚˆˆXÛÜ˜][Ûˆ›ŞXÛÜ˜][ÛŠˆÛÛÜˆ\ÛÛÜœËœš[X\KÚ]˜[Y\Ê[NˆŒLŠKˆ›Ü™\”˜Y]\Îˆ\˜Y]\Ë˜œ‘[ˆ
KˆÚ[ˆÛ\™Xİ
ˆ›Ü™\”˜Y]\Îˆ\˜Y]\Ë˜œ‘[ˆÚ[ˆ[XYÙK˜\ÜÙ]
ˆ	Ø\ÜÙ]ËØ]˜]\œËØÛØXÚÌKšœÉËˆš]ˆ›Şš]˜Ûİ™\‹ˆ\œ›ÜZ[\ˆ
ÛÛ^\œ›Ü‹İXÚÕ˜XÙJHOˆÙ[\ŠˆÚ[ˆ^
ˆÛØXÚË›˜[YKš\Ó›İ[\HOHYHÈÛØXÚK›˜[YVÌKÕ\\Ø\ÙJ
Hˆ	ĞÉËˆİ[NˆÛÛœİ^İ[JÛÛÜˆ\ÛÛÜœËœš[X\K›ÛÙZYÚˆ›ÛÙZYÚÍÌ›ÛÚ^™NˆN
Kˆ
Kˆ
Kˆ
Kˆ
Kˆ
Kˆ
KˆÛÛœİÚ^™Y›Ş
ÚYˆÜXÚ[™ÔØØ[KœÌLŠKˆ^[™Y
ˆÚ[ˆÛÛ[[ŠˆÜ›ÜÜĞ^\Ğ[YÛ›Y[ˆÜ›ÜÜĞ^\Ğ[YÛ›Y[œİ\ˆÚ[™[ˆÂˆ^
ÛØXÚË›˜[YHÏÈ	ĞÛØXÚ	Ëİ[Nˆ\^İ[\Ë]LË˜ÛÜUÚ]
›ÛÙZYÚˆ›ÛÙZYÚÍŒÛÛÜˆ^š[X\JJKˆ^
ÛØXÚËœÜXÚX[^˜][ÛˆÏÈ	ÔÜXÚX[\İ	Ëİ[Nˆ\^İ[\Ë˜Ø\[Û‹˜ÛÜUÚ]
ÛÛÜˆ^ÙXÛÛ™\JJKˆKˆ
Kˆ
KˆXÛÛ]ÛŠˆXÛÛˆÛÛœİXÛÛŠXÛÛœË˜Ú]ØX˜›WÛİ][™WÜ›İ[™YÛÛÜˆ\ÛÛÜœËœš[X\KÚ^™NˆŒ
KˆÛ”™\ÜÙYˆ

HOˆÛÛ^œ\Ú
	ËØÚ]	ÊKˆ
KˆKˆ
Kˆ
NÂˆBŸB‚