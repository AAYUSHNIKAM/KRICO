import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/radius/radius.dart';
import '../../../../design_system/spacing/spacing_scale.dart';
import '../../../../design_system/typography/text_styles.dart';
import '../../data/session_qr_service.dart';

class SessionAttendanceScannerModal extends StatefulWidget {
  final String currentUserId;
  final String? initialSessionId;

  const SessionAttendanceScannerModal({
    super.key,
    required this.currentUserId,
    this.initialSessionId,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String currentUserId,
    String? initialSessionId,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SessionAttendanceScannerModal(
        currentUserId: currentUserId,
        initialSessionId: initialSessionId,
      ),
    );
  }

  @override
  State<SessionAttendanceScannerModal> createState() => _SessionAttendanceScannerModalState();
}

class _SessionAttendanceScannerModalState extends State<SessionAttendanceScannerModal> {
  final _pinController = TextEditingController();
  final _qrService = SessionQrService();
  bool _isVerifying = false;
  CheckInResult? _result;

  @override
  void initState() {
    super.initState();
    if (widget.initialSessionId != null) {
      _pinController.text = widget.initialSessionId!;
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _submitVerification(String code) async {
    if (code.trim().isEmpty) return;

    setState(() {
      _isVerifying = true;
      _result = null;
    });

    final res = await _qrService.verifyAndRecordAttendance(
      rawPayload: code,
      attendeeUserId: widget.currentUserId,
      isPlayer: true,
    );

    if (res.success) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.vibrate();
    }

    if (mounted) {
      setState(() {
        _isVerifying = false;
        _result = res;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final cardColor = isDark ? AppColors.card : AppColors.lightCard;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final textTertiary = isDark ? AppColors.textTertiary : AppColors.lightTextTertiary;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl3)),
            border: Border(
              top: BorderSide(color: borderColor, width: 1.5),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            SpacingScale.s24,
            SpacingScale.s20,
            SpacingScale.s24,
            SpacingScale.s24 + bottomInset,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: textTertiary.withValues(alpha: 0.3),
                    borderRadius: AppRadius.brFull,
                  ),
                ),
                const SizedBox(height: SpacingScale.s20),

                if (_result != null && _result!.success) ...[
                  Container(
                    padding: const EdgeInsets.all(SpacingScale.s20),
                    decoration: BoxDecoration(
                      color: AppColors.emerald.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.emerald, width: 2),
                    ),
                    child: const Icon(
                      Icons.verified_rounded,
                      color: AppColors.emerald,
                      size: 56,
                    ),
                  ).animate().scale(curve: Curves.elasticOut, duration: 600.ms),
                  const SizedBox(height: SpacingScale.s16),
                  Text(
                    'Attendance Confirmed!',
                    style: AppTextStyles.heading2.copyWith(color: textPrimary),
                  ),
                  const SizedBox(height: SpacingScale.s8),
                  Text(
                    _result!.message,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(color: textSecondary),
                  ),
                  const SizedBox(height: SpacingScale.s24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      foregroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.brXl),
                    ),
                    child: const Text('Back to Training', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(SpacingScale.s10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: AppRadius.brLg,
                        ),
                        child: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: SpacingScale.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Session Check-In',
                              style: AppTextStyles.heading3.copyWith(color: textPrimary),
                            ),
                            Text(
                              'Scan coach QR or enter session code',
                              style: AppTextStyles.bodySm.copyWith(color: textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SpacingScale.s20),

                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: AppRadius.brXl2,
                      border: Border.all(color: borderColor),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.emerald, width: 2),
                            borderRadius: AppRadius.brLg,
                          ),
                        ),
                        Container(
                          width: 120,
                          height: 2,
                          color: AppColors.emerald,
                        ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: -50, end: 50, duration: 1500.ms),
                        Positioned(
                          bottom: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s12, vertical: SpacingScale.s4),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: AppRadius.brFull,
                            ),
                            child: Text(
                              'Align Coach QR inside frame',
                              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: SpacingScale.s16),

                  if (_result != null && !_result!.success) ...[
                    Container(
                      padding: const EdgeInsets.all(SpacingScale.s12),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.12),
                        borderRadius: AppRadius.brMd,
                        border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 20),
                          const SizedBox(width: SpacingScale.s8),
                          Expanded(
                            child: Text(
                              _result!.message,
                              style: AppTextStyles.caption.copyWith(color: AppColors.danger),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: SpacingScale.s16),
                  ],

                  TextField(
                    controller: _pinController,
                    textCapitalization: TextCapitalization.characters,
                    style: AppTextStyles.bodyLg.copyWith(
                      color: textPrimary,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Session PIN or ID',
                      labelStyle: TextStyle(color: textSecondary),
                      hintText: 'e.g. 583921',
                      hintStyle: TextStyle(color: textTertiary, letterSpacing: 0),
                      prefixIcon: const Icon(Icons.pin_rounded, color: AppColors.primary),
                      suffixIcon: _isVerifying
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: Center(
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.emerald),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.emerald),
                              onPressed: () => _submitVerification(_pinController.text),
                            ),
                      filled: true,
                      fillColor: cardColor,
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.brXl,
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.brXl,
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppRadius.brXl,
                        borderSide: const BorderSide(color: AppColors.emerald, width: 2),
                      ),
                    ),
                    onSubmitted: _submitVerification,
                  ),

                  const SizedBox(height: SpacingScale.s16),

                  ElevatedButton(
                    onPressed: _isVerifying ? null : () => _submitVerification(_pinController.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.brXl),
                    ),
                    child: _isVerifying
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Verify & Check In', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
