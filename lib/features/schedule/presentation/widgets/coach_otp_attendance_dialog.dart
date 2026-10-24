import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/radius/radius.dart';
import '../../../../design_system/spacing/spacing_scale.dart';
import '../../../../design_system/typography/text_styles.dart';
import '../../data/session_qr_service.dart';

class CoachOtpAttendanceDialog extends ConsumerStatefulWidget {
  final String sessionId;
  final String coachId;
  final String playerName;
  final String sport;

  const CoachOtpAttendanceDialog({
    super.key,
    required this.sessionId,
    required this.coachId,
    required this.playerName,
    required this.sport,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String sessionId,
    required String coachId,
    required String playerName,
    required String sport,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => CoachOtpAttendanceDialog(
        sessionId: sessionId,
        coachId: coachId,
        playerName: playerName,
        sport: sport,
      ),
    );
  }

  @override
  ConsumerState<CoachOtpAttendanceDialog> createState() =>
      _CoachOtpAttendanceDialogState();
}

class _CoachOtpAttendanceDialogState
    extends ConsumerState<CoachOtpAttendanceDialog> {
  final TextEditingController _otpController = TextEditingController();
  final SessionQrService _qrService = SessionQrService();

  bool _isVerifying = false;
  String? _errorMessage;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      setState(() => _errorMessage = 'Please enter a valid 6-digit OTP code.');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final sessionRef =
          FirebaseFirestore.instance.collection('sessions').doc(widget.sessionId);
      final snap = await sessionRef.get();

      if (!snap.exists) {
        setState(() {
          _isVerifying = false;
          _errorMessage = 'Session record not found.';
        });
        return;
      }

      final expectedPin = SessionQrService.getQuickPin(widget.sessionId);
      final storedOtp = snap.data()?['checkInOtp'] as String?;

      if (otp == expectedPin || (storedOtp != null && otp == storedOtp)) {
        await sessionRef.update({
          'status': 'checked_in',
          'checkedInAt': FieldValue.serverTimestamp(),
          'checkInMethod': 'coach_otp_input',
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        final res = await _qrService.verifyAndRecordAttendance(
          rawPayload: otp,
          attendeeUserId: widget.coachId,
          isPlayer: false,
        );

        if (res.success) {
          if (mounted) Navigator.of(context).pop(true);
        } else {
          setState(() {
            _isVerifying = false;
            _errorMessage = 'Invalid OTP. Ask  to confirm the code on their screen.';
          });
        }
      }
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _errorMessage = 'Verification error: ';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

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
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: AppRadius.brLg,
                  ),
                  child: const Icon(Icons.password_rounded, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: SpacingScale.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Athlete OTP Attendance',
                        style: AppTextStyles.title3.copyWith(
                          color: textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Verify check-in for ',
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
                      'Ask  to open their session page and read out the 6-digit Check-In OTP.',
                      style: TextStyle(fontSize: 12, color: textSecondary, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpacingScale.s20),
            TextField(
              controller: _otpController,
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
                hintStyle: TextStyle(
                  letterSpacing: 8,
                  color: isDark ? Colors.grey[700] : Colors.grey[400],
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.brLg,
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.brLg,
                  borderSide: const BorderSide(color: AppColors.volt, width: 2),
                ),
              ),
              onSubmitted: (_) => _verifyOtp(),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: SpacingScale.s8),
              Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 12, color: AppColors.danger, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: SpacingScale.s24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isVerifying ? null : () => Navigator.of(context).pop(false),
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
                    onPressed: _isVerifying ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                    ),
                    child: _isVerifying
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Verify & Check In', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
