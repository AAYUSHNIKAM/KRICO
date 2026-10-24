import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../design_system/radius/radius.dart';
import '../../../design_system/widgets/page_headers/page_hero.dart';
import '../../../design_system/responsive/responsive_helpers.dart';
import '../../../design_system/widgets/buttons/primary_button.dart';
import '../../../models/coach_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/booking_providers.dart';
import '../../../services/providers.dart';
import '../../../services/availability_service.dart';
import '../../booking/presentation/widgets/availability_calendar.dart';

class CoachDetailScreen extends ConsumerWidget {
  final String coachId;

  const CoachDetailScreen({super.key, required this.coachId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final coachAsync = ref.watch(coachProvider(coachId));
    final reviewsAsync = ref.watch(coachReviewsProvider(coachId));

    return coachAsync.when(
      data: (coach) => _CoachDetailContent(
        coach: coach,
        reviewsAsync: reviewsAsync,
        isDark: isDark,
        ref: ref,
      ),
      loading: () => _DetailLoading(isDark: isDark),
      error: (e, _) => _DetailError(isDark: isDark, error: e.toString()),
    );
  }
}

class _CoachDetailContent extends StatelessWidget {
  final CoachModel coach;
  final AsyncValue<List> reviewsAsync;
  final bool isDark;
  final WidgetRef ref;

