import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../design_system/colors/app_colors.dart';
import '../../../../../design_system/typography/text_styles.dart';
import '../../../../../design_system/spacing/spacing_scale.dart';
import '../../../../../design_system/radius/radius.dart';
import '../../../../../services/providers.dart';
import '../../../../../providers/auth_provider.dart';
import 'admin_section_header.dart';

class AdminCouponSection extends ConsumerStatefulWidget {
  const AdminCouponSection({super.key});

  @override
  ConsumerState<AdminCouponSection> createState() => _AdminCouponSectionState();
}

class _AdminCouponSectionState extends ConsumerState<AdminCouponSection> {
  final _couponCodeCtrl = TextEditingController();
  final _couponDiscountCtrl = TextEditingController();
  bool _isReleasingCoupon = false;

  @override
  void dispose() {
    _couponCodeCtrl.dispose();
    _couponDiscountCtrl.dispose();
    super.dispose();
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
          SnackBar(content: Text('Failed to release coupon: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isReleasingCoupon = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final couponList = ref.watch(couponsProvider).asData?.value.docs ?? [];
    final activeCount = couponList.where((d) {
      final data = d.data();
      return data['isActive'] as bool? ?? true;
    }).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminSectionHeader(title: 'Premium Coupons', subtitle: 'Manage discount coupons'),
        SizedBox(height: SpacingScale.s12),
        Container(
          padding: EdgeInsets.all(SpacingScale.s16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.card : AppColors.lightCard,
            borderRadius: AppRadius.brXl3,
            border: Border.all(color: AppColors.orange.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.orange.withValues(alpha: 0.12),
                      borderRadius: AppRadius.brLg,
                    ),
                    child: const Icon(Icons.local_offer_rounded, color: AppColors.orange, size: 20),
                  ),
                  SizedBox(width: SpacingScale.s10),
                  Text('Active Coupons', style: AppTextStyles.title3.copyWith(fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary)),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: SpacingScale.s10, vertical: SpacingScale.s4),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: AppRadius.brLg,
                    ),
                    child: Text('$activeCount Active', style: AppTextStyles.labelSm.copyWith(color: AppColors.gold, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              SizedBox(height: SpacingScale.s16),
              if (couponList.isEmpty)
                Container(
                  padding: EdgeInsets.all(SpacingScale.s12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surface : AppColors.lightSurfaceSecondary,
                    borderRadius: AppRadius.brLg,
                    border: Border.all(color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.4)),
                  ),
                  child: Center(
                    child: Text('No coupons yet. Release your first coupon below.',
                        style: AppTextStyles.caption.copyWith(color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary)),
                  ),
                )
              else
                ...couponList.take(3).map((doc) {
                  final data = doc.data();
                  final code = data['code'] as String? ?? '';
                  final discount = data['discount'] as String? ?? '';
                  final isActive = data['isActive'] as bool? ?? true;
                  return Container(
                    margin: EdgeInsets.only(bottom: SpacingScale.s6),
                    padding: EdgeInsets.all(SpacingScale.s12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surface : AppColors.lightSurfaceSecondary,
                      borderRadius: AppRadius.brLg,
                      border: Border.all(color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(code, style: AppTextStyles.buttonLg.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 1)),
                              SizedBox(height: SpacingScale.s2),
                              Text(discount, style: AppTextStyles.caption.copyWith(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
                            ],
                          ),
                        ),
                        Icon(isActive ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            size: 20, color: isActive ? AppColors.success : AppColors.danger),
                      ],
                    ),
                  );
                }),
              SizedBox(height: SpacingScale.s16),
              Container(
                padding: EdgeInsets.all(SpacingScale.s12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surface : AppColors.lightSurfaceSecondary,
                  borderRadius: AppRadius.brLg,
                  border: Border.all(color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.4)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _couponCodeCtrl,
                            style: AppTextStyles.body.copyWith(color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary),
                            decoration: InputDecoration(
                              hintText: 'Coupon code',
                              hintStyle: AppTextStyles.bodySm.copyWith(color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: SpacingScale.s12, vertical: SpacingScale.s10),
                              filled: true,
                              fillColor: isDark ? AppColors.surface : AppColors.lightSurfaceSecondary,
                              border: OutlineInputBorder(
                                borderRadius: AppRadius.brLg,
                                borderSide: BorderSide(color: isDark ? AppColors.border : AppColors.lightBorder),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: AppRadius.brLg,
                                borderSide: BorderSide(color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5)),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: SpacingScale.s8),
                        Expanded(
                          child: TextField(
                            controller: _couponDiscountCtrl,
                            style: AppTextStyles.body.copyWith(color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary),
                            decoration: InputDecoration(
                              hintText: 'Discount %',
                              hintStyle: AppTextStyles.bodySm.copyWith(color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: SpacingScale.s12, vertical: SpacingScale.s10),
                              filled: true,
                              fillColor: isDark ? AppColors.surface : AppColors.lightSurfaceSecondary,
                              border: OutlineInputBorder(
                                borderRadius: AppRadius.brLg,
                                borderSide: BorderSide(color: isDark ? AppColors.border : AppColors.lightBorder),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: AppRadius.brLg,
                                borderSide: BorderSide(color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: SpacingScale.s10),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: _isReleasingCoupon ? null : _releaseCoupon,
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [AppColors.primary, AppColors.orange]),
                            borderRadius: AppRadius.brXl2,
                          ),
                          child: Center(
                            child: _isReleasingCoupon
                                ? const SizedBox(
                                    width: 20, height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Text('Release New Coupon', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
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
}
