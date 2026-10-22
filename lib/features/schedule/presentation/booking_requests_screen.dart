import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../design_system/radius/radius.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../services/providers.dart';
import '../../../providers/auth_provider.dart';

class BookingRequestsScreen extends ConsumerStatefulWidget {
  final String coachId;

  const BookingRequestsScreen({super.key, required this.coachId});

  @override
  ConsumerState<BookingRequestsScreen> createState() => _BookingRequestsScreenState();
}

class _BookingRequestsScreenState extends ConsumerState<BookingRequestsScreen> {
  int _selectedTabIndex = 0; // 0: Pending, 1: Confirmed, 2: History

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allSessionsAsync = ref.watch(coachSessionsProvider(widget.coachId));
    final pendingAsync = ref.watch(pendingBookingsProvider(widget.coachId));

    final bgColor = isDark ? const Color(0xFF0B0E14) : const Color(0xFFF8FAFC);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final pendingCount = pendingAsync.asData?.value.docs.length ?? 0;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          // 1. High-Impact Athletic Header
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            elevation: 0,
            backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/backgrounds/stadium_floodlights.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(color: const Color(0xFF0B0E14)),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          (isDark ? const Color(0xFF0B0E14) : Colors.white).withValues(alpha: 0.95),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: SpacingScale.s16,
                    left: SpacingScale.s20,
                    right: SpacingScale.s20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFCCFF00),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/animations/live_pulse.gif',
                                    width: 14,
                                    height: 14,
                                    errorBuilder: (_, _, _) => const Icon(Icons.circle, size: 8, color: Colors.black),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'MATCHDAY SESSIONS',
                                    style: AppTextStyles.captionXs.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            if (pendingCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF4D00),
                                  borderRadius: BorderRadius.circular(100),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF4D00).withValues(alpha: 0.4),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '$pendingCount ACTION NEEDED',
                                  style: AppTextStyles.captionXs.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: SpacingScale.s8),
                        Text(
                          'Booking Requests',
                          style: AppTextStyles.heading2.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Segmented Filter Tabs
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(SpacingScale.s16, SpacingScale.s12, SpacingScale.s16, SpacingScale.s12),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF131D31) : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        _buildTabButton(
                          index: 0,
                          title: 'Pending',
                          badgeCount: pendingCount,
                          isDark: isDark,
                        ),
                        _buildTabButton(
                          index: 1,
                          title: 'Confirmed',
                          badgeCount: 0,
                          isDark: isDark,
                        ),
                        _buildTabButton(
                          index: 2,
                          title: 'History',
                          badgeCount: 0,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 3. Request Stream List or Confirmed/History Stream
          allSessionsAsync.when(
            data: (allSnap) {
              final now = DateTime.now();
              final allDocs = allSnap.docs;

              final List<QueryDocumentSnapshot<Map<String, dynamic>>> filteredDocs;
              if (_selectedTabIndex == 0) {
                // Pending
                filteredDocs = allDocs.where((d) => d.data()['status'] == 'booked').toList();
              } else if (_selectedTabIndex == 1) {
                // Confirmed upcoming
                filteredDocs = allDocs.where((d) {
                  final status = d.data()['status'] as String? ?? '';
                  final time = (d.data()['dateTime'] as Timestamp?)?.toDate();
                  return status == 'confirmed' && (time == null || time.isAfter(now.subtract(const Duration(hours: 2))));
                }).toList();
              } else {
                // History
                filteredDocs = allDocs.where((d) {
                  final status = d.data()['status'] as String? ?? '';
                  final time = (d.data()['dateTime'] as Timestamp?)?.toDate();
                  return status == 'completed' || status == 'cancelled' || (time != null && time.isBefore(now));
                }).toList();
              }

              filteredDocs.sort((a, b) {
                final aTime = (a.data()['dateTime'] as Timestamp?)?.toDate();
                final bTime = (b.data()['dateTime'] as Timestamp?)?.toDate();
                if (aTime == null && bTime == null) return 0;
                if (aTime == null) return 1;
                if (bTime == null) return -1;
                return _selectedTabIndex == 2 ? bTime.compareTo(aTime) : aTime.compareTo(bTime);
              });

              if (filteredDocs.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(SpacingScale.s32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              'assets/animations/calendar_empty.gif',
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Icon(Icons.calendar_today_rounded, size: 64, color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(height: SpacingScale.s20),
                          Text(
                            _selectedTabIndex == 0
                                ? 'No Pending Requests'
                                : _selectedTabIndex == 1
                                    ? 'No Upcoming Confirmed Sessions'
                                    : 'No Past Session History',
                            style: AppTextStyles.title1.copyWith(
                              color: textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: SpacingScale.s8),
                          Text(
                            _selectedTabIndex == 0
                                ? 'Your schedule is wide open! Share your calendar with athletes to get booked fast.'
                                : 'Accepted training sessions with verified athletes will appear here.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySm.copyWith(color: textSecondary),
                          ),
                          const SizedBox(height: SpacingScale.s20),
                          ElevatedButton.icon(
                            onPressed: () => context.push('/manage-availability'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.tune_rounded, size: 18),
                            label: const Text('Broadcast Availability'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(SpacingScale.s16, SpacingScale.s4, SpacingScale.s16, SpacingScale.s40),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final doc = filteredDocs[index];
                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 760),
                          child: _AthleticSessionPass(
                            sessionId: doc.id,
                            data: doc.data(),
                            isDark: isDark,
                            onRespond: (status) => _respond(context, doc.id, status),
                          ).animate().fadeIn(delay: (index * 50).ms, duration: 300.ms).slideY(begin: 0.05, end: 0),
                        ),
                      );
                    },
                    childCount: filteredDocs.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),
            error: (err, _) => SliverFillRemaining(
              child: Center(
                child: Text('Error loading sessions: $err', style: const TextStyle(color: Colors.red)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required String title,
    required int badgeCount,
    required bool isDark,
  }) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedTabIndex = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF1E293B) : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: AppTextStyles.label.copyWith(
                  color: isSelected
                      ? (isDark ? Colors.white : const Color(0xFF0F172A))
                      : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              if (badgeCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4D00),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    badgeCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
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

  Future<void> _respond(BuildContext context, String sessionId, String status) async {
    HapticFeedback.heavyImpact();
    try {
      await ref.read(coachServiceProvider).respondToBooking(sessionId, status);
      if (!context.mounted) return;
      if (status == 'confirmed') {
        _showCelebrationDialog(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Booking request declined.'),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: $e'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showCelebrationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Center(
        child: Container(
          margin: const EdgeInsets.all(SpacingScale.s24),
          padding: const EdgeInsets.all(SpacingScale.s24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFCCFF00), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFCCFF00).withValues(alpha: 0.3),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/animations/success_check.gif',
                width: 100,
                height: 100,
                errorBuilder: (_, _, _) => const Icon(Icons.check_circle, size: 72, color: Color(0xFFCCFF00)),
              ),
              const SizedBox(height: SpacingScale.s16),
              Text(
                'SESSION CONFIRMED!',
                style: AppTextStyles.title1.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: SpacingScale.s8),
              Text(
                'The athlete has been notified and the court slot is confirmed.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySm.copyWith(color: const Color(0xFF94A3B8)),
              ),
              const SizedBox(height: SpacingScale.s20),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCCFF00),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                ),
                child: const Text('GREAT, DONE', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AthleticSessionPass extends ConsumerWidget {
  final String sessionId;
  final Map<String, dynamic> data;
  final bool isDark;
  final ValueChanged<String> onRespond;

  const _AthleticSessionPass({
    required this.sessionId,
    required this.data,
    required this.isDark,
    required this.onRespond,
  });

  String _getSportImage(String sport) {
    final s = sport.toLowerCase();
    if (s.contains('badminton')) return 'assets/images/sports/badminton_smash.jpg';
    if (s.contains('football') || s.contains('soccer')) return 'assets/images/sports/football_action.jpeg';
    if (s.contains('tennis')) return 'assets/images/sports/tennis_racket.jpg';
    if (s.contains('basketball')) return 'assets/images/sports/basketball_hoop.webp';
    return 'assets/backgrounds/stadium_floodlights.jpg';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateTime = (data['dateTime'] as Timestamp?)?.toDate();
    final sport = data['sport'] as String? ?? 'Athletic Training';
    final playerId = data['playerId'] as String? ?? '';
    final amount = (data['amount'] as num?)?.toDouble() ?? 0;
    final status = data['status'] as String? ?? 'booked';
    final venue = data['venue'] as String? ?? 'Sports Arena Complex';

    final playerAsync = playerId.isNotEmpty ? ref.watch(userProfileProvider(playerId)) : null;
    final playerName = playerAsync?.value?.name ?? 'Athlete';
    final playerPhoto = playerAsync?.value?.photoUrl;

    final now = DateTime.now();
    String countdownChip = '';
    if (dateTime != null) {
      final diff = dateTime.difference(now);
      if (diff.isNegative) {
        countdownChip = 'Session Past';
      } else if (diff.inHours < 1) {
        countdownChip = 'Starts in ${diff.inMinutes}m';
      } else if (diff.inHours < 24) {
        countdownChip = 'Starts in ${diff.inHours}h';
      } else {
        countdownChip = 'In ${diff.inDays} days';
      }
    }

    final cardBg = isDark ? const Color(0xFF131D31) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final isPending = status == 'booked';

    return Container(
      margin: const EdgeInsets.only(bottom: SpacingScale.s16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPending ? const Color(0xFFCCFF00).withValues(alpha: 0.4) : borderColor,
          width: isPending ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Sport Photography Header
            SizedBox(
              height: 110,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    _getSportImage(sport),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(color: AppColors.primary),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.2),
                          Colors.black.withValues(alpha: 0.85),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(SpacingScale.s12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.sports_rounded, color: Color(0xFFCCFF00), size: 14),
                                  const SizedBox(width: 6),
                                  Text(
                                    sport.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            if (countdownChip.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isPending ? const Color(0xFFFF4D00) : const Color(0xFF10B981),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.timer_outlined, size: 12, color: Colors.white),
                                    const SizedBox(width: 4),
                                    Text(
                                      countdownChip,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (dateTime != null)
                              Row(
                                children: [
                                  const Icon(Icons.calendar_month_rounded, color: Colors.white70, size: 14),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${DateFormat('EEEE, MMM d').format(dateTime)} • ${DateFormat('hh:mm a').format(dateTime)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            if (amount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFCCFF00),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '₹${amount.toInt()} NET',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Athlete Information & Venue Section
            Padding(
              padding: const EdgeInsets.all(SpacingScale.s16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFCCFF00), width: 1.5),
                        ),
                        child: ClipOval(
                          child: playerPhoto != null
                              ? Image.network(playerPhoto, fit: BoxFit.cover)
                              : Image.asset(
                                  'assets/avatars/athlete_1.jpg',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Center(
                                    child: Text(
                                      playerName[0].toUpperCase(),
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: SpacingScale.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    playerName,
                                    style: AppTextStyles.title2.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'ATHLETE',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined, size: 14, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    venue,
                                    style: AppTextStyles.caption.copyWith(
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (playerId.isNotEmpty)
                        IconButton(
                          tooltip: 'Message athlete',
                          onPressed: () => context.push('/chat'),
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: AppColors.primary),
                          ),
                        ),
                    ],
                  ),

                  // 3. Actions for Pending Requests
                  if (isPending) ...[
                    const SizedBox(height: SpacingScale.s16),
                    const Divider(height: 1),
                    const SizedBox(height: SpacingScale.s12),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: ElevatedButton.icon(
                            onPressed: () => onRespond('confirmed'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFCCFF00),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.check_circle_rounded, size: 18),
                            label: const Text(
                              'ACCEPT SESSION',
                              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
                            ),
                          ),
                        ),
                        const SizedBox(width: SpacingScale.s8),
                        Expanded(
                          flex: 2,
                          child: OutlinedButton.icon(
                            onPressed: () => onRespond('cancelled'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFEF4444),
                              side: const BorderSide(color: Color(0xFFEF4444)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.close_rounded, size: 16),
                            label: const Text(
                              'DECLINE',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const SizedBox(height: SpacingScale.s12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: status == 'confirmed'
                            ? const Color(0xFF10B981).withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            status == 'confirmed' ? Icons.check_circle_rounded : Icons.info_outline,
                            size: 16,
                            color: status == 'confirmed' ? const Color(0xFF10B981) : Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            status == 'confirmed' ? 'SESSION CONFIRMED & SCHEDULED' : 'SESSION COMPLETED',
                            style: TextStyle(
                              color: status == 'confirmed' ? const Color(0xFF10B981) : Colors.grey,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
