import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/radius/radius.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../design_system/utils/extensions.dart';
import '../../../design_system/widgets/buttons/primary_button.dart';
import '../../../design_system/widgets/page_headers/page_hero.dart';
import '../../../design_system/widgets/surfaces/progress_bar_widget.dart';
import '../../../models/certificate_model.dart';
import '../../../models/gamification_model.dart';
import '../../../models/player_model.dart';
import '../../../services/progress_and_gamification_service.dart';
import '../../../services/providers.dart';
import '../../profile/presentation/widgets/certificate_viewer_dialog.dart';

const List<String> kReadinessStatuses = [
  'Fundamentals',
  'Sparring Ready',
  'Tournament Ready',
  'Elite Roster',
];

Color _getReadinessColor(String status) {
  switch (status) {
    case 'Elite Roster':
      return AppColors.gold;
    case 'Tournament Ready':
      return AppColors.emerald;
    case 'Sparring Ready':
      return AppColors.primary;
    case 'Fundamentals':
    default:
      return const Color(0xFF94A3B8);
  }
}

class StudentProgressScreen extends ConsumerWidget {
  const StudentProgressScreen({
    super.key,
    required this.playerId,
    required this.coachId,
  });

  final String playerId;
  final String coachId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final padH = context.width > 1280
        ? SpacingScale.s32
        : context.width > 600
            ? SpacingScale.s24
            : SpacingScale.s16;

    final playerAsync = ref.watch(playerProvider(playerId));
    final progressAsync = ref.watch(studentProgressProvider(playerId));
    final certsAsync = ref.watch(playerCertificatesProvider(playerId));

    final player = playerAsync.asData?.value;
    final logs = progressAsync.asData?.value ?? const <Map<String, dynamic>>[];
    final certs = certsAsync.asData?.value ?? const <PlayerCertificateModel>[];

    final points = player?.points ?? 0;
    final levelModel = LevelModel.getLevel(points);

    return Scaffold(
      body: Container(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        child: CustomScrollView(
          slivers: [
            PageHero(
              title: 'Student Progression',
              subtitle: player != null
                  ? '${player.name} \u2022 Level ${levelModel.level} ${levelModel.title}'
                  : 'Tracking performance & verified milestones',
              backgroundColor: AppColors.primary,
              showPhoneHeader: true,
              phoneTitle: 'Student Progression',
            ),
            SliverToBoxAdapter(
              child: _StudentSummaryCard(
                playerId: playerId,
                player: player,
                levelModel: levelModel,
                onUpdateReadiness: (newStatus) =>
                    _updateReadiness(context, ref, newStatus),
              ),
            ),
            SliverToBoxAdapter(
              child: _CertificateShowcaseCard(
                points: points,
                earnedCertificates: certs,
                playerName: player?.name ?? 'Athlete',
              ),
            ),
            if (player != null && (player.totalPbs > 0 || player.totalDrills > 0))
              SliverToBoxAdapter(
                child: _PersonalBestsAndDrillsCard(
                  totalPbs: player.totalPbs,
                  totalDrills: player.totalDrills,
                  logs: logs,
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: padH, vertical: SpacingScale.s12),
                child: PrimaryButton(
                  label: 'Log 30-Second Evaluation',
                  icon: Icons.assignment_turned_in_rounded,
                  expanded: true,
                  onPressed: () => _openEvaluationSheet(context, ref, player),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    padH, SpacingScale.s12, padH, SpacingScale.s8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Session Debrief History',
                      style: AppTextStyles.title1
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${logs.length} sessions logged',
                      style: AppTextStyles.captionXs.copyWith(
                        color: isDark
                            ? AppColors.textTertiary
                            : AppColors.lightTextTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (logs.isEmpty)
              const SliverToBoxAdapter(child: _EmptyProgressLogs()),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final log = logs[index];
                  return _SessionLogCard(
                    log: log,
                    onDelete: () => _confirmDelete(context, ref, log),
                  );
                },
                childCount: logs.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: SpacingScale.s32)),
          ],
        ),
      ),
    );
  }

  Future<void> _updateReadiness(
      BuildContext context, WidgetRef ref, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('players')
          .doc(playerId)
          .update({'readinessStatus': newStatus});
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Athlete readiness updated to $newStatus'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
          ),
        );
      }
    }
  }

  void _openEvaluationSheet(
      BuildContext context, WidgetRef ref, PlayerModel? player) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LogSessionEvaluationSheet(
        playerId: playerId,
        coachId: coachId,
        playerName: player?.name ?? 'Athlete',
        sport: (player?.sports != null && player!.sports!.isNotEmpty)
            ? player.sports!.first
            : 'Athletics',
        currentPbs: player?.totalPbs ?? 0,
        currentReadiness: player?.readinessStatus ?? 'Fundamentals',
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, Map<String, dynamic> log) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surface : AppColors.lightSurface,
        title: const Text('Delete session log?'),
        content: const Text(
            'This session evaluation log will be permanently removed from student history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final progressId = log['progressId'] as String? ?? '';
      if (progressId.isNotEmpty) {
        await ref
            .read(playerServiceProvider)
            .deleteStudentProgress(progressId);
      }
    } catch (e) {
      debugPrint('Delete error: $e');
    }
  }
}

