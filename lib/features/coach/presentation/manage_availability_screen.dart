import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/radius/radius.dart';
import '../../../models/availability_model.dart';
import '../../../models/coach_model.dart';
import '../../../providers/booking_providers.dart';
import '../../../services/availability_service.dart';
import '../../../services/providers.dart';

class ManageAvailabilityScreen extends ConsumerStatefulWidget {
  const ManageAvailabilityScreen({super.key, required this.coachId});

  final String coachId;

  @override
  ConsumerState<ManageAvailabilityScreen> createState() => _ManageAvailabilityScreenState();
}

class _ManageAvailabilityScreenState extends ConsumerState<ManageAvailabilityScreen> {
  static const _slotPool = [
    '08:00', '09:00', '10:00', '11:00', '12:00',
    '13:00', '14:00', '15:00', '16:00', '17:00', '18:00',
  ];

  DateTime? _selectedDate;
  DateTime? _overviewSelectedDate;
  final Set<String> _selectedSlots = {};
  final TextEditingController _rateController = TextEditingController();
  bool _saving = false;
  bool _savingRate = false;
  bool _rateInit = false;

  @override
  void initState() {
    super.initState();
    // Default select today
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final bgColor = isDark ? AppColors.background : AppColors.lightBackground;
    final availabilityAsync = ref.watch(coachAvailabilityProvider(widget.coachId));
    final entries = availabilityAsync.asData?.value ?? const <AvailabilityModel>[];
    final coachAsync = ref.watch(coachProvider(widget.coachId));
    final coach = coachAsync.asData?.value;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverHeader(isDark),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (coach != null && coach.penaltyBalance > 0) ...[
                        _buildPenaltyBanner(coach, isDark),
                        const SizedBox(height: 16),
                      ],
                      _buildLeadTimeSection(coach, isDark, textPrimary, textSecondary),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFCCFF00).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.calendar_today_rounded, color: Color(0xFFCCFF00), size: 18),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select Dispatch Date',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: textPrimary,
                                ),
                              ),
                              Text(
                                'Choose a day on your training calendar',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildDayPicker(isDark, textPrimary, textSecondary),
                      const SizedBox(height: 24),
                      if (_selectedDate != null) ...[
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.access_time_rounded, color: Color(0xFF00E5FF), size: 18),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Available Training Slots',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: textPrimary,
                                  ),
                                ),
                                Text(
                                  'Toggle slots for ${DateFormat('EEEE, MMM d').format(_selectedDate!)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFCCFF00).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${_selectedSlots.length} active',
                                style: const TextStyle(
                                  color: Color(0xFFCCFF00),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Quick Presets
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildPresetChip('Morning (8-12)', () {
                              setState(() {
                                _selectedSlots.addAll(['08:00', '09:00', '10:00', '11:00', '12:00']);
                              });
                            }, isDark),
                            _buildPresetChip('Evening (13-18)', () {
                              setState(() {
                                _selectedSlots.addAll(['13:00', '14:00', '15:00', '16:00', '17:00', '18:00']);
                              });
                            }, isDark),
                            _buildPresetChip('Clear', () {
                              setState(() {
                                _selectedSlots.clear();
                              });
                            }, isDark, isClear: true),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildSlotToggles(isDark, textPrimary),
                        const SizedBox(height: 20),
                        _buildSaveBar(isDark, textPrimary, textSecondary),
                        const SizedBox(height: 24),
                        _buildHourlyRateCard(isDark, textPrimary, textSecondary, coach),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFB388FF).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.event_available_rounded, color: Color(0xFFB388FF), size: 18),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Published Schedule Overview',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: textPrimary,
                                  ),
                                ),
                                Text(
                                  'Open sessions visible to athletes & parents',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      _buildUpcomingList(isDark, textPrimary, textSecondary, entries),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(String label, VoidCallback onTap, bool isDark, {bool isClear = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isClear
              ? Colors.red.withValues(alpha: 0.1)
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isClear
                ? Colors.red.withValues(alpha: 0.3)
                : (isDark ? Colors.white12 : Colors.black12),
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isClear ? Colors.redAccent : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverHeader(bool isDark) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: isDark ? AppColors.surface : AppColors.primary,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/backgrounds/stadium_floodlights.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(color: const Color(0xFF0F172A)),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.35),
                    const Color(0xFF0F172A).withValues(alpha: 0.88),
                    (isDark ? AppColors.background : AppColors.lightBackground),
                  ],
                  stops: const [0.0, 0.65, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 18,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCFF00).withValues(alpha: 0.15),
                      borderRadius: AppRadius.brFull,
                      border: Border.all(
                        color: const Color(0xFFCCFF00).withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt_rounded, color: Color(0xFFCCFF00), size: 14),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'COACH AVAILABILITY ENGINE',
                            style: TextStyle(
                              color: Color(0xFFCCFF00),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Manage Availability',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Publish free slots for students and academies to book coaching sessions',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DateTime> get _nextDays {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return List.generate(14, (i) => today.add(Duration(days: i)));
  }

  Widget _buildDayPicker(bool isDark, Color textPrimary, Color textSecondary) {
    final dates = _nextDays;
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: dates.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = _selectedDate != null && DateUtils.isSameDay(_selectedDate!, date);
          final hasSlots = _hasSlotsFor(date);
          final isToday = DateUtils.isSameDay(date, DateTime.now());

          return InkWell(
            onTap: () => _selectDate(date),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFCCFF00)
                    : (isDark ? const Color(0xFF131D31) : Colors.white),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFCCFF00)
                      : (hasSlots
                          ? const Color(0xFF00E5FF).withValues(alpha: 0.6)
                          : (isDark ? Colors.white12 : Colors.black12)),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFFCCFF00).withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('EEE').format(date).toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.black87 : textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? Colors.black : textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasSlots)
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : const Color(0xFF00E5FF),
                            shape: BoxShape.circle,
                          ),
                        ),
                      if (hasSlots && isToday) const SizedBox(width: 3),
                      if (isToday)
                        Text(
                          'TODAY',
                          style: TextStyle(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w900,
                            color: isSelected ? Colors.black : const Color(0xFFCCFF00),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSlotToggles(bool isDark, Color textPrimary) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _slotPool.map((slot) {
        final isSelected = _selectedSlots.contains(slot);
        return InkWell(
          onTap: () => _toggleSlot(slot),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFCCFF00)
                  : (isDark ? const Color(0xFF131D31) : Colors.white),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFCCFF00)
                    : (isDark ? Colors.white12 : Colors.black12),
                width: 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFFCCFF00).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  size: 14,
                  color: isSelected ? Colors.black : Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatSlot(slot),
                  style: TextStyle(
                    color: isSelected ? Colors.black : textPrimary,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSaveBar(bool isDark, Color textPrimary, Color textSecondary) {
    final existing = _selectedDate != null ? _hasSlotsFor(_selectedDate!) : false;
    return Column(
      children: [
        InkWell(
          onTap: _saving ? null : _onPublishPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 52,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFCCFF00), Color(0xFF99E600)]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFCCFF00).withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload_rounded, color: Colors.black, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'PUBLISH AVAILABILITY SLOTS',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        if (existing) ...[
          const SizedBox(height: 10),
          InkWell(
            onTap: _saving ? null : _removeDay,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 44,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3), width: 1),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Remove All Slots For This Date',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHourlyRateCard(bool isDark, Color textPrimary, Color textSecondary, CoachModel? coach) {
    if (!_rateInit && coach != null) {
      _rateInit = true;
      _rateController.text = (coach.hourlyRate > 0 ? coach.hourlyRate : 500.0).toInt().toString();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131D31) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFCCFF00).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFCCFF00).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.monetization_on_rounded, color: Color(0xFFCCFF00), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Session Rate (Price per Session)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    Text(
                      'This fee is shown to athletes booking coaching sessions with you',
                      style: TextStyle(fontSize: 11, color: textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text('₹ ', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                      Expanded(
                        child: TextField(
                          controller: _rateController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '500',
                            isDense: true,
                          ),
                        ),
                      ),
                      Text('/ session', style: TextStyle(color: textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _savingRate ? null : () async {
                  final newRate = double.tryParse(_rateController.text.trim());
                  if (newRate == null || newRate <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a valid session fee')),
                    );
                    return;
                  }
                  setState(() => _savingRate = true);
                  try {
                    await FirebaseFirestore.instance.collection('coaches').doc(widget.coachId).set({
                      'hourlyRate': newRate,
                    }, SetOptions(merge: true));
                    await FirebaseFirestore.instance.collection('users').doc(widget.coachId).set({
                      'hourlyRate': newRate,
                    }, SetOptions(merge: true));
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✅ Session rate successfully updated to ₹\ / session!'),
                          backgroundColor: AppColors.emerald,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update rate: ')),
                      );
                    }
                  } finally {
                    if (mounted) setState(() => _savingRate = false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCCFF00),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _savingRate
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Text('Save Rate', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingList(bool isDark, Color textPrimary, Color textSecondary, List<AvailabilityModel> entries) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final upcoming = entries.where((e) => !e.date.isBefore(today)).toList()..sort((a, b) => a.date.compareTo(b.date));

    if (upcoming.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131D31) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08)),
        ),
        child: Column(
          children: [
            Icon(Icons.event_busy_rounded, size: 40, color: textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: 10),
            Text(
              'No Published Availability',
              style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Pick a date above, select your working hours, and tap Publish.',
              textAlign: TextAlign.center,
              style: TextStyle(color: textSecondary, fontSize: 12),
            ),
          ],
        ),
      );
    }

    // Default select earliest upcoming date
    if (_overviewSelectedDate == null || !upcoming.any((e) => DateUtils.isSameDay(e.date, _overviewSelectedDate!))) {
      _overviewSelectedDate = upcoming.first.date;
    }

    final selectedEntry = upcoming.firstWhere(
      (e) => DateUtils.isSameDay(e.date, _overviewSelectedDate!),
      orElse: () => upcoming.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Horizontal calendar day strip
        SizedBox(
          height: 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: upcoming.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (ctx, i) {
              final item = upcoming[i];
              final isSelected = DateUtils.isSameDay(item.date, _overviewSelectedDate!);
              return InkWell(
                onTap: () => setState(() => _overviewSelectedDate = item.date),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 78,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF00E5FF).withValues(alpha: 0.15)
                        : (isDark ? const Color(0xFF131D31) : Colors.white),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF00E5FF)
                          : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08)),
                      width: isSelected ? 1.8 : 1,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: const Color(0xFF00E5FF).withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2))]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('E').format(item.date).toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? const Color(0xFF00E5FF) : textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('d').format(item.date),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isSelected ? const Color(0xFF00E5FF) : textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: (isSelected ? const Color(0xFF00E5FF) : textSecondary).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '\ slots',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? const Color(0xFF00E5FF) : textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // Display ONLY the selected day's slots
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131D31) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.event_available_rounded, size: 20, color: Color(0xFF00E5FF)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE, MMMM d, yyyy').format(selectedEntry.date),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          '\ available slots for athletes',
                          style: TextStyle(
                            fontSize: 11,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Delete day slots',
                    icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent),
                    onPressed: () => _removeEntry(selectedEntry),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selectedEntry.timeSlots.map((slot) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCCFF00).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCCFF00).withValues(alpha: 0.4), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time_rounded, size: 12, color: Color(0xFFCCFF00)),
                      const SizedBox(width: 5),
                      Text(
                        _formatSlot(slot),
                        style: const TextStyle(
                          color: Color(0xFFCCFF00),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _hasSlotsFor(DateTime date) {
    final entries = ref.watch(coachAvailabilityProvider(widget.coachId)).value ?? const <AvailabilityModel>[];
    return entries.any((e) => DateUtils.isSameDay(e.date, date) && e.timeSlots.isNotEmpty);
  }

  void _selectDate(DateTime date) {
    final entries = ref.read(coachAvailabilityProvider(widget.coachId)).value ?? const <AvailabilityModel>[];
    final existing = entries.where((e) => DateUtils.isSameDay(e.date, date)).map((e) => e.timeSlots).expand((s) => s).toSet();
    setState(() {
      _selectedDate = date;
      _selectedSlots
        ..clear()
        ..addAll(existing);
    });
  }

  void _toggleSlot(String slot) {
    final date = _selectedDate;
    if (date != null && _selectedSlots.contains(slot)) {
      final entries = ref.read(coachAvailabilityProvider(widget.coachId)).value ?? const <AvailabilityModel>[];
      final isAlreadyPublished = entries
          .where((e) => DateUtils.isSameDay(e.date, date))
          .any((e) => e.timeSlots.contains(slot));
      if (isAlreadyPublished && AvailabilityService.isWithin24Hours(date, slot)) {
        _showSnack('🔒 Slot is locked within 24h of session time and cannot be removed.', AppColors.warning);
        return;
      }
    }

    setState(() {
      if (_selectedSlots.contains(slot)) {
        _selectedSlots.remove(slot);
      } else {
        _selectedSlots.add(slot);
      }
    });
  }

  void _onPublishPressed() {
    final date = _selectedDate;
    if (date == null) {
      _showSnack('Please select a date first', AppColors.warning);
      return;
    }
    if (_selectedSlots.isEmpty) {
      _showSnack('Please select at least one time slot before publishing', AppColors.warning);
      return;
    }
    _showPublishScopeModal(date);
  }

  void _showPublishScopeModal(DateTime startDate) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    int selectedScopeIndex = 0; // 0: single, 1: 7d, 2: 14d, 3: 30d, 4: custom
    int customDays = 5;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final scopeOptions = [
              {
                'title': 'Selected Date Only',
                'subtitle': DateFormat('EEEE, MMM d').format(startDate),
                'days': 1,
                'icon': Icons.today_rounded,
              },
              {
                'title': 'Next 1 Week',
                'subtitle': 'Publish same slots for the next 7 consecutive days',
                'days': 7,
                'icon': Icons.date_range_rounded,
              },
              {
                'title': 'Next 2 Weeks',
                'subtitle': 'Publish same slots for the next 14 consecutive days',
                'days': 14,
                'icon': Icons.calendar_view_week_rounded,
              },
              {
                'title': 'Next 1 Month',
                'subtitle': 'Publish same slots for the next 30 days',
                'days': 30,
                'icon': Icons.calendar_month_rounded,
              },
              {
                'title': 'Custom Duration',
                'subtitle': 'Repeat for a custom number of days ($customDays days)',
                'days': customDays,
                'icon': Icons.tune_rounded,
              },
            ];

            return Container(
              padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCCFF00).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.schedule_send_rounded, color: Color(0xFFCCFF00), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mass Publish Availability',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'Apply ${_selectedSlots.length} slots across multiple days',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  ...List.generate(scopeOptions.length, (idx) {
                    final opt = scopeOptions[idx];
                    final isChosen = selectedScopeIndex == idx;
                    return InkWell(
                      onTap: () => setModalState(() => selectedScopeIndex = idx),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isChosen
                              ? const Color(0xFFCCFF00).withValues(alpha: 0.12)
                              : (isDark ? const Color(0xFF1E293B).withValues(alpha: 0.5) : const Color(0xFFF8FAFC)),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isChosen ? const Color(0xFFCCFF00) : (isDark ? Colors.white10 : Colors.black12),
                            width: isChosen ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              opt['icon'] as IconData,
                              size: 20,
                              color: isChosen ? const Color(0xFFCCFF00) : (isDark ? Colors.white70 : Colors.black87),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    opt['title'] as String,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    opt['subtitle'] as String,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isChosen ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                              color: isChosen ? const Color(0xFFCCFF00) : Colors.grey,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  if (selectedScopeIndex == 4) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          'Number of days: $customDays',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, size: 22),
                          onPressed: customDays > 2
                              ? () => setModalState(() => customDays--)
                              : null,
                        ),
                        Text(
                          '$customDays',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, size: 22),
                          onPressed: customDays < 90
                              ? () => setModalState(() => customDays++)
                              : null,
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        final daysCount = selectedScopeIndex == 4
                            ? customDays
                            : (scopeOptions[selectedScopeIndex]['days'] as int);
                        final targetDates = List.generate(
                          daysCount,
                          (i) => DateTime(startDate.year, startDate.month, startDate.day).add(Duration(days: i)),
                        );
                        _publishWithScope(targetDates);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCCFF00),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'CONFIRM & PUBLISH SLOTS',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _publishWithScope(List<DateTime> targetDates) async {
    setState(() => _saving = true);
    try {
      final sortedSlots = _selectedSlots.toList()..sort();
      if (targetDates.length == 1) {
        await ref.read(availabilityServiceProvider).setAvailability(
          coachId: widget.coachId,
          date: targetDates.first,
          timeSlots: sortedSlots,
        );
      } else {
        await ref.read(availabilityServiceProvider).setBulkAvailability(
          coachId: widget.coachId,
          dates: targetDates,
          timeSlots: sortedSlots,
        );
      }
      if (mounted) {
        _showSnack(
          targetDates.length == 1
              ? 'Availability saved for ${DateFormat('EEE, MMM d').format(targetDates.first)}!'
              : 'Published availability across ${targetDates.length} days!',
          const Color(0xFFCCFF00),
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Failed to save availability: $e', AppColors.danger);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _removeDay() async {
    final date = _selectedDate;
    if (date == null) return;

    if (AvailabilityService.isWithin24Hours(date)) {
      _showSnack('🔒 Action Blocked: You cannot remove availability within 24 hours of session time.', AppColors.danger);
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(availabilityServiceProvider).deleteAvailability(
        widget.coachId,
        date,
      );
      setState(() {
        _selectedSlots.clear();
      });
      if (mounted) {
        _showSnack('Availability removed for this date', AppColors.textSecondary);
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Failed to remove: $e', AppColors.danger);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _removeEntry(AvailabilityModel entry) async {
    if (AvailabilityService.isWithin24Hours(entry.date)) {
      _showSnack('🔒 Action Blocked: You cannot remove availability within 24 hours of session time.', AppColors.danger);
      return;
    }

    try {
      await ref.read(availabilityServiceProvider).deleteAvailability(
        widget.coachId,
        entry.date,
      );
      if (_selectedDate != null && DateUtils.isSameDay(_selectedDate!, entry.date)) {
        setState(() {
          _selectedSlots.clear();
        });
      }
      if (mounted) {
        _showSnack('Availability removed for ${DateFormat('MMM d').format(entry.date)}', AppColors.textSecondary);
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Failed to delete: $e', AppColors.danger);
      }
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black)),
        backgroundColor: color == const Color(0xFFCCFF00) ? const Color(0xFFCCFF00) : color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _formatSlot(String slot) {
    final parts = slot.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts.length > 1 ? parts[1] : '00';
    final period = hour >= 12 ? 'PM' : 'AM';
    final h12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$h12:$minute $period';
  }

  Widget _buildPenaltyBanner(CoachModel coach, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB300).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFB300).withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFFFB300), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pending Cancellation Deduction',
                  style: TextStyle(
                    color: Color(0xFFFFB300),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '₹${coach.penaltyBalance.toInt()} will be deducted from your next completed session payout to cover previous cancellation disruption.',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadTimeSection(
    CoachModel? coach,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
  ) {
    final currentLeadHours = coach?.leadTimeHours ?? 2;
    const options = [1, 2, 4, 6, 12, 24, 48];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131D31) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
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
                child: const Icon(Icons.timer_outlined, color: Color(0xFF00E5FF), size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking Notice Window',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    Text(
                      'How many hours advance notice do you require before a session?',
                      style: TextStyle(fontSize: 11, color: textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((hrs) {
              final isSelected = currentLeadHours == hrs;
              final label = hrs >= 24 ? '${hrs ~/ 24} Day${hrs >= 48 ? "s" : ""}' : '$hrs hr${hrs > 1 ? "s" : ""}';
              return ChoiceChip(
                label: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.black : textPrimary,
                  ),
                ),
                selected: isSelected,
                selectedColor: const Color(0xFFCCFF00),
                backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
                onSelected: (selected) async {
                  if (selected) {
                    try {
                      await FirebaseFirestore.instance
                          .collection('coaches')
                          .doc(widget.coachId)
                          .update({'leadTimeHours': hrs});
                      if (mounted) {
                        _showSnack('Notice window updated to $label notice', const Color(0xFFCCFF00));
                      }
                    } catch (e) {
                      if (mounted) _showSnack('Failed to update: $e', AppColors.danger);
                    }
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
