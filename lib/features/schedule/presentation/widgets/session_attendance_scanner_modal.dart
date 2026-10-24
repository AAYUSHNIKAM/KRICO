import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/radius/radius.dart';
import '../../../../design_system/spacing/spacing_scale.dart';
import '../../../../design_system/typography/text_styles.dart';
import '../../data/session_qr_service.dart';

class SessionAttendanceScannerModal extends ConsumerStatefulWidget {
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
  ConsumerState<SessionAttendanceScannerModal> createState() =>
      _SessionAttendanceScannerModalState();
}

class _SessionAttendanceScannerModalState
    extends ConsumerState<SessionAttendanceScannerModal> {
  final TextEditingController _pinController = TextEditingController();
  late final MobileScannerController _scannerController;
  final SessionQrService _qrService = SessionQrService();

  bool _isVerifying = false;
  CheckInResult? _result;
  bool _cameraFallback = false;
  bool _torchOn = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    if (widget.initialSessionId != null && widget.initialSessionId!.isNotEmpty) {
      _pinController.text = SessionQrService.getQuickPin(widget.initialSessionId!);
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _submitVerification(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty || _isVerifying) return;

    setState(() {
      _isVerifying = true;
      _result = null;
    });

    try {
      final res = await _qrService.verifyAndRecordAttendance(
        rawPayload: trimmed,
        attendeeUserId: widget.currentUserId,
        isPlayer: true,
      );

      if (mounted) {
        setState(() {
          _result = res;
          _isVerifying = false;
        });

        if (res.success) {
          Future.delayed(const Duration(milliseconds: 1400), () {
            if (mounted) Navigator.of(context).pop(true);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _result = CheckInResult(
            success: false,
            message: 'Verification failed: ',
          );
        });
      }
    }
  }

  Widget _buildCameraFallback(bool isDark, Color borderColor, Color textSecondary) {
    return Container(
      color: isDark ? const Color(0xFF131826) : const Color(0xFF0F172A),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code_scanner_rounded, size: 40, color: AppColors.volt),
            const SizedBox(height: 8),
            Text(
              'Camera Viewfinder Active',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              'Or enter the 6-digit session OTP below',
              style: TextStyle(color: textSecondary, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final textTertiary = isDark ? AppColors.textTertiary : AppColors.lightTextTertiary;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: borderColor),
        ),
        padding: const EdgeInsets.all(SpacingScale.s20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: AppRadius.brFull,
                  ),
                ),
              ),
              const SizedBox(height: SpacingScale.s16),

              if (_result != null && _result!.success) ...[
                const SizedBox(height: SpacingScale.s20),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(SpacingScale.s16),
                    decoration: BoxDecoration(
                      color: AppColors.emerald.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.emerald,
                      size: 54,
                    ),
                  ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                ),
                const SizedBox(height: SpacingScale.s16),
                Text(
                  'Checked In Successfully!',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.title2.copyWith(color: textPrimary, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: SpacingScale.s8),
                Text(
                  _result!.message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySm.copyWith(color: textSecondary),
                ),
                const SizedBox(height: SpacingScale.s24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.brXl),
                  ),
                  child: const Text('Continue to Active Session', style: TextStyle(fontWeight: FontWeight.bold)),
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
                            'Session Check-In Scanner',
                            style: AppTextStyles.heading3.copyWith(color: textPrimary),
                          ),
                          Text(
                            'Scan coach QR code or enter session OTP',
                            style: AppTextStyles.bodySm.copyWith(color: textSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                        color: _torchOn ? AppColors.volt : textSecondary,
                      ),
                      onPressed: () {
                        setState(() => _torchOn = !_torchOn);
                        _scannerController.toggleTorch();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: SpacingScale.s16),

                // Live Camera Scanner Box
                ClipRRect(
                  borderRadius: AppRadius.brXl2,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: AppRadius.brXl2,
                      border: Border.all(color: borderColor),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (!_cameraFallback)
                          MobileScanner(
                            controller: _scannerController,
                            onDetect: (capture) {
                              final barcodes = capture.barcodes;
                              for (final barcode in barcodes) {
                                final raw = barcode.rawValue;
                                if (raw != null && raw.isNotEmpty && !_isVerifying) {
                                  _submitVerification(raw);
                                  break;
                                }
                              }
                            },
                            errorBuilder: (context, error) {
                              return _buildCameraFallback(isDark, borderColor, textSecondary);
                            },
                          )
                        else
                          _buildCameraFallback(isDark, borderColor, textSecondary),

                        // Scanning reticle
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.volt, width: 2),
                            borderRadius: AppRadius.brLg,
                          ),
                        ),
                        Container(
                          width: 130,
                          height: 2,
                          color: AppColors.volt,
                        ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: -55, end: 55, duration: 1400.ms),

                        Positioned(
                          bottom: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: AppRadius.brFull,
                            ),
                            child: Text(
                              'Align Coach QR within box',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
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
                  const SizedBox(height: SpacingScale.s12),
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
                    labelText: '6-Digit Check-In OTP or Session PIN',
                    labelStyle: TextStyle(color: textSecondary),
                    hintText: 'e.g. 583921',
                    hintStyle: TextStyle(color: textTertiary, letterSpacing: 0),
                    prefixIcon: const Icon(Icons.pin_rounded, color: AppColors.primary),
                    suffixIcon: _isVerifying
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.volt),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.volt),
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
                      borderSide: const BorderSide(color: AppColors.volt, width: 2),
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
                      : const Text('Verify OTP & Check In', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
