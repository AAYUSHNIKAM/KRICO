import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../models/coach_model.dart';
import '../../../services/providers.dart';
import '../../../providers/auth_provider.dart';

class CoachDiscoveryScreen extends ConsumerStatefulWidget {
  const CoachDiscoveryScreen({super.key});

  @override
  ConsumerState<CoachDiscoveryScreen> createState() => _CoachDiscoveryScreenState();
}

class _CoachDiscoveryScreenState extends ConsumerState<CoachDiscoveryScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _selectedSport;
  String? _selectedLocation;
  double? _minRating;

  final _sports = ['All', 'Cricket', 'Football', 'Tennis', 'Badminton', 'Swimming', 'Basketball'];
  final _locations = ['All', 'Mumbai', 'Delhi', 'Pune', 'Bangalore', 'Chennai'];
  final _ratings = ['Any', '4.5+', '4.0+', '3.5+'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coachesAsync = ref.watch(coachesStreamProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withValues(alpha: 0.8)],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Find Your Coach', style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search coaches, sports, location...',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white38),
                          prefixIcon: Icon(Icons.search_rounded, color: Colors.white38, size: 22),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear_rounded, color: Colors.white38, size: 18),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                children: [
                  _buildFilterChip('Sport', _selectedSport ?? 'All', _sports, (v) => setState(() => _selectedSport = v == 'All' ? null : v)),
                  const SizedBox(width: 8),
                  _buildFilterChip('Location', _selectedLocation ?? 'All', _locations, (v) => setState(() => _selectedLocation = v == 'All' ? null : v)),
                  const SizedBox(width: 8),
                  _buildFilterChip('Rating', _minRating == null ? 'Any' : '${_minRating!}+', _ratings, (v) {
                    setState(() {
                      _minRating = v == 'Any' ? null : double.tryParse(v.replaceAll('+', ''));
                    });
                  }),
                ],
              ),
            ),
          ),
          coachesAsync.when(
            data: (coaches) {
              final filtered = coaches.where((c) {
                if (_searchQuery.isNotEmpty) {
                  final matches = c.name.toLowerCase().contains(_searchQuery) ||
                      (c.specialization?.toLowerCase().contains(_searchQuery) ?? false) ||
                      (c.city?.toLowerCase().contains(_searchQuery) ?? false);
                  if (!matches) return false;
                }
                if (_selectedSport != null && c.specialization != null) {
                  if (!c.specialization!.toLowerCase().contains(_selectedSport!.toLowerCase())) return false;
                }
                if (_selectedLocation != null && c.city != null) {
                  if (!c.city!.toLowerCase().contains(_selectedLocation!.toLowerCase())) return false;
                }
                if (_minRating != null && c.rating < _minRating!) return false;
                return true;
              }).toList();
              if (filtered.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_search_rounded, size: 64, color: AppColors.textDim),
                        const SizedBox(height: 16),
                        Text('No coaches found', style: AppTextStyles.titleSmall.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final coach = filtered[index];
                      return _buildCoachCard(context, coach).animate().fade(duration: 300.ms).slideY(begin: 0.1, delay: (index * 50).ms);
                    },
                    childCount: filtered.length,
                  ),
                ),
              );
            },
            loading: () => SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_off_rounded, size: 64, color: AppColors.textDim),
                    const SizedBox(height: 16),
                    Text('Something went wrong', style: AppTextStyles.titleSmall.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String selected, List<String> options, ValueChanged<String> onChanged) {
    return GestureDetector(
      onTap: () => _showFilterSheet(context, label, options, selected, onChanged),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(selected, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down_rounded, size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, String label, List<String> options, String selected, ValueChanged<String> onChanged) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter by $label', style: AppTextStyles.titleMedium),
            const SizedBox(height: 16),
            ...options.map((opt) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  onChanged(opt);
                  Navigator.pop(ctx);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: opt == selected ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Text(opt, style: AppTextStyles.bodyMedium.copyWith(
                        color: opt == selected ? AppColors.primary : AppColors.textPrimary,
                        fontWeight: opt == selected ? FontWeight.w600 : FontWeight.w400,
                      )),
                      if (opt == selected) ...[
                        const Spacer(),
                        Icon(Icons.check_rounded, size: 18, color: AppColors.primary),
                      ],
                    ],
                  ),
                ),
              ),
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildCoachCard(BuildContext context, CoachModel coach) {
    final initials = coach.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary.withValues(alpha: 0.3), AppColors.accent.withValues(alpha: 0.3)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Center(
                    child: Text(initials, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(coach.name, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700)),
                          ),
                          _buildSubscriptionBadge(coach.subscriptionTier),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        coach.specialization ?? 'General Coach',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _buildInfoChip(Icons.star_rounded, coach.rating.toStringAsFixed(1), AppColors.gold),
                const SizedBox(width: 8),
                _buildInfoChip(Icons.work_rounded, '${coach.experience} yrs', AppColors.info),
                const SizedBox(width: 8),
                _buildInfoChip(Icons.location_on_rounded, coach.city ?? 'Remote', AppColors.textSecondary),
                const Spacer(),
                Text('₹${coach.hourlyRate.toInt()}/hr', style: AppTextStyles.priceSmall.copyWith(color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                if (coach.isVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_rounded, size: 12, color: AppColors.success),
                        const SizedBox(width: 3),
                        Text('Verified', style: AppTextStyles.caption.copyWith(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                const Spacer(),
                SizedBox(
                  width: 120, height: 38,
                  child: GradientButton(
                    onPressed: () => _showBookingSheet(context, coach),
                    height: 38,
                    borderRadius: 10,
                    child: Text('Book Now', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionBadge(String tier) {
    Color color;
    switch (tier.toLowerCase()) {
      case 'pro':
        color = AppColors.gold;
        break;
      case 'plus':
        color = AppColors.accent;
        break;
      default:
        color = AppColors.textSecondary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(tier, style: AppTextStyles.caption.copyWith(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(text, style: AppTextStyles.caption.copyWith(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showBookingSheet(BuildContext context, CoachModel coach) {
    final dateCtrl = TextEditingController();
    final timeCtrl = TextEditingController();
    final sportCtrl = TextEditingController(text: coach.specialization ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary.withValues(alpha: 0.3), AppColors.accent.withValues(alpha: 0.3)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        coach.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Book ${coach.name}', style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700)),
                        Text('₹${coach.hourlyRate.toInt()}/hr', style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: dateCtrl,
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 60)),
                    builder: (context, child) => Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.dark(
                          primary: AppColors.primary,
                          surface: AppColors.cardDark,
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (date != null) {
                    dateCtrl.text = '${date.day}/${date.month}/${date.year}';
                  }
                },
                validator: (v) => v == null || v.isEmpty ? 'Select a date' : null,
                style: AppTextStyles.bodyMedium,
                decoration: _bookingInputDeco('Date', 'Select date', Icons.calendar_today_rounded),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: timeCtrl,
                readOnly: true,
                onTap: () async {
                  final time = await showTimePicker(
                    context: ctx,
                    initialTime: const TimeOfDay(hour: 9, minute: 0),
                    builder: (context, child) => Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.dark(
                          primary: AppColors.primary,
                          surface: AppColors.cardDark,
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (time != null && ctx.mounted) {
                    timeCtrl.text = time.format(ctx);
                  }
                },
                validator: (v) => v == null || v.isEmpty ? 'Select a time' : null,
                style: AppTextStyles.bodyMedium,
                decoration: _bookingInputDeco('Time', 'Select time', Icons.access_time_rounded),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: sportCtrl,
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter sport' : null,
                style: AppTextStyles.bodyMedium,
                decoration: _bookingInputDeco('Sport', 'Enter sport type', Icons.sports_rounded),
              ),
              const SizedBox(height: 24),
              GradientButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  try {
                    final authService = ref.read(authServiceProvider);
                    final userId = authService.currentUser?.uid;
                    if (userId == null) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text('Please sign in first'), backgroundColor: AppColors.warning),
                        );
                      }
                      return;
                    }
                    final parts = dateCtrl.text.split('/');
                    final date = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
                    final timeParts = timeCtrl.text.split(' ');
                    final timeSplit = timeParts[0].split(':');
                    var hour = int.parse(timeSplit[0]);
                    final minute = int.parse(timeSplit[1]);
                    if (timeParts.length > 1 && timeParts[1].toUpperCase() == 'PM' && hour != 12) hour += 12;
                    if (timeParts.length > 1 && timeParts[1].toUpperCase() == 'AM' && hour == 12) hour = 0;
                    final dateTime = DateTime(date.year, date.month, date.day, hour, minute);
                    final coachService = ref.read(coachServiceProvider);
                    await coachService.bookSession(coach.coachId, userId, dateTime, sportCtrl.text.trim());
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Session booked successfully!'), backgroundColor: AppColors.success),
                      );
                    }
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text('Booking failed: $e'), backgroundColor: AppColors.error),
                      );
                    }
                  }
                },
                height: 50,
                child: const Text('Confirm Booking', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _bookingInputDeco(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
      hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textDim),
      prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondary),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      filled: true,
      fillColor: AppColors.surfaceMid,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.borderLight.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}
