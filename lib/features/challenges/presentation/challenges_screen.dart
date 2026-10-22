import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'challenge_create_sheet.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/radius/radius.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../design_system/tokens/duration_tokens.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../design_system/widgets/surfaces/shimmer_widget.dart';
import '../../player/presentation/dashboard/widgets/dashboard_empty_state.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/challenges_service.dart';
import '../providers/challenges_providers.dart';

enum _ChallengeTab { active, pending, completed }

class ChallengesScreen extends ConsumerStatefulWidget {
  final String playerId;
  final String playerName;

  const ChallengesScreen({
    super.key,
    required this.playerId,
    required this.playerName,
  });

  @override
  ConsumerState<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends ConsumerState<ChallengesScreen> {
  _ChallengeTab _tab = _ChallengeTab.active;
  bool _createHovered = false;

  Color _getSportColor(String sport) {
    switch (sport.toLowerCase()) {
      case 'football':
        return const Color(0xFF00E676);
      case 'basketball':
        return const Color(0xFFFF9100);
      case 'cricket':
        return const Color(0xFF00E5FF);
      case 'tennis':
        return const Color(0xFFCCFF00);
      case 'badminton':
        return const Color(0xFFB388FF);
      case 'swimming':
        return const Color(0xFF00B0FF);
      default:
        return const Color(0xFFCCFF00);
    }
  }

  IconData _getSportIcon(String sport) {
    switch (sport.toLowerCase()) {
      case 'football':
        return Icons.sports_soccer_rounded;
      case 'basketball':
        return Icons.sports_basketball_rounded;
      case 'cricket':
        return Icons.sports_cricket_rounded;
      case 'tennis':
        return Icons.sports_tennis_rounded;
      case 'badminton':
        return Icons.sports_tennis_rounded;
      case 'swimming':
        return Icons.pool_rounded;
      default:
        return Icons.emoji_events_rounded;
    }
  }

  void _showCreateSheet() {
    showCreateChallengeSheet(
      context,
      ref,
      challengerId: widget.playerId,
      challengerName: widget.playerName,
    );
  }

  void _showWinnerPicker(Challenge challenge) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: isDark ? const Color(0xFF131D31) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black12,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(SpacingScale.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD700), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Declare Victor',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : AppColors.lightTextPrimary,
                        ),
                      ),
                      Text(
                        'Select the winning athlete',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: SpacingScale.s20),
              ...challenge.participants.entries.map((entry) {
                final name = challenge.participantNames[entry.key] ?? entry.key;
                final value = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: SpacingScale.s10),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      _completeChallenge(challenge, winnerId: entry.key);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFCCFF00).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          UserAvatar(
                            userId: entry.key,
                            name: name,
                            size: 36,
                            readOnly: true,
                            backgroundColor: const Color(0xFFCCFF00),
                          ),
                          const SizedBox(width: SpacingScale.s12),
                          Expanded(
                            child: Text(
                              name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : AppColors.lightTextPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFCCFF00).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '$value ${challenge.metricUnit}',
                              style: const TextStyle(
                                color: Color(0xFFCCFF00),
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: SpacingScale.s8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _completeChallenge(Challenge challenge, {String? winnerId}) async {
    try {
      await ref
          .read(challengesServiceProvider)
          .completeChallenge(challenge.challengeId, winnerId: winnerId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD700)),
                SizedBox(width: 8),
                Text('Challenge completed! Glory to the victor!'),
              ],
            ),
            backgroundColor: const Color(0xFF0F172A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete challenge: $e'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
          ),
        );
      }
    }
  }

  Future<void> _acceptChallenge(Challenge challenge) async {
    try {
      await ref.read(challengesServiceProvider).acceptChallenge(challenge.challengeId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.bolt_rounded, color: Color(0xFFCCFF00)),
                SizedBox(width: 8),
                Text('Challenge accepted! Arena unlocked!'),
              ],
            ),
            backgroundColor: const Color(0xFF0F172A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
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

  Future<void> _declineChallenge(Challenge challenge) async {
    try {
      await ref.read(challengesServiceProvider).declineChallenge(challenge.challengeId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Challenge declined'),
            backgroundColor: const Color(0xFF0F172A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
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

  Future<void> _logProgress(Challenge challenge) async {
    try {
      await ref
          .read(challengesServiceProvider)
          .logProgress(challenge.challengeId, widget.playerId, 1);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.bolt_rounded, color: Color(0xFFCCFF00)),
                const SizedBox(width: 8),
                Text('+1 ${challenge.metricUnit} scored!'),
              ],
            ),
            backgroundColor: const Color(0xFF0F172A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to log progress: $e'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
          ),
        );
      }
    }
  }

  Future<void> _shareChallengeOnWhatsApp(Challenge challenge) async {
    final text = '🏆 Join my challenge on KRICO Sports: "${challenge.title}" (Target: ${challenge.targetValue} ${challenge.metricUnit}). Can you beat my record? Accept here: https://krico.app/challenges';
    final whatsappUri = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(text)}');
    final webUri = Uri.parse('https://api.whatsapp.com/send?text=${Uri.encodeComponent(text)}');
    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final challengesAsync = ref.watch(userChallengesProvider(widget.playerId));
    final all = challengesAsync.value ?? <Challenge>[];
    final active = all.where((c) => c.isActive).toList();
    final pending = all.where((c) => c.isPending).toList();
    final past = all.where((c) => c.isCompleted || c.isDeclined).toList();
    final currentList = _tab == _ChallengeTab.active
        ? active
        : (_tab == _ChallengeTab.pending ? pending : past);

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverHeader(isDark),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: SpacingScale.s16, vertical: SpacingScale.s16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Tab Selector Bar
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF131D31) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildTabButton(
                            label: 'Active (${active.length})',
                            icon: Icons.bolt_rounded,
                            selected: _tab == _ChallengeTab.active,
                            activeColor: const Color(0xFFCCFF00),
                            isDark: isDark,
                            onTap: () => setState(() => _tab = _ChallengeTab.active),
                          ),
                          const SizedBox(width: 4),
                          _buildTabButton(
                            label: 'Pending (${pending.length})',
                            icon: Icons.schedule_rounded,
                            selected: _tab == _ChallengeTab.pending,
                            activeColor: const Color(0xFF00E5FF),
                            isDark: isDark,
                            onTap: () => setState(() => _tab = _ChallengeTab.pending),
                          ),
                          const SizedBox(width: 4),
                          _buildTabButton(
                            label: 'Past (${past.length})',
                            icon: Icons.history_rounded,
                            selected: _tab == _ChallengeTab.completed,
                            activeColor: const Color(0xFFB388FF),
                            isDark: isDark,
                            onTap: () => setState(() => _tab = _ChallengeTab.completed),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: SpacingScale.s16),
                    if (challengesAsync.isLoading)
                      _buildShimmerLoading(isDark)
                    else if (challengesAsync.hasError)
                      _buildErrorState(isDark)
                    else if (_tab == _ChallengeTab.active && active.isEmpty)
                      DashboardEmptyState(
                        icon: Icons.bolt_rounded,
                        title: 'No Active Duels',
                        subtitle: 'Issue a 1v1 challenge or start a squad matchup to get in the arena!',
                      )
                    else if (_tab == _ChallengeTab.pending && pending.isEmpty)
                      DashboardEmptyState(
                        icon: Icons.schedule_rounded,
                        title: 'No Pending Invites',
                        subtitle: 'Challenge another athlete or teammate to send them a direct invitation.',
                      )
                    else if (_tab == _ChallengeTab.completed && past.isEmpty)
                      DashboardEmptyState(
                        icon: Icons.history_rounded,
                        title: 'No Duel History',
                        subtitle: 'Completed duels and showdown outcomes will be recorded here.',
                      )
                    else
                      ...currentList.map(
                        (c) => _buildChallengeCard(c, isDark)
                            .animate(delay: 150.ms)
                            .fadeIn(duration: 300.ms)
                            .slideY(begin: 0.05, end: 0),
                      ),
                    SizedBox(height: SpacingScale.s20),
                    _buildNewChallengeButton(),
                  ]),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverHeader(bool isDark) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: isDark ? AppColors.surface : AppColors.primary,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/backgrounds/stadium_floodlights.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(color: const Color(0xFF0F172A)),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.35),
                    const Color(0xFF0F172A).withValues(alpha: 0.88),
                    (isDark ? AppColors.background : AppColors.lightBackground),
                  ],
                  stops: const [0.0, 0.65, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 18,
              left: SpacingScale.s16,
              right: SpacingScale.s16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCFF00).withValues(alpha: 0.15),
                      borderRadius: AppRadius.brFull,
                      border: Border.all(
                        color: const Color(0xFFCCFF00).withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFCCFF00),
                            boxShadow: [
                              BoxShadow(color: Color(0xFFCCFF00), blurRadius: 6),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'ATHLETIC ARENA \u2022 HEAD-TO-HEAD DUELS',
                          style: TextStyle(
                            color: Color(0xFFCCFF00),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Challenges & Duels',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Compete head-to-head or battle as a squad for supreme glory',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required IconData icon,
    required bool selected,
    required Color activeColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: DurationTokens.fast,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? activeColor.withValues(alpha: isDark ? 0.2 : 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? activeColor.withValues(alpha: 0.8) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: selected ? activeColor : (isDark ? Colors.white60 : Colors.black54),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected
                        ? (isDark ? Colors.white : AppColors.lightTextPrimary)
                        : (isDark ? Colors.white60 : Colors.black54),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeCard(Challenge challenge, bool isDark) {
    final daysLeft = challenge.deadline.difference(DateTime.now()).inDays;
    final sportColor = _getSportColor(challenge.sport);
    final sportIcon = _getSportIcon(challenge.sport);
    final isCreator = challenge.creatorId == widget.playerId;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131D31) : Colors.white,
        borderRadius: AppRadius.brXl3,
        border: Border.all(
          color: challenge.isCompleted
              ? AppColors.success.withValues(alpha: 0.4)
              : (challenge.isDeclined
                  ? Colors.white12
                  : sportColor.withValues(alpha: 0.35)),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: sportColor.withValues(alpha: isDark ? 0.08 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: sportColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: sportColor.withValues(alpha: 0.4), width: 1),
                  ),
                  child: Icon(sportIcon, color: sportColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              challenge.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: isDark ? Colors.white : AppColors.lightTextPrimary,
                              ),
                            ),
                          ),
                          if (challenge.isCompleted) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD700), size: 12),
                                  SizedBox(width: 4),
                                  Text(
                                    'COMPLETED',
                                    style: TextStyle(color: AppColors.success, fontSize: 9, fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: sportColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              challenge.isPlayerChallenge ? '1v1 DUEL' : 'SQUAD RIVALRY',
                              style: TextStyle(
                                color: sportColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 9,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${challenge.sport} \u2022 ${challenge.metric}',
                            style: TextStyle(
                              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (!challenge.isCompleted && !challenge.isDeclined)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: daysLeft <= 3
                          ? AppColors.warning.withValues(alpha: 0.15)
                          : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: daysLeft <= 3 ? AppColors.warning.withValues(alpha: 0.4) : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      daysLeft <= 0 ? 'Ends today' : '$daysLeft d left',
                      style: TextStyle(
                        color: daysLeft <= 3 ? AppColors.warning : (isDark ? Colors.white70 : AppColors.lightTextSecondary),
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
            if (challenge.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                challenge.description,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
            const SizedBox(height: 14),
            // Overall progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 8,
                child: LinearProgressIndicator(
                  value: challenge.progress.clamp(0.0, 1.0),
                  backgroundColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(sportColor),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${challenge.progressPercent}% Target Reached',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: sportColor,
                  ),
                ),
                Text(
                  '${challenge.isPlayerChallenge ? challenge.bestPlayerProgress : challenge.totalProgress} / ${challenge.targetValue} ${challenge.metricUnit}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
            if (challenge.isPlayerChallenge) ...[
              const SizedBox(height: 14),
              // Head to head participants duel box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.6) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  children: challenge.participants.entries.map((entry) {
                    return _buildPlayerRow(
                      entry.key,
                      challenge.participantNames[entry.key] ?? entry.key,
                      entry.value,
                      challenge.targetValue,
                      challenge.metricUnit,
                      sportColor,
                      isDark,
                    );
                  }).toList(),
                ),
              ),
            ],
            const SizedBox(height: 12),
            // Reward and Winner Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.4) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.card_giftcard_rounded, size: 15, color: Color(0xFFB388FF)),
                  const SizedBox(width: 6),
                  Text(
                    challenge.reward,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFB388FF),
                    ),
                  ),
                  const Spacer(),
                  if (challenge.isCompleted && challenge.winnerId != null) ...[
                    const Icon(Icons.emoji_events_rounded, size: 15, color: Color(0xFFFFD700)),
                    const SizedBox(width: 4),
                    Text(
                      'Winner: ${challenge.participantNames[challenge.winnerId] ?? 'Athlete'}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFFD700),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildStatusActions(challenge, isDark, isCreator, sportColor),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerRow(
    String uid,
    String name,
    int value,
    int target,
    String unit,
    Color sportColor,
    bool isDark,
  ) {
    final progress = target > 0 ? (value / target).clamp(0.0, 1.0) : 0.0;
    final isMe = uid == widget.playerId;
    final color = isMe ? const Color(0xFFCCFF00) : const Color(0xFF00E5FF);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          UserAvatar(
            userId: uid,
            name: name,
            size: 30,
            readOnly: true,
            backgroundColor: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        isMe ? '$name (You)' : name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isMe ? FontWeight.w800 : FontWeight.w600,
                          color: isMe ? color : (isDark ? Colors.white : AppColors.lightTextPrimary),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$value / $target $unit',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusActions(Challenge challenge, bool isDark, bool isCreator, Color sportColor) {
    if (challenge.isPending) {
      if (isCreator) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFF9100).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFF9100).withValues(alpha: 0.3), width: 1),
          ),
          child: Row(
            children: [
              const Icon(Icons.hourglass_top_rounded, size: 16, color: Color(0xFFFF9100)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Waiting for opponent to enter arena',
                  style: TextStyle(
                    color: Color(0xFFFF9100),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.share_rounded, size: 18, color: Color(0xFF25D366)),
                tooltip: 'Invite opponent on WhatsApp',
                onPressed: () => _shareChallengeOnWhatsApp(challenge),
              ),
            ],
          ),
        );
      }
      return Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _acceptChallenge(challenge),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFCCFF00), Color(0xFF99E600)]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFCCFF00).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 3)),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_rounded, size: 18, color: Colors.black),
                    SizedBox(width: 6),
                    Text(
                      'ACCEPT DUEL',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () => _declineChallenge(challenge),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.white12 : Colors.black12, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.close_rounded, size: 18, color: isDark ? Colors.white60 : Colors.black54),
                    const SizedBox(width: 6),
                    Text(
                      'DECLINE',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (challenge.isActive) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _logProgress(challenge),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFCCFF00), Color(0xFF99E600)]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFCCFF00).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.bolt_rounded, size: 18, color: Colors.black),
                        const SizedBox(width: 6),
                        Text(
                          'LOG PROGRESS (+1 ${challenge.metricUnit.toUpperCase()})',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                icon: const Icon(Icons.share_rounded, color: Color(0xFF25D366)),
                tooltip: 'Share challenge on WhatsApp',
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366).withValues(alpha: 0.15),
                  padding: const EdgeInsets.all(12),
                ),
                onPressed: () => _shareChallengeOnWhatsApp(challenge),
              ),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => challenge.isPlayerChallenge ? _showWinnerPicker(challenge) : _completeChallenge(challenge),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.emoji_events_rounded, size: 16, color: Color(0xFFFFD700)),
                  const SizedBox(width: 6),
                  Text(
                    challenge.isPlayerChallenge ? 'DECLARE VICTOR' : 'FINALIZE CHALLENGE',
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final declined = challenge.isDeclined;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        color: declined
            ? (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05))
            : AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            declined ? Icons.block_rounded : Icons.emoji_events_rounded,
            size: 16,
            color: declined ? Colors.white54 : AppColors.success,
          ),
          const SizedBox(width: 8),
          Text(
            declined ? 'Challenge declined' : 'Challenge showdown concluded',
            style: TextStyle(
              color: declined ? (isDark ? Colors.white60 : Colors.black54) : AppColors.success,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewChallengeButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _createHovered = true),
      onExit: (_) => setState(() => _createHovered = false),
      child: InkWell(
        onTap: _showCreateSheet,
        borderRadius: AppRadius.brXl2,
        child: AnimatedContainer(
          duration: DurationTokens.fast,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFCCFF00), Color(0xFF99E600)],
            ),
            borderRadius: AppRadius.brXl2,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFCCFF00).withValues(alpha: _createHovered ? 0.45 : 0.25),
                blurRadius: _createHovered ? 20 : 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline_rounded, color: Colors.black, size: 20),
              SizedBox(width: 8),
              Text(
                'ISSUE NEW ARENA CHALLENGE',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl2,
        border: Border.all(
          color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: const CardShimmer(count: 3),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Container(
      padding: EdgeInsets.all(SpacingScale.s24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl3,
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline_rounded, size: 40, color: AppColors.danger),
          SizedBox(height: SpacingScale.s8),
          Text('Failed to load challenges', style: AppTextStyles.body.copyWith(color: AppColors.danger)),
        ],
      ),
    );
  }
}