class _StudentSummaryCard extends StatelessWidget {
  const _StudentSummaryCard({
    required this.playerId,
    required this.player,
    required this.levelModel,
    required this.onUpdateReadiness,
  });

  final String playerId;
  final PlayerModel? player;
  final LevelModel levelModel;
  final ValueChanged<String> onUpdateReadiness;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final padH = context.width > 1280
        ? SpacingScale.s32
        : context.width > 600
            ? SpacingScale.s24
            : SpacingScale.s16;
    final textSecondary =
        isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final textTertiary =
        isDark ? AppColors.textTertiary : AppColors.lightTextTertiary;

    final name = player?.name ?? 'Unknown Athlete';
    final points = player?.points ?? 0;
    final streak = player?.consistencyStreak ?? 1;
    final readiness = player?.readinessStatus ?? 'Fundamentals';
    final levelProgress = LevelModel.getProgress(points);
    final readinessColor = _getReadinessColor(readiness);

    final sportsList = player?.sports;
    final sportsDisplay = (sportsList != null && sportsList.isNotEmpty)
        ? sportsList.join(', ')
        : 'Athletics';
    final avatarUrl = player?.avatarUrl;

    return Padding(
      padding:
          EdgeInsets.fromLTRB(padH, SpacingScale.s16, padH, SpacingScale.s6),
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
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppRadius.brLg,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: avatarUrl != null && avatarUrl.isNotEmpty
                      ? Image.network(avatarUrl, fit: BoxFit.cover)
                      : Center(
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'A',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: SpacingScale.s16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.title1
                            .copyWith(fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: SpacingScale.s4),
                      Text(
                        '$sportsDisplay \u2022 ${player?.level ?? 'Intermediate'}',
                        style:
                            AppTextStyles.bodySm.copyWith(color: textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: SpacingScale.s12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: SpacingScale.s10,
                          vertical: SpacingScale.s4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: AppRadius.brLg,
                      ),
                      child: Text(
                        'Level ${levelModel.level}',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: SpacingScale.s4),
                    Text(
                      '$points XP',
                      style: AppTextStyles.bodySm.copyWith(
                        color: textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: SpacingScale.s16),

            // Regular Level Progress Bar (Every 500 XP)
            ClipRRect(
              borderRadius: AppRadius.brFull,
              child: LinearProgressIndicator(
                value: levelProgress,
                minHeight: 6,
                backgroundColor: isDark
                    ? AppColors.surfaceElevated
                    : AppColors.lightSurfaceSecondary,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(height: SpacingScale.s6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${levelModel.title} (Level ${levelModel.level})',
                    style: AppTextStyles.captionXs
                        .copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: SpacingScale.s6),
                Text(
                  '${levelModel.maxPoints - points} XP to Level ${levelModel.level + 1}',
                  style: AppTextStyles.captionXs.copyWith(color: textTertiary),
                ),
              ],
            ),
            const SizedBox(height: SpacingScale.s16),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: SpacingScale.s12),

            // Consistency Streak & Match Readiness Row
            Row(
              children: [
                // Consistency Streak Pill
                Expanded(
                  child: Tooltip(
                    message:
                        '76-Hour Consistency Window: Base 20 XP + 1 XP per consecutive session if gap <= 76h. Resets if inactive for >76h.',
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: SpacingScale.s10, vertical: SpacingScale.s8),
                      decoration: BoxDecoration(
                        color: AppColors.orange.withValues(alpha: 0.1),
                        borderRadius: AppRadius.brLg,
                        border: Border.all(
                            color: AppColors.orange.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_fire_department_rounded,
                              size: 16, color: AppColors.orange),
                          const SizedBox(width: SpacingScale.s6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Streak: $streak Session${streak > 1 ? "s" : ""}',
                                  style: AppTextStyles.captionXs.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.orange,
                                  ),
                                ),
                                Text(
                                  '76h Window Active',
                                  style: AppTextStyles.captionXs.copyWith(
                                    fontSize: 9,
                                    color: textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: SpacingScale.s10),

                // Match Readiness Pill with selector
                Expanded(
                  child: InkWell(
                    onTap: () => _showReadinessPicker(context),
                    borderRadius: AppRadius.brLg,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: SpacingScale.s10, vertical: SpacingScale.s8),
                      decoration: BoxDecoration(
                        color: readinessColor.withValues(alpha: 0.1),
                        borderRadius: AppRadius.brLg,
                        border: Border.all(
                            color: readinessColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.shield_outlined,
                              size: 16, color: readinessColor),
                          const SizedBox(width: SpacingScale.s6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  readiness,
                                  style: AppTextStyles.captionXs.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: readinessColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Tap to adjust status',
                                  style: AppTextStyles.captionXs.copyWith(
                                    fontSize: 9,
                                    color: textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_drop_down_rounded,
                              size: 16, color: readinessColor),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showReadinessPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(SpacingScale.s20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surface : AppColors.lightSurface,
            borderRadius: AppRadius.top(AppRadius.xl2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Update Match Readiness',
                  style: AppTextStyles.title2
                      .copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: SpacingScale.s6),
              Text(
                'Set the athlete\'s current competitive stage based on technique & stamina.',
                style: AppTextStyles.bodySm.copyWith(
                  color: isDark
                      ? AppColors.textSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: SpacingScale.s16),
              for (final status in kReadinessStatuses)
                ListTile(
                  leading: Icon(
                    Icons.check_circle_outline_rounded,
                    color: _getReadinessColor(status),
                  ),
                  title: Text(
                    status,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _getReadinessColor(status),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    onUpdateReadiness(status);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CertificateShowcaseCard extends StatelessWidget {
  const _CertificateShowcaseCard({
    required this.points,
    required this.earnedCertificates,
    required this.playerName,
  });

  final int points;
  final List<PlayerCertificateModel> earnedCertificates;
  final String playerName;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final padH = context.width > 1280
        ? SpacingScale.s32
        : context.width > 600
            ? SpacingScale.s24
            : SpacingScale.s16;
    final textSecondary =
        isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    final nextTier = CertificateRegistry.getNextTier(points);
    final progressToNext = CertificateRegistry.getProgressToNextTier(points);

    return Padding(
      padding:
          EdgeInsets.fromLTRB(padH, SpacingScale.s6, padH, SpacingScale.s6),
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
                Expanded(
                  child: Row(
                    children: [
                      const Text('🏆', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: SpacingScale.s8),
                      Flexible(
                        child: Text(
                          'Prestige Certificates',
                          style: AppTextStyles.title2
                              .copyWith(fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: SpacingScale.s8),
                Text(
                  '${earnedCertificates.length} / 15 Unlocked',
                  style: AppTextStyles.captionXs.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpacingScale.s10),

            // Next Certificate Target Bar
            if (nextTier != null) ...[
              Container(
                padding: const EdgeInsets.all(SpacingScale.s12),
                decoration: BoxDecoration(
                  color: nextTier.primaryColor.withValues(alpha: 0.08),
                  borderRadius: AppRadius.brLg,
                  border: Border.all(
                    color: nextTier.borderColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Next Milestone: ${nextTier.crestBadge} ${nextTier.title}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: nextTier.primaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: SpacingScale.s6),
                        Text(
                          '${nextTier.requiredXp - points} XP away',
                          style: AppTextStyles.captionXs
                              .copyWith(color: textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: SpacingScale.s8),
                    AppProgressBar(
                      value: progressToNext,
                      height: 6,
                      color: nextTier.primaryColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SpacingScale.s12),
            ],

            // Horizontal Scroll of All 15 Certificate Tiers
            SizedBox(
              height: 136,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: CertificateRegistry.allTiers.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: SpacingScale.s10),
                itemBuilder: (context, index) {
                  final tier = CertificateRegistry.allTiers[index];
                  final isEarned = points >= tier.requiredXp;
                  final earnedCert = isEarned
                      ? earnedCertificates.firstWhere(
                          (c) => c.tier == tier.tier,
                          orElse: () => PlayerCertificateModel(
                            id: 'temp_${tier.tier}',
                            playerId: '',
                            playerName: playerName,
                            sport: 'Athletics',
                            tier: tier.tier,
                            title: tier.title,
                            requiredXp: tier.requiredXp,
                            awardedAt: DateTime.now(),
                            verificationHash:
                                'SEC-2026-${1000 + tier.tier}-VAL',
                          ),
                        )
                      : null;

                  return InkWell(
                    onTap: isEarned && earnedCert != null
                        ? () => CertificateViewerDialog.show(
                            context, earnedCert)
                        : null,
                    borderRadius: AppRadius.brXl2,
                    child: Container(
                      width: 104,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      decoration: BoxDecoration(
                        color: isEarned
                            ? tier.primaryColor.withValues(alpha: 0.12)
                            : (isDark
                                ? AppColors.surfaceElevated
                                : AppColors.lightSurfaceSecondary),
                        borderRadius: AppRadius.brXl2,
                        border: Border.all(
                          color: isEarned
                              ? tier.borderColor
                              : (isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0)),
                          width: isEarned ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isEarned ? tier.crestBadge : '🔒',
                            style: TextStyle(fontSize: isEarned ? 24 : 18),
                          ),
                          const SizedBox(height: SpacingScale.s4),
                          Text(
                            tier.title,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isEarned
                                  ? tier.primaryColor
                                  : (isDark ? Colors.white60 : Colors.black45),
                            ),
                          ),
                          const SizedBox(height: SpacingScale.s2),
                          Text(
                            '${tier.requiredXp} XP',
                            style: TextStyle(
                              fontSize: 9,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ),
                          if (isEarned) ...[
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: tier.primaryColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'VIEW CRED',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 7,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonalBestsAndDrillsCard extends StatelessWidget {
  const _PersonalBestsAndDrillsCard({
    required this.totalPbs,
    required this.totalDrills,
    required this.logs,
  });

  final int totalPbs;
  final int totalDrills;
  final List<Map<String, dynamic>> logs;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final padH = context.width > 1280
        ? SpacingScale.s32
        : context.width > 600
            ? SpacingScale.s24
            : SpacingScale.s16;

    // Extract recent PB entries from logs
    final recentPbs = <Map<String, dynamic>>[];
    for (final log in logs) {
      final pbMap = log['newPbMetrics'] as Map<String, dynamic>?;
      if (pbMap != null && pbMap.isNotEmpty) {
        for (final entry in pbMap.entries) {
          recentPbs.add({
            'name': entry.key,
            'value': entry.value,
            'date': (log['loggedAt'] as Timestamp?)?.toDate(),
          });
        }
      }
    }

    return Padding(
      padding:
          EdgeInsets.fromLTRB(padH, SpacingScale.s6, padH, SpacingScale.s6),
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
                Expanded(
                  child: Text(
                    'Verified Benchmarks & PBs',
                    style: AppTextStyles.title3
                        .copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: SpacingScale.s6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.purple.withValues(alpha: 0.12),
                        borderRadius: AppRadius.brLg,
                      ),
                      child: Text('$totalPbs Career PBs',
                          style: AppTextStyles.captionXs.copyWith(
                              color: AppColors.purple,
                              fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withValues(alpha: 0.12),
                        borderRadius: AppRadius.brLg,
                      ),
                      child: Text('$totalDrills Drills',
                          style: AppTextStyles.captionXs.copyWith(
                              color: AppColors.emerald,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ],
            ),
            if (recentPbs.isNotEmpty) ...[
              const SizedBox(height: SpacingScale.s12),
              Wrap(
                spacing: SpacingScale.s8,
                runSpacing: SpacingScale.s8,
                children: recentPbs.take(6).map((pb) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceElevated
                          : AppColors.lightSurfaceSecondary,
                      borderRadius: AppRadius.brLg,
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt_rounded,
                            size: 14, color: AppColors.gold),
                        const SizedBox(width: 4),
                        Text(
                          '${pb['name']}: ${pb['value']}',
                          style: AppTextStyles.captionXs.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SessionLogCard extends StatelessWidget {
  const _SessionLogCard({required this.log, required this.onDelete});

  final Map<String, dynamic> log;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final padH = context.width > 1280
        ? SpacingScale.s32
        : context.width > 600
            ? SpacingScale.s24
            : SpacingScale.s16;
    final textSecondary =
        isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final textTertiary =
        isDark ? AppColors.textTertiary : AppColors.lightTextTertiary;

    final coachName = log['coachName'] as String? ?? 'Coach';
    final workEthic = (log['workEthicRating'] as num?)?.toInt() ?? 4;
    final technical = (log['technicalRating'] as num?)?.toInt() ?? 4;
    final totalXp = (log['totalXpAwarded'] as num?)?.toInt() ??
        ((log['score'] as num?)?.toInt() ?? 10);
    final notes = log['coachNotes'] as String? ??
        (log['notes'] as String? ?? '');
    final nextGoal = log['nextSessionGoal'] as String? ?? '';
    final drills = List<String>.from(log['verifiedDrills'] as List? ?? []);
    final pbs = log['newPbMetrics'] as Map<String, dynamic>? ?? {};
    final loggedAt = (log['loggedAt'] as Timestamp?)?.toDate();

    return Container(
      margin:
          EdgeInsets.fromLTRB(padH, SpacingScale.s6, padH, SpacingScale.s6),
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
                padding: const EdgeInsets.symmetric(
                    horizontal: SpacingScale.s8, vertical: SpacingScale.s2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: AppRadius.brLg,
                ),
                child: Text(
                  'Debrief by $coachName',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: SpacingScale.s8, vertical: SpacingScale.s2),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.15),
                  borderRadius: AppRadius.brLg,
                ),
                child: Text(
                  '+$totalXp XP',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.emerald,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline_rounded,
                    size: 18, color: textTertiary),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: SpacingScale.s10),

          // Rating scorecards
          Row(
            children: [
              _metricPill(
                label: 'Work Ethic',
                value: '$workEthic/5 XP',
                color: AppColors.orange,
                isDark: isDark,
              ),
              const SizedBox(width: SpacingScale.s8),
              _metricPill(
                label: 'Technical',
                value: '$technical/5 XP',
                color: AppColors.primary,
                isDark: isDark,
              ),
            ],
          ),

          // Drills verified
          if (drills.isNotEmpty) ...[
            const SizedBox(height: SpacingScale.s8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: drills.map((d) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.emerald.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    '✓ $d',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.emerald,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // PBs logged
          if (pbs.isNotEmpty) ...[
            const SizedBox(height: SpacingScale.s8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: pbs.entries.map((e) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'PB: ${e.key} \u2022 ${e.value}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // Next Session Focus Goal
          if (nextGoal.isNotEmpty) ...[
            const SizedBox(height: SpacingScale.s10),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: SpacingScale.s10, vertical: SpacingScale.s6),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceElevated
                    : AppColors.lightSurfaceSecondary,
                borderRadius: AppRadius.brMd,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flag_rounded,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Next Goal: $nextGoal',
                      style: AppTextStyles.captionXs.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (notes.isNotEmpty) ...[
            const SizedBox(height: SpacingScale.s8),
            Text(notes,
                style: AppTextStyles.bodySm.copyWith(color: textSecondary)),
          ],

          if (loggedAt != null) ...[
            const SizedBox(height: SpacingScale.s8),
            Text(
              DateFormat('MMM d, yyyy \u2022 h:mm a').format(loggedAt),
              style: AppTextStyles.captionXs.copyWith(color: textTertiary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _metricPill({
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyProgressLogs extends StatelessWidget {
  const _EmptyProgressLogs();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(SpacingScale.s40),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: (isDark
                      ? AppColors.textTertiary
                      : AppColors.lightTextTertiary)
                  .withValues(alpha: 0.12),
              borderRadius: AppRadius.brXl2,
            ),
            child: Icon(Icons.assignment_turned_in_rounded,
                size: 32,
                color: isDark
                    ? AppColors.textTertiary
                    : AppColors.lightTextTertiary),
          ),
          const SizedBox(height: SpacingScale.s16),
          Text('No session evaluations yet',
              style: AppTextStyles.title3.copyWith(
                color:
                    isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: SpacingScale.s4),
          Text(
              'Log the athlete\'s 30-second debrief to award verified session XP and unlock certificates.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySm.copyWith(
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.lightTextSecondary,
              )),
        ],
      ),
    );
  }
}

class _LogSessionEvaluationSheet extends ConsumerStatefulWidget {
  const _LogSessionEvaluationSheet({
    required this.playerId,
    required this.coachId,
    required this.playerName,
    required this.sport,
    required this.currentPbs,
    required this.currentReadiness,
  });

  final String playerId;
  final String coachId;
  final String playerName;
  final String sport;
  final int currentPbs;
  final String currentReadiness;

  @override
  ConsumerState<_LogSessionEvaluationSheet> createState() =>
      _LogSessionEvaluationSheetState();
}

class _LogSessionEvaluationSheetState
    extends ConsumerState<_LogSessionEvaluationSheet> {
  int _workEthic = 4; // 1 to 5
  int _technical = 4; // 1 to 5
  final List<String> _selectedDrills = [];
  bool _recordPb = false;
  final _pbMetricNameCtrl = TextEditingController();
  final _pbValueCtrl = TextEditingController();
  final _nextGoalCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  late String _readiness;
  bool _submitting = false;

  final List<String> _availableDrills = [
    'Footwork & Speed Ladder',
    '80%+ Precision Rally/Shot',
    'High-Tempo Match Stamina',
    'Defensive Reaction Test',
  ];

  @override
  void initState() {
    super.initState();
    _readiness = widget.currentReadiness;
  }

  @override
  void dispose() {
    _pbMetricNameCtrl.dispose();
    _pbValueCtrl.dispose();
    _nextGoalCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  int get _coachRatingXp => (_workEthic + _technical).clamp(1, 10);
  int get _drillXp => (_selectedDrills.length * 4).clamp(0, 8);
  int get _pbXp {
    if (!_recordPb || _pbMetricNameCtrl.text.trim().isEmpty) return 0;
    return ref
        .read(progressAndGamificationServiceProvider)
        .calculatePbBonusXp(widget.currentPbs);
  }
  int get _totalXp => _coachRatingXp + _drillXp + _pbXp;

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final pbMap = <String, double>{};
      if (_recordPb &&
          _pbMetricNameCtrl.text.trim().isNotEmpty &&
          _pbValueCtrl.text.trim().isNotEmpty) {
        final val = double.tryParse(_pbValueCtrl.text.trim()) ?? 1.0;
        pbMap[_pbMetricNameCtrl.text.trim()] = val;
      }

      final result = await ref
          .read(progressAndGamificationServiceProvider)
          .logSessionProgress(
            coachId: widget.coachId,
            coachName: 'Lead Coach',
            playerId: widget.playerId,
            playerName: widget.playerName,
            sport: widget.sport,
            workEthicRating: _workEthic,
            technicalRating: _technical,
            verifiedDrills: _selectedDrills,
            newPbMetrics: pbMap,
            coachNotes: _notesCtrl.text.trim(),
            nextSessionGoal: _nextGoalCtrl.text.trim(),
            readinessStatus: _readiness,
          );

      if (!mounted) return;
      Navigator.pop(context);

      final newCerts =
          result['newCertificates'] as List<PlayerCertificateModel>? ?? [];

      if (newCerts.isNotEmpty) {
        final firstCert = newCerts.first;
        CertificateViewerDialog.show(context, firstCert);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Evaluation Logged! +${result['totalSessionXp']} XP awarded to ${widget.playerName}'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to log evaluation: $e'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
      padding: EdgeInsets.only(
        left: SpacingScale.s16,
        right: SpacingScale.s16,
        top: SpacingScale.s12,
        bottom: MediaQuery.of(context).viewInsets.bottom + SpacingScale.s16,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        borderRadius: AppRadius.top(AppRadius.xl2),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.textTertiary
                      : AppColors.lightTextTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: SpacingScale.s16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text('30-Second Debrief',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.title1.copyWith(
                          fontWeight: FontWeight.w700, color: textPrimary)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+$_totalXp XP',
                    style: const TextStyle(
                      color: AppColors.emerald,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpacingScale.s4),
            Text(
              'Evaluate \ • XP awarded strictly adheres to non-inflated limits (Max 10 XP coach rating).',
              style: AppTextStyles.bodySm.copyWith(color: textSecondary),
            ),
            const SizedBox(height: SpacingScale.s16),

            // 1. Work Ethic Rating (1 - 5)
            Text('Work Ethic & Focus: $_workEthic / 5 XP',
                style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w700, color: textPrimary)),
            const SizedBox(height: SpacingScale.s6),
            Row(
              children: List.generate(5, (index) {
                final score = index + 1;
                final selected = _workEthic >= score;
                return Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _workEthic = score),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.orange
                            : (isDark
                                ? AppColors.surfaceElevated
                                : AppColors.lightSurfaceSecondary),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$score',
                        style: TextStyle(
                          color: selected ? Colors.black : textSecondary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: SpacingScale.s16),

            // 2. Technical Execution (1 - 5)
            Text('Technical Execution: $_technical / 5 XP',
                style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w700, color: textPrimary)),
            const SizedBox(height: SpacingScale.s6),
            Row(
              children: List.generate(5, (index) {
                final score = index + 1;
                final selected = _technical >= score;
                return Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _technical = score),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.surfaceElevated
                                : AppColors.lightSurfaceSecondary),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$score',
                        style: TextStyle(
                          color: selected ? Colors.white : textSecondary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: SpacingScale.s16),

            // 3. Concrete Drills Checklist
            Text('Verified Drills (4 XP each, max 8 XP)',
                style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w700, color: textPrimary)),
            const SizedBox(height: SpacingScale.s6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableDrills.map((drill) {
                final isSelected = _selectedDrills.contains(drill);
                return FilterChip(
                  label: Text(drill),
                  selected: isSelected,
                  selectedColor: AppColors.emerald.withValues(alpha: 0.25),
                  checkmarkColor: AppColors.emerald,
                  onSelected: (checked) {
                    setState(() {
                      if (checked) {
                        if (_selectedDrills.length < 2) {
                          _selectedDrills.add(drill);
                        }
                      } else {
                        _selectedDrills.remove(drill);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: SpacingScale.s16),

            // 4. Personal Best (PB) Toggle & Fields
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Record Personal Best (PB) this session',
                  style: AppTextStyles.caption
                      .copyWith(fontWeight: FontWeight.w700)),
              subtitle: Text(
                'Awards progressive bonus XP (${ref.read(progressAndGamificationServiceProvider).calculatePbBonusXp(widget.currentPbs)} XP for PB #${widget.currentPbs + 1})',
                style: AppTextStyles.captionXs.copyWith(color: textSecondary),
              ),
              value: _recordPb,
              onChanged: (v) => setState(() => _recordPb = v ?? false),
            ),
            if (_recordPb) ...[
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _pbMetricNameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Metric',
                        hintText: 'e.g. 100m Sprint',
                      ),
                    ),
                  ),
                  const SizedBox(width: SpacingScale.s8),
                  Expanded(
                    child: TextField(
                      controller: _pbValueCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Value',
                        hintText: '11.4s',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpacingScale.s12),
            ],

            // 5. Next Session Actionable Goal (Replaces heavy video homework)
            TextField(
              controller: _nextGoalCtrl,
              decoration: const InputDecoration(
                labelText: 'Next Session Actionable Focus',
                hintText: 'e.g. Deep court recovery & high wrist finish',
              ),
            ),
            const SizedBox(height: SpacingScale.s12),

            // 6. Match Readiness Selector
            DropdownButtonFormField<String>(
              initialValue: _readiness,
              decoration: const InputDecoration(labelText: 'Match Readiness'),
              items: kReadinessStatuses
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _readiness = v ?? _readiness),
            ),
            const SizedBox(height: SpacingScale.s12),

            // 7. Qualitative Notes
            TextField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Coach Notes (optional)',
                hintText: 'Brief debrief on student performance...',
              ),
            ),
            const SizedBox(height: SpacingScale.s20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: 'Log Evaluation & Award +$_totalXp XP',
                icon: Icons.check_circle_rounded,
                loading: _submitting,
                onPressed: _submitting ? null : _submit,
                expanded: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
