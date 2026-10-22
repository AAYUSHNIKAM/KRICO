import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/radius/radius.dart';
import '../../../../design_system/spacing/spacing_scale.dart';
import '../../../../design_system/typography/text_styles.dart';
import '../../../../design_system/widgets/page_headers/page_hero.dart';
import '../../../../design_system/widgets/surfaces/progress_bar_widget.dart';
import '../../../../models/certificate_model.dart';
import '../../../../services/certificate_pdf_service.dart';
import '../../../../services/progress_and_gamification_service.dart';
import '../../../../services/providers.dart';
import '../../../../design_system/widgets/sportseco_empty_state.dart';
import '../../../profile/presentation/widgets/certificate_viewer_dialog.dart';

class AthleteCertificatesScreen extends ConsumerStatefulWidget {
  const AthleteCertificatesScreen({
    super.key,
    required this.playerId,
  });

  final String playerId;

  @override
  ConsumerState<AthleteCertificatesScreen> createState() => _AthleteCertificatesScreenState();
}

class _AthleteCertificatesScreenState extends ConsumerState<AthleteCertificatesScreen> {
  int _selectedFilterIndex = 0; // 0: All, 1: Earned, 2: Locked

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final playerAsync = ref.watch(playerProvider(widget.playerId));
    final certsAsync = ref.watch(playerCertificatesProvider(widget.playerId));

    final player = playerAsync.asData?.value;
    final earnedCerts = certsAsync.asData?.value ?? const <PlayerCertificateModel>[];
    final points = player?.points ?? 0;
    final highestTier = CertificateRegistry.getTierByXp(points);
    final nextTier = CertificateRegistry.getNextTier(points);

    // Filter tiers based on tab
    final allTiers = CertificateRegistry.allTiers;
    final displayedTiers = allTiers.where((tier) {
      final isEarned = points >= tier.requiredXp;
      if (_selectedFilterIndex == 1) return isEarned;
      if (_selectedFilterIndex == 2) return !isEarned;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          PageHero(
            title: 'Trophy Room & Certificates',
            subtitle: player != null
                ? '${player.name} \u2022 ${earnedCerts.length} of 15 Prestige Certificates Earned'
                : 'Official Athletic Credentials & Accreditations',
            backgroundColor: AppColors.primary,
            showPhoneHeader: true,
            phoneTitle: 'Certificates & Credentials',
          ),

          // 1. Career XP & Progress Header Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(SpacingScale.s16, SpacingScale.s16, SpacingScale.s16, SpacingScale.s8),
              child: Container(
                padding: const EdgeInsets.all(SpacingScale.s16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.card : AppColors.lightCard,
                  borderRadius: AppRadius.brXl3,
                  border: Border.all(
                    color: isDark ? AppColors.border : AppColors.lightBorder,
                    width: 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.15),
                            borderRadius: AppRadius.brLg,
                            border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                          ),
                          child: Center(
                            child: Text(
                              highestTier?.crestBadge ?? '🥉',
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        const SizedBox(width: SpacingScale.s12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                highestTier?.title ?? 'Prestige In Progress',
                                style: AppTextStyles.title2.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Highest Accreditation \u2022 $points Career XP',
                                style: AppTextStyles.captionXs.copyWith(
                                  color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: AppRadius.brFull,
                          ),
                          child: Text(
                            '${earnedCerts.length} / 15 Unlocked',
                            style: AppTextStyles.captionXs.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (nextTier != null) ...[
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Next: ${nextTier.crestBadge} ${nextTier.title}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: nextTier.primaryColor,
                            ),
                          ),
                          Text(
                            '${nextTier.requiredXp - points} XP remaining',
                            style: AppTextStyles.captionXs.copyWith(
                              color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: SpacingScale.s6),
                      AppProgressBar(
                        value: CertificateRegistry.getProgressToNextTier(points),
                        height: 6,
                        color: nextTier.primaryColor,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // 2. Filter Pills Segment
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s16, vertical: SpacingScale.s8),
              child: Row(
                children: [
                  _filterChip(label: 'All Tiers (15)', index: 0, isDark: isDark),
                  const SizedBox(width: SpacingScale.s8),
                  _filterChip(label: 'Earned (${earnedCerts.length})', index: 1, isDark: isDark),
                  const SizedBox(width: SpacingScale.s8),
                  _filterChip(label: 'Locked (${15 - earnedCerts.length})', index: 2, isDark: isDark),
                ],
              ),
            ),
          ),

          // 3. Certificates List or Empty State
          if (displayedTiers.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: SpacingScale.s40),
                child: KricoEmptyState(
                  type: EmptyStateType.noCertificates,
                  customTitle: 'No Certificates in this Filter',
                  customSubtitle: 'You haven\'t unlocked any certificates in this category yet. Attend training sessions to earn XP.',
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s16, vertical: SpacingScale.s8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final tier = displayedTiers[index];
                    final isEarned = points >= tier.requiredXp;

                    // Find matching earned certificate model
                    final earnedCert = isEarned
                        ? earnedCerts.firstWhere(
                            (c) => c.tier == tier.tier,
                            orElse: () => PlayerCertificateModel(
                              id: 'cert_${tier.requiredXp}_${widget.playerId}',
                              playerId: widget.playerId,
                              playerName: player?.name ?? 'Athlete',
                              sport: (player?.sports != null && player!.sports!.isNotEmpty)
                                  ? player.sports!.first
                                  : 'Athletics',
                              tier: tier.tier,
                              title: tier.title,
                              requiredXp: tier.requiredXp,
                              awardedAt: DateTime.now(),
                              verificationHash: 'KRC-2026-${1000 + tier.tier * 37}-${tier.tier.toString().padLeft(2, '0')}',
                            ),
                          )
                        : null;

                    return _CertificateTierCard(
                      tier: tier,
                      isEarned: isEarned,
                      earnedCert: earnedCert,
                      currentPoints: points,
                      isDark: isDark,
                    );
                  },
                  childCount: displayedTiers.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: SpacingScale.s40)),
        ],
      ),
    );
  }

  Widget _filterChip({required String label, required int index, required bool isDark}) {
    final selected = _selectedFilterIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedFilterIndex = index),
      borderRadius: AppRadius.brFull,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : (isDark ? AppColors.card : AppColors.lightCard),
          borderRadius: AppRadius.brFull,
          border: Border.all(
            color: selected
                ? AppColors.primary
                : (isDark ? AppColors.border : AppColors.lightBorder),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }
}