  const _CoachDetailContent({
    required this.coach,
    required this.reviewsAsync,
    required this.isDark,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final initials = coach.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final bgColor = isDark ? AppColors.background : AppColors.lightBackground;
    final surfaceColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final currentUserId = ref.watch(authStateProvider).value?.uid;
    final canReview = currentUserId != null && coach.coachId != currentUserId;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          if (context.isPhone)
            PageHero(title: coach.name, showPhoneHeader: true)
          else
            SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primaryLight,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(SpacingScale.s20, 60, SpacingScale.s20, SpacingScale.s20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: AppRadius.brXl3,
                                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                              ),
                              child: Center(
                                child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 24)),
                              ),
                            ),
                            const SizedBox(width: SpacingScale.s16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(coach.name, style: AppTextStyles.heading3.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                                      ),
                                      if (coach.isVerified)
                                        const Icon(Icons.verified_rounded, color: AppColors.successLight, size: 20),
                                    ],
                                  ),
                                  const SizedBox(height: SpacingScale.s4),
                                  Text(coach.specialization ?? 'General Coach', style: AppTextStyles.body.copyWith(color: Colors.white70)),
                                  const SizedBox(height: SpacingScale.s4),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on_rounded, size: 14, color: Colors.white60),
                                      const SizedBox(width: SpacingScale.s4),
                                      Flexible(child: Text(coach.city ?? 'Remote', style: AppTextStyles.caption.copyWith(color: Colors.white60), overflow: TextOverflow.ellipsis)),
                                      const SizedBox(width: SpacingScale.s12),
                                      Icon(Icons.star_rounded, size: 14, color: AppColors.gold),
                                      const SizedBox(width: SpacingScale.s4),
                                      Text(coach.rating.toStringAsFixed(1), style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                                      Text(' (${coach.totalReviews})', style: AppTextStyles.caption.copyWith(color: Colors.white60)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(SpacingScale.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsRow(coach, textSecondary, textPrimary),
                  const SizedBox(height: SpacingScale.s20),
                  if (coach.bio != null && coach.bio!.isNotEmpty) ...[
                    Text('About', style: AppTextStyles.title2.copyWith(fontWeight: FontWeight.w700, color: textPrimary)),
                    const SizedBox(height: SpacingScale.s8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(SpacingScale.s16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.card : AppColors.lightCard,
                        borderRadius: AppRadius.brXl2,
                        border: Border.all(color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5)),
                      ),
                      child: Text(coach.bio!, style: AppTextStyles.body.copyWith(color: textSecondary, height: 1.7)),
                    ),
                    const SizedBox(height: SpacingScale.s20),
                  ],
                  if (coach.certificates != null && coach.certificates!.isNotEmpty) ...[
                    Text('Certificates', style: AppTextStyles.title2.copyWith(fontWeight: FontWeight.w700, color: textPrimary)),
                    const SizedBox(height: SpacingScale.s8),
                    ...coach.certificates!.map((cert) => Padding(
                      padding: const EdgeInsets.only(bottom: SpacingScale.s6),
                      child: Row(
                        children: [
                          Icon(Icons.verified_rounded, size: 16, color: AppColors.success),
                          const SizedBox(width: SpacingScale.s8),
                          Expanded(child: Text(cert, style: AppTextStyles.body.copyWith(color: textSecondary))),
                        ],
                      ),
                    )),
                    const SizedBox(height: SpacingScale.s16),
                  ],
                  // Upcoming Masterclasses & Group Clinics created by Coach
                  ref.watch(typedCoachSessionsProvider(coach.coachId)).when(
                    data: (sessions) {
                      final upcoming = sessions.where((s) => s.dateTime.isAfter(DateTime.now().subtract(const Duration(hours: 2)))).toList();
                      if (upcoming.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.sports_score_rounded, color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Upcoming Clinics & Masterclasses',
                                style: AppTextStyles.title2.copyWith(fontWeight: FontWeight.w700, color: textPrimary),
                              ),
                            ],
                          ),
                          const SizedBox(height: SpacingScale.s10),
                          for (final session in upcoming)
                            Container(
                              margin: const EdgeInsets.only(bottom: SpacingScale.s10),
                              padding: const EdgeInsets.all(SpacingScale.s12),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.card : AppColors.lightCard,
                                borderRadius: AppRadius.brXl,
                                border: Border.all(color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          session.title != null && session.title!.isNotEmpty ? session.title! : '${session.sport} Clinic',
                                          style: AppTextStyles.title3.copyWith(fontWeight: FontWeight.w700, color: textPrimary),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${session.sport} • ${DateFormat('EEE, MMM d • h:mm a').format(session.dateTime)}',
                                          style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                                        ),
                                        if (session.venueName != null && session.venueName!.isNotEmpty)
                                          Text(
                                            '📍 ${session.venueName}',
                                            style: AppTextStyles.captionXs.copyWith(color: textSecondary),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '₹${session.amount.toInt()}',
                                        style: AppTextStyles.title3.copyWith(fontWeight: FontWeight.w800, color: AppColors.emerald),
                                      ),
                                      const SizedBox(height: 4),
                                      ElevatedButton(
                                        onPressed: () => context.push('/booking', extra: coach),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: const Color(0xFF0F172A),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                                        ),
                                        child: const Text('Book Spot', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: SpacingScale.s20),
                        ],
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (e, s) => const SizedBox.shrink(),
                  ),
                  _TrainingCurriculumSection(
                    coach: coach,
                    isDark: isDark,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Reviews', style: AppTextStyles.title2.copyWith(fontWeight: FontWeight.w700, color: textPrimary)),
                      if (canReview)
                        TextButton.icon(
                          onPressed: () => _openReviewComposer(context),
                          icon: const Icon(Icons.edit_rounded, size: 16),
                          label: const Text('Write a review'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            textStyle: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w600),
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        )
                      else
                        Text('${coach.totalReviews} reviews', style: AppTextStyles.bodySm.copyWith(color: textSecondary)),
                    ],
                  ),
                  const SizedBox(height: SpacingScale.s12),
                  reviewsAsync.when(
                    data: (reviews) {
                      if (reviews.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(SpacingScale.s24),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.card : AppColors.lightCard,
                            borderRadius: AppRadius.brXl2,
                            border: Border.all(color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5)),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.rate_review_outlined, size: 40, color: textSecondary.withValues(alpha: 0.5)),
                              const SizedBox(height: SpacingScale.s8),
                              Text('No reviews yet', style: AppTextStyles.body.copyWith(color: textSecondary)),
                            ],
                          ),
                        );
                      }
                      return Column(
                        children: reviews.map((review) => _ReviewCard(
                          playerId: review.playerId,
                          playerName: review.playerName,
                          rating: review.rating,
                          comment: review.comment,
                          createdAt: review.createdAt,
                          isDark: isDark,
                        )).toList(),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    error: (e, _) => Text('Failed to load reviews', style: AppTextStyles.bodySm.copyWith(color: AppColors.danger)),
                  ),
                  const SizedBox(height: SpacingScale.s24),
                  _AvailabilitySection(coach: coach),
                  const SizedBox(height: SpacingScale.s8),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(SpacingScale.s16, SpacingScale.s12, SpacingScale.s16, MediaQuery.of(context).padding.bottom + SpacingScale.s12),
        decoration: BoxDecoration(
          color: surfaceColor,
          border: Border(top: BorderSide(color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5))),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('₹${coach.hourlyRate.toInt()}/hr', style: AppTextStyles.title1.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                  Text('per session', style: AppTextStyles.caption.copyWith(color: textSecondary)),
                ],
              ),
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
              label: const Text('Chat'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
              ),
              onPressed: () async {
                final user = ref.read(authStateProvider).value;
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please log in to chat with this coach.')),
                  );
                  return;
                }
                final chatId = await ref.read(chatServiceProvider).getOrCreateDirectChat(
                  user.uid,
                  coach.coachId,
                  starterMessage: 'Hi Coach ${coach.name}, I am interested in training sessions for ${coach.specialization ?? "coaching"}.',
                  starterSenderId: user.uid,
                );
                if (context.mounted) {
                  context.push('/chat/$chatId');
                }
              },
            ),
            const SizedBox(width: SpacingScale.s8),
            PrimaryButton(
              label: 'Book Session',
              icon: Icons.calendar_today_rounded,
              onPressed: () => context.push('/booking', extra: coach),
              expanded: false,
            ),
          ],
        ),
      ),
    );
  }

  void _openReviewComposer(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReviewComposer(coach: coach),
    );
  }

  Widget _buildStatsRow(CoachModel coach, Color textSecondary, Color textPrimary) {
    return Row(
      children: [
        _buildStatItem(Icons.work_rounded, '${coach.experience}', 'Years Exp', textSecondary, textPrimary),
        _buildDivider(),
        _buildStatItem(Icons.people_rounded, '${coach.totalReviews}', 'Students', textSecondary, textPrimary),
        _buildDivider(),
        _buildStatItem(Icons.sports_rounded, coach.specialization ?? 'General', 'Sport', textSecondary, textPrimary),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color textSecondary, Color textPrimary) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: SpacingScale.s4),
          Text(value, style: AppTextStyles.title2.copyWith(fontWeight: FontWeight.w700, color: textPrimary)),
          Text(label, style: AppTextStyles.caption.copyWith(color: textSecondary)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 40, color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5));
  }

}

