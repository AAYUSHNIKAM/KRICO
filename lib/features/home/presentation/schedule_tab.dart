import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../services/providers.dart';

class ScheduleTab extends ConsumerWidget {
  final String coachId;
  const ScheduleTab({super.key, required this.coachId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(coachSessionsProvider(coachId));

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.surfaceDark, AppColors.surfaceMid],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 160,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.gradientPrimary,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Schedule',
                              style: AppTextStyles.displaySmall.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text('Manage your training sessions',
                              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            sessionsAsync.when(
              data: (snap) {
                final docs = [...snap.docs]
                  ..sort((a, b) {
                    final aTime = (a.data()['dateTime'] as Timestamp?)?.toDate();
                    final bTime = (b.data()['dateTime'] as Timestamp?)?.toDate();
                    if (aTime == null && bTime == null) return 0;
                    if (aTime == null) return 1;
                    if (bTime == null) return -1;
                    return aTime.compareTo(bTime);
                  });
                if (docs.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_month_rounded, size: 64, color: AppColors.textDim),
                          SizedBox(height: 16),
                          Text('No sessions scheduled', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                          SizedBox(height: 8),
                          Text('Bookings will appear here', style: TextStyle(color: AppColors.textDim, fontSize: 13)),
                        ],
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final data = docs[index].data();
                      final dateTime = (data['dateTime'] as Timestamp).toDate();
                      final status = data['status'] as String? ?? 'booked';
                      final playerId = data['playerId'] as String? ?? '';
                      final sport = data['sport'] as String? ?? 'General';
                      final isPast = dateTime.isBefore(DateTime.now());
                      final isToday = DateUtils.isSameDay(dateTime, DateTime.now());

                      Color statusColor;
                      String statusLabel;
                      switch (status) {
                        case 'completed':
                          statusColor = AppColors.success;
                          statusLabel = 'Completed';
                        case 'cancelled':
                          statusColor = AppColors.error;
                          statusLabel = 'Cancelled';
                        default:
                          statusColor = isPast ? AppColors.warning : AppColors.primary;
                          statusLabel = isPast ? 'Missed' : 'Upcoming';
                      }

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardDark,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isToday
                                  ? AppColors.primary.withValues(alpha: 0.3)
                                  : AppColors.borderLight.withValues(alpha: 0.1),
                            ),
                          ),
                        child: _SessionCard(
                          dateTime: dateTime,
                          sport: sport,
                          playerId: playerId,
                          isToday: isToday,
                          statusColor: statusColor,
                          statusLabel: statusLabel,
                        ),
                        ),
                      ).animate().fadeIn(delay: (index * 60).ms).slideY(begin: 0.1, end: 0);
                    },
                    childCount: docs.length,
                  ),
                );
              },
              loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
              error: (e, _) {
                debugPrint('Schedule sessions error: $e');
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.error),
                        const SizedBox(height: 12),
                        Text('Unable to load schedule right now.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('Please try again.',
                            style: TextStyle(color: AppColors.textDim, fontSize: 13)),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _SessionCard extends ConsumerWidget {
  final DateTime dateTime;
  final String sport;
  final String playerId;
  final bool isToday;
  final Color statusColor;
  final String statusLabel;

  const _SessionCard({
    required this.dateTime,
    required this.sport,
    required this.playerId,
    required this.isToday,
    required this.statusColor,
    required this.statusLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerAsync = playerId.isNotEmpty ? ref.watch(playerProvider(playerId)) : null;
    String playerName = playerId.isEmpty ? 'Unknown' : playerId;
    if (playerAsync != null) {
      final player = playerAsync.asData?.value;
      if (player != null) {
        playerName = player.name;
      }
    }

    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.gradientPrimary,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(DateFormat('d').format(dateTime),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              Text(DateFormat('MMM').format(dateTime),
                  style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(sport,
                  style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(playerName,
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.access_time_rounded, size: 12, color: AppColors.textDim),
                  const SizedBox(width: 4),
                  Text(DateFormat('hh:mm a').format(dateTime),
                      style: AppTextStyles.caption.copyWith(color: AppColors.textDim)),
                  const SizedBox(width: 8),
                  if (isToday)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('Today',
                          style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
            ],
          ),
        ),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(statusLabel,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}
