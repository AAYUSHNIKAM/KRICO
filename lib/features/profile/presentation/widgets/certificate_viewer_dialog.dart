import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/radius/radius.dart';
import '../../../../design_system/spacing/spacing_scale.dart';
import '../../../../models/certificate_model.dart';
import '../../../../services/certificate_pdf_service.dart';

class CertificateViewerDialog extends StatefulWidget {
  const CertificateViewerDialog({
    super.key,
    required this.certificate,
  });

  final PlayerCertificateModel certificate;

  static void show(BuildContext context, PlayerCertificateModel certificate) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (ctx) => CertificateViewerDialog(certificate: certificate),
    );
  }

  @override
  State<CertificateViewerDialog> createState() => _CertificateViewerDialogState();
}

class _CertificateViewerDialogState extends State<CertificateViewerDialog> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  bool _isSharingImage = false;
  bool _isCapturing = false;

  Future<void> _shareCardAsImage() async {
    if (_isSharingImage) return;
    setState(() {
      _isSharingImage = true;
      _isCapturing = true;
    });

    try {
      // Wait for next frame so close button and action buttons are cleanly hidden
      await WidgetsBinding.instance.endOfFrame;

      final boundary = _repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Unable to locate render boundary');
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to encode image snapshot');
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final safeTitle = widget.certificate.title.replaceAll(' ', '_');
      final filename = 'KRICO_${safeTitle}_Tier${widget.certificate.tier}.png';

      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              pngBytes,
              mimeType: 'image/png',
              name: filename,
            ),
          ],
          text: '🏆 Proud to achieve the ${widget.certificate.title} Certificate (Tier ${widget.certificate.tier}) on KRICO! Verification Hash: ${widget.certificate.verificationHash}',
          subject: 'KRICO Certificate Snapshot - ${widget.certificate.title}',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not share image snapshot: $e'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharingImage = false;
          _isCapturing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final certificate = widget.certificate;
    final tier = certificate.tierDefinition;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final maxWidth = (size.width - 32).clamp(320.0, 560.0);
    final level = tier.decorationLevel;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: SingleChildScrollView(
          child: RepaintBoundary(
            key: _repaintBoundaryKey,
            child: Container(
              width: maxWidth,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0D131F) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: tier.borderColor,
                width: level >= 4 ? 3 : (level >= 3 ? 2.5 : 2),
              ),
              boxShadow: [
                BoxShadow(
                  color: tier.primaryColor.withValues(alpha: level >= 4 ? 0.45 : 0.3),
                  blurRadius: level >= 4 ? 40 : 28,
                  spreadRadius: level >= 4 ? 3 : 1,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Ornate Background Accents
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Stack(
                      children: [
                        // Radial glow top center
                        Positioned(
                          top: -60,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: level >= 4 ? 320 : 260,
                              height: level >= 4 ? 320 : 260,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    tier.primaryColor.withValues(alpha: level >= 4 ? 0.3 : 0.2),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Inner decorative border inset
                        Positioned.fill(
                          child: Padding(
                            padding: EdgeInsets.all(level >= 4 ? 12 : (level >= 3 ? 10 : 8)),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: level >= 3
                                      ? AppColors.gold.withValues(alpha: 0.45)
                                      : tier.borderColor.withValues(alpha: 0.35),
                                  width: level >= 4 ? 1.5 : 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Corner Stars for Level 3+
                        if (level >= 3) ...[
                          Positioned(
                            top: 14,
                            left: 14,
                            child: Icon(Icons.star_rounded, size: 14, color: AppColors.gold.withValues(alpha: 0.7)),
                          ),
                          Positioned(
                            top: 14,
                            right: 48,
                            child: Icon(Icons.star_rounded, size: 14, color: AppColors.gold.withValues(alpha: 0.7)),
                          ),
                          Positioned(
                            bottom: 14,
                            left: 14,
                            child: Icon(Icons.star_rounded, size: 14, color: AppColors.gold.withValues(alpha: 0.7)),
                          ),
                          Positioned(
                            bottom: 14,
                            right: 14,
                            child: Icon(Icons.star_rounded, size: 14, color: AppColors.gold.withValues(alpha: 0.7)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Main Certificate Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Close Button
                      if (!_isCapturing) ...[
                        Align(
                          alignment: Alignment.topRight,
                          child: InkWell(
                            onTap: () => Navigator.pop(context),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      ],

                      // Accreditation Header Banner
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.stars_rounded, size: 14, color: level >= 3 ? AppColors.gold : tier.primaryColor),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              tier.accreditationHeader,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: level >= 3 ? AppColors.gold : tier.primaryColor,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.stars_rounded, size: 14, color: level >= 3 ? AppColors.gold : tier.primaryColor),
                        ],
                      ),
                      const SizedBox(height: SpacingScale.s12),

                      // Tier Crest Badge
                      Container(
                        width: level >= 4 ? 84 : 76,
                        height: level >= 4 ? 84 : 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              tier.primaryColor,
                              tier.secondaryColor,
                            ],
                          ),
                          border: Border.all(
                            color: level >= 3 ? AppColors.gold : tier.borderColor,
                            width: level >= 4 ? 3.5 : 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: tier.primaryColor.withValues(alpha: level >= 4 ? 0.5 : 0.4),
                              blurRadius: level >= 4 ? 22 : 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            tier.crestBadge,
                            style: TextStyle(fontSize: level >= 4 ? 40 : 36),
                          ),
                        ),
                      ),
                      const SizedBox(height: SpacingScale.s12),

                      // Title & Subtitle
                      Text(
                        tier.certificateHeading,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: SpacingScale.s4),
                      Text(
                        tier.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: tier.primaryColor,
                          fontSize: level >= 4 ? 23 : 21,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),

                      // Latin Motto (Level 2+)
                      if (level >= 2) ...[
                        const SizedBox(height: SpacingScale.s4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: (level >= 3 ? AppColors.gold : tier.primaryColor).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: (level >= 3 ? AppColors.gold : tier.borderColor).withValues(alpha: 0.3),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            '~ ${tier.latinMotto.toUpperCase()} ~',
                            style: TextStyle(
                              fontSize: 9,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w700,
                              color: level >= 3 ? AppColors.gold : tier.primaryColor,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: SpacingScale.s10),

                      // "Presented to" line
                      Text(
                        level >= 4
                            ? 'By supreme decree of the board, conferred upon'
                            : 'This credential is formally conferred upon',
                        style: TextStyle(
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          fontSize: 11.5,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: SpacingScale.s6),

                      // Athlete Name
                      Text(
                        certificate.playerName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: SpacingScale.s4),

                      // Sport & Accolade
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: tier.primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: tier.primaryColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${certificate.sport.toUpperCase()} \u2022 ${tier.accolade}',
                          style: TextStyle(
                            color: tier.primaryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: SpacingScale.s16),

                      // Description
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          tier.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                            fontSize: 12,
                            height: 1.45,
                          ),
                        ),
                      ),
                      const SizedBox(height: SpacingScale.s20),

                      // Milestone Stat Box
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.3)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _statColumn(
                              label: 'MILESTONE',
                              value: '${certificate.requiredXp} XP',
                              color: tier.primaryColor,
                              isDark: isDark,
                            ),
                            Container(width: 1, height: 26, color: Colors.grey.withValues(alpha: 0.3)),
                            _statColumn(
                              label: 'TIER RANK',
                              value: 'Prestige ${tier.tier} / 15',
                              color: isDark ? Colors.white : Colors.black87,
                              isDark: isDark,
                            ),
                            Container(width: 1, height: 26, color: Colors.grey.withValues(alpha: 0.3)),
                            _statColumn(
                              label: 'DATE ISSUED',
                              value: DateFormat('MMM d, yyyy').format(certificate.awardedAt),
                              color: isDark ? Colors.white : Colors.black87,
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: SpacingScale.s16),

                      // Signatories & Verification
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Endorsing Coach / Executive Panel
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  level >= 4 ? 'EXECUTIVE BOARD ACCREDITATION' : 'ENDORSED BY',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white54 : Colors.black45,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  certificate.coachName ?? 'KRICO Coaching Panel',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  tier.signatoryRoles.join(' \u2022 '),
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Tier Accredited Seal
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                colors: [
                                  (level >= 3 ? AppColors.gold : tier.primaryColor).withValues(alpha: 0.2),
                                  tier.secondaryColor.withValues(alpha: 0.3),
                                ],
                              ),
                              border: Border.all(
                                color: level >= 3 ? AppColors.gold : tier.borderColor,
                                width: level >= 4 ? 1.5 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  level >= 4 ? Icons.workspace_premium_rounded : Icons.verified_rounded,
                                  size: 16,
                                  color: level >= 3 ? AppColors.gold : tier.primaryColor,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  tier.sealTitle,
                                  style: TextStyle(
                                    color: level >= 3 ? AppColors.gold : tier.primaryColor,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (level == 5) ...[
                        const SizedBox(height: SpacingScale.s12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF881337), Color(0xFF4D7C0F)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.gold, width: 1),
                          ),
                          child: const Center(
                            child: Text(
                              'PERPETUAL HALL OF FAME RECORD \u2022 IMMORTALIZED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),

                      // Verification Hash Bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF06090F) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              size: 13,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'HASH: ${certificate.verificationHash}',
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: certificate.verificationHash));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Verification Hash copied: ${certificate.verificationHash}'),
                                    backgroundColor: AppColors.success,
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 2),
                                    shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(
                                  Icons.copy_rounded,
                                  size: 14,
                                  color: tier.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: SpacingScale.s16),

                      // Download / Print PDF & Share Actions Row
                      if (_isCapturing) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: tier.primaryColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: tier.primaryColor.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.verified_rounded, size: 14, color: tier.primaryColor),
                              const SizedBox(width: 6),
                              Text(
                                'VERIFIED ATHLETE ACCREDITATION  •  KRICO NETWORK',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                  color: tier.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Row(
                          children: [
                            // 1. Download / Print PDF
                            Expanded(
                              flex: 4,
                              child: ElevatedButton.icon(
                                onPressed: () => CertificatePdfService.downloadOrPrintCertificate(certificate),
                                icon: const Icon(Icons.picture_as_pdf_rounded, size: 15),
                                label: const Text('Download PDF'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: tier.primaryColor,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5),
                                ),
                              ),
                            ),
                            const SizedBox(width: SpacingScale.s8),
                            // 2. Share Image Snapshot
                            Expanded(
                              flex: 4,
                              child: ElevatedButton.icon(
                                onPressed: _isSharingImage ? null : _shareCardAsImage,
                                icon: _isSharingImage
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Icon(Icons.camera_alt_rounded, size: 15),
                                label: Text(_isSharingImage ? 'Sharing...' : 'Share Image'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                                  foregroundColor: isDark ? Colors.white : Colors.black87,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5),
                                ),
                              ),
                            ),
                            const SizedBox(width: SpacingScale.s8),
                            // 3. Share PDF Document
                            IconButton(
                              onPressed: () => CertificatePdfService.shareCertificatePdf(certificate),
                              icon: const Icon(Icons.share_rounded, size: 18),
                              style: IconButton.styleFrom(
                                backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                                foregroundColor: isDark ? Colors.white : Colors.black87,
                                padding: const EdgeInsets.all(12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              tooltip: 'Share Certificate PDF',
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _statColumn({
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}
