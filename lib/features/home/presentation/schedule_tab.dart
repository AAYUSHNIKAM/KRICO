import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../design_system/radius/radius.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../design_system/utils/extensions.dart';
import '../../../services/providers.dart';

class ScheduleTab extends ConsumerStatefulWidget {
  final String coachId;
  const ScheduleTab({super.key, required this.coachId});

  @override
  ConsumerState<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends ConsumerState<ScheduleTab> {
  DateTime? _filterDate;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sessionsAsync = ref.watch(coachSessionsProvider(widget.coachId));
    final padH = context.width > 1280
        ? 48.0
        : context.width > 600 && context.width <= 1280
            ? 28.0
            : 16.0;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090B10) : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _ScheduleHeroHeader(coachId: widget.coachId),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(padH, 16, padH, 12),
              child: ref.watch(pendingBookingsProvider(widget.coachId)).when(
                data: (pendingSnap) {
                  final count = pendingSnap.docs.length;
                  return _BookingRequestsCard(coachId: widget.coachId, count: count);
                },
                loading: () => _BookingRequestsCard(coachId: widget.coachId, count: 0, showSpinner: true),
                error: (_, _) => _BookingRequestsCard(coachId: widget.coachId, count: 0),
              ),
            ),
          ),
          _buildAssignedBatchesSliver(isDark, padH),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(padH, 0, padH, 12),
              child: _buildDateFilterBar(isDark),
            ),
          ),
          sessionsAsync.when(
            data: (snap) {
              var docs = [...snap.docs]
                ..sort((a, b) {
                  final aTime = (a.data()['dateTime'] as Timestamp?)?.toDate();
                  final bTime = (b.data()['dateTime'] as Timestamp?)?.toDate();
                  if (aTime == null && bTime == null) return 0;
                  if (aTime == null) return 1;
                  if (bTime == null) return -1;
                  return bTime.compareTo(aTime); // Most recent to least ones
                });

              if (_filterDate != null) {
                docs = docs.where((doc) {
                  final dt = (doc.data()['dateTime'] as Timestamp?)?.toDate();
                  return dt != null && DateUtils.isSameDay(dt, _filterDate!);
                }).toList();
              }
              if (docs.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Container(
                    padding: const EdgeInsets.all(SpacingScale.s40),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                              borderRadius: AppRadius.brXl2,
                              border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.2)),
                            ),
                            child: const Icon(Icons.calendar_month_rounded,
                                size: 36,
                                color: Color(0xFF00E5FF)),
                          ),
                          const SizedBox(height: SpacingScale.s16),
                          Text('No Sessions Scheduled',
                              style: AppTextStyles.title2.copyWith(
                                color: isDark
                                    ? AppColors.textPrimary
                                    : AppColors.lightTextPrimary,
                                fontWeight: FontWeight.w700,
                              )),
                          const SizedBox(height: SpacingScale.s6),
                          Text('Incoming student bookings and match fixtures will appear here',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodySm.copyWith(
                                color: isDark
                                    ? AppColors.textSecondary
                                    : AppColors.lightTextSecondary,
                              )),
                        ],
                      ),
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
                        statusColor = const Color(0xFFCCFF00);
                        statusLabel = 'COMPLETED';
                      case 'cancelled':
                        statusColor = AppColors.danger;
                        statusLabel = 'CANCELLED';
                      default:
                        statusColor = isPast ? const Color(0xFFFFB300) : const Color(0xFF00E5FF);
                        statusLabel = isPast ? 'MISSED' : (isToday ? 'TODAY' : 'UPCOMING');
                    }

                    final sessionDocId = docs[index].id;
                    return Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: padH, vertical: 6),
                      child: _TacticalSessionCard(
                        sessionDocId: sessionDocId,
                        dateTime: dateTime,
                        sport: sport,
                        playerId: playerId,
                        isToday: isToday,
                        isPast: isPast,
                        statusColor: statusColor,
                        statusLabel: statusLabel,
                        isDark: isDark,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: (index * 45).ms, duration: 320.ms)
                        .slideY(begin: 0.05, end: 0);
                  },
                  childCount: docs.length,
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF00E5FF)),
              ),
            ),
            error: (e, _) {
              debugPrint('Schedule sessions error: $e');
              return SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.12),
                          borderRadius: AppRadius.brXl2,
                        ),
                        child: Icon(Icons.cloud_off_rounded,
                            size: 32, color: AppColors.danger),
                      ),
                      const SizedBox(height: SpacingScale.s16),
                      Text('Unable to load schedule',
                          style: AppTextStyles.title3.copyWith(
                            color: isDark
                                ? AppColors.textPrimary
                                : AppColors.lightTextPrimary,
                            fontWeight: FontWeight.w600,
                          )),
                    ],
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: SpacingScale.s32)),
        ],
      ),
    );
  }

  Widget _buildAssignedBatchesSliver(bool isDark, double padH) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('batches')
          .where('coachId', isEqualTo: widget.coachId)
          .where('isActive', isEqualTo: true)
          .snapshots(),
      builder: (ctx, snap) {
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        final batches = snap.data!.docs;
        return SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(padH, 0, padH, 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131D31) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.groups_rounded, color: Color(0xFF00E5FF), size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Assigned Academy Batches (${batches.length})',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  for (final doc in batches) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      doc.data()['name'] ?? 'Squad Batch',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFCCFF00).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        (doc.data()['sport'] ?? 'Sport').toString().toUpperCase(),
                                        style: const TextStyle(
                                          color: Color(0xFFCCFF00),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.schedule_rounded, size: 12, color: Color(0xFF00E5FF)),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        doc.data()['schedule'] ?? 'Regular Schedule',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? Colors.white70 : Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${((doc.data()['playerIds'] as List<dynamic>?) ?? []).length} Athletes',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF00E5FF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

Widget _buildDateFilterBar(bool isDark) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isAll = _filterDate == null;
    final isToday = _filterDate != null && DateUtils.isSameDay(_filterDate!, today);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          Text(
            'Filter by Date:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('All Sessions'),
            selected: isAll,
            selectedColor: const Color(0xFF00E5FF),
            labelStyle: TextStyle(
              color: isAll ? Colors.black : (isDark ? Colors.white : Colors.black87),
              fontWeight: isAll ? FontWeight.w800 : FontWeight.w500,
              fontSize: 12,
            ),
            onSelected: (_) => setState(() => _filterDate = null),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Today'),
            selected: isToday,
            selectedColor: const Color(0xFFCCFF00),
            labelStyle: TextStyle(
              color: isToday ? Colors.black : (isDark ? Colors.white : Colors.black87),
              fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
              fontSize: 12,
            ),
            onSelected: (_) => setState(() => _filterDate = today),
          ),
          const SizedBox(width: 8),
          ActionChip(
            avatar: Icon(
              Icons.calendar_today_rounded,
              size: 14,
              color: (!isAll && !isToday) ? Colors.black : const Color(0xFF00E5FF),
            ),
            label: Text(
              (!isAll && !isToday) ? DateFormat('MMM d, yyyy').format(_filterDate!) : 'Pick Date',
              style: TextStyle(
                fontWeight: (!isAll && !isToday) ? FontWeight.w800 : FontWeight.w500,
                color: (!isAll && !isToday) ? Colors.black : (isDark ? Colors.white : Colors.black87),
                fontSize: 12,
              ),
            ),
            backgroundColor: (!isAll && !isToday) ? const Color(0xFF00E5FF) : null,
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _filterDate ?? today,
                firstDate: today.subtract(const Duration(days: 365)),
                lastDate: today.add(const Duration(days: 365)),
              );
              if (picked != null) {
                setState(() => _filterDate = picked);
              }
            },
          ),
          if (_filterDate != null) ...[
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Clear Date Filter',
              icon: const Icon(Icons.close_rounded, size: 16),
              onPressed: () => setState(() => _filterDate = null),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScheduleHeroHeader extends ConsumerWidget {
  final String coachId;
  const _ScheduleHeroHeader({required this.coachId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsSnap = ref.watch(coachSessionsProvider(coachId)).asData?.value;
    final totalCount = sessionsSnap?.docs.length ?? 0;
    final upcomingCount = sessionsSnap?.docs.where((d) {
          final dt = (d.data()['dateTime'] as Timestamp?)?.toDate();
          return dt != null && dt.isAfter(DateTime.now()) && d.data()['status'] != 'cancelled';
        }).length ?? 0;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 180),
      decoration: BoxDecoration(
        color: const Color(0xFF090B10),
        image: const DecorationImage(
          image: AssetImage('assets/backgrounds/stadium_floodlights.jpg'),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
            width: 1,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.55),
              const Color(0xFF090B10).withValues(alpha: 0.88),
              const Color(0xFF090B10),
            ],
            stops: const [0.0, 0.65, 1.0],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00E5FF),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'COACH TACTICAL ROSTER',
                        style: TextStyle(
                          color: Color(0xFF00E5FF),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: Text(
                    DateFormat('EEEE, MMM d').format(DateTime.now()),
                    style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Training Schedule',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Synchronized timetable for athlete training sessions & field matches',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                _buildStatPill('ACTIVE FIXTURES', '$upcomingCount', const Color(0xFF00E5FF)),
                _buildStatPill('TOTAL SESSIONS', '$totalCount', const Color(0xFFCCFF00)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatPill(String label, String value, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(color: accent, fontSize: 14, fontWeight: FontWeight.w900),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingRequestsCard extends ConsumerWidget {
  final String coachId;
  final int count;
  final bool showSpinner;

  const _BookingRequestsCard({
    required this.coachId,
    this.count = 0,
    this.showSpinner = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasPending = count > 0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.push('/booking-requests', extra: coachId),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF121622) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasPending
                  ? const Color(0xFFCCFF00).withValues(alpha: 0.5)
                  : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08)),
              width: hasPending ? 1.5 : 1,
            ),
            boxShadow: [
              if (hasPending)
                BoxShadow(
                  color: const Color(0xFFCCFF00).withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: hasPending
                        ? [const Color(0xFFCCFF00), const Color(0xFF88FF00)]
                        : [const Color(0xFF00E5FF).withValues(alpha: 0.2), const Color(0xFF00E5FF).withValues(alpha: 0.05)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.mark_email_unread_rounded,
                  color: hasPending ? Colors.black : const Color(0xFF00E5FF),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          'Booking Requests',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (hasPending)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFCCFF00),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'ACTION NEEDED',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      hasPending
                          ? '$count athlete${count > 1 ? 's' : ''} awaiting your session confirmation'
                          : 'Review and confirm incoming athlete bookings',
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (showSpinner)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00E5FF)),
                )
              else if (count > 0)
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFCCFF00),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                )
              else
                Icon(Icons.chevron_right_rounded,
                    color: isDark ? Colors.white38 : Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}

class _TacticalSessionCard extends ConsumerWidget {
  final String sessionDocId;
  final DateTime dateTime;
  final String sport;
  final String playerId;
  final bool isToday;
  final bool isPast;
  final Color statusColor;
  final String statusLabel;
  final bool isDark;

  const _TacticalSessionCard({
    required this.sessionDocId,
    required this.dateTime,
    required this.sport,
    required this.playerId,
    required this.isToday,
    required this.isPast,
    required this.statusColor,
    required this.statusLabel,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerAsync = playerId.isNotEmpty ? ref.watch(playerProvider(playerId)) : null;
    String playerName = playerId.isEmpty ? 'Athlete' : playerId;
    String? playerPhoto;
    if (playerAsync != null) {
      final player = playerAsync.asData?.value;
      if (player != null) {
        playerName = player.name;
        playerPhoto = player.avatarUrl;
      }
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.push('/session/$sessionDocId'),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF121622) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isToday
                  ? const Color(0xFF00E5FF).withValues(alpha: 0.5)
                  : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08)),
              width: isToday ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isToday
                        ? [const Color(0xFF00E5FF), const Color(0xFF0088FF)]
                        : (isDark
                            ? [const Color(0xFF1B2234), const Color(0xFF141926)]
                            : [Colors.grey.shade200, Colors.grey.shade300]),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isToday
                        ? const Color(0xFF00E5FF)
                        : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('MMM').format(dateTime).toUpperCase(),
                      style: TextStyle(
                        color: isToday ? Colors.black : (isDark ? Colors.white70 : Colors.black54),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('d').format(dateTime),
                      style: TextStyle(
                        color: isToday ? Colors.black : (isDark ? Colors.white : Colors.black87),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            sport.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF00E5FF),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        if (isToday)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFCCFF00),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'TODAY',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        if (playerPhoto != null && playerPhoto.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(playerPhoto, width: 20, height: 20, fit: BoxFit.cover),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            playerName,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('hh:mm a').format(dateTime),
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: isDark ? Colors.white30 : Colors.black26,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
