import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/stats_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../services/providers.dart';
import '../../../models/coach_model.dart';

class EarningsTab extends ConsumerWidget {
  final String coachId;
  const EarningsTab({super.key, required this.coachId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(coachSessionsProvider(coachId));
    final coachAsync = ref.watch(coachProvider(coachId));
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.gradientGold,
                  ),
                ),
                padding: EdgeInsets.fromLTRB(
                    20, MediaQuery.of(context).padding.top + 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Earnings',
                        style: AppTextStyles.headlineMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                    Text('Track your coaching income',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.7))),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                sessionsAsync.when(
                  data: (snapshot) {
                    return coachAsync.when(
                      data: (coach) => _buildEarningsContent(context, snapshot, coach),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (_, __) => _buildEarningsContent(context, snapshot, null),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) {
                    debugPrint('Earnings error: $e');
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.error),
                          const SizedBox(height: 12),
                          Text('Unable to load earnings data right now.',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.error)),
                        ],
                      ),
                    );
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsContent(BuildContext context, QuerySnapshot<Map<String, dynamic>> snapshot, CoachModel? coach) {
    final sessions = snapshot.docs;
    final totalSessions = sessions.length;
    final completedSessions =
        sessions.where((d) => d.data()['status'] == 'completed').length;
    final rate = coach?.hourlyRate ?? 0;
    final estimatedEarnings = completedSessions * rate;

    return Column(
      children: [
        Animate(
          effects: const [
            FadeEffect(duration: Duration(milliseconds: 400)),
            SlideEffect(
                begin: Offset(0, 0.05),
                end: Offset.zero,
                duration: Duration(milliseconds: 400)),
          ],
          child: isWide(context)
              ? _buildWideStatsRow(totalSessions, completedSessions,
                    estimatedEarnings, rate)
              : _buildMobileStats(totalSessions, completedSessions,
                    estimatedEarnings, rate),
        ),
        const SizedBox(height: 8),
        const SectionHeader(title: 'Session History'),
        const SizedBox(height: 8),
        Animate(
          effects: const [
            FadeEffect(
                duration: Duration(milliseconds: 400),
                delay: Duration(milliseconds: 100)),
            SlideEffect(
                begin: Offset(0, 0.05),
                end: Offset.zero,
                duration: Duration(milliseconds: 400),
                delay: Duration(milliseconds: 100)),
          ],
          child: sessions.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long_rounded,
                            size: 40, color: AppColors.textSecondary),
                        const SizedBox(height: 8),
                        Text('No sessions yet',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: sessions.take(10).map((doc) {
                    final d = doc.data();
                    final sport = d['sport'] as String? ?? 'Session';
                    final ts = d['dateTime'] as Timestamp?;
                    final status = d['status'] as String? ?? 'booked';
                    final timeStr = ts != null
                        ? _formatDate(ts.toDate())
                        : 'TBD';
                    return _buildSessionRow(sport, timeStr, status, rate);
                  }).toList(),
                ),
        ),
      ],
    );
  }

  bool isWide(BuildContext context) => MediaQuery.of(context).size.width > 600;

  Widget _buildWideStatsRow(int total, int completed, double earnings, double rate) {
    return Row(
      children: [
        Expanded(child: StatsCard(label: 'Total Sessions', value: '$total', icon: Icons.schedule_rounded, iconColor: AppColors.primary)),
        const SizedBox(width: 12),
        Expanded(child: StatsCard(label: 'Completed', value: '$completed', icon: Icons.check_circle_rounded, iconColor: AppColors.success)),
        const SizedBox(width: 12),
        Expanded(child: StatsCard(label: 'Est. Earnings', value: '₹${earnings.toInt()}', icon: Icons.account_balance_wallet_rounded, iconColor: AppColors.gold, gradient: AppColors.gradientAccent)),
        const SizedBox(width: 12),
        Expanded(child: StatsCard(label: 'Hourly Rate', value: '₹${rate.toInt()}', icon: Icons.attach_money_rounded, iconColor: AppColors.accent)),
      ],
    );
  }

  Widget _buildMobileStats(int total, int completed, double earnings, double rate) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: StatsCard(label: 'Total Sessions', value: '$total', icon: Icons.schedule_rounded, iconColor: AppColors.primary)),
            const SizedBox(width: 12),
            Expanded(child: StatsCard(label: 'Completed', value: '$completed', icon: Icons.check_circle_rounded, iconColor: AppColors.success)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: StatsCard(label: 'Est. Earnings', value: '₹${earnings.toInt()}', icon: Icons.account_balance_wallet_rounded, iconColor: AppColors.gold, gradient: AppColors.gradientAccent)),
            const SizedBox(width: 12),
            Expanded(child: StatsCard(label: 'Hourly Rate', value: '₹${rate.toInt()}', icon: Icons.attach_money_rounded, iconColor: AppColors.accent)),
          ],
        ),
      ],
    );
  }

  Widget _buildSessionRow(String name, String time, String status, double rate) {
    final isCompleted = status == 'completed';
    final statusColor = isCompleted ? AppColors.success : AppColors.warning;
    final statusIcon = isCompleted ? Icons.check_circle_rounded : Icons.pending_rounded;
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
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.sports_rounded, color: AppColors.primary, size: 22),
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
                Text(time,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Icon(statusIcon, size: 18, color: statusColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(statusLabel(status),
                style: AppTextStyles.labelSmall.copyWith(
                    color: statusColor, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  String statusLabel(String status) {
    switch (status) {
      case 'completed': return 'Paid';
      case 'cancelled': return 'Cancelled';
      default: return 'Pending';
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
