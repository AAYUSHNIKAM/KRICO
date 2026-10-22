import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../../design_system/colors/app_colors.dart';
import '../../../../../design_system/typography/text_styles.dart';
import '../../../../../design_system/spacing/spacing_scale.dart';
import '../../../../../design_system/radius/radius.dart';
import '../../../../../design_system/responsive/responsive_helpers.dart';
import '../../../../../design_system/tokens/duration_tokens.dart';
import '../../../../../services/providers.dart';
import 'dashboard_loading.dart';

class DailyMissionsSection extends ConsumerWidget {
  final String playerId;

  const DailyMissionsSection({super.key, required this.playerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerAsync = ref.watch(playerProvider(playerId));
    final sessionsAsync = ref.watch(playerSessionsProvider(playerId));

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.isDesktop ? SpacingScale.s32 : (context.isTablet ? SpacingScale.s24 : SpacingScale.s16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: context.isDesktop ? SpacingScale.s28 : SpacingScale.s24),
          playerAsync.when(
            data: (player) {
              return sessionsAsync.when(
                data: (snap) {
                  final sessions = snap.docs.map((d) => d.data()).toList();
                  return _MissionsContent(
                    playerId: playerId,
                    playerPoints: player.points,
                    sessions: sessions,
                  );
                },
                loading: () => const DashboardSectionShimmer(height: 280),
                error: (_, _) => const SizedBox.shrink(),
              );
            },
            loading: () => const DashboardSectionShimmer(height: 280),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _MissionsContent extends ConsumerStatefulWidget {
  final String playerId;
  final int playerPoints;
  final List<Map<String, dynamic>> sessions;

  const _MissionsContent({
    required this.playerId,
    required this.playerPoints,
    required this.sessions,
  });

  @override
  ConsumerState<_MissionsContent> createState() => _MissionsContentState();
}

class _MissionsContentState extends ConsumerState<_MissionsContent> {
  final Set<int> _completedMissions = {};
  final Set<int> _animatingMissions = {};

  String get _todayKey => DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadPersistedMissions();
  }

  Future<void> _loadPersistedMissions() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.playerId)
          .collection('dailyMissions')
          .doc(_todayKey)
          .get();

      if (doc.exists && doc.data() != null) {
        final list = (doc.data()!['completedIndices'] as List<dynamic>?)?.cast<int>() ?? [];
        if (mounted) {
          setState(() {
            _completedMissions.addAll(list);
          });
        }
      }

      final completedSessions = widget.sessions.where((s) => s['status'] == 'completed').length;
      if (completedSessions > 0 && mounted) {
        setState(() => _completedMissions.add(1));
      }
    } catch (_) {}
  }

