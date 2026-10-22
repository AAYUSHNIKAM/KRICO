import '../../../../core/routing/app_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../design_system/radius/radius.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../design_system/responsive/responsive_helpers.dart';
import '../../../models/user_model.dart';
import '../../../models/player_model.dart';
import '../../../services/providers.dart';
import '../../../design_system/layouts/premium_shell.dart';
import 'workspace_destinations.dart';

class ParentDashboard extends ConsumerStatefulWidget {
  const ParentDashboard({super.key, required this.userModel});

  final UserModel userModel;

  @override
  ConsumerState<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends ConsumerState<ParentDashboard> {
  final _durationCtrl = TextEditingController(text: '60');
  final _notesCtrl = TextEditingController();
  String _activityType = 'Practice & Drills';
  int _effortRating = 4;
  String _energyLevel = 'High Energy';
  bool _isLogging = false;
  String? _selectedPlayerId;

  @override
  void dispose() {
    _durationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _logSession() async {
    if (_isLogging) return;
    final duration = double.tryParse(_durationCtrl.text.trim()) ?? 60.0;
    if (duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid session duration in minutes.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isLogging = true);
    try {
      final players = await ref.read(
        parentPlayersProvider(widget.userModel.uid).future,
      );
      final playerId =
          _selectedPlayerId ??
          (players.length == 1 ? players.first.playerId : null);
      if (players.isEmpty) {
        throw StateError('Link a player before logging training.');
      }
      if (playerId == null || !players.any((p) => p.playerId == playerId)) {
        throw StateError('Select which player this training belongs to.');
      }

      final playerService = ref.read(playerServiceProvider);

      // Log duration metric
      await playerService.logMetric(
        playerId: playerId,
        metric: 'duration',
        value: duration,
        unit: 'min',
      );

      // Log effort score
      await playerService.logMetric(
        playerId: playerId,
        metric: 'effort',
        value: _effortRating.toDouble(),
        unit: '/5',
      );

      // Save parent activity debrief document in Firestore
      await FirebaseFirestore.instance
          .collection('players')
          .doc(playerId)
          .collection('parentLogs')
          .add({
        'activityType': _activityType,
        'durationMinutes': duration,
        'effortRating': _effortRating,
        'energyLevel': _energyLevel,
        'notes': _notesCtrl.text.trim(),
        'loggedByParentId': widget.userModel.uid,
        'parentName': widget.userModel.name,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Award XP to player
      await playerService.addPoints(playerId, 25);

      // Notify assigned coach if present
      final selectedPlayer = players.firstWhere((p) => p.playerId == playerId);
      if (selectedPlayer.coachId != null && selectedPlayer.coachId!.isNotEmpty) {
        try {
          await ref.read(notificationServiceProvider).createNotification(
            userId: selectedPlayer.coachId!,
            title: 'Home Practice Debrief',
            body: '${widget.userModel.name} logged a $_activityType practice (${duration.toInt()} min, Effort: $_effortRating/5) for ${selectedPlayer.name}.',
            type: 'training_debrief',
            refId: playerId,
          );
        } catch (_) {}
      }

      _notesCtrl.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 20),
                const SizedBox(width: 8),
                Text('Training logged for athlete!  +25 XP Awarded'),
              ],
            ),
            backgroundColor: const Color(0xFF0F172A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLogging = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final playersAsync = ref.watch(parentPlayersProvider(widget.userModel.uid));

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: CustomScrollView(
            slivers: [
              if (context.isPhone)
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surface : AppColors.lightSurface,
                      border: Border(
                        bottom: BorderSide(
                          color: isDark ? AppColors.border : AppColors.lightBorder,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: AppTextStyles.caption.copyWith(
                                  color: isDark
                                      ? AppColors.textSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                          const SizedBox(height: 2),
                          Text(
                            widget.userModel.name,
                            style: AppTextStyles.title2.copyWith(
                              color: isDark
                                  ? AppColors.textPrimary
                                  : AppColors.lightTextPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    playersAsync.when(
                      data: (players) {
                        final totalXP = players.fold<int>(
                          0,
                          (s, p) => s + p.points,
                        );
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: AppRadius.brFull,
                          ),
                          child: Text(
                            '$totalXP XP',
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: AppColors.primary,
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: AppTextStyles.body.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: SpacingScale.s4),
                              Text(
                                widget.userModel.name,
                                style: AppTextStyles.heading3.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () => context.push(AppRoutes.notifications),
                            borderRadius: AppRadius.brLg,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: AppRadius.brLg,
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                clipBehavior: Clip.none,
                                children: [
                                  const Icon(
                                    Icons.notifications_rounded,
                                    color: Colors.white,
                                  ),
                                  if (ref.watch(unreadNotificationsProvider(widget.userModel.uid)) > 0)
                                    Positioned(
                                      top: 10,
                                      right: 12,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: AppColors.volt,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: const Color(0xFF0F172A),
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.volt.withValues(alpha: 0.8),
                                              blurRadius: 4,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      playersAsync.when(
                        data: (players) {
                          final totalWins = players.fold<int>(
                            0,
                            (s, p) => s + p.championshipWins,
                          );
                          final totalXP = players.fold<int>(
                            0,
                            (s, p) => s + p.points,
                          );
                          return Row(
                            children: [
                              _buildLevelBadge('$totalWins Wins'),
                              const SizedBox(width: SpacingScale.s12),
                              _buildLevelBadge('${players.length} Players'),
                              const Spacer(),
                              Text(
                                '$totalXP XP',
                                style: AppTextStyles.title2.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          );
                        },
                        loading: () => const SizedBox(height: 24),
                        error: (_, _) => const SizedBox(height: 24),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.all(SpacingScale.s16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                playersAsync.when(
                  data: (players) {
                    final totalWins = players.fold<int>(
                      0,
                      (s, p) => s + p.championshipWins,
                    );
                    final totalPoints = players.fold<int>(
                      0,
                      (s, p) => s + p.tournamentPoints,
                    );
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                isDark,
                                'Championship Wins',
                                totalWins.toString(),
                                Icons.emoji_events_rounded,
                                AppColors.gold,
                              ),
                            ),
                            const SizedBox(width: SpacingScale.s12),
                            Expanded(
                              child: _buildStatCard(
                                isDark,
                                'Tournament Points',
                                totalPoints.toString(),
                                Icons.workspace_premium_rounded,
                                AppColors.purple,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: SpacingScale.s12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                isDark,
                                'Active Players',
                                players.length.toString(),
                                Icons.people_rounded,
                                AppColors.success,
                              ),
                            ),
                            const SizedBox(width: SpacingScale.s12),
                            Expanded(
                              child: _buildStatCard(
                                isDark,
                                'Avg XP',
                                players.isNotEmpty
                                    ? '${(totalPoints ~/ players.length)}'
                                    : '0',
                                Icons.trending_up_rounded,
                                AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                  loading: () => const Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 80,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                    ],
                  ),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.all(SpacingScale.s20),
                    child: Text(
                      'Failed to load data: $e',
                      style: const TextStyle(color: AppColors.danger),
                    ),
                  ),
                ),
                const SizedBox(height: SpacingScale.s20),
                _buildDuesAndAttendanceTrackerCard(context, isDark, playersAsync),
                const SizedBox(height: SpacingScale.s24),
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: AppRadius.brLg,
                      ),
                      child: const Icon(
                        Icons.trending_up_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: SpacingScale.s10),
                    Text(
                      'Student Progress',
                      style: AppTextStyles.title2.copyWith(
                        color: isDark
                            ? AppColors.textPrimary
                            : AppColors.lightTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        WorkspaceNavigation.go(
                          context,
                          workspaceDestinations(UserRole.parent).indexWhere((d) => d.id == 'progress'),
                        );
                      },
                      child: Text(
                        'See All',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SpacingScale.s12),
                playersAsync.when(
                  data: (players) {
                    if (players.isEmpty) {
                      return Container(
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.all(SpacingScale.s24),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.card : AppColors.lightCard,
                          borderRadius: AppRadius.brXl3,
                          border: Border.all(
                            color: isDark
                                ? AppColors.border
                                : AppColors.lightBorder,
                            width: 0.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: isDark
                                      ? AppColors.textSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                                const SizedBox(width: SpacingScale.s12),
                                Expanded(
                                  child: Text(
                                    'No children linked yet',
                                    style: AppTextStyles.body.copyWith(
                                      color: isDark
                                          ? AppColors.textSecondary
                                          : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: SpacingScale.s16),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () => context.push('/add-child'),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: SpacingScale.s12,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        AppColors.primaryLight,
                                      ],
                                    ),
                                    borderRadius: AppRadius.brXl2,
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.person_add_alt_1_rounded,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: SpacingScale.s8),
                                      Text(
                                        'Add Child',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return Column(
                      children: players
                          .map(
                            (player) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: SpacingScale.s8,
                              ),
                              child: GestureDetector(
                                onTap: () =>
                                    context.push('/child/${player.playerId}'),
                                child: Container(
                                  margin: EdgeInsets.zero,
                                  padding: const EdgeInsets.all(
                                    SpacingScale.s16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.card
                                        : AppColors.lightCard,
                                    borderRadius: AppRadius.brXl3,
                                    border: Border.all(
                                      color: isDark
                                          ? AppColors.border
                                          : AppColors.lightBorder,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: AppRadius.brLg,
                                        ),
                                        child: player.avatarUrl != null
                                            ? ClipRRect(
                                                borderRadius: AppRadius.brLg,
                                                child: Image.network(
                                                  player.avatarUrl!,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : Center(
                                                child: Text(
                                                  player.name.isNotEmpty
                                                      ? player.name[0]
                                                            .toUpperCase()
                                                      : '?',
                                                  style: AppTextStyles.title2
                                                      .copyWith(
                                                        color:
                                                            AppColors.primary,
                                                      ),
                                                ),
                                              ),
                                      ),
                                      const SizedBox(width: SpacingScale.s12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              player.name,
                                              style: AppTextStyles.title3
                                                  .copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: isDark
                                                        ? AppColors.textPrimary
                                                        : AppColors
                                                              .lightTextPrimary,
                                                  ),
                                            ),
                                            const SizedBox(
                                              height: SpacingScale.s6,
                                            ),
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              child: LinearProgressIndicator(
                                                value: player.points > 0
                                                    ? (player.points % 100) /
                                                          100
                                                    : 0.0,
                                                minHeight: 6,
                                                backgroundColor:
                                                    (isDark
                                                            ? AppColors.border
                                                            : AppColors
                                                                  .lightBorder)
                                                        .withValues(alpha: 0.3),
                                                valueColor:
                                                    const AlwaysStoppedAnimation<
                                                      Color
                                                    >(AppColors.primary),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: SpacingScale.s2,
                                            ),
                                            Text(
                                              '${player.points} XP \u2022 ${player.level ?? 'Beginner'}',
                                              style: AppTextStyles.bodySm
                                                  .copyWith(
                                                    color: isDark
                                                        ? AppColors
                                                              .textSecondary
                                                        : AppColors
                                                              .lightTextSecondary,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '${player.championshipWins}',
                                        style: AppTextStyles.label.copyWith(
                                          color: AppColors.gold,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                  loading: () => Container(
                    margin: EdgeInsets.zero,
                    padding: const EdgeInsets.all(SpacingScale.s24),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.card : AppColors.lightCard,
                      borderRadius: AppRadius.brXl3,
                      border: Border.all(
                        color: isDark
                            ? AppColors.border
                            : AppColors.lightBorder,
                        width: 0.5,
                      ),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: SpacingScale.s12),
                        Text('Loading students...'),
                      ],
                    ),
                  ),
                  error: (e, _) => Container(
                    margin: EdgeInsets.zero,
                    padding: const EdgeInsets.all(SpacingScale.s24),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.card : AppColors.lightCard,
                      borderRadius: AppRadius.brXl3,
                      border: Border.all(
                        color: isDark
                            ? AppColors.border
                            : AppColors.lightBorder,
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      'Error loading students: $e',
                      style: const TextStyle(color: AppColors.danger),
                    ),
                  ),
                ),
                const SizedBox(height: SpacingScale.s24),
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: AppRadius.brLg,
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: SpacingScale.s10),
                    Text(
                      'Quick Actions',
                      style: AppTextStyles.title2.copyWith(
                        color: isDark
                            ? AppColors.textPrimary
                            : AppColors.lightTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SpacingScale.s12),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickAction(
                        context,
                        'Track Metrics',
                        Icons.biotech_rounded,
                        AppColors.primary,
                        () {
                          WorkspaceNavigation.go(
                            context,
                            workspaceDestinations(
                              UserRole.parent,
                            ).indexWhere((d) => d.id == 'progress'),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: SpacingScale.s12),
                    Expanded(
                      child: _buildQuickAction(
                        context,
                        'Find Coach',
                        Icons.search_rounded,
                        AppColors.purple,
                        () {
                          context.push('/coach-discovery');
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SpacingScale.s12),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickAction(
                        context,
                        'Add Child',
                        Icons.person_add_alt_1_rounded,
                        AppColors.success,
                        () {
                          context.push('/add-child');
                        },
                      ),
                    ),
                    const SizedBox(width: SpacingScale.s12),
                    Expanded(
                      child: _buildQuickAction(
                        context,
                        'Book Venue',
                        Icons.stadium_rounded,
                        AppColors.success,
                        () {
                          context.push('/venues');
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SpacingScale.s24),
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: AppRadius.brLg,
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: SpacingScale.s10),
                    Text(
                      'Log training',
                      style: AppTextStyles.title2.copyWith(
                        color: isDark
                            ? AppColors.textPrimary
                            : AppColors.lightTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SpacingScale.s12),
                playersAsync.maybeWhen(
                  data: (players) =>
                      _buildSmartInputPanel(context, isDark, players),
                  orElse: () => const SizedBox.shrink(),
                ),
                const SizedBox(height: SpacingScale.s32),
              ]),
            ),
          ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildLevelBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: AppRadius.brXl3,
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatCard(
    bool isDark,
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
          padding: const EdgeInsets.all(SpacingScale.s16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.card : AppColors.lightCard,
            borderRadius: AppRadius.brXl3,
            border: Border.all(
              color: isDark ? AppColors.border : AppColors.lightBorder,
              width: 0.5,
            ),
            boxShadow: isDark
                ? null
                : const [
                    BoxShadow(
                      color: Color(0x0A0F172A),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.brLg,
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(height: SpacingScale.s12),
              Text(
                value,
                style: AppTextStyles.numericSm.copyWith(
                  color: isDark
                      ? AppColors.textPrimary
                      : AppColors.lightTextPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: SpacingScale.s2),
              Text(
                label,
                style: AppTextStyles.bodySm.copyWith(
                  color: isDark
                      ? AppColors.textSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        )
        .animate(delay: 200.ms)
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.06, end: 0);
  }

  Widget _buildQuickAction(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              margin: EdgeInsets.zero,
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
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: AppRadius.brLg,
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(height: SpacingScale.s8),
                  Text(
                    label,
                    style: AppTextStyles.label.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate(delay: 200.ms)
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.06, end: 0);
  }

  Widget _buildSmartInputPanel(
    BuildContext context,
    bool isDark,
    List<PlayerModel> players,
  ) {
    if (players.isEmpty) {
      return Text(
        'Link a player to start logging their training.',
        style: AppTextStyles.bodySm.copyWith(
          color: isDark
              ? AppColors.textSecondary
              : AppColors.lightTextSecondary,
        ),
      );
    }
    final selectedId = players.any((p) => p.playerId == _selectedPlayerId)
        ? _selectedPlayerId
        : (players.length == 1 ? players.first.playerId : null);
    return Container(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.all(SpacingScale.s16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.card : AppColors.lightCard,
            borderRadius: AppRadius.brXl3,
            border: Border.all(
              color: isDark ? AppColors.border : AppColors.lightBorder,
              width: 0.5,
            ),
            boxShadow: isDark
                ? null
                : const [
                    BoxShadow(
                      color: Color(0x0A0F172A),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: SpacingScale.s8),
                  Text(
                    'Record a training session',
                    style: AppTextStyles.title3.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpacingScale.s16),
              DropdownButtonFormField<String>(
                key: ValueKey(selectedId),
                initialValue: selectedId,
                decoration: const InputDecoration(
                  labelText: 'Select Athlete',
                  isDense: true,
                ),
                items: [
                  for (final p in players)
                    DropdownMenuItem<String>(
                      value: p.playerId,
                      child: Text(p.name.trim().isNotEmpty ? p.name : 'Player'),
                    ),
                ],
                onChanged: (value) => setState(() => _selectedPlayerId = value),
              ),
              const SizedBox(height: SpacingScale.s12),
              Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: DropdownButtonFormField<String>(
                      initialValue: _activityType,
                      decoration: const InputDecoration(
                        labelText: 'Activity / Drill Type',
                        isDense: true,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Practice & Drills', child: Text('Practice & Drills')),
                        DropdownMenuItem(value: 'Matchplay & Scrimmage', child: Text('Matchplay')),
                        DropdownMenuItem(value: 'Fitness & Conditioning', child: Text('Conditioning')),
                        DropdownMenuItem(value: 'Academy Session', child: Text('Academy Session')),
                        DropdownMenuItem(value: 'Rest & Recovery', child: Text('Rest / Active Recovery')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _activityType = v);
                      },
                    ),
                  ),
                  const SizedBox(width: SpacingScale.s8),
                  Expanded(
                    flex: 4,
                    child: _buildMetricField(
                      context,
                      'Duration (min)',
                      _durationCtrl,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpacingScale.s12),
              // Effort & Intensity Rating (1-5)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Perceived Effort & Intensity:',
                    style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Row(
                    children: [
                      for (int star = 1; star <= 5; star++)
                        GestureDetector(
                          onTap: () => setState(() => _effortRating = star),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Icon(
                              star <= _effortRating ? Icons.star_rounded : Icons.star_outline_rounded,
                              size: 24,
                              color: star <= _effortRating ? const Color(0xFFFFB300) : Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: SpacingScale.s8),
              // Energy & Mood
              Row(
                children: [
                  Text('Energy Level: ', style: AppTextStyles.caption),
                  const SizedBox(width: 8),
                  for (final mood in ['High Energy', 'Good', 'Fatigued'])
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(mood, style: const TextStyle(fontSize: 11)),
                        selected: _energyLevel == mood,
                        onSelected: (sel) {
                          if (sel) setState(() => _energyLevel = mood);
                        },
                      ),
                    ),
                ],
              ),
              const SizedBox(height: SpacingScale.s12),
              TextField(
                controller: _notesCtrl,
                maxLines: 2,
                style: AppTextStyles.bodySm,
                decoration: const InputDecoration(
                  labelText: 'Session Notes & Coach Observation',
                  hintText: 'e.g. Worked on backhand defense. Great focus and hydration today.',
                  isDense: true,
                ),
              ),
              const SizedBox(height: SpacingScale.s16),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: _isLogging ? null : _logSession,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: SpacingScale.s12,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                      ),
                      borderRadius: AppRadius.brXl2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isLogging
                              ? Icons.hourglass_top_rounded
                              : Icons.save_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: SpacingScale.s8),
                        Text(
                          _isLogging ? 'Logging...' : 'Log Session',
                          style: AppTextStyles.label.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
        .animate(delay: 200.ms)
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.06, end: 0);
  }

  Widget _buildMetricField(
    BuildContext context,
    String label,
    TextEditingController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: AppTextStyles.body.copyWith(
        color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodySm.copyWith(
          color: isDark
              ? AppColors.textSecondary
              : AppColors.lightTextSecondary,
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        filled: true,
        fillColor: isDark ? AppColors.surface : AppColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: AppRadius.brLg,
          borderSide: BorderSide(
            color: isDark ? AppColors.border : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.brLg,
          borderSide: BorderSide(
            color: isDark ? AppColors.border : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.brLg,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDuesAndAttendanceTrackerCard(
    BuildContext context,
    bool isDark,
    AsyncValue<List<PlayerModel>> playersAsync,
  ) {
    final cardColor = isDark ? AppColors.card : AppColors.lightCard;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: AppRadius.brXl3,
        border: Border.all(color: borderColor, width: 0.5),
      ),
      padding: const EdgeInsets.all(SpacingScale.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: AppRadius.brLg,
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: SpacingScale.s10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Academy Dues & Attendance Tracker',
                      style: AppTextStyles.title3.copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Pune Pilot Batch Cycle \u2022 Covered by Pass',
                      style: AppTextStyles.caption.copyWith(
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.15),
                  borderRadius: AppRadius.brFull,
                  border: Border.all(color: AppColors.emerald.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 12, color: AppColors.emerald),
                    const SizedBox(width: 4),
                    Text(
                      'ACTIVE',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.emerald,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingScale.s16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(SpacingScale.s12),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.surface : AppColors.lightSurface),
                    borderRadius: AppRadius.brLg,
                    border: Border.all(color: borderColor, width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Cycle Due',
                        style: AppTextStyles.caption.copyWith(color: textSecondary),
                      ),
                      const SizedBox(height: SpacingScale.s4),
                      Text(
                        '01 Nov 2026',
                        style: AppTextStyles.title3.copyWith(
                          color: textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: SpacingScale.s2),
                      Text(
                        '\u20B92,500/mo (Covered)',
                        style: AppTextStyles.labelSm.copyWith(color: AppColors.emerald),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: SpacingScale.s10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(SpacingScale.s12),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.surface : AppColors.lightSurface),
                    borderRadius: AppRadius.brLg,
                    border: Border.all(color: borderColor, width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly Attendance',
                        style: AppTextStyles.caption.copyWith(color: textSecondary),
                      ),
                      const SizedBox(height: SpacingScale.s4),
                      Text(
                        '14 / 16 Sessions (88%)',
                        style: AppTextStyles.title3.copyWith(
                          color: textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: SpacingScale.s6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: const LinearProgressIndicator(
                          value: 0.875,
                          minHeight: 5,
                          backgroundColor: Colors.grey,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingScale.s12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.list_alt_rounded, size: 16),
              label: const Text('View Detailed Attendance Ledger & Receipts'),
              style: OutlinedButton.styleFrom(
                foregroundColor: textPrimary,
                side: BorderSide(color: borderColor),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
              ),
              onPressed: () => _showAttendanceLedgerSheet(context, isDark),
            ),
          ),
        ],
      ),
    );
  }

  void _showAttendanceLedgerSheet(BuildContext context, bool isDark) {
    final surfaceColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final cardColor = isDark ? AppColors.card : AppColors.lightCard;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          SpacingScale.s20,
          SpacingScale.s20,
          SpacingScale.s20,
          SpacingScale.s28 + MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: SpacingScale.s16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(SpacingScale.s10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: AppRadius.brLg,
                  ),
                  child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: SpacingScale.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Attendance Ledger & Dues Breakdown', style: AppTextStyles.title2.copyWith(color: textPrimary, fontWeight: FontWeight.bold)),
                      Text('Grassroots Pilot Escrow Ledger \u2022 Pune', style: AppTextStyles.bodySm.copyWith(color: textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpacingScale.s20),
            Container(
              padding: const EdgeInsets.all(SpacingScale.s16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: AppRadius.brLg,
                border: Border.all(color: borderColor, width: 0.5),
              ),
              child: Column(
                children: [
                  _ledgerRow('Monthly Coaching Fee', '\u20B92,500', isDark, isHighlight: false),
                  const Divider(height: 16),
                  _ledgerRow('KRICO Pilot Pass Pro Discount', '-\u20B92,500', isDark, isHighlight: true, color: AppColors.emerald),
                  const Divider(height: 16),
                  _ledgerRow('Net Balance Payable', '\u20B90.00 (Fully Settled)', isDark, isHighlight: true, color: AppColors.primary),
                ],
              ),
            ),
            const SizedBox(height: SpacingScale.s16),
            Text('Recent Verified Sessions', style: AppTextStyles.label.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
            const SizedBox(height: SpacingScale.s8),
            _sessionHistoryTile('Field Practice & Agility Drills', '16 Oct 2026, 5:30 PM', 'Present (QR Verified)', AppColors.emerald, cardColor, borderColor, textPrimary, textSecondary),
            const SizedBox(height: SpacingScale.s6),
            _sessionHistoryTile('Strength & Conditioning', '14 Oct 2026, 5:30 PM', 'Present (QR Verified)', AppColors.emerald, cardColor, borderColor, textPrimary, textSecondary),
            const SizedBox(height: SpacingScale.s6),
            _sessionHistoryTile('Tactical Match Simulation', '11 Oct 2026, 5:30 PM', 'Excused Absence (Rain)', AppColors.warning, cardColor, borderColor, textPrimary, textSecondary),
            const SizedBox(height: SpacingScale.s20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text('Acknowledge Ledger'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                ),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ledgerRow(String label, String value, bool isDark, {bool isHighlight = false, Color? color}) {
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body.copyWith(color: isHighlight ? textPrimary : textSecondary, fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal)),
        Text(value, style: AppTextStyles.title3.copyWith(color: color ?? textPrimary, fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600)),
      ],
    );
  }

  Widget _sessionHistoryTile(String title, String date, String status, Color statusColor, Color cardColor, Color borderColor, Color textPrimary, Color textSecondary) {
    return Container(
      padding: const EdgeInsets.all(SpacingScale.s10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: AppRadius.brMd,
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline_rounded, size: 16, color: statusColor),
          const SizedBox(width: SpacingScale.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodySm.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                Text(date, style: AppTextStyles.captionXs.copyWith(color: textSecondary)),
              ],
            ),
          ),
          Text(status, style: AppTextStyles.caption.copyWith(color: statusColor, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
