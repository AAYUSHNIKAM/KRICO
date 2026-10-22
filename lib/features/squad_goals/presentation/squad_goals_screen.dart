import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../design_system/radius/radius.dart';
import '../../../design_system/tokens/duration_tokens.dart';
import '../../../design_system/widgets/surfaces/shimmer_widget.dart';
import '../../player/presentation/dashboard/widgets/dashboard_empty_state.dart';
import '../data/squad_goals_service.dart';
import '../providers/squad_goals_providers.dart';

class SquadGoalsScreen extends ConsumerStatefulWidget {
  final String playerId;
  final String playerName;

  const SquadGoalsScreen({
    super.key,
    required this.playerId,
    required this.playerName,
  });

  @override
  ConsumerState<SquadGoalsScreen> createState() => _SquadGoalsScreenState();
}

class _SquadGoalsScreenState extends ConsumerState<SquadGoalsScreen> {
  bool _createHovered = false;
  String? _hoveredGoalId;

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
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    final rewardCtrl = TextEditingController();
    final memberCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final sports = ['Cricket', 'Football', 'Tennis', 'Badminton', 'Swimming', 'Basketball'];
    final metrics = {
      'Cricket': 'Runs',
      'Football': 'Goals',
      'Tennis': 'Points',
      'Badminton': 'Points',
      'Swimming': 'Laps',
      'Basketball': 'Points',
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String selectedSport = 'Cricket';
        String selectedMetric = 'Runs';
        DateTime deadline = DateTime.now().add(const Duration(days: 30));
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final sheetDark = Theme.of(ctx).brightness == Brightness.dark;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 580),
                child: Container(
                  height: MediaQuery.of(ctx).size.height * 0.88,
                  decoration: BoxDecoration(
                    color: sheetDark ? const Color(0xFF131D31) : AppColors.lightSurface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    border: Border.all(
                      color: sheetDark ? Colors.white.withValues(alpha: 0.1) : Colors.black12,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 16,
                      bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                    ),
                    child: Form(
                      key: formKey,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: 44,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: sheetDark ? Colors.white24 : Colors.black26,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFCCFF00).withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.group_work_rounded, color: Color(0xFFCCFF00), size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Create Squad Mission',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: sheetDark ? Colors.white : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                    Text(
                                      'Rally teammates toward a shared milestone',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: sheetDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),
                            TextFormField(
                              controller: titleCtrl,
                              style: TextStyle(color: sheetDark ? Colors.white : Colors.black),
                              decoration: InputDecoration(
                                labelText: 'Mission Title',
                                hintText: 'e.g. 5,000 Runs Squad Odyssey',
                                filled: true,
                                fillColor: sheetDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: descCtrl,
                              maxLines: 2,
                              style: TextStyle(color: sheetDark ? Colors.white : Colors.black),
                              decoration: InputDecoration(
                                labelText: 'Objective Details',
                                hintText: 'Explain targets, roles & team strategy...',
                                filled: true,
                                fillColor: sheetDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              initialValue: selectedSport,
                              dropdownColor: sheetDark ? const Color(0xFF1E293B) : Colors.white,
                              style: TextStyle(color: sheetDark ? Colors.white : Colors.black),
                              decoration: InputDecoration(
                                labelText: 'Sport Category',
                                prefixIcon: Icon(_getSportIcon(selectedSport), color: _getSportColor(selectedSport)),
                                filled: true,
                                fillColor: sheetDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                              items: sports.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  setSheetState(() {
                                    selectedSport = v;
                                    selectedMetric = metrics[v] ?? 'Points';
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: targetCtrl,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(color: sheetDark ? Colors.white : Colors.black),
                                    decoration: InputDecoration(
                                      labelText: 'Target $selectedMetric',
                                      filled: true,
                                      fillColor: sheetDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                    ),
                                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: rewardCtrl,
                                    style: TextStyle(color: sheetDark ? Colors.white : Colors.black),
                                    decoration: InputDecoration(
                                      labelText: 'Squad Reward',
                                      hintText: 'e.g. VIP Trophy + 500 XP',
                                      filled: true,
                                      fillColor: sheetDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                    ),
                                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: memberCtrl,
                              style: TextStyle(color: sheetDark ? Colors.white : Colors.black),
                              decoration: InputDecoration(
                                labelText: 'Teammate IDs (comma-separated)',
                                hintText: 'player_01, player_02',
                                filled: true,
                                fillColor: sheetDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: sheetDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.event_available_rounded, color: Color(0xFFCCFF00)),
                                title: Text(
                                  'Mission Deadline',
                                  style: TextStyle(
                                    color: sheetDark ? Colors.white : AppColors.lightTextPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Text(
                                  DateFormat('MMMM d, yyyy').format(deadline),
                                  style: TextStyle(
                                    color: sheetDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white54),
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: ctx,
                                    initialDate: deadline,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                  );
                                  if (picked != null) setSheetState(() => deadline = picked);
                                },
                              ),
                            ),
                            const SizedBox(height: 22),
                            InkWell(
                              onTap: () async {
                                if (!formKey.currentState!.validate()) return;
                                final memberIds = memberCtrl.text.isNotEmpty
                                    ? memberCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
                                    : <String>[];
                                final service = ref.read(squadGoalsServiceProvider);
                                try {
                                  await service.createGoal(
                                    title: titleCtrl.text.trim(),
                                    description: descCtrl.text.trim(),
                                    sport: selectedSport,
                                    targetValue: int.tryParse(targetCtrl.text) ?? 0,
                                    metric: selectedMetric,
                                    metricUnit: selectedMetric,
                                    creatorId: widget.playerId,
                                    reward: rewardCtrl.text.trim(),
                                    memberIds: memberIds,
                                    deadline: deadline,
                                  );
                                  if (ctx.mounted) {
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                      SnackBar(
                                        content: const Row(
                                          children: [
                                            Icon(Icons.check_circle_rounded, color: Color(0xFFCCFF00)),
                                            SizedBox(width: 8),
                                            Text('Squad Mission launched!'),
                                          ],
                                        ),
                                        backgroundColor: const Color(0xFF0F172A),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (ctx.mounted) {
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to create goal: $e'),
                                        backgroundColor: AppColors.danger,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                                      ),
                                    );
                                  }
                                }
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFCCFF00), Color(0xFF99E600)],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFCCFF00).withValues(alpha: 0.35),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    'LAUNCH SQUAD MISSION',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goalsAsync = ref.watch(playerSquadGoalsProvider(widget.playerId));

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
                padding: EdgeInsets.all(SpacingScale.s16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCCFF00).withValues(alpha: 0.15),
                            borderRadius: AppRadius.brLg,
                          ),
                          child: const Icon(Icons.sports_score_rounded, size: 20, color: Color(0xFFCCFF00)),
                        ),
                        const SizedBox(width: SpacingScale.s10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Active Squad Missions',
                                style: TextStyle(
                                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                'Collective milestones & team unlockables',
                                style: TextStyle(
                                  color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: _showCreateSheet,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFCCFF00).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFCCFF00).withValues(alpha: 0.4),
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.add_rounded, size: 14, color: Color(0xFFCCFF00)),
                                SizedBox(width: 4),
                                Text(
                                  'NEW MISSION',
                                  style: TextStyle(
                                    color: Color(0xFFCCFF00),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ).animate(delay: 150.ms).fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0),
                    SizedBox(height: SpacingScale.s16),
                    ...goalsAsync.when(
                      data: (goals) => <Widget>[
                        if (goals.isEmpty)
                          DashboardEmptyState(
                            icon: Icons.emoji_events_rounded,
                            title: 'No active squad goals',
                            subtitle: 'Launch a mission to challenge your squad to achieve together!',
                          )
                        else
                          ...goals.map(
                            (g) => _buildGoalCard(g, isDark)
                                .animate(delay: 150.ms)
                                .fadeIn(duration: 300.ms)
                                .slideY(begin: 0.05, end: 0),
                          ),
                      ],
                      loading: () => <Widget>[_buildShimmerLoading(isDark)],
                      error: (e, _) => <Widget>[_buildErrorState(e, isDark)],
                    ),
                    SizedBox(height: SpacingScale.s20),
                    _buildNewGoalButton(),
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
              'assets/backgrounds/stadium_tunnel.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(color: const Color(0xFF0F172A)),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
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
                          'SQUAD CO-OP OBJECTIVES',
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
                    'Squad Goals & Missions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Achieve milestones together \u2022 Unlock exclusive team rewards',
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

  Widget _buildGoalCard(SquadGoal goal, bool isDark) {
    final progressPercent = (goal.progress * 100).toInt();
    final daysLeft = goal.deadline.difference(DateTime.now()).inDays;
    final sportColor = _getSportColor(goal.sport);
    final sportIcon = _getSportIcon(goal.sport);
    final isHovered = _hoveredGoalId == goal.goalId;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131D31) : Colors.white,
        borderRadius: AppRadius.brXl3,
        border: Border.all(
          color: goal.isCompleted
              ? AppColors.success.withValues(alpha: 0.5)
              : sportColor.withValues(alpha: 0.35),
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
                              goal.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: isDark ? Colors.white : AppColors.lightTextPrimary,
                              ),
                            ),
                          ),
                          if (goal.isCompleted) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_rounded, color: AppColors.success, size: 12),
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
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: sportColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              goal.sport.toUpperCase(),
                              style: TextStyle(
                                color: sportColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 9,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Target: ${goal.targetValue} ${goal.metricUnit}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: daysLeft <= 3
                        ? AppColors.warning.withValues(alpha: 0.15)
                        : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: daysLeft <= 3
                          ? AppColors.warning.withValues(alpha: 0.4)
                          : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    daysLeft <= 0 ? 'Ending today' : '$daysLeft days left',
                    style: TextStyle(
                      color: daysLeft <= 3 ? AppColors.warning : (isDark ? Colors.white70 : AppColors.lightTextSecondary),
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 8,
                child: LinearProgressIndicator(
                  value: goal.progress.clamp(0.0, 1.0),
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
                  '$progressPercent% Completed',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: sportColor,
                  ),
                ),
                Text(
                  '${goal.currentValue} / ${goal.targetValue} ${goal.metricUnit}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Squad stats + reward row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.6) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.people_alt_rounded, size: 16, color: isDark ? Colors.white70 : AppColors.lightTextSecondary),
                  const SizedBox(width: 6),
                  Text(
                    '${goal.memberIds.length} Squad Members',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.card_giftcard_rounded, size: 15, color: Color(0xFFB388FF)),
                  const SizedBox(width: 5),
                  Text(
                    goal.reward,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFB388FF),
                    ),
                  ),
                ],
              ),
            ),
            if (!goal.isCompleted) ...[
              const SizedBox(height: 12),
              MouseRegion(
                onEnter: (_) => setState(() => _hoveredGoalId = goal.goalId),
                onExit: (_) => setState(() => _hoveredGoalId = null),
                child: InkWell(
                  onTap: () async {
                    try {
                      await ref.read(squadGoalsServiceProvider).contribute(goal.goalId, widget.playerId, 1);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.bolt_rounded, color: Color(0xFFCCFF00)),
                              const SizedBox(width: 8),
                              Text('+1 ${goal.metricUnit} contribution added!'),
                            ],
                          ),
                          backgroundColor: const Color(0xFF0F172A),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to contribute: $e'),
                          backgroundColor: AppColors.danger,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                        ),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: DurationTokens.fast,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isHovered ? sportColor.withValues(alpha: 0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: sportColor.withValues(alpha: isHovered ? 0.9 : 0.4),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_task_rounded, size: 18, color: sportColor),
                        const SizedBox(width: 8),
                        Text(
                          'LOG CONTRIBUTION (+1 ${goal.metricUnit.toUpperCase()})',
                          style: TextStyle(
                            color: sportColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNewGoalButton() {
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
                'LAUNCH NEW SQUAD GOAL',
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

  Widget _buildErrorState(Object e, bool isDark) {
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
          Text('Failed to load squad goals: $e', style: AppTextStyles.body.copyWith(color: AppColors.danger)),
        ],
      ),
    );
  }
}