  Future<void> _completeMission(int index) async {
    if (_completedMissions.contains(index)) return;
    HapticFeedback.mediumImpact();
    setState(() => _animatingMissions.add(index));

    final missions = _generateMissions();
    final missionXp = index < missions.length ? missions[index].xp : 15;

    try {
      // Award real points in Firestore
      await ref.read(playerServiceProvider).addPoints(widget.playerId, missionXp);

      // Persist daily mission record
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.playerId)
          .collection('dailyMissions')
          .doc(_todayKey)
          .set({
        'completedIndices': FieldValue.arrayUnion([index]),
        'date': _todayKey,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        setState(() {
          _animatingMissions.remove(index);
          _completedMissions.add(index);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.stars_rounded, color: AppColors.warning, size: 20),
                const SizedBox(width: 8),
                Text('Mission Complete! +$missionXp XP Awarded'),
              ],
            ),
            backgroundColor: const Color(0xFF0F172A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _animatingMissions.remove(index));
      }
    }
  }

  int _dayOfYear() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    return now.difference(startOfYear).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final secColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    final totalCompleted = _completedMissions.length;
    final totalMissions = 5;
    final progress = totalCompleted / totalMissions;

    final missions = _generateMissions();
    final motivationalMessage = _motivations[_dayOfYear() % _motivations.length];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.task_alt_rounded, size: 18, color: AppColors.primary),
            const SizedBox(width: SpacingScale.s8),
            Text('Daily Missions', style: AppTextStyles.title2.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            )),
            const Spacer(),
            Text('$totalCompleted/$totalMissions', style: AppTextStyles.label.copyWith(
              color: secColor,
              fontWeight: FontWeight.w500,
            )),
          ],
        ),
        const SizedBox(height: SpacingScale.s12),
        ClipRRect(
          borderRadius: AppRadius.brFull,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: DurationTokens.long,
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: 4,
              backgroundColor: isDark ? AppColors.divider : AppColors.lightDivider,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.emerald),
            ),
          ),
        ),
        const SizedBox(height: SpacingScale.s16),
        ...List.generate(missions.length, (i) {
          final mission = missions[i];
          final isCompleted = _completedMissions.contains(i);
          final isAnimating = _animatingMissions.contains(i);

          return Padding(
            padding: const EdgeInsets.only(bottom: SpacingScale.s8),
            child: _MissionTile(
              mission: mission,
              index: i,
              isCompleted: isCompleted,
              isAnimating: isAnimating,
              onComplete: () => _completeMission(i),
            ),
          );
        }),
        const SizedBox(height: SpacingScale.s12),
        Container(
          padding: const EdgeInsets.all(SpacingScale.s12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary,
            borderRadius: AppRadius.brLg,
            border: Border.all(
              color: isDark ? AppColors.border : AppColors.lightBorder,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.emoji_objects_rounded, size: 16, color: AppColors.warning),
              const SizedBox(width: SpacingScale.s8),
              Expanded(
                child: Text(
                  motivationalMessage,
                  style: AppTextStyles.caption.copyWith(
                    color: secColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<_MissionData> _generateMissions() {
    final hasSession = widget.sessions.any((s) =>
        s['status'] == 'scheduled' || s['status'] == 'booked');
    final hasCoach = widget.sessions.any((s) => s['coachId'] != null);

    return [
      _MissionData(
        icon: Icons.accessibility_new_rounded,
        title: 'Complete Warmup',
        subtitle: '5 min dynamic stretching',
        xp: 50,
        actionLabel: 'Start',
      ),
      _MissionData(
        icon: Icons.sports_soccer_rounded,
        title: 'Attend Session',
        subtitle: hasSession ? 'You have a session scheduled' : 'Book a training session',
        xp: 100,
        actionLabel: hasSession ? 'Go to Session' : 'Book Now',
      ),
      _MissionData(
        icon: Icons.upload_file_rounded,
        title: 'Upload Performance',
        subtitle: 'Log your training metrics',
        xp: 75,
        actionLabel: 'Upload',
      ),
      _MissionData(
        icon: Icons.rate_review_rounded,
        title: 'Review Coach Notes',
        subtitle: hasCoach ? 'View feedback from your coach' : 'Read training tips',
        xp: 30,
        actionLabel: 'Review',
      ),
      _MissionData(
        icon: Icons.people_rounded,
        title: 'Help Community',
        subtitle: 'Answer a question or share a tip',
        xp: 40,
        actionLabel: 'Help',
      ),
    ];
  }
}

class _MissionData {
  final IconData icon;
  final String title;
  final String subtitle;
  final int xp;
  final String actionLabel;

  const _MissionData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.xp,
    required this.actionLabel,
  });
}

class _MissionTile extends StatefulWidget {
  final _MissionData mission;
  final int index;
  final bool isCompleted;
  final bool isAnimating;
  final VoidCallback onComplete;

  const _MissionTile({
    required this.mission,
    required this.index,
    required this.isCompleted,
    required this.isAnimating,
    required this.onComplete,
  });

  @override
  State<_MissionTile> createState() => _MissionTileState();
}

class _MissionTileState extends State<_MissionTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final secColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: DurationTokens.fast,
        decoration: BoxDecoration(
          color: widget.isCompleted
              ? AppColors.emerald.withValues(alpha: 0.06)
              : (isDark ? AppColors.card : AppColors.lightCard),
          borderRadius: AppRadius.brXl2,
          border: Border.all(
            color: widget.isCompleted
                ? AppColors.emerald.withValues(alpha: 0.2)
                : _hovered
                    ? (isDark ? AppColors.borderHover : AppColors.lightBorderHover)
                    : (isDark ? AppColors.border : AppColors.lightBorder),
            width: 0.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: AppRadius.brXl2,
            onTap: widget.isCompleted ? null : widget.onComplete,
            child: Padding(
              padding: const EdgeInsets.all(SpacingScale.s12),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: DurationTokens.medium,
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.isCompleted
                          ? AppColors.emerald.withValues(alpha: 0.15)
                          : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: AppRadius.brLg,
                    ),
                    child: widget.isAnimating
                        ? _CheckAnimation()
                        : Icon(
                            widget.isCompleted
                                ? Icons.check_circle_rounded
                                : widget.mission.icon,
                            size: 18,
                            color: widget.isCompleted
                                ? AppColors.emerald
                                : AppColors.primary,
                          ),
                  ),
                  const SizedBox(width: SpacingScale.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.mission.title,
                          style: AppTextStyles.body.copyWith(
                            color: widget.isCompleted ? AppColors.emerald : textColor,
                            fontWeight: FontWeight.w600,
                            decoration: widget.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: SpacingScale.s2),
                        Text(
                          widget.mission.subtitle,
                          style: AppTextStyles.caption.copyWith(color: secColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: SpacingScale.s8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s8, vertical: SpacingScale.s4),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: AppRadius.brFull,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.stars_rounded, size: 10, color: AppColors.warning),
                        const SizedBox(width: 2),
                        Text(
                          '+${widget.mission.xp}',
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!widget.isCompleted) ...[
                    const SizedBox(width: SpacingScale.s8),
                    AnimatedContainer(
                      duration: DurationTokens.fast,
                      padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s10, vertical: SpacingScale.s6),
                      decoration: BoxDecoration(
                        color: _hovered ? AppColors.primaryHover : AppColors.primary,
                        borderRadius: AppRadius.brLg,
                      ),
                      child: Text(
                        widget.mission.actionLabel,
                        style: AppTextStyles.buttonSm.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ).animate(delay: (150 + widget.index * 60).ms)
          .fadeIn(duration: 300.ms)
          .slideY(begin: 0.06, end: 0),
    );
  }
}

class _CheckAnimation extends StatefulWidget {
  @override
  State<_CheckAnimation> createState() => _CheckAnimationState();
}

class _CheckAnimationState extends State<_CheckAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: DurationTokens.slower,
    );
    _scale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _rotation = Tween<double>(begin: -0.5, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.scale(
        scale: _scale.value,
        child: Transform.rotate(
          angle: _rotation.value,
          child: const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.emerald),
        ),
      ),
    );
  }
}

const List<String> _motivations = [
  'Small daily improvements lead to big results.',
  'Consistency beats intensity every time.',
  'Your only competition is yesterday\'s you.',
  'Champions are built in practice, not games.',
  'One more rep, one more set, one more step.',
  'Discipline is choosing between what you want now and what you want most.',
  'The pain you feel today is the strength you feel tomorrow.',
  'Success is the sum of small efforts repeated daily.',
];
