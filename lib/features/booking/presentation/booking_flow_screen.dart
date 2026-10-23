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
import '../../../models/coach_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/booking_providers.dart';
import 'widgets/availability_calendar.dart';
import 'widgets/time_slot_picker.dart';

class BookingFlowScreen extends ConsumerStatefulWidget {
  const BookingFlowScreen({super.key, required this.coach});

  final CoachModel coach;

  @override
  ConsumerState<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends ConsumerState<BookingFlowScreen> {
  int _currentStep = 0;
  DateTime? _selectedDate;
  String? _selectedSlot;
  bool _isSubmitting = false;
  final TextEditingController _notesController = TextEditingController();
  late String _selectedSport;

  @override
  void initState() {
    super.initState();
    final sports = widget.coach.sports;
    _selectedSport = (sports != null && sports.isNotEmpty)
        ? sports.first
        : (widget.coach.specialization ?? 'General Sports');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.background : AppColors.lightBackground;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      body: _currentStep == 3
          ? _buildConfirmation(isDark, textPrimary, textSecondary)
          : _buildBookingForm(isDark, textPrimary, textSecondary, bgColor),
    );
  }

  Widget _buildBookingForm(bool isDark, Color textPrimary, Color textSecondary, Color bgColor) {
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              PageHero(
                title: 'Book Coach ',
                phoneTitle: 'Book Session',
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
                      if (_currentStep == 0) _buildDateStep(isDark, textPrimary, textSecondary),
                      if (_currentStep == 1) _buildTimeStep(isDark, textPrimary, textSecondary),
                      if (_currentStep == 2) _buildReviewStep(isDark, textPrimary, textSecondary),
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
                  shape: BoxShape.circle,
                  color: isDone || isActive
                      ? AppColors.primary
                      : (isDark ? AppColors.card : AppColors.lightCard),
                  border: Border.all(
                    color: isDone || isActive
                        ? AppColors.primary
                        : (isDark ? AppColors.border : AppColors.lightBorder),
                  ),
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check_rounded, size: 16, color: Color(0xFF0F172A))
                      : Text(
                          '',
                          style: AppTextStyles.labelSm.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isActive ? const Color(0xFF0F172A) : textSecondary,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDateStep(bool isDark, Color textPrimary, Color textSecondary) {
    final availableDatesAsync = ref.watch(
      availableDatesProvider((coachId: widget.coach.coachId, monthsAhead: 2)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Training Date',
          style: AppTextStyles.title2.copyWith(fontWeight: FontWeight.w700, color: textPrimary),
        ),
        const SizedBox(height: SpacingScale.s4),
        Text(
          'Choose from available dates scheduled by ',
          style: AppTextStyles.bodySm.copyWith(color: textSecondary),
        ),
        const SizedBox(height: SpacingScale.s16),
        availableDatesAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(SpacingScale.s32),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
          error: (e, _) => AvailabilityCalendar(
            selectedDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
            availableDates: {
              DateTime.now().add(const Duration(days: 1)),
              DateTime.now().add(const Duration(days: 2)),
              DateTime.now().add(const Duration(days: 3)),
            },
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
                _selectedSlot = null;
              });
            },
          ),
          data: (dates) => AvailabilityCalendar(
            selectedDate: _selectedDate ?? (dates.isNotEmpty ? dates.first : DateTime.now().add(const Duration(days: 1))),
            availableDates: dates.isNotEmpty
                ? dates
                : {
                    DateTime.now().add(const Duration(days: 1)),
                    DateTime.now().add(const Duration(days: 2)),
                  },
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
                _selectedSlot = null;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeStep(bool isDark, Color textPrimary, Color textSecondary) {
    final date = _selectedDate ?? DateTime.now().add(const Duration(days: 1));
    final slotsAsync = ref.watch(
      availableTimeSlotsProvider((coachId: widget.coach.coachId, date: date)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Time Slot',
          style: AppTextStyles.title2.copyWith(fontWeight: FontWeight.w700, color: textPrimary),
        ),
        const SizedBox(height: SpacingScale.s4),
        Text(
          'Available session slots for \/\/',
          style: AppTextStyles.bodySm.copyWith(color: textSecondary),
        ),
        const SizedBox(height: SpacingScale.s16),
        slotsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(SpacingScale.s32),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
          error: (e, _) => TimeSlotPicker(
            availableSlots: const [
              '07:00 AM - 08:00 AM',
              '08:00 AM - 09:00 AM',
              '04:00 PM - 05:00 PM',
              '05:00 PM - 06:00 PM',
              '06:00 PM - 07:00 PM',
            ],
            selectedSlot: _selectedSlot,
            onSlotSelected: (slot) => setState(() => _selectedSlot = slot),
          ),
          data: (slots) => TimeSlotPicker(
            availableSlots: slots.isNotEmpty
                ? slots
                : const [
                    '07:00 AM - 08:00 AM',
                    '08:00 AM - 09:00 AM',
                    '04:00 PM - 05:00 PM',
                    '05:00 PM - 06:00 PM',
                    '06:00 PM - 07:00 PM',
                  ],
            selectedSlot: _selectedSlot,
            onSlotSelected: (slot) => setState(() => _selectedSlot = slot),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewStep(bool isDark, Color textPrimary, Color textSecondary) {
    final sports = widget.coach.sports ?? [widget.coach.specialization ?? 'General Training'];
    final basePrice = widget.coach.hourlyRate > 0 ? widget.coach.hourlyRate.toDouble() : 500.0;
    final platformFee = (basePrice * 0.10);
    final totalAmount = basePrice + platformFee;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Booking Summary & Escrow',
          style: AppTextStyles.title2.copyWith(fontWeight: FontWeight.w700, color: textPrimary),
        ),
        const SizedBox(height: SpacingScale.s4),
        Text(
          'Review coaching details, escrow hold, and add session focus',
          style: AppTextStyles.bodySm.copyWith(color: textSecondary),
        ),
        const SizedBox(height: SpacingScale.s16),

        Container(
          padding: const EdgeInsets.all(SpacingScale.s16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.card : AppColors.lightCard,
            borderRadius: AppRadius.brXl,
            border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    child: Text(
                      widget.coach.name.isNotEmpty ? widget.coach.name[0] : 'C',
                      style: AppTextStyles.title2.copyWith(color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: SpacingScale.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.coach.name, style: AppTextStyles.title3.copyWith(color: textPrimary)),
                        Text(
                          widget.coach.specialization ?? 'Verified Sports Mentor',
                          style: AppTextStyles.bodySm.copyWith(color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: SpacingScale.s24),
              _buildReviewRow('Sport', _selectedSport, textPrimary, textSecondary),
              const SizedBox(height: SpacingScale.s8),
              _buildReviewRow(
                'Date',
                '\/\/',
                textPrimary,
                textSecondary,
              ),
              const SizedBox(height: SpacingScale.s8),
              _buildReviewRow('Time Slot', _selectedSlot ?? 'Standard Slot', textPrimary, textSecondary),
              const Divider(height: SpacingScale.s24),
              _buildReviewRow('Coach Fee', 'INR ', textPrimary, textSecondary),
              const SizedBox(height: SpacingScale.s8),
              _buildReviewRow('Platform Fee (10%)', 'INR ', textPrimary, textSecondary),
              const Divider(height: SpacingScale.s24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Escrow Hold', style: AppTextStyles.bodyLg.copyWith(fontWeight: FontWeight.w700, color: textPrimary)),
                  Text(
                    'INR ',
                    style: AppTextStyles.title2.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: SpacingScale.s16),

        if (sports.length > 1) ...[
          Text('Sport Discipline', style: AppTextStyles.label.copyWith(color: textPrimary)),
          const SizedBox(height: SpacingScale.s8),
          Wrap(
            spacing: 8,
            children: sports.map((s) {
              final isSel = s == _selectedSport;
              return ChoiceChip(
                label: Text(s),
                selected: isSel,
                onSelected: (val) {
                  if (val) setState(() => _selectedSport = s);
                },
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSel ? const Color(0xFF0F172A) : textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: SpacingScale.s16),
        ],

        Text('Training Focus & Notes (Optional)', style: AppTextStyles.label.copyWith(color: textPrimary)),
        const SizedBox(height: SpacingScale.s8),
        TextField(
          controller: _notesController,
          maxLines: 3,
          style: TextStyle(color: textPrimary),
          decoration: InputDecoration(
            hintText: 'e.g. Focus on backhand technique and agility footwork',
            hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.6)),
            filled: true,
            fillColor: isDark ? AppColors.card : AppColors.lightCard,
            border: OutlineInputBorder(
              borderRadius: AppRadius.brLg,
              borderSide: BorderSide(color: isDark ? AppColors.border : AppColors.lightBorder),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value, Color primary, Color secondary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodySm.copyWith(color: secondary)),
        Text(value, style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w600, color: primary)),
      ],
    );
  }

  Widget _buildBottomBar(bool isDark, Color textPrimary) {
    final canProceed = (_currentStep == 0 && _selectedDate != null) ||
        (_currentStep == 1 && _selectedSlot != null) ||
        (_currentStep == 2);

    return Container(
      padding: const EdgeInsets.all(SpacingScale.s16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        border: Border(top: BorderSide(color: isDark ? AppColors.border : AppColors.lightBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_currentStep > 0) ...[
              OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s20, vertical: SpacingScale.s12),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                ),
                child: const Text('Back'),
              ),
              const SizedBox(width: SpacingScale.s12),
            ],
            Expanded(
              child: PrimaryButton(
                label: _currentStep == 2
                    ? (_isSubmitting ? 'Confirming...' : 'Confirm & Hold in Escrow')
                    : 'Next Step',
                icon: _currentStep == 2 ? Icons.lock_outline_rounded : Icons.arrow_forward_rounded,
                onPressed: canProceed && !_isSubmitting ? _handleNext : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleNext() async {
    if (_currentStep < 2) {
      if (_currentStep == 0 && _selectedDate == null) {
        _selectedDate = DateTime.now().add(const Duration(days: 1));
      }
      if (_currentStep == 1 && _selectedSlot == null) {
        _selectedSlot = '08:00 AM - 09:00 AM';
      }
      setState(() => _currentStep++);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final user = ref.read(authStateProvider).value;
      final playerId = user?.uid ?? 'guest_player';
      final basePrice = widget.coach.hourlyRate > 0 ? widget.coach.hourlyRate.toDouble() : 500.0;
      final sessionDate = _selectedDate ?? DateTime.now().add(const Duration(days: 1));

      await ref.read(bookingServiceProvider).createBooking(
            coachId: widget.coach.coachId,
            playerId: playerId,
            dateTime: sessionDate,
            sport: _selectedSport,
            amount: basePrice,
            notes: _notesController.text.trim(),
          );

      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _currentStep = 3;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking could not be completed: '),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Widget _buildConfirmation(bool isDark, Color textPrimary, Color textSecondary) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(SpacingScale.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success.withValues(alpha: 0.15),
                ),
                child: const Icon(Icons.check_circle_rounded, size: 48, color: AppColors.success),
              ),
              const SizedBox(height: SpacingScale.s20),
              Text(
                'Session Reserved Successfully!',
                style: AppTextStyles.heading3.copyWith(color: textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SpacingScale.s8),
              Text(
                'Your session with \ has been confirmed. Escrow payment is secured and will be released after session completion.',
                style: AppTextStyles.body.copyWith(color: textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SpacingScale.s28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.go('/'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: SpacingScale.s12),
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                      ),
                      child: const Text('Back to Home'),
                    ),
                  ),
                  const SizedBox(width: SpacingScale.s12),
                  Expanded(
                    child: PrimaryButton(
                      label: 'View Bookings',
                      icon: Icons.calendar_today_rounded,
                      onPressed: () => context.go(AppRoutes.myBookings),
                    ),
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
