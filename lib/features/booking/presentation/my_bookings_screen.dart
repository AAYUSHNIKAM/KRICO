import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/typography/text_styles.dart';
// Removed unused import
import '../../../models/user_model.dart';
import '../../../services/providers.dart';
import '../domain/booking_entry.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key, required this.user});
  final UserModel user;

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen> {
  String? _childId;
  BookingFilter _filter = BookingFilter.upcoming;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0B0E14) : const Color(0xFFF8FAFC);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              // 1. Athletic Header with Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCCFF00),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'ATHLETIC TRAINING PASSES',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 9.5,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'My Bookings',
                        style: AppTextStyles.heading2.copyWith(
                          color: textPrimary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/coach-discovery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCCFF00),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Book Coach', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. Segmented Filter Chips
              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final filter in BookingFilter.values)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(switch (filter) {
                            BookingFilter.upcoming => 'Upcoming',
                            BookingFilter.requests => 'Pending Review',
                            BookingFilter.history => 'Completed',
                            BookingFilter.all => 'All Passes',
                          }),
                          selected: _filter == filter,
                          onSelected: (_) => setState(() => _filter = filter),
                          selectedColor: const Color(0xFFCCFF00),
                          backgroundColor: isDark ? const Color(0xFF131D31) : const Color(0xFFF1F5F9),
                          labelStyle: TextStyle(
                            color: _filter == filter ? Colors.black : (isDark ? Colors.white70 : Colors.black87),
                            fontWeight: _filter == filter ? FontWeight.w800 : FontWeight.w500,
                            fontSize: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                            side: BorderSide(
                              color: _filter == filter ? const Color(0xFFCCFF00) : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Parent Child Selector (if parent)
              if (widget.user.role == UserRole.parent)
                ref.watch(parentPlayersProvider(widget.user.uid)).when(
                  loading: () => const LinearProgressIndicator(color: Color(0xFFCCFF00)),
                  error: (_, _) => _empty('Could not load linked players.', 'Retry', () => ref.invalidate(parentPlayersProvider(widget.user.uid)), isDark),
                  data: (players) {
                    if (players.isEmpty) {
                      return _empty('Link a student athlete to manage their sports bookings.', 'Link Player', () => context.push('/add-child'), isDark);
                    }
                    final selected = players.any((p) => p.playerId == _childId) ? _childId! : players.first.playerId;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF131D31) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selected,
                              items: [for (final p in players) DropdownMenuItem(value: p.playerId, child: Text('Athlete: ${p.name}', style: const TextStyle(fontWeight: FontWeight.bold)))],
                              onChanged: (val) => setState(() => _childId = val),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _sessions(selected, isDark),
                      ],
                    );
                  },
                )
              else
                _sessions(widget.user.uid, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sessions(String playerId, bool isDark) => ref.watch(playerSessionsProvider(playerId)).when(
    loading: () => const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: Color(0xFFCCFF00)))),
    error: (_, _) => _empty('Could not load bookings.', 'Retry', () => ref.invalidate(playerSessionsProvider(playerId)), isDark),
    data: (snapshot) {
      final now = DateTime.now();
      final entries = snapshot.docs.map((doc) => BookingEntry(id: doc.id, data: doc.data()))
          .where((entry) => entry.matches(_filter, now)).toList()
        ..sort((a, b) {
          final comparison = (a.date ?? DateTime(9999)).compareTo(b.date ?? DateTime(9999));
          return _filter == BookingFilter.history ? -comparison : comparison;
        });

      if (entries.isEmpty) {
        return _empty('No active passes in this category.', 'Find a Coach', () => context.push('/coach-discovery'), isDark);
      }

      return Column(
        children: [
          for (var i = 0; i < entries.length; i++)
            _buildPassCard(entries[i], isDark)
                .animate()
                .fade(duration: 250.ms)
                .slideY(begin: 0.04, delay: (i * 30).ms),
        ],
      );
    },
  );

  Widget _buildPassCard(BookingEntry entry, bool isDark) {
    final sport = entry.data['sport'] as String? ?? 'Coaching Session';
    final coachId = entry.data['coachId'] as String?;
    final venue = entry.data['venue'] as String? ?? 'Training Sports Complex';
    final amount = (entry.data['amount'] as num?)?.toDouble() ?? 0;
    final status = entry.data['status'] as String? ?? 'booked';
    final isConfirmed = status == 'confirmed';

    String sportCover;
    final s = sport.toLowerCase();
    if (s.contains('badminton')) {
      sportCover = 'assets/images/sports/badminton_smash.jpg';
    } else if (s.contains('football')) {
      sportCover = 'assets/images/sports/football_action.jpeg';
    } else if (s.contains('tennis')) {
      sportCover = 'assets/images/sports/tennis_racket.jpg';
    } else if (s.contains('basketball')) {
      sportCover = 'assets/images/sports/basketball_hoop.webp';
    } else {
      sportCover = 'assets/backgrounds/stadium_floodlights.jpg';
    }

    final cardBg = isDark ? const Color(0xFF131D31) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isConfirmed ? const Color(0xFFCCFF00).withValues(alpha: 0.4) : borderColor,
          width: isConfirmed ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          children: [
            // Top Visual Banner
            SizedBox(
              height: 100,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(sportCover, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withValues(alpha: 0.2), Colors.black.withValues(alpha: 0.85)],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                sport.toUpperCase(),
                                style: const TextStyle(color: Color(0xFFCCFF00), fontSize: 10, fontWeight: FontWeight.w900),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isConfirmed ? const Color(0xFF10B981) : const Color(0xFFFF4D00),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                isConfirmed ? 'CONFIRMED PASS' : 'WAITING ACCEPTANCE',
                                style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.date == null ? 'Date TBD' : DateFormat('EEEE, MMM d • hh:mm a').format(entry.date!),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                            ),
                            if (amount > 0)
                              Text('₹${amount.toInt()}', style: const TextStyle(color: Color(0xFFCCFF00), fontWeight: FontWeight.w900, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (coachId != null)
                    ref.watch(coachProvider(coachId)).when(
                      data: (coach) => Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: const AssetImage('assets/avatars/coach_experienced.jpg'),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Coach ${coach.name}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                                Text(coach.specialization ?? 'Sports Trainer', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => context.push('/chat'),
                            icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary, size: 20),
                          ),
                        ],
                      ),
                      loading: () => const Text('Loading coach details...', style: TextStyle(color: Colors.grey)),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(venue, style: const TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => context.push('/session/${entry.id}'),
                        icon: const Icon(Icons.qr_code_2_rounded, size: 18),
                        label: const Text('Pass & QR Check-in', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty(String message, String action, VoidCallback onTap, bool isDark) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/animations/calendar_empty.gif',
              width: 110,
              height: 110,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(Icons.event_note_outlined, size: 60, color: Color(0xFFCCFF00)),
            ),
          ),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCCFF00),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(action, style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    ),
  );
}