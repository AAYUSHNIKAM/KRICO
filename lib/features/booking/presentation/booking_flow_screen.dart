import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../design_system/radius/radius.dart';
import '../../../design_system/widgets/buttons/primary_button.dart';
import '../../../models/coach_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/booking_providers.dart';
import '../../../services/availability_service.dart';
import 'widgets/availability_calendar.dart';
import 'widgets/time_slot_picker.dart';

class BookingFlowScreen extends ConsumerStatefulWidget {
  final CoachModel coach;

  const BookingFlowScreen({super.key, required this.coach});

  @override
  ConsumerState<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends ConsumerState<BookingFlowScreen> {
  int _currentStep = 0;
  DateTime? _selectedDate;
  String? _selectedSlot;
  bool _submitting = false;
  String _selectedSport = 'General';
  String _sessionType = '1-on-1 Training';
  String _paymentMethod = 'UPI / Instant Pay';
  late TextEditingController _notesCtrl;
  late TextEditingController _couponCtrl;
  late TextEditingController _emergencyContactCtrl;
  bool _waiverAccepted = true;
  String? _appliedCouponCode;
  double _discountAmount = 0.0;
  String? _couponError;
  bool _isValidatingCoupon = false;
  String? _confirmedSessionId;

  final List<String> _sessionTypes = [
    '1-on-1 Training',
    'Technique Assessment',
    'Fitness & Conditioning',
    'Match Strategy',
  ];

  final List<String> _paymentMethods = [
    'UPI / Instant Pay',
    'Credit / Debit Card',
    'KRICO Escrow (Protected)',
  ];

  @override
  void initState() {
    super.initState();
    _selectedSport = (widget.coach.specialization != null && widget.coach.specialization!.trim().isNotEmpty)
        ? widget.coach.specialization!.trim()
        : 'General';
    _notesCtrl = TextEditingController();
    _couponCtrl = TextEditingController();
    _emergencyContactCtrl = TextEditingController();
    _selectedDate = DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    _couponCtrl.dispose();
    _emergencyContactCtrl.dispose();
    super.dispose();
  }

  double get _sessionPrice => widget.coach.hourlyRate > 0 ? widget.coach.hourlyRate : 500.0;
  double get _platformFee => _sessionPrice * 0.10;
  double get _totalPrice => (_sessionPrice + _platformFee - _discountAmount).clamp(0.0, double.infinity);

  DateTime? get _calculatedSessionDateTime {
    if (_selectedDate == null) return null;
    if (_selectedSlot == null) {
      return DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, 10, 0);
    }
    try {
      final parts = _selectedSlot!.split(RegExp(r'[: ]'));
      int hour = int.parse(parts[0]);
      final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
      final isPm = _selectedSlot!.toLowerCase().contains('pm');
      if (isPm && hour < 12) hour += 12;
      if (!isPm && hour == 12) hour = 0;
      return DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, hour, minute);
    } catch (_) {
      return DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, 10, 0);
    }
  }

  DateTime _parseSlotToDateTime(DateTime date, String slotStr) {
    try {
      final parts = slotStr.split(RegExp(r'[: ]'));
      int hour = int.parse(parts[0]);
      final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
      final isPm = slotStr.toLowerCase().contains('pm');
      if (isPm && hour < 12) hour += 12;
      if (!isPm && hour == 12) hour = 0;
      return DateTime(date.year, date.month, date.day, hour, minute);
    } catch (_) {
      return DateTime(date.year, date.month, date.day, 10, 0);
    }
  }

  Future<void> _applyCoupon() async {
    final code = _couponCtrl.text.trim().toUpperCase();
    if (code.isEmpty) return;

    setState(() {
      _isValidatingCoupon = true;
      _couponError = null;
    });

    try {
      final snap = await FirebaseFirestore.instance.collection('coupons').doc(code).get();
      if (snap.exists && snap.data()?['isActive'] == true) {
        final data = snap.data()!;
        final type = data['type'] as String? ?? 'flat';
        final val = (data['value'] as num?)?.toDouble() ?? 50.0;
        final discount = type == 'percentage'
            ? (_sessionPrice * (val / 100))
            : val;
        setState(() {
          _appliedCouponCode = code;
          _discountAmount = discount.clamp(0.0, _sessionPrice);
          _couponError = null;
        });
        return;
      }

      if (code == 'FIRST50') {
        setState(() {
          _appliedCouponCode = 'FIRST50';
          _discountAmount = 50.0;
          _couponError = null;
        });
      } else if (code == 'SPORT20') {
        setState(() {
          _appliedCouponCode = 'SPORT20';
          _discountAmount = (_sessionPrice * 0.20).clamp(0.0, 150.0);
          _couponError = null;
        });
      } else if (code == 'PRO100') {
        setState(() {
          _appliedCouponCode = 'PRO100';
          _discountAmount = 100.0;
          _couponError = null;
        });
      } else if (code == 'CHAMPION') {
        setState(() {
          _appliedCouponCode = 'CHAMPION';
          _discountAmount = 200.0;
          _couponError = null;
        });
      } else {
        setState(() {
          _couponError = 'Invalid promo code. Try FIRST50 or SPORT20';
        });
      }
    } catch (_) {
      if (code == 'FIRST50' || code == 'SPORT20' || code == 'PRO100') {
        setState(() {
          _appliedCouponCode = code;
          _discountAmount = code == 'FIRST50' ? 50.0 : (code == 'PRO100' ? 100.0 : 75.0);
          _couponError = null;
        });
      } else {
        setState(() {
          _couponError = 'Invalid promo code';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isValidatingCoupon = false;
        });
      }
    }
  }

  void _removeCoupon() {
    setState(() {
      _appliedCouponCode = null;
      _discountAmount = 0.0;
      _couponCtrl.clear();
      _couponError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.background : AppColors.lightBackground;
    final surfaceColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          onPressed: () {
            if (_currentStep > 0 && _currentStep < 3) {
              setState(() => _currentStep--);
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          _currentStep == 3 ? 'Booking Confirmed' : 'Book ${widget.coach.name}',
          style: AppTextStyles.title2.copyWith(fontWeight: FontWeight.w700, color: textPrimary),
        ),
      ),
      body: _currentStep == 3
          ? _buildConfirmation(isDark, textPrimary, textSecondary, surfaceColor)
          : _buildBookingForm(isDark, textPrimary, textSecondary, surfaceColor),
    );
  }

  Widget _buildBookingForm(bool isDark, Color textPrimary, Color textSecondary, Color surfaceColor) {
    return Column(
      children: [
        _buildStepIndicator(isDark, textPrimary, textSecondary),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(SpacingScale.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_currentStep == 0) _buildDateAndServiceStep(isDark, textPrimary, textSecondary, surfaceColor),
                if (_currentStep == 1) _buildTimeStep(isDark, textPrimary, textSecondary, surfaceColor),
                if (_currentStep == 2) _buildReviewAndPayStep(isDark, textPrimary, textSecondary, surfaceColor),
              ],
            ),
          ),
        ),
        _buildBottomBar(isDark, textPrimary, surfaceColor),
      ],
    );
  }

  Widget _buildStepIndicator(bool isDark, Color textPrimary, Color textSecondary) {
    final steps = ['Date & Training', 'Time Slot', 'Review & Pay'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s16, vertical: SpacingScale.s12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        border: Border(bottom: BorderSide(color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5))),
      ),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isActive = _currentStep == index;
          final isCompleted = _currentStep > index;
          return Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: isCompleted
                      ? AppColors.success
                      : isActive
                          ? AppColors.primary
                          : (isDark ? AppColors.card : AppColors.lightCard),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isActive ? Colors.white : textSecondary,
                          ),
                        ),
                ),
                const SizedBox(width: SpacingScale.s6),
                Expanded(
                  child: Text(
                    steps[index],
                    style: AppTextStyles.caption.copyWith(
                      color: isActive ? textPrimary : textSecondary,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (index < steps.length - 1)
                  Container(
                    width: 16,
                    height: 1,
                    color: isDark ? AppColors.border : AppColors.lightBorder,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDateAndServiceStep(bool isDark, Color textPrimary, Color textSecondary, Color surfaceColor) {
    final spec = widget.coach.specialization?.trim();
    final sportsList = (spec != null && spec.isNotEmpty)
        ? [spec, 'Fitness & Conditioning', 'General Training']
        : ['General Training', 'Fitness & Conditioning', 'Cricket', 'Football', 'Tennis'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Sport', style: AppTextStyles.title3.copyWith(color: textPrimary, fontWeight: FontWeight.w700)),
        const SizedBox(height: SpacingScale.s8),
        Wrap(
          spacing: SpacingScale.s8,
          runSpacing: SpacingScale.s8,
          children: sportsList.map((sport) {
            final isSelected = _selectedSport == sport;
            return ChoiceChip(
              label: Text(sport),
              selected: isSelected,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              onSelected: (_) => setState(() => _selectedSport = sport),
            );
          }).toList(),
        ),
        const SizedBox(height: SpacingScale.s20),
        Text('Training Session Type', style: AppTextStyles.title3.copyWith(color: textPrimary, fontWeight: FontWeight.w700)),
        const SizedBox(height: SpacingScale.s8),
        Column(
          children: _sessionTypes.map((type) {
            final isSelected = _sessionType == type;
            return InkWell(
              onTap: () => setState(() => _sessionType = type),
              borderRadius: AppRadius.brXl2,
              child: Container(
                margin: const EdgeInsets.only(bottom: SpacingScale.s8),
                padding: const EdgeInsets.all(SpacingScale.s12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : (isDark ? AppColors.card : AppColors.lightCard),
                  borderRadius: AppRadius.brXl2,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isSelected ? AppColors.primary : textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: SpacingScale.s12),
                    Expanded(
                      child: Text(
                        type,
                        style: AppTextStyles.body.copyWith(
                          color: textPrimary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '₹${_sessionPrice.toInt()}',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: SpacingScale.s20),
        Text('Choose Date', style: AppTextStyles.title3.copyWith(color: textPrimary, fontWeight: FontWeight.w700)),
        const SizedBox(height: SpacingScale.s8),
        AvailabilityCalendar(
          selectedDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
          availableDates: {
            for (int i = 1; i <= 30; i++) DateTime.now().add(Duration(days: i)),
          },
          onDateSelected: (date) {
            setState(() {
              _selectedDate = date;
              _selectedSlot = null;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTimeStep(bool isDark, Color textPrimary, Color textSecondary, Color surfaceColor) {
    final selectedDay = _selectedDate ?? DateTime.now().add(const Duration(days: 1));
    final normalizedDate = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    final slotsAsync = ref.watch(availableTimeSlotsProvider((
      coachId: widget.coach.coachId,
      date: normalizedDate,
    )));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selected Date',
          style: AppTextStyles.caption.copyWith(color: textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          _selectedDate != null ? DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate!) : 'No date selected',
          style: AppTextStyles.title2.copyWith(color: textPrimary, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: SpacingScale.s20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Available Time Slots', style: AppTextStyles.title3.copyWith(color: textPrimary, fontWeight: FontWeight.w700)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Requires ${widget.coach.leadTimeHours}h notice',
                style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: SpacingScale.s8),
        slotsAsync.when(
          data: (slots) {
            final now = DateTime.now();
            final earliestAllowed = now.add(Duration(hours: widget.coach.leadTimeHours));
            final baseSlots = slots.isNotEmpty ? slots : AvailabilityService.defaultSlots;
            final available = baseSlots.where((slotStr) {
              final parsed = _parseSlotToDateTime(normalizedDate, slotStr);
              return parsed.isAfter(earliestAllowed);
            }).toList();

            return TimeSlotPicker(
              availableSlots: available.isNotEmpty ? available : baseSlots,
              selectedSlot: _selectedSlot,
              onSlotSelected: (slot) => setState(() => _selectedSlot = slot),
            );
          },
          loading: () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00E5FF)),
                  ),
                ),
              ),
              TimeSlotPicker(
                availableSlots: AvailabilityService.defaultSlots,
                selectedSlot: _selectedSlot,
                onSlotSelected: (slot) => setState(() => _selectedSlot = slot),
              ),
            ],
          ),
          error: (_, _) => TimeSlotPicker(
            availableSlots: AvailabilityService.defaultSlots,
            selectedSlot: _selectedSlot,
            onSlotSelected: (slot) => setState(() => _selectedSlot = slot),
          ),
        ),
        const SizedBox(height: SpacingScale.s20),
        Text('Notes / Training Goals', style: AppTextStyles.title3.copyWith(color: textPrimary, fontWeight: FontWeight.w700)),
        const SizedBox(height: SpacingScale.s8),
        TextField(
          controller: _notesCtrl,
          maxLines: 3,
          style: TextStyle(color: textPrimary),
          decoration: InputDecoration(
            hintText: 'Tell the coach about your current skill level, focus areas, or upcoming matches...',
            hintStyle: TextStyle(color: textSecondary),
            filled: true,
            fillColor: isDark ? AppColors.card : AppColors.lightCard,
            border: OutlineInputBorder(
              borderRadius: AppRadius.brXl2,
              borderSide: BorderSide(color: isDark ? AppColors.border : AppColors.lightBorder),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewAndPayStep(bool isDark, Color textPrimary, Color textSecondary, Color surfaceColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(SpacingScale.s16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.card : AppColors.lightCard,
            borderRadius: AppRadius.brXl2,
            border: Border.all(color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      widget.coach.name.isNotEmpty ? widget.coach.name[0].toUpperCase() : 'C',
                      style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: SpacingScale.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.coach.name, style: AppTextStyles.title2.copyWith(color: textPrimary, fontWeight: FontWeight.w700)),
                        Text(
                          '$_selectedSport • $_sessionType',
                          style: AppTextStyles.caption.copyWith(color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              _summaryRow('Date', _selectedDate != null ? DateFormat('EEE, MMM d, yyyy').format(_selectedDate!) : '-' , textPrimary, textSecondary),
              const SizedBox(height: 6),
              _summaryRow('Time Slot', _selectedSlot ?? '10:00 AM', textPrimary, textSecondary),
              const SizedBox(height: 6),
              _summaryRow('Duration', '60 minutes', textPrimary, textSecondary),
              const SizedBox(height: 6),
              _summaryRow('Session Fee', '₹${_sessionPrice.toInt()}', textPrimary, textSecondary),
              const SizedBox(height: 6),
              _summaryRow('Platform & Insurance Fee', '₹${_platformFee.toInt()}', textPrimary, textSecondary),
              if (_discountAmount > 0) ...[
                const SizedBox(height: 6),
                _summaryRow(
                  'Promo Discount ($_appliedCouponCode)',
                  '-₹${_discountAmount.toInt()}',
                  AppColors.emerald,
                  textSecondary,
                ),
              ],
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Payable', style: AppTextStyles.title2.copyWith(color: textPrimary, fontWeight: FontWeight.w800)),
                  Text(
                    '₹${_totalPrice.toInt()}',
                    style: AppTextStyles.title1.copyWith(color: AppColors.primary, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: SpacingScale.s16),
        _buildCouponSection(isDark, textPrimary, textSecondary),
        const SizedBox(height: SpacingScale.s20),
        Text('Payment Method', style: AppTextStyles.title3.copyWith(color: textPrimary, fontWeight: FontWeight.w700)),
        const SizedBox(height: SpacingScale.s8),
        Column(
          children: _paymentMethods.map((method) {
            final isSelected = _paymentMethod == method;
            return InkWell(
              onTap: () => setState(() => _paymentMethod = method),
              borderRadius: AppRadius.brXl2,
              child: Container(
                margin: const EdgeInsets.only(bottom: SpacingScale.s8),
                padding: const EdgeInsets.all(SpacingScale.s12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : (isDark ? AppColors.card : AppColors.lightCard),
                  borderRadius: AppRadius.brXl2,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                      color: isSelected ? AppColors.primary : textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: SpacingScale.s12),
                    Expanded(
                      child: Text(
                        method,
                        style: AppTextStyles.body.copyWith(
                          color: textPrimary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (method.contains('Escrow'))
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.emerald.withValues(alpha: 0.15),
                          borderRadius: AppRadius.brFull,
                        ),
                        child: Text(
                          'Safe & Refundable',
                          style: TextStyle(color: AppColors.emerald, fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: SpacingScale.s12),
        Container(
          padding: const EdgeInsets.all(SpacingScale.s12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: AppRadius.brLg,
          ),
          child: Row(
            children: [
              Icon(Icons.shield_outlined, size: 20, color: AppColors.primary),
              const SizedBox(width: SpacingScale.s8),
              Expanded(
                child: Text(
                  'Free cancellation up to 12 hours before session start. 100% money back guarantee.',
                  style: AppTextStyles.caption.copyWith(color: textPrimary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: SpacingScale.s16),
        // Emergency Contact Field
        Text('Emergency Contact (Optional)', style: AppTextStyles.title3.copyWith(color: textPrimary, fontWeight: FontWeight.w700)),
        const SizedBox(height: SpacingScale.s6),
        TextField(
          controller: _emergencyContactCtrl,
          style: TextStyle(color: textPrimary, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Parent / Guardian name & phone number',
            hintStyle: TextStyle(color: textSecondary, fontSize: 12),
            prefixIcon: const Icon(Icons.contact_emergency_outlined, size: 18),
            filled: true,
            fillColor: surfaceColor,
            border: OutlineInputBorder(borderRadius: AppRadius.brLg, borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: SpacingScale.s16),
        // Athletic Health & Liability Waiver Card
        Container(
          padding: const EdgeInsets.all(SpacingScale.s12),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: AppRadius.brLg,
            border: Border.all(color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CheckboxListTile(
                value: _waiverAccepted,
                activeColor: const Color(0xFFCCFF00),
                checkColor: Colors.black,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  'Athletic Health & Safety Waiver',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: textPrimary),
                ),
                subtitle: Text(
                  'I certify the participant is medically fit for athletic training drills and agree to the platform safety terms.',
                  style: TextStyle(fontSize: 11, color: textSecondary),
                ),
                onChanged: (val) => setState(() => _waiverAccepted = val ?? false),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value, Color textPrimary, Color textSecondary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodySm.copyWith(color: textSecondary)),
        Text(value, style: AppTextStyles.bodySm.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildCouponSection(bool isDark, Color textPrimary, Color textSecondary) {
    final hasCoupon = _appliedCouponCode != null;
    return Container(
      padding: const EdgeInsets.all(SpacingScale.s12),
      decoration: BoxDecoration(
        color: hasCoupon
            ? AppColors.emerald.withValues(alpha: 0.08)
            : (isDark ? AppColors.card : AppColors.lightCard),
        borderRadius: AppRadius.brXl2,
        border: Border.all(
          color: hasCoupon
              ? AppColors.emerald.withValues(alpha: 0.5)
              : (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_offer_outlined,
                size: 18,
                color: hasCoupon ? AppColors.emerald : AppColors.primary,
              ),
              const SizedBox(width: SpacingScale.s8),
              Text(
                'Promo Code & Discounts',
                style: AppTextStyles.bodySm.copyWith(
                  color: textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (hasCoupon)
                InkWell(
                  onTap: _removeCoupon,
                  child: Text(
                    'Remove',
                    style: TextStyle(
                      color: AppColors.danger,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: SpacingScale.s8),
          if (hasCoupon)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.15),
                    borderRadius: AppRadius.brSm,
                  ),
                  child: Text(
                    _appliedCouponCode!,
                    style: const TextStyle(
                      color: AppColors.emerald,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: SpacingScale.s8),
                Expanded(
                  child: Text(
                    'Saved ₹${_discountAmount.toInt()} on session fee!',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.emerald,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _couponCtrl,
                      textCapitalization: TextCapitalization.characters,
                      style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: 'Enter coupon (e.g. FIRST50, SPORT20)',
                        hintStyle: TextStyle(color: textSecondary, fontSize: 12),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        filled: true,
                        fillColor: isDark ? AppColors.surface : AppColors.lightSurface,
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.brLg,
                          borderSide: BorderSide(color: isDark ? AppColors.border : AppColors.lightBorder),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: SpacingScale.s8),
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _isValidatingCoupon ? null : _applyCoupon,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      elevation: 0,
                    ),
                    child: _isValidatingCoupon
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Apply', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                ),
              ],
            ),
            if (_couponError != null) ...[
              const SizedBox(height: 4),
              Text(
                _couponError!,
                style: const TextStyle(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ],
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: ['FIRST50', 'SPORT20', 'PRO100'].map((code) {
                return InkWell(
                  onTap: () {
                    _couponCtrl.text = code;
                    _applyCoupon();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: AppRadius.brSm,
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      'Use $code',
                      style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool isDark, Color textPrimary, Color surfaceColor) {
    final canProceed = _currentStep == 0
        ? _selectedDate != null
        : _currentStep == 1
            ? _selectedSlot != null
            : true;

    return Container(
      padding: EdgeInsets.fromLTRB(
        SpacingScale.s16,
        SpacingScale.s12,
        SpacingScale.s16,
        MediaQuery.of(context).padding.bottom + SpacingScale.s12,
      ),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(top: BorderSide(color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5))),
      ),
      child: Row(
        children: [
          if (_currentStep == 2)
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹${_totalPrice.toInt()}',
                    style: AppTextStyles.title1.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800),
                  ),
                  Text('Total inclusive of fees', style: AppTextStyles.caption.copyWith(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
                ],
              ),
            ),
          Expanded(
            child: PrimaryButton(
              label: _currentStep == 2
                  ? (_submitting ? 'Processing...' : 'Confirm & Pay')
                  : 'Continue',
              icon: _currentStep == 2 ? Icons.lock_outline_rounded : Icons.arrow_forward_rounded,
              onPressed: canProceed && !_submitting ? _handleNext : null,
              expanded: true,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNext() async {
    if (_currentStep < 2) {
      if (_currentStep == 0 && _selectedSlot == null) {
        _selectedSlot = '10:00 AM';
      }
      setState(() => _currentStep++);
      return;
    }

    if (!_waiverAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Athletic Health & Safety Waiver to proceed.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to complete your booking.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final sessionTime = _calculatedSessionDateTime ?? DateTime.now().add(const Duration(days: 1, hours: 10));
      final bookingService = ref.read(bookingServiceProvider);
      final result = await bookingService.createBooking(
        coachId: widget.coach.coachId,
        playerId: user.uid,
        dateTime: sessionTime,
        sport: _selectedSport,
        amount: _sessionPrice,
        notes: '[$_sessionType] ${_notesCtrl.text.trim()} (Paid via $_paymentMethod)${_appliedCouponCode != null ? " [Coupon: $_appliedCouponCode -₹${_discountAmount.toInt()}]" : ""}',
        couponCode: _appliedCouponCode,
        discountAmount: _discountAmount,
      );

      if (!mounted) return;
      setState(() {
        _submitting = false;
        _confirmedSessionId = result.sessionId;
        _currentStep = 3;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking failed: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Widget _buildConfirmation(bool isDark, Color textPrimary, Color textSecondary, Color surfaceColor) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(SpacingScale.s24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, size: 52, color: AppColors.success),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
            const SizedBox(height: SpacingScale.s20),
            Text(
              'Training Booked Successfully!',
              style: AppTextStyles.heading2.copyWith(color: textPrimary, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SpacingScale.s8),
            Text(
              'Your session request with ${widget.coach.name} has been placed. You will receive a notification as soon as the coach accepts.',
              style: AppTextStyles.body.copyWith(color: textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SpacingScale.s24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(SpacingScale.s16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.card : AppColors.lightCard,
                borderRadius: AppRadius.brXl2,
                border: Border.all(color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  _summaryRow('Session ID', _confirmedSessionId != null && _confirmedSessionId!.length >= 8 ? _confirmedSessionId!.substring(0, 8).toUpperCase() : 'CONFIRMED', textPrimary, textSecondary),
                  const SizedBox(height: 6),
                  _summaryRow('Coach', widget.coach.name, textPrimary, textSecondary),
                  const SizedBox(height: 6),
                  _summaryRow('Sport & Type', '$_selectedSport ($_sessionType)', textPrimary, textSecondary),
                  const SizedBox(height: 6),
                  _summaryRow('Date & Time', '${DateFormat("MMM d").format(_selectedDate ?? DateTime.now())} at ${_selectedSlot ?? "10:00 AM"}', textPrimary, textSecondary),
                  if (_appliedCouponCode != null) ...[
                    const SizedBox(height: 6),
                    _summaryRow('Promo Code', '$_appliedCouponCode (-₹${_discountAmount.toInt()})', AppColors.emerald, textSecondary),
                  ],
                  const SizedBox(height: 6),
                  _summaryRow('Payment Status', 'Escrow Held (₹${_totalPrice.toInt()})', AppColors.success, textSecondary),
                ],
              ),
            ),
            const SizedBox(height: SpacingScale.s32),
            PrimaryButton(
              label: 'View My Bookings',
              icon: Icons.calendar_today_rounded,
              onPressed: () {
                context.go('/home');
              },
              expanded: true,
            ),
            const SizedBox(height: SpacingScale.s12),
            OutlinedButton(
              onPressed: () => context.go('/home'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                side: BorderSide(color: isDark ? AppColors.border : AppColors.lightBorder),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.brXl2),
              ),
              child: Text('Back to Home', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
