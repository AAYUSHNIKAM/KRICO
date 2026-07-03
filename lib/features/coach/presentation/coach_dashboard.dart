import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/stats_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/providers.dart';
import '../../../models/coach_model.dart';

class CoachDashboard extends ConsumerWidget {
  const CoachDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateProvider);
    return authAsync.when(
      data: (firebaseUser) {
        if (firebaseUser == null) {
          return Scaffold(
            body: Center(
              child: Text('Please sign in to view your dashboard',
                  style: AppTextStyles.bodyLarge),
            ),
          );
        }
        final coachAsync = ref.watch(coachProvider(firebaseUser.uid));
        return coachAsync.when(
          data: (coach) => _CoachDashboardContent(coach: coach),
          loading: () => const _DashboardLoading(),
          error: (e, _) => Scaffold(
            body: Center(
                child: Text('Error: $e', style: AppTextStyles.bodyLarge)),
          ),
        );
      },
      loading: () => const _DashboardLoading(),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e', style: AppTextStyles.bodyLarge)),
      ),
    );
  }
}

class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _CoachDashboardContent extends ConsumerWidget {
  const _CoachDashboardContent({required this.coach});

  final CoachModel coach;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.of(context).size.width > 600;
    final statsAsync = ref.watch(coachStatsProvider(coach.coachId));
    final monthlyAsync = ref.watch(coachMonthlyEarningsProvider(coach.coachId));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.gradientPrimary,
                  ),
                ),
                padding: EdgeInsets.fromLTRB(
                    20, MediaQuery.of(context).padding.top + 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.15),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 2),
                          ),
                          child: coach.photoUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(28),
                                  child: Image.network(coach.photoUrl!,
                                      fit: BoxFit.cover),
                                )
                              : Icon(Icons.person_rounded,
                                  size: 28,
                                  color: Colors.white.withValues(alpha: 0.8)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              Text('Coach Dashboard',
                                  style: AppTextStyles.bodySmall.copyWith(
                                      color:
                                          Colors.white.withValues(alpha: 0.7))),
                              const SizedBox(height: 2),
                              Text(coach.name,
                                  style: AppTextStyles.headlineMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700)),
                              if (coach.specialization != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(coach.specialization!,
                                      style: AppTextStyles.bodySmall.copyWith(
                                          color: Colors.white
                                              .withValues(alpha: 0.7))),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star_rounded,
                                  size: 14, color: AppColors.gold),
                              const SizedBox(width: 3),
                              Text(
                                  coach.rating.toStringAsFixed(1),
                                  style: AppTextStyles.labelMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        children: [
                          if (coach.isVerified)
                            Icon(Icons.verified_rounded,
                                size: 18, color: AppColors.primary),
                          if (coach.isVerified) const SizedBox(width: 8),
                          Text('${coach.subscriptionTier} Plan',
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                          if (coach.isSubscribed) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('Active',
                                  style: AppTextStyles.overline.copyWith(
                                      color: AppColors.success, fontSize: 9)),
                            ),
                          ],
                          const Spacer(),
                          if (coach.hourlyRate > 0)
                            Text('₹${coach.hourlyRate.toInt()}/hr',
                                style: AppTextStyles.labelLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildStatsSection(context, ref, statsAsync, monthlyAsync, isWide),
                const SizedBox(height: 8),
                const SectionHeader(title: 'Upcoming Sessions', actionLabel: 'View All', onActionTap: null),
                const SizedBox(height: 8),
                _buildSessionsSection(context, ref),
                const SizedBox(height: 8),
                const SectionHeader(
                    title: 'Career Progress', subtitle: 'Your milestones'),
                const SizedBox(height: 8),
                _buildMilestonesSection(context, ref),
                const SizedBox(height: 8),
                const SectionHeader(title: 'Subscription'),
                const SizedBox(height: 8),
                _buildSubscriptionCard(context, ref),
                const SizedBox(height: 16),
                _buildQuickActions(context, ref),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<Map<String, dynamic>> statsAsync,
    AsyncValue<Map<String, int>> monthlyAsync,
    bool isWide,
  ) {
    return Animate(
      effects: const [
        FadeEffect(duration: Duration(milliseconds: 400)),
        SlideEffect(
            begin: Offset(0, 0.05),
            end: Offset.zero,
            duration: Duration(milliseconds: 400)),
      ],
      child: statsAsync.when(
        data: (stats) {
          final totalSessions = stats['totalSessions'] as int? ?? 0;
          final totalStudents = stats['totalStudents'] as int? ?? 0;
          final monthlyData = monthlyAsync.asData?.value;
          final monthlyEarnings = monthlyData?['monthlyEarnings'] ?? 0;

          return isWide
              ? Row(
                  children: [
                    Expanded(child: StatsCard(label: 'Total Sessions', value: '$totalSessions', icon: Icons.schedule_rounded, iconColor: AppColors.primary)),
                    const SizedBox(width: 12),
                    Expanded(child: StatsCard(label: 'Students', value: '$totalStudents', icon: Icons.people_rounded, iconColor: AppColors.success)),
                    const SizedBox(width: 12),
                    Expanded(child: StatsCard(label: 'This Month', value: '₹$monthlyEarnings', icon: Icons.account_balance_wallet_rounded, iconColor: AppColors.gold, gradient: AppColors.gradientAccent)),
                    const SizedBox(width: 12),
                    Expanded(child: StatsCard(label: 'Rating', value: coach.rating.toStringAsFixed(1), icon: Icons.star_rounded, iconColor: AppColors.accent)),
                  ],
                )
              : Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: StatsCard(label: 'Total Sessions', value: '$totalSessions', icon: Icons.schedule_rounded, iconColor: AppColors.primary)),
                        const SizedBox(width: 12),
                        Expanded(child: StatsCard(label: 'Students', value: '$totalStudents', icon: Icons.people_rounded, iconColor: AppColors.success)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: StatsCard(label: 'This Month', value: '₹$monthlyEarnings', icon: Icons.account_balance_wallet_rounded, iconColor: AppColors.gold, gradient: AppColors.gradientAccent)),
                        const SizedBox(width: 12),
                        Expanded(child: StatsCard(label: 'Rating', value: coach.rating.toStringAsFixed(1), icon: Icons.star_rounded, iconColor: AppColors.accent)),
                      ],
                    ),
                  ],
                );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) {
          debugPrint('Stats error: $e');
          return Text('Unable to load stats right now.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error));
        },
      ),
    );
  }

  Widget _buildSessionsSection(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(coachSessionsProvider(coach.coachId));
    return Animate(
      effects: const [
        FadeEffect(duration: Duration(milliseconds: 400), delay: Duration(milliseconds: 100)),
        SlideEffect(begin: Offset(0, 0.05), end: Offset.zero, duration: Duration(milliseconds: 400), delay: Duration(milliseconds: 100)),
      ],
      child: sessionsAsync.when(
        data: (snapshot) {
          final sessions = snapshot.docs;
          final sorted = [...sessions]
            ..sort((a, b) {
              final aTime = (a.data()['dateTime'] as Timestamp?)?.toDate();
              final bTime = (b.data()['dateTime'] as Timestamp?)?.toDate();
              if (aTime == null && bTime == null) return 0;
              if (aTime == null) return 1;
              if (bTime == null) return -1;
              return aTime.compareTo(bTime);
            });
          if (sorted.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.event_busy_rounded, size: 40, color: AppColors.textSecondary),
                    const SizedBox(height: 8),
                    Text('No upcoming sessions yet',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    GradientButton(
                      onPressed: () => context.push('/create-session'),
                      height: 36,
                      borderRadius: 8,
                      child: const Text('Create Session',
                          style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            );
          }
          return Column(
            children: sorted.take(5).map((doc) {
              final d = doc.data();
              final sport = d['sport'] as String? ?? 'Session';
              final ts = d['dateTime'] as Timestamp?;
              final timeStr = ts != null ? _formatSessionTime(ts.toDate()) : 'TBD';
              final playerId = d['playerId'] as String? ?? '';
              final price = d['price'] as num? ?? 0;
              return _buildSessionCard(
                context, ref, doc.id, sport, timeStr, playerId, price,
                _getSportIcon(sport), _getSportColor(sport),
              );
            }).toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) {
          debugPrint('Sessions error: $e');
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: [
                Icon(Icons.cloud_off_rounded, size: 32, color: AppColors.error),
                const SizedBox(height: 8),
                Text('Unable to load sessions right now. Please try again.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatSessionTime(DateTime dt) {
    final now = DateTime.now();
    final diff = dt.difference(now);
    if (diff.isNegative) return 'Ongoing';
    if (diff.inDays == 0) {
      return 'Today, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    if (diff.inDays == 1) {
      return 'Tomorrow, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.day}/${dt.month}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  IconData _getSportIcon(String sport) {
    final lower = sport.toLowerCase();
    if (lower.contains('cricket')) return Icons.sports_cricket_rounded;
    if (lower.contains('swim')) return Icons.pool_rounded;
    if (lower.contains('tennis')) return Icons.sports_tennis_rounded;
    if (lower.contains('football') || lower.contains('soccer')) return Icons.sports_football_rounded;
    if (lower.contains('basketball')) return Icons.sports_basketball_rounded;
    if (lower.contains('baseball')) return Icons.sports_baseball_rounded;
    if (lower.contains('kabaddi')) return Icons.sports_kabaddi_rounded;
    if (lower.contains('hockey')) return Icons.sports_hockey_rounded;
    if (lower.contains('golf')) return Icons.golf_course_rounded;
    if (lower.contains('yoga')) return Icons.self_improvement_rounded;
    if (lower.contains('gym') || lower.contains('fitness')) return Icons.fitness_center_rounded;
    return Icons.sports_rounded;
  }

  Color _getSportColor(String sport) {
    final lower = sport.toLowerCase();
    if (lower.contains('cricket')) return AppColors.primary;
    if (lower.contains('swim')) return AppColors.success;
    if (lower.contains('tennis')) return AppColors.warning;
    if (lower.contains('football') || lower.contains('soccer')) return AppColors.info;
    if (lower.contains('basketball')) return AppColors.accent;
    if (lower.contains('baseball')) return Colors.orange;
    if (lower.contains('kabaddi')) return Colors.brown;
    if (lower.contains('hockey')) return Colors.indigo;
    if (lower.contains('yoga')) return Colors.purple;
    return AppColors.primary;
  }

  Widget _buildSessionCard(
    BuildContext context,
    WidgetRef ref,
    String sessionId,
    String name,
    String time,
    String studentId,
    num price,
    IconData icon,
    Color color,
  ) {
    final playerAsync = studentId.isNotEmpty
        ? ref.watch(playerProvider(studentId))
        : null;

    String studentName = studentId;
    if (playerAsync != null) {
      final playerData = playerAsync.asData?.value;
      if (playerData != null) {
        studentName = playerData.name;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: AppTextStyles.titleSmall
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('$studentName · $time',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          GradientButton(
            onPressed: () => _showSessionActions(context, sessionId),
            height: 32,
            borderRadius: 8,
            child: Text('Join',
                style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showSessionActions(BuildContext context, String sessionId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceMid,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            _actionTile(ctx, Icons.videocam_rounded, 'Start Video Session', () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Video session feature coming soon')),
              );
            }),
            _actionTile(ctx, Icons.message_rounded, 'Send Message', () {
              Navigator.pop(ctx);
              context.push('/chat');
            }),
            _actionTile(ctx, Icons.edit_calendar_rounded, 'Reschedule', () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rescheduling coming soon')),
              );
            }),
            _actionTile(ctx, Icons.cancel_outlined, 'Cancel Session',
                () {
              Navigator.pop(ctx);
              _confirmCancelSession(context, sessionId);
            },
                color: AppColors.error),
          ],
        ),
      ),
    );
  }

  Widget _actionTile(BuildContext context, IconData icon, String label, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.primary),
      title: Text(label,
          style: AppTextStyles.bodyMedium.copyWith(color: color ?? AppColors.textPrimary)),
      onTap: onTap,
    );
  }

  void _confirmCancelSession(BuildContext context, String sessionId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceMid,
        title: const Text('Cancel Session'),
        content: const Text('Are you sure you want to cancel this session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Session cancelled')),
              );
            },
            child: const Text('Yes, Cancel', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestonesSection(BuildContext context, WidgetRef ref) {
    final milestonesAsync = ref.watch(coachMilestonesProvider(coach.coachId));
    return Animate(
      effects: const [
        FadeEffect(duration: Duration(milliseconds: 400), delay: Duration(milliseconds: 200)),
        SlideEffect(begin: Offset(0, 0.05), end: Offset.zero, duration: Duration(milliseconds: 400), delay: Duration(milliseconds: 200)),
      ],
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.timeline_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Milestones',
                      style: AppTextStyles.titleSmall
                          .copyWith(fontWeight: FontWeight.w600)),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 20, color: AppColors.primary),
                  onPressed: () => _showAddMilestoneDialog(context, ref),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 16),
            milestonesAsync.when(
              data: (snapshot) {
                final milestones = snapshot.docs;
                if (milestones.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Icon(Icons.flag_outlined, size: 40, color: AppColors.textDim),
                        const SizedBox(height: 8),
                        Text('No milestones yet',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: 12),
                        GradientButton(
                          onPressed: () => _showAddMilestoneDialog(context, ref),
                          height: 36,
                          borderRadius: 8,
                          child: const Text('Add Milestone',
                              style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ],
                    ),
                  );
                }
                return Column(
                  children: milestones.map((doc) {
                    final d = doc.data();
                    final label = d['label'] as String? ?? '';
                    final done = d['done'] as bool? ?? false;
                    return _buildMilestoneItem(context, ref, doc.id, label, done);
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) {
                debugPrint('Milestones error: $e');
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Icon(Icons.cloud_off_rounded, size: 32, color: AppColors.error),
                      const SizedBox(height: 8),
                      Text('Unable to load milestones right now. Please try again.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestoneItem(BuildContext context, WidgetRef ref, String id, String label, bool done) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          InkWell(
            onTap: done ? null : () => ref.read(coachServiceProvider).completeMilestone(id),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: done ? AppColors.success : AppColors.borderLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                done ? Icons.check : Icons.close,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: done ? AppColors.textPrimary : AppColors.textSecondary,
                  decoration: done ? TextDecoration.lineThrough : null,
                )),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.textDim),
            onPressed: () => ref.read(coachServiceProvider).deleteMilestone(id),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  void _showAddMilestoneDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceMid,
        title: const Text('Add Milestone'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g., Complete 100 Sessions',
            border: OutlineInputBorder(),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          GradientButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(coachServiceProvider).addMilestone(coach.coachId, controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            height: 38,
            child: const Text('Add',
                style: TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context, WidgetRef ref) {
    final price = coach.subscriptionTier == 'Professional'
        ? 499
        : coach.subscriptionTier == 'Premium'
            ? 999
            : 0;
    final expiryStr = coach.subscriptionExpiry != null
        ? 'Renewal: ${_formatDate(coach.subscriptionExpiry!)}'
        : 'No expiry date';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.primary.withValues(alpha: 0.05),
          AppColors.primaryDark.withValues(alpha: 0.08),
        ]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium_rounded,
                  color: AppColors.primary),
              const SizedBox(width: 8),
              Text('${coach.subscriptionTier} Plan',
                  style: AppTextStyles.titleSmall
                      .copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: coach.isSubscribed
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  coach.isSubscribed ? 'Active' : 'Inactive',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: coach.isSubscribed
                        ? AppColors.success
                        : AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (price > 0) ...[
                Text('₹$price',
                    style: AppTextStyles.headlineLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
                Text('/mo',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary)),
              ] else
                Text('Free Tier',
                    style: AppTextStyles.headlineSmall
                        .copyWith(color: AppColors.textSecondary)),
              const Spacer(),
              Text(expiryStr,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          GradientButton(
            onPressed: () => _showManageSubscription(context),
            height: 42,
            child: const Text('Manage Plan',
                style: TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _showManageSubscription(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceMid,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text('Manage Plan', style: AppTextStyles.titleLarge),
            const SizedBox(height: 16),
            _planOption(ctx, 'Starter', '₹0/mo', 'Basic features', coach.subscriptionTier == 'Starter'),
            const SizedBox(height: 8),
            _planOption(ctx, 'Professional', '₹499/mo', 'Advanced analytics, priority support', coach.subscriptionTier == 'Professional'),
            const SizedBox(height: 8),
            _planOption(ctx, 'Premium', '₹999/mo', 'All features, unlimited sessions, dedicated manager', coach.subscriptionTier == 'Premium'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _planOption(BuildContext context, String name, String price, String desc, bool isCurrent) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCurrent ? AppColors.primary.withValues(alpha: 0.1) : AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: isCurrent
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
            : Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(desc, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(price, style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
          if (isCurrent) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('Current', style: AppTextStyles.caption.copyWith(color: AppColors.success, fontSize: 9)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    return Animate(
      effects: const [
        FadeEffect(duration: Duration(milliseconds: 400), delay: Duration(milliseconds: 300)),
        SlideEffect(begin: Offset(0, 0.05), end: Offset.zero, duration: Duration(milliseconds: 400), delay: Duration(milliseconds: 300)),
      ],
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick Actions', style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _quickActionChip(context, Icons.message_rounded, 'Messages', () => context.push('/chat'))),
                const SizedBox(width: 8),
                Expanded(child: _quickActionChip(context, Icons.school_rounded, 'Academy Jobs', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Academy jobs coming soon'))))),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _quickActionChip(context, Icons.videocam_rounded, 'Video Tips', () => context.push('/video-analysis'))),
                const SizedBox(width: 8),
                Expanded(child: _quickActionChip(context, Icons.analytics_rounded, 'Reports', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reports coming soon'))))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickActionChip(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
}
