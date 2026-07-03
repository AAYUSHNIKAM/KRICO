import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/stats_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../models/venue_model.dart';
import '../../../services/providers.dart';
import '../../../providers/auth_provider.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  final _venueFormKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _sportCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  final _amenitiesCtrl = TextEditingController();
  final _couponCodeCtrl = TextEditingController();
  final _couponDiscountCtrl = TextEditingController();
  bool _isAddingVenue = false;
  bool _isReleasingCoupon = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _sportCtrl.dispose();
    _capacityCtrl.dispose();
    _amenitiesCtrl.dispose();
    _couponCodeCtrl.dispose();
    _couponDiscountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitVenue() async {
    if (!_venueFormKey.currentState!.validate()) return;
    setState(() => _isAddingVenue = true);
    try {
      final venueService = ref.read(venueServiceProvider);
      final venue = VenueModel(
        venueId: '',
        name: _nameCtrl.text.trim(),
        address: _locationCtrl.text.trim(),
        sports: [_sportCtrl.text.trim()],
        capacity: int.tryParse(_capacityCtrl.text.trim()),
        amenities: _amenitiesCtrl.text.trim().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        isVerified: false,
        createdAt: DateTime.now(),
      );
      await venueService.addVenue(venue);
      _venueFormKey.currentState!.reset();
      _nameCtrl.clear();
      _locationCtrl.clear();
      _sportCtrl.clear();
      _capacityCtrl.clear();
      _amenitiesCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Venue added successfully'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add venue: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isAddingVenue = false);
    }
  }

  Future<void> _releaseCoupon() async {
    if (_couponCodeCtrl.text.trim().isEmpty || _couponDiscountCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter coupon code and discount'), backgroundColor: AppColors.warning),
      );
      return;
    }
    setState(() => _isReleasingCoupon = true);
    try {
      final authService = ref.read(authServiceProvider);
      await authService.addCoupon(
        code: _couponCodeCtrl.text.trim(),
        discount: _couponDiscountCtrl.text.trim(),
        eligibility: 'All users',
      );
      _couponCodeCtrl.clear();
      _couponDiscountCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coupon released!'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to release coupon: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isReleasingCoupon = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);
    final venuesAsync = ref.watch(venuesStreamProvider);
    final revenueAsync = ref.watch(totalRevenueProvider);
    final activeUsersAsync = ref.watch(activeUsersCountProvider);
    final tasksAsync = ref.watch(adminTasksProvider);
    final totalUsers = usersAsync.asData?.value.docs.length ?? 0;
    final totalVenues = venuesAsync.asData?.value.length ?? 0;
    final totalRevenue = revenueAsync.asData?.value ?? 0;
    final activeUsers = activeUsersAsync.asData?.value ?? 0;
    final taskList = tasksAsync.asData?.value.docs ?? [];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1C1C1E), Color(0xFF2C2C2E)],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Admin Dashboard', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
                            const SizedBox(height: 4),
                            Text('Platform Control', style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                          ),
                          child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline_rounded, size: 16, color: AppColors.warning),
                          const SizedBox(width: 6),
                          Text('${taskList.length} Pending Tasks', style: AppTextStyles.labelMedium.copyWith(color: AppColors.warning, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ).animate().shake(duration: 600.ms),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  children: [
                    Expanded(child: StatsCard(label: 'Total Users', value: '$totalUsers', icon: Icons.people_rounded, iconColor: AppColors.primary).animate().fade(duration: 400.ms).slideX(begin: -0.1)),
                    const SizedBox(width: 12),
                    Expanded(child: StatsCard(label: 'Venues', value: '$totalVenues', icon: Icons.stadium_rounded, iconColor: AppColors.success).animate().fade(duration: 400.ms, delay: 100.ms).slideX(begin: 0.1)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: StatsCard(label: 'Revenue', value: '₹${totalRevenue.toStringAsFixed(0)}', icon: Icons.account_balance_rounded, iconColor: AppColors.gold, gradient: AppColors.gradientAccent).animate().fade(duration: 400.ms, delay: 200.ms).slideX(begin: -0.1)),
                    const SizedBox(width: 12),
                    Expanded(child: StatsCard(label: 'Active Users', value: '$activeUsers', icon: Icons.trending_up_rounded, iconColor: AppColors.info).animate().fade(duration: 400.ms, delay: 300.ms).slideX(begin: 0.1)),
                  ],
                ),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Task Master', actionLabel: 'View All'),
                const SizedBox(height: 12),
                if (taskList.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
                    ),
                    child: Center(
                      child: Text('No tasks yet', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDim)),
                    ),
                  )
                else
                  ...taskList.map((doc) => _buildTaskCardFromDoc(context, doc)).toList().animate(interval: 100.ms).fade(),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Manual Venue Addition'),
                const SizedBox(height: 12),
                _buildVenueAdditionForm(context),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Premium Coupons', subtitle: 'Manage discount coupons'),
                const SizedBox(height: 12),
                _buildCouponSection(context),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCardFromDoc(BuildContext context, QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final title = data['title'] as String? ?? 'Untitled Task';
    final status = data['status'] as String? ?? 'Pending';
    final statusColors = {
      'Pending': AppColors.warning,
      'In Review': AppColors.info,
      'Open': AppColors.error,
      'Low': AppColors.success,
    };
    final color = statusColors[status] ?? AppColors.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {},
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.task_alt_rounded, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                    child: Text(status, style: AppTextStyles.caption.copyWith(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildVenueAdditionForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
      ),
      child: Form(
        key: _venueFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add_location_alt_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 10),
                Text('Add New Venue', style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 16),
            _buildFormField(
              controller: _nameCtrl,
              label: 'Venue Name',
              hint: 'Enter venue name',
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 10),
            _buildFormField(
              controller: _locationCtrl,
              label: 'Location',
              hint: 'Enter address or coordinates',
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildFormField(
                    controller: _sportCtrl,
                    label: 'Sport Type',
                    hint: 'e.g., Cricket',
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFormField(
                    controller: _capacityCtrl,
                    label: 'Capacity',
                    hint: 'Number',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (int.tryParse(v.trim()) == null) return 'Invalid number';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildFormField(
              controller: _amenitiesCtrl,
              label: 'Amenities',
              hint: 'Comma separated (e.g., Parking, Lights)',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: AppColors.borderLight),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Add Photos', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GradientButton(
                    onPressed: _isAddingVenue ? null : _submitVenue,
                    height: 44,
                    isLoading: _isAddingVenue,
                    child: const Text('Submit Venue', style: TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
        hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textDim),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        filled: true,
        fillColor: AppColors.surfaceMid,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.borderLight.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildCouponSection(BuildContext context) {
    final couponList = ref.watch(couponsProvider).asData?.value.docs ?? [];
    final activeCount = couponList.where((d) {
      final data = d.data();
      return data['isActive'] as bool? ?? true;
    }).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.accent.withValues(alpha: 0.08), AppColors.accentLight.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_offer_rounded, color: AppColors.accent, size: 20),
              ),
              const SizedBox(width: 10),
              Text('Active Coupons', style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                child: Text('$activeCount Active', style: AppTextStyles.labelSmall.copyWith(color: AppColors.gold, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (couponList.isEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.4)),
              ),
              child: Center(
                child: Text('No coupons yet. Release your first coupon below.',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textDim)),
              ),
            )
          else
            ...couponList.take(3).map((doc) {
              final data = doc.data();
              final code = data['code'] as String? ?? '';
              final discount = data['discount'] as String? ?? '';
              final isActive = data['isActive'] as bool? ?? true;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(code, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 1)),
                          const SizedBox(height: 2),
                          Text(discount, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Icon(isActive ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        size: 20, color: isActive ? AppColors.success : AppColors.error),
                  ],
                ),
              );
            }),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.4)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _couponCodeCtrl,
                        style: AppTextStyles.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'Coupon code',
                          hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textDim),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          filled: true,
                          fillColor: AppColors.surfaceMid,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.borderLight),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.borderLight.withValues(alpha: 0.5)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _couponDiscountCtrl,
                        style: AppTextStyles.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'Discount %',
                          hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textDim),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          filled: true,
                          fillColor: AppColors.surfaceMid,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.borderLight),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.borderLight.withValues(alpha: 0.5)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                GradientButton(
                  onPressed: _isReleasingCoupon ? null : _releaseCoupon,
                  height: 40,
                  gradient: AppColors.gradientAccent,
                  isLoading: _isReleasingCoupon,
                  child: const Text('Release New Coupon', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