class _ReviewCard extends StatelessWidget {
  final String playerId;
  final String playerName;
  final double rating;
  final String comment;
  final DateTime? createdAt;
  final bool isDark;

  const _ReviewCard({
    required this.playerId,
    required this.playerName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final initials = playerName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
    final dateStr = createdAt != null ? DateFormat('MMM d, yyyy').format(createdAt!) : '';

    return Container(
      margin: const EdgeInsets.only(bottom: SpacingScale.s8),
      padding: const EdgeInsets.all(SpacingScale.s12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl2,
        border: Border.all(color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              if (playerId.isNotEmpty) {
                context.push('/profile/$playerId');
              }
            },
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: AppRadius.brFull,
              ),
              child: Center(child: Text(initials, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12))),
            ),
          ),
          const SizedBox(width: SpacingScale.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (playerId.isNotEmpty) {
                            context.push('/profile/$playerId');
                          }
                        },
                        child: Text(playerName, style: AppTextStyles.title3.copyWith(fontWeight: FontWeight.w600, color: textPrimary)),
                      ),
                    ),
                    if (dateStr.isNotEmpty)
                      Text(dateStr, style: AppTextStyles.caption.copyWith(color: textSecondary)),
                  ],
                ),
                const SizedBox(height: SpacingScale.s4),
                Row(
                  children: List.generate(5, (i) => Icon(
                    i < rating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 14, color: i < rating.round() ? AppColors.gold : AppColors.textTertiary,
                  )),
                ),
                const SizedBox(height: SpacingScale.s6),
                Text(comment, style: AppTextStyles.body.copyWith(color: textSecondary, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailabilitySection extends ConsumerStatefulWidget {
  const _AvailabilitySection({required this.coach});

  final CoachModel coach;

  @override
  ConsumerState<_AvailabilitySection> createState() => _AvailabilitySectionState();
}

class _AvailabilitySectionState extends ConsumerState<_AvailabilitySection> {
  DateTime? _selectedDate;

  DateTime? _firstFutureDate(Set<DateTime> dates) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final upcoming = dates.where((d) => !d.isBefore(today)).toList()..sort();
    return upcoming.isEmpty ? null : upcoming.first;
  }

  Widget _slotChip(String slot, bool isDark) {
    final parts = slot.split(':');
    final hour = int.tryParse(parts.firstOrNull ?? '') ?? 0;
    final minute = parts.length > 1 ? parts[1] : '00';
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final label = '${displayHour.toString().padLeft(2, '0')}:$minute $period';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s12, vertical: SpacingScale.s8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brLg,
        border: Border.all(color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: AppTextStyles.button.copyWith(
          color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _emptyCard(bool isDark, Color textSecondary, String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SpacingScale.s24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl2,
        border: Border.all(color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy_rounded, size: 32, color: textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: SpacingScale.s8),
          Text(title, style: AppTextStyles.body.copyWith(color: textSecondary)),
          const SizedBox(height: SpacingScale.s4),
          Text(subtitle, style: AppTextStyles.caption.copyWith(color: textSecondary)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    final datesAsync = ref.watch(availableDatesProvider((coachId: widget.coach.coachId, monthsAhead: 1)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Availability', style: AppTextStyles.title2.copyWith(fontWeight: FontWeight.w700, color: textPrimary)),
        const SizedBox(height: SpacingScale.s4),
        Text('Check free slots before booking a session', style: AppTextStyles.bodySm.copyWith(color: textSecondary)),
        const SizedBox(height: SpacingScale.s12),
        datesAsync.when(
          data: (dates) {
            final effectiveDate = (_selectedDate != null && dates.any((d) => DateUtils.isSameDay(d, _selectedDate!)))
                ? _selectedDate
                : _firstFutureDate(dates);

            if (effectiveDate == null) {
              return _emptyCard(
                isDark,
                textSecondary,
                'No availability published yet',
                'Ask the coach to add their free slots',
              );
            }

            final slotAsync = ref.watch(availableTimeSlotsProvider((coachId: widget.coach.coachId, date: effectiveDate)));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(SpacingScale.s16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.card : AppColors.lightCard,
                    borderRadius: AppRadius.brXl2,
                    border: Border.all(color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5)),
                  ),
                  child: AvailabilityCalendar(
                    selectedDate: effectiveDate,
                    availableDates: dates,
                    onDateSelected: (date) => setState(() => _selectedDate = date),
                  ),
                ),
                const SizedBox(height: SpacingScale.s16),
                Text(
                  'Slots for ${DateFormat('EEE, MMM d').format(effectiveDate)}',
                  style: AppTextStyles.title3.copyWith(fontWeight: FontWeight.w600, color: textPrimary),
                ),
                const SizedBox(height: SpacingScale.s8),
                slotAsync.when(
                  data: (slots) {
                    final displaySlots = slots.isNotEmpty ? slots : AvailabilityService.defaultSlots;
                    return Wrap(
                      spacing: SpacingScale.s8,
                      runSpacing: SpacingScale.s8,
                      children: displaySlots.map((slot) => _slotChip(slot, isDark)).toList(),
                    );
                  },
                  loading: () => Wrap(
                    spacing: SpacingScale.s8,
                    runSpacing: SpacingScale.s8,
                    children: AvailabilityService.defaultSlots.map((slot) => _slotChip(slot, isDark)).toList(),
                  ),
                  error: (e, _) => Wrap(
                    spacing: SpacingScale.s8,
                    runSpacing: SpacingScale.s8,
                    children: AvailabilityService.defaultSlots.map((slot) => _slotChip(slot, isDark)).toList(),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) => Text('Could not load availability', style: AppTextStyles.bodySm.copyWith(color: AppColors.danger)),
        ),
      ],
    );
  }
}

class _ReviewComposer extends ConsumerStatefulWidget {
  const _ReviewComposer({required this.coach});

  final CoachModel coach;

  @override
  ConsumerState<_ReviewComposer> createState() => _ReviewComposerState();
}

class _ReviewComposerState extends ConsumerState<_ReviewComposer> {
  final _commentCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  double _rating = 0;
  bool _submitting = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a star rating'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
        ),
      );
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    setState(() => _submitting = true);
    try {
      await ref.read(reviewServiceProvider).addReview(
        coachId: widget.coach.coachId,
        playerId: user.uid,
        playerName: (user.displayName?.trim().isNotEmpty ?? false)
            ? user.displayName!.trim()
            : 'Anonymous Player',
        playerPhotoUrl: user.photoURL,
        rating: _rating,
        comment: _commentCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Review submitted!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit review: $e'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
      padding: EdgeInsets.only(
        left: SpacingScale.s16,
        right: SpacingScale.s16,
        top: SpacingScale.s12,
        bottom: MediaQuery.of(context).viewInsets.bottom + SpacingScale.s16,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        borderRadius: AppRadius.top(AppRadius.xl2),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: SpacingScale.s16),
              Text('Rate ${widget.coach.name}',
                  style: AppTextStyles.title1.copyWith(fontWeight: FontWeight.w700, color: textPrimary)),
              const SizedBox(height: SpacingScale.s4),
              Text('Share your experience to help others choose',
                  style: AppTextStyles.bodySm.copyWith(color: textSecondary)),
              const SizedBox(height: SpacingScale.s12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final index = i + 1;
                  final active = index <= _rating.round();
                  return IconButton(
                    onPressed: () => setState(() => _rating = index.toDouble()),
                    icon: Icon(
                      active ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 36,
                      color: active ? AppColors.gold : AppColors.textTertiary,
                    ),
                  );
                }),
              ),
              const SizedBox(height: SpacingScale.s8),
              TextFormField(
                controller: _commentCtrl,
                maxLines: 4,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'Your review',
                  hintText: 'What did you like about this coach?',
                  alignLabelWithHint: true,
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please write a short review' : null,
              ),
              const SizedBox(height: SpacingScale.s8),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Submit Review',
                  icon: Icons.send_rounded,
                  loading: _submitting,
                  onPressed: _submitting ? null : _submit,
                  expanded: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailLoading extends StatelessWidget {
  final bool isDark;
  const _DetailLoading({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
      body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }
}

class _DetailError extends StatelessWidget {
  final bool isDark;
  final String error;
  const _DetailError({required this.isDark, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(SpacingScale.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_rounded, size: 64, color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
              const SizedBox(height: SpacingScale.s16),
              Text('Something went wrong', style: AppTextStyles.title2.copyWith(color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary)),
              const SizedBox(height: SpacingScale.s8),
              Text(error, style: AppTextStyles.bodySm.copyWith(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}


class _TrainingCurriculumSection extends StatelessWidget {
  final CoachModel coach;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;

  const _TrainingCurriculumSection({
    required this.coach,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final routines = coach.routines;
    final cardBg = isDark ? AppColors.card : AppColors.lightCard;
    final borderColor = (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: AppRadius.brSm,
                        ),
                        child: const Icon(Icons.fitness_center_rounded, size: 16, color: AppColors.primary),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Training Curriculum & Routines',
                          style: AppTextStyles.title2.copyWith(fontWeight: FontWeight.w700, color: textPrimary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Standardized routines with 100% KRICO XP progression',
                    style: AppTextStyles.caption.copyWith(color: textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: SpacingScale.s12),
        Container(
          padding: const EdgeInsets.all(SpacingScale.s12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xF1131D31) : const Color(0xFF1F5F:),
            borderRadius: AppRadius.brLg,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.stars_rounded, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Every session awards up to 25 XP (scaling up to 45 XP as player level increases). Sub-routine XP is earned based on verified completed progress during session checkout.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: isDark ? const Color(0xF94A3B8) : const Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: SpacingScale.s12),
        if (routines.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(SpacingScale.s16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: AppRadius.brXl,
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.sports_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        coach.specialization + ' Standard Training Framework',
                        style: AppTextStyles.title3.copyWith(fontWeight: FontWeight.sw700, color: textPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'This coach structures bookings into standardized sub-routines (Warm-Up, Technical Drills, High-Intensity Match Scenarios, & Tactical Assessment) with 100% total XP distribution.',
                  style: AppTextStyles.bodySm.copyWith(color: textSecondary, height: 1.4),
                ),
              ],
            ),
          )
        else
          for (final routine in routines)
            Container(
              margin: const EdgeInsets.only(bottom: SpacingScale.s12),
              padding: const EdgeInsets.all(SpacingScale.s16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: AppRadius.brXl,
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          routine.name,
                          style: AppTextStyles.title3.copyWith(fontWeight: FontWeight.w700, color: textPrimary),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: AppRadius.brSm,
                        ),
                        child: Text(
                          routine.sport,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (routine.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      routine.description,
                      style: AppTextStyles.bodySm.copyWith(color: textSecondary),
                    ),
                  ],
                  const SizedBox(height: SpacingScale.s12),
                  const Divider(height: 1),
                  const SizedBox(height: SpacingScale.s8),
                  Text(
                    'SUB-ROUTINES �� XP BREAKDOWN',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: SpacingScale.s8),
                  for (final sub in routine.subRoutines)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0x0F172A) : const Color(0xF8FAFC),
                        borderRadius: AppRadius.brMd,
                        border: Border.all(
                          color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              sub.percentageAllocation.toString() + '% XP',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0x0F172A),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sub.name,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                  ),
                                ),
                                if (sub.description.isNotEmpty)
                                  Text(
                                    sub.description,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: textSecondary,
                                    ),
                                  ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    if (sub.completionCriteria.isNotEmpty)
                                      Expanded(
                                        child: Text(
                                          'Criteria: ' + sub.completionCriteria,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.sw700,
                                            color: AppColors.primary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    if (sub.progressTrackingField.isNotEmpty)
                                      Text(
                                        'Metric: ' + sub.progressTrackingField,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: textSecondary,
                                        ),
                                     ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        const SizedBox(height: SpacingScale.s20),
      ],
    );
  }
}
