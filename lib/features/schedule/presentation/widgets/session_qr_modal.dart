import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/radius/radius.dart';
import '../../../../design_system/spacing/spacing_scale.dart';
import '../../../../design_system/typography/text_styles.dart';
import '../../data/session_qr_service.dart';

class SessionQrModal extends StatelessWidget {
  final String sessionId;
  final String coachId;
  final String playerId;
  final String playerName;
  final String sport;
  final String sessionTime;

  const SessionQrModal({
    super.key,
    required this.sessionId,
    required this.coachId,
    required this.playerId,
    required this.playerName,
    required this.sport,
    required this.sessionTime,
  });

  static Future<void> show(
    BuildContext context, {
    required String sessionId,
    required String coachId,
    required String playerId,
    required String playerName,
    required String sport,
    required String sessionTime,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SessionQrModal(
        sessionId: sessionId,
        coachId: coachId,
        playerId: playerId,
        playerName: playerName,
        sport: sport,
        sessionTime: sessionTime,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final cardColor = isDark ? AppColors.card : AppColors.lightCard;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final textTertiary = isDark ? AppColors.textTertiary : AppColors.lightTextTertiary;

    final payload = SessionQrService.generateSessionQrPayload(
      sessionId: sessionId,
      coachId: coachId,
      playerId: playerId,
      sport: sport,
    );
    final quickPin = SessionQrService.getQuickPin(sessionId);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('sessions').doc(sessionId).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final isCompleted = data?['status'] == 'completed' || data?['attendanceVerified'] == true;

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
              padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s24, vertical: SpacingScale.s20),
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

                  if (isCompleted) ...[
                    Container(
                      padding: const EdgeInsets.all(SpacingScale.s24),
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.emerald, width: 2),
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.emerald,
                        size: 64,
                      ),
                    ).animate().scale(curve: Curves.elasticOut, duration: 600.ms),
                    const SizedBox(height: SpacingScale.s16),
                    Text(
                      'Attendance Verified!',
                      style: AppTextStyles.heading2.copyWith(color: textPrimary),
                    ),
                    const SizedBox(height: SpacingScale.s8),
                    Text(
                      'Athlete $playerName successfully checked in. Escrow release initiated.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(color: textSecondary),
                    ),
                    const SizedBox(height: SpacingScale.s24),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.brXl),
                        padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s32, vertical: SpacingScale.s16),
                      ),
                      child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Session Check-In QR',
                              style: AppTextStyles.heading3.copyWith(color: textPrimary),
                            ),
                            Text(
                              '$sport • $sessionTime',
                              style: AppTextStyles.bodySm.copyWith(color: textSecondary),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s10, vertical: SpacingScale.s4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: AppRadius.brFull,
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(0.8, 0.8), end: const Offset(1.3, 1.3)),
                              const SizedBox(width: SpacingScale.s6),
                              Text(
                                'LIVE',
                                style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: SpacingScale.s20),

                    Container(
                      padding: const EdgeInsets.all(SpacingScale.s20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadius.brXl2,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: payload,
                        version: QrVersions.auto,
                        size: 200.0,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Color(0xFF0F172A),
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ).animate().fadeIn().scale(duration: 400.ms),

                    const SizedBox(height: SpacingScale.s20),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s16, vertical: SpacingScale.s10),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: AppRadius.brLg,
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Athlete: $playerName',
                            style: AppTextStyles.body.copyWith(color: textPrimary),
                          ),
                          Row(
                            children: [
                              Text(
                                'PIN: ',
                                style: AppTextStyles.bodySm.copyWith(color: textSecondary),
                              ),
                              Text(
                                quickPin,
                                style: AppTextStyles.title3.copyWith(
                                  color: AppColors.emerald,
                                  letterSpacing: 2.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: SpacingScale.s16),
                    Text(
                      'Have $playerName scan this QR on their KRICO app to verify physical presence and unlock coach payout.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(color: textTertiary),
                    ),
                  ],
                  const SizedBox(height: SpacingScale.s20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
