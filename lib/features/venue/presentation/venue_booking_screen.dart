import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/app_router.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../design_system/radius/radius.dart';
import '../../../design_system/widgets/page_headers/page_hero.dart';
import '../../../design_system/widgets/buttons/primary_button.dart';
import '../../../models/venue_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/providers.dart';
import '../../booking/presentation/widgets/availability_calendar.dart';
import '../../booking/presentation/widgets/time_slot_picker.dart';

class VenueBookingScreen extends ConsumerStatefulWidget {
  const VenueBookingScreen({super.key, required this.venueId});

  final String venueId;

  @override
  ConsumerState<VenueBookingScreen> createState() => _VenueBookingScreenState();
}

class _VenueBookingScreenState extends ConsumerState<VenueBookingScreen> {
  int _currentStep = 0;
  DateTime? _selectedDate;
  String? _selectedSlot;
  bool _isSubmitting = false;
  bool _splitWithTeam = false;
  int _squadSize = 4;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.background : AppColors.lightBackground;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final venueAsync = ref.watch(venueProvider(widget.venueId));

    return Scaffold(
      backgroundColor: bgColor,
      body: venueAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: AppColors.danger),
              const SizedBox(height: SpacingScale.s16),
              Text('Failed to load venue', style: AppTextStyles.bodyLg.copyWith(color: textSecondary)),
              const SizedBox(height: SpacingScale.s12),
              GestureDetector(
                onTap: () => ref.invalidate(venueProvider(widget.venueId)),
                child: Text('Retry', style: AppTextStyles.button.copyWith(color: AppColors.primary)),
              ),
            ],
          ),
        ),
        data: (venue) => _currentStep == 3
            ? _buildConfirmation(venue, isDark, textPrimary, textSecondary)
            : _buildBookingForm(venue, isDark, textPrimary, textSecondary, bgColor),
      ),
    );
  }

  Widget _buildBookingForm(VenueModel venue, bool isDark, Color textPrimary, Color textSecondary, Color bgColor) {
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              PageHero(
                title: 'Book ${venue.name}',
                phoneTitle: 'Book Venue',
                showPhoneHeader: true,
                expandedHeight: 140,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(SpacingScale.s16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStepIndicator(isDark, textPrimary, textSecondary),
                      const SizedBox(height: SpacingScale.s20),
                      if (_currentStep == 0) _buildDateStep(venue, isDark, textPrimary, textSecondary),
                      if (_currentStep == 1) _buildTimeStep(venue, isDark, textPrimary, textSecondary),
                      if (_currentStep == 2) _buildReviewStep(venue, isDark, textPrimary, textSecondary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildBottomBar(isDark, textPrimary),
      ],
    );
  }

  Widget _buildStepIndicator(bool isDark, Color textPrimary, Color textSecondary) {
    return Row(
      children: List.generate(3, (i) {
        final isActive = i == _currentStep;
        final isDone = i < _currentStep;
        return Expanded(
          child: Row(
            children: [
              if (i > 0)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isDone ? AppColors.primary : (isDark ? AppColors.border : AppColors.lightBorder),
                  ),
                ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDone || isActive ? AppColors.primary : (isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                      : Text('${i + 1}', style: AppTextStyles.buttonSm.copyWith(
                          color: isActive ? Colors.white : textSecondary,
                          fontWeight: FontWeight.w700,
                        )),
                ),
              ),
              if (i < 2)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isActive || isDone ? AppColors.primary : (isDark ? AppColors.border : AppColors.lightBorder),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDateStep(VenueModel venue, bool isDark, Color textPrimary, Color textSecondary) {
    final now = DateTime.now();
    final availableDates = <DateTime>{
      for (int i = 1; i <= 60; i++)
        DateTime(now.year, now.month, now.day + i),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select a Date', style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.w700, color: textPrimary)),
        const SizedBox(height: SpacingScale.s4),
        Text('Choose a date to book ${venue.name}', style: AppTextStyles.body.copyWith(color: textSecondary)),
        const SizedBox(height: SpacingScale.s20),
        Container(
          padding: const EdgeInsets.all(SpacingScale.s16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.card : AppColors.lightCard,
            borderRadius: AppRadius.brXl3,
            border: Border.all(color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5)),
          ),
          child: AvailabilityCalendar(
            selectedDate: _selectedDate ?? DateTime.now(),
            availableDates: availableDates,
            onDateSelected: (date) => setState(() {
              _selectedDate = date;
              _selectedSlot = null;
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeStep(VenueModel venue, bool isDark, Color textPrimary, Color textSecondary) {
    final date = _selectedDate;
    final slots = <String>[];
    if (date != null) {
      final booked = ref.watch(venueBookedSlotsProvider((venueId: venue.venueId, dateKey: _dateKey(date))));
      final now = DateTime.now();
      final isToday = DateUtils.isSameDay(date, now);
      slots.addAll(
        VenueTimeSlot.slots
            .where((s) => !booked.contains(s.startTime))
            .where((s) => !(isToday && _isSlotPast(s.startTime, now)))
            .map((s) => s.startTime),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select a Time', style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.w700, color: textPrimary)),
        const SizedBox(height: SpacingScale.s4),
        Text('Pick an available time slot', style: AppTextStyles.body.copyWith(color: textSecondary)),
        const SizedBox(height: SpacingScale.s20),
        TimeSlotPicker(
          availableSlots: slots,
          selectedSlot: _selectedSlot,
          onSlotSelected: (slot) => setState(() => _selectedSlot = slot),
        ),
      ],
    );
  }

  Widget _buildReviewStep(VenueModel venue, bool isDark, Color textPrimary, Color textSecondary) {
    final slot = _selectedSlot != null
        ? VenueTimeSlot.slots.where((s) => s.startTime == _selectedSlot).firstOrNull
        : null;
    final amount = slot?.price.toDouble() ?? venue.pricePerHour ?? 0;
    final total = amount + amount * 0.10;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Review & Confirm', style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.w700, color: textPrimary)),
        const SizedBox(height: SpacingScale.s4),
        Text('Please review your booking details', style: AppTextStyles.body.copyWith(color: textSecondary)),
        const SizedBox(height: SpacingScale.s20),
        Container(
          padding: const EdgeInsets.all(SpacingScale.s16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.card : AppColors.lightCard,
            borderRadius: AppRadius.brXl3,
            border: Border.all(color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              _buildReviewRow(Icons.stadium_rounded, 'Venue', venue.name, textPrimary, textSecondary),
              const Divider(height: SpacingScale.s24),
              _buildReviewRow(Icons.sports_rounded, 'Sport', venue.sports?.join(', ') ?? 'Multi-sport', textPrimary, textSecondary),
              const Divider(height: SpacingScale.s24),
              _buildReviewRow(Icons.calendar_today_rounded, 'Date', _selectedDate != null ? _formatDate(_selectedDate!) : '-', textPrimary, textSecondary),
              const Divider(height: SpacingScale.s24),
              _buildReviewRow(Icons.access_time_rounded, 'Time', slot?.displayLabel ?? '-', textPrimary, textSecondary),
              const Divider(height: SpacingScale.s24),
              _buildReviewRow(Icons.currency_rupee_rounded, 'Amount', '₹${amount.toInt()}', textPrimary, textSecondary),
              const Divider(height: SpacingScale.s24),
              _buildReviewRow(Icons.receipt_rounded, 'Platform Fee', '₹${(amount * 0.10).toInt()}', textPrimary, textSecondary),
              const Divider(height: SpacingScale.s24),
              _buildReviewRow(Icons.account_balance_wallet_rounded, 'Total', '₹${total.toInt()}', AppColors.primary, textSecondary),
            ],
          ),
        ),
        const SizedBox(height: SpacingScale.s16),
        // Split Court Cost Card
        Container(
          padding: const EdgeInsets.all(SpacingScale.s16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131D31) : Colors.white,
            borderRadius: AppRadius.brXl2,
            border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.group_add_rounded, color: Color(0xFF00E5FF), size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Split Court Cost with Squad', style: TextStyle(fontWeight: FontWeight.w800, color: textPrimary, fontSize: 14)),
                        Text('Invite friends to pay their share via shareable pass link', style: TextStyle(color: textSecondary, fontSize: 11)),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _splitWithTeam,
                    activeTrackColor: const Color(0xFFCCFF00),
                    onChanged: (val) => setState(() => _splitWithTeam = val),
                  ),
                ],
              ),
              if (_splitWithTeam) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Squad Size:', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 12)),
                    Row(
                      children: [2, 4, 6, 10].map((count) {
                        final isSel = _squadSize == count;
                        return Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: ChoiceChip(
                            label: Text('$count players', style: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.w800 : FontWeight.w600, color: isSel ? Colors.black : textPrimary)),
                            selected: isSel,
                            selectedColor: const Color(0xFFCCFF00),
                            onSelected: (_) => setState(() => _squadSize = count),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.share_rounded, size: 16, color: Color(0xFF00E5FF)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your Share: ₹${(total / _squadSize).ceil()} \u2022 Match Invite Link will be generated upon confirmation',
                          style: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.w700, fontSize: 11.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: SpacingScale.s12),
        // All-Weather Guarantee Banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('All-Weather & Rainout Guarantee', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w800, fontSize: 12)),
                    Text(
                      'If unplayable due to rain, waterlogging, or power cuts, 100% instant refund or 14-day free reschedule pass is guaranteed from platform escrow.',
                      style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRow(IconData icon, String label, String value, Color textPrimary, Color textSecondary) {
    return Row(
      children: [
        Icon(icon, size: 18, color: textSecondary),
        const SizedBox(width: SpacingScale.s10),
        Expanded(
          child: Text(label, style: AppTextStyles.body.copyWith(color: textSecondary)),
        ),
        Text(value, style: AppTextStyles.title3.copyWith(fontWeight: FontWeight.w600, color: textPrimary)),
      ],
    );
  }

  Widget _buildBottomBar(bool isDark, Color textPrimary) {
    return Container(
      padding: EdgeInsets.fromLTRB(SpacingScale.s16, SpacingScale.s12, SpacingScale.s16, MediaQuery.of(context).padding.bottom + SpacingScale.s12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        border: Border(top: BorderSide(color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5))),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : () => setState(() => _currentStep--),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: SpacingScale.s12),
                  side: BorderSide(color: isDark ? AppColors.border : AppColors.lightBorder),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                ),
                child: Text('Back', style: AppTextStyles.button.copyWith(color: textPrimary)),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: SpacingScale.s12),
          Expanded(
            flex: 2,
            child: PrimaryButton(
              label: _currentStep == 2 ? 'Confirm Booking' : 'Continue',
              icon: _currentStep == 2 ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
              onPressed: _currentStep == 2 ? _confirmBooking : _nextStep,
              loading: _isSubmitting,
              expanded: true,
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep == 0 && _selectedDate == null) {
      _showSnack('Please select a date', AppColors.warning);
      return;
    }
    if (_currentStep == 1 && _selectedSlot == null) {
      _showSnack('Please select a time slot', AppColors.warning);
      return;
    }
    setState(() => _currentStep++);
  }

  Future<void> _confirmBooking() async {
    final venue = ref.read(venueProvider(widget.venueId)).value;
    final date = _selectedDate;
    final slotStart = _selectedSlot;
    if (venue == null || date == null || slotStart == null) return;

    final authService = ref.read(authServiceProvider);
    final userId = authService.currentUser?.uid;
    if (userId == null) {
      _showSnack('Please sign in first', AppColors.warning);
      return;
    }

    final slot = VenueTimeSlot.slots.where((s) => s.startTime == slotStart).firstOrNull;
    final amount = slot?.price.toDouble() ?? venue.pricePerHour ?? 0;

    setState(() => _isSubmitting = true);
    try {
      final profile = await authService.getUserProfile(userId);
      final userName = (profile?.username ?? '').trim().isNotEmpty ? profile!.username : 'Player';
      await ref.read(venueServiceProvider).createVenueBooking(
        venueId: venue.venueId,
        venueName: venue.name,
        userId: userId,
        userName: userName,
        date: date,
        startTime: slotStart,
        amount: amount,
      );
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _currentStep = 3;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showSnack('Booking failed: $e', AppColors.danger);
    }
  }

  Widget _buildConfirmation(VenueModel venue, bool isDark, Color textPrimary, Color textSecondary) {
    final slot = _selectedSlot != null
        ? VenueTimeSlot.slots.where((s) => s.startTime == _selectedSlot).firstOrNull
        : null;
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              PageHero(
                title: 'Booking Confirmed',
                showPhoneHeader: true,
                expandedHeight: 140,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(SpacingScale.s24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: Image.asset(
                          'assets/animations/success_check.gif',
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check_circle_rounded, size: 48, color: AppColors.success),
                          ),
                        ),
                      ),
                      const SizedBox(height: SpacingScale.s24),
                      Text('Your booking at ${venue.name} has been confirmed', style: AppTextStyles.body.copyWith(color: textSecondary), textAlign: TextAlign.center),
                      const SizedBox(height: SpacingScale.s24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(SpacingScale.s16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.card : AppColors.lightCard,
                          borderRadius: AppRadius.brXl3,
                          border: Border.all(color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          children: [
                            _buildReviewRow(Icons.calendar_today_rounded, 'Date', _selectedDate != null ? _formatDate(_selectedDate!) : '-', textPrimary, textSecondary),
                            const Divider(height: SpacingScale.s24),
                            _buildReviewRow(Icons.access_time_rounded, 'Time', slot?.displayLabel ?? '-', textPrimary, textSecondary),
                          ],
                        ),
                      ),
                      const SizedBox(height: SpacingScale.s32),
                      PrimaryButton(
                        label: 'Back to Venue',
                        icon: Icons.stadium_rounded,
                        onPressed: () => context.pop(),
                        expanded: true,
                      ),
                      const SizedBox(height: SpacingScale.s12),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.home),
                        child: Text('Back to Home', style: AppTextStyles.button.copyWith(color: textSecondary)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
    ));
  }

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  bool _isSlotPast(String startTime, DateTime now) {
    final parts = startTime.split(':');
    if (parts.length != 2) return false;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    if (now.hour != hour) return now.hour > hour;
    return now.minute >= minute;
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
