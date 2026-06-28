import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/section_header.dart';
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
          builder: (ctx, setSheetState) => Container(
        height: MediaQuery.of(ctx).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(ctx).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 24, right: 24, top: 16, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textDim, borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 20),
                  Text('Create Squad Goal', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text('Challenge your squad to achieve together', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Goal Title', hintText: '10000 Runs in a Month'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Description', hintText: 'Describe the challenge...'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedSport,
                    decoration: const InputDecoration(labelText: 'Sport', prefixIcon: Icon(Icons.sports_rounded)),
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
                          decoration: InputDecoration(labelText: 'Target $selectedMetric'),
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: rewardCtrl,
                          decoration: const InputDecoration(labelText: 'Reward', hintText: 'Free session'),
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: memberCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Teammate IDs (comma-separated)',
                      hintText: 'user_id1, user_id2',
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Deadline'),
                    subtitle: Text(DateFormat('MMM d, yyyy').format(deadline)),
                    trailing: const Icon(Icons.calendar_today_rounded),
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
                  const SizedBox(height: 20),
                  GradientButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final memberIds = memberCtrl.text.isNotEmpty
                          ? memberCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
                          : <String>[];
                      final service = ref.read(squadGoalsServiceProvider);
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
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: const Text('Create Goal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        ),
          ));
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final goalsAsync = ref.watch(playerSquadGoalsProvider(widget.playerId));

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateSheet,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Goal'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFEC4899), Color(0xFFF59E0B)],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Squad Goals', style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('Achieve together, unlock rewards', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SectionHeader(title: 'Active Challenges'),
                const SizedBox(height: 12),
              ]),
            ),
          ),
          goalsAsync.when(
            data: (goals) {
              if (goals.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.emoji_events_rounded, size: 64, color: AppColors.textDim),
                        const SizedBox(height: 16),
                        Text('No active squad goals', style: AppTextStyles.titleSmall.copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        Text('Create one to challenge your team!', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textDim)),
                      ],
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final goal = goals[index];
                    return _buildGoalCard(theme, goal).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.2, end: 0);
                  },
                  childCount: goals.length,
                ),
              );
            },
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SliverFillRemaining(child: Center(child: Text('Failed to load goals'))),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildGoalCard(ThemeData theme, SquadGoal goal) {
    final progressPercent = (goal.progress * 100).toInt();
    final daysLeft = goal.deadline.difference(DateTime.now()).inDays;
    final color = goal.isCompleted ? AppColors.success : AppColors.primary;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      goal.isCompleted ? Icons.emoji_events_rounded : Icons.my_location_rounded,
                      color: color, size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(goal.title, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600)),
                        Text('${goal.sport} \u2022 ${goal.metric}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: daysLeft <= 3 ? AppColors.warning.withValues(alpha: 0.1) : AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$daysLeft days',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: daysLeft <= 3 ? AppColors.warning : AppColors.success,
                        fontWeight: FontWeight.w600, fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: goal.progress,
                  minHeight: 8,
                  backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$progressPercent% complete', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                  Text('${goal.currentValue}/${goal.targetValue} ${goal.metricUnit}',
                      style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w600, color: color)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.people_rounded, size: 16, color: AppColors.textDim),
                  const SizedBox(width: 4),
                  Text('${goal.memberIds.length} members', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                  const Spacer(),
                  Icon(Icons.card_giftcard_rounded, size: 14, color: AppColors.accent),
                  const SizedBox(width: 4),
                  Text(goal.reward, style: AppTextStyles.caption.copyWith(color: AppColors.accent, fontWeight: FontWeight.w600)),
                ],
              ),
              if (!goal.isCompleted) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await ref.read(squadGoalsServiceProvider).contribute(goal.goalId, widget.playerId, 1);
                    },
                    icon: const Icon(Icons.add_task_rounded, size: 18),
                    label: Text('Log Contribution (+1 ${goal.metricUnit})'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