class _CertificateTierCard extends StatelessWidget {
  const _CertificateTierCard({
    required this.tier,
    required this.isEarned,
    required this.earnedCert,
    required this.currentPoints,
    required this.isDark,
  });

  final CertificateTierDefinition tier;
  final bool isEarned;
  final PlayerCertificateModel? earnedCert;
  final int currentPoints;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final cardBg = isEarned
        ? (isDark ? const Color(0xFF0F172A) : Colors.white)
        : (isDark ? const Color(0xFF090D16) : const Color(0xFFF1F5F9));
    final borderColor = isEarned
        ? tier.borderColor
        : (isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1));

    return Container(
      margin: const EdgeInsets.only(bottom: SpacingScale.s12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.brXl3,
        border: Border.all(color: borderColor, width: isEarned ? 1.5 : 1),
        boxShadow: isEarned
            ? [
                BoxShadow(
                  color: tier.primaryColor.withValues(alpha: isDark ? 0.2 : 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(SpacingScale.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Crest Badge Box
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isEarned
                        ? tier.primaryColor.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.05),
                    borderRadius: AppRadius.brLg,
                    border: Border.all(
                      color: isEarned ? tier.borderColor : Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      isEarned ? tier.crestBadge : '🔒',
                      style: TextStyle(fontSize: isEarned ? 26 : 20),
                    ),
                  ),
                ),
                const SizedBox(width: SpacingScale.s12),

                // Title & Milestone Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              tier.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isEarned ? tier.primaryColor : (isDark ? Colors.white60 : Colors.black54),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isEarned
                                  ? tier.primaryColor.withValues(alpha: 0.15)
                                  : Colors.grey.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isEarned ? 'EARNED' : 'LOCKED',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: isEarned ? tier.primaryColor : Colors.grey,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tier ${tier.tier} \u2022 ${tier.requiredXp} Career XP Milestone',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        children: [
                          Text(
                            tier.accolade,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: tier.primaryColor,
                            ),
                          ),
                          Text(
                            '\u2022  ${tier.latinMotto}',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontStyle: FontStyle.italic,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpacingScale.s10),

            // Description
            Text(
              tier.description,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                height: 1.4,
              ),
            ),

            if (isEarned && earnedCert != null) ...[
              const SizedBox(height: SpacingScale.s12),
              const Divider(height: 1, thickness: 0.5),
              const SizedBox(height: SpacingScale.s10),

              // Verification Hash & Award Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Awarded: ${DateFormat('MMM d, yyyy').format(earnedCert!.awardedAt)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    ),
                  ),
                  Text(
                    'HASH: ${earnedCert!.verificationHash}',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpacingScale.s12),

              // Action Buttons: View Credential + Download / Print PDF + Share
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => CertificateViewerDialog.show(context, earnedCert!),
                      icon: const Icon(Icons.remove_red_eye_rounded, size: 14),
                      label: const Text('View Credential'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? Colors.white : Colors.black87,
                        side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
                      ),
                    ),
                  ),
                  const SizedBox(width: SpacingScale.s8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => CertificatePdfService.downloadOrPrintCertificate(earnedCert!),
                      icon: const Icon(Icons.picture_as_pdf_rounded, size: 14),
                      label: const Text('Download PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tier.primaryColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
                      ),
                    ),
                  ),
                  const SizedBox(width: SpacingScale.s6),
                  IconButton(
                    onPressed: () => CertificatePdfService.shareCertificatePdf(earnedCert!),
                    icon: const Icon(Icons.share_rounded, size: 16),
                    style: IconButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                      foregroundColor: isDark ? Colors.white : Colors.black87,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    tooltip: 'Share Certificate PDF',
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: SpacingScale.s10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${tier.requiredXp - currentPoints} XP to unlock',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                  Text(
                    '${(currentPoints / tier.requiredXp * 100).clamp(0, 99).toInt()}%',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              AppProgressBar(
                value: (currentPoints / tier.requiredXp).clamp(0.0, 1.0),
                height: 4,
                color: tier.primaryColor.withValues(alpha: 0.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
