import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../design_system/radius/radius.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../design_system/widgets/page_headers/page_hero.dart';
import '../../../services/providers.dart';
import '../../../providers/auth_provider.dart';

class CouponsTab extends ConsumerStatefulWidget {
  const CouponsTab({super.key});

  @override
  ConsumerState<CouponsTab> createState() => _CouponsTabState();
}

class _CouponsTabState extends ConsumerState<CouponsTab> {
  final _codeCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _discountCtrl.dispose();
    super.dispose();
  }

  Future<void> _createCoupon() async {
    if (_codeCtrl.text.trim().isEmpty || _discountCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter code and discount'), backgroundColor: AppColors.warning),
      );
      return;
    }
    setState(() => _isCreating = true);
    try {
      await ref.read(authServiceProvider).addCoupon(
        code: _codeCtrl.text.trim(),
        discount: _discountCtrl.text.trim(),
        eligibility: 'All users',
      );
      _codeCtrl.clear();
      _discountCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coupon created'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final couponsAsync = ref.watch(couponsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          PageHero(
            title: 'Coupons',
            subtitle: 'Manage discounts and promotions',
            backgroundColor: AppColors.primary,
            expandedHeight: 120,
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
                SpacingScale.s16, SpacingScale.s16, SpacingScale.s16, SpacingScale.s32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildCreateCouponCard(isDark: isDark),
                const SizedBox(height: SpacingScale.s16),
                Animate(
                  effects: const [
                    FadeEffect(duration: Duration(milliseconds: 400)),
                    SlideEffect(
                        begin: Offset(0, 0.05),
                        end: Offset.zero,
                        duration: Duration(milliseconds: 400)),
                  ],
                  child: Row(children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: AppRadius.brLg,
                      ),
                      child: const Icon(Icons.list_alt_rounded, size: 18, color: AppColors.primary),
                    ),
                    const SizedBox(width: SpacingScale.s10),
                    Text(
                      'Active Coupons',
                      style: AppTextStyles.title2.copyWith(
                        color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: SpacingScale.s8),
                couponsAsync.when(
                  data: (snap) {
                    final docs = snap.docs;
                    if (docs.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(SpacingScale.s16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.card : AppColors.lightCard,
                          borderRadius: AppRadius.brXl3,
                          border: Border.all(
                              color: isDark ? AppColors.border : AppColors.lightBorder, width: 0.5),
                        ),
                        child: Center(
                          child: Text('No coupons yet',
                              style: AppTextStyles.body.copyWith(
                                  color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary)),
                        ),
                      );
                    }
                    return Column(
                      children: docs.map((doc) {
                        final data = doc.data();
                        return _buildCouponCard(
                          context: context,
                          isDark: isDark,
                          docId: doc.id,
                          code: data['code'] as String? ?? '',
                          discount: data['discount'] as String? ?? '',
                          eligibility: data['eligibility'] as String? ?? 'All users',
                          isActive: data['isActive'] as bool? ?? true,
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Text('Failed to load coupons',
                        style: TextStyle(color: AppColors.danger)),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateCouponCard({required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(SpacingScale.s16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl3,
        border: Border.all(
            color: isDark ? AppColors.border : AppColors.lightBorder, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.12),
                  borderRadius: AppRadius.brLg,
                ),
                child: const Icon(Icons.local_offer_rounded,
                    size: 18, color: AppColors.gold),
              ),
              const SizedBox(width: SpacingScale.s10),
              Text('Create New Coupon',
                  style: AppTextStyles.title3.copyWith(
                      color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: SpacingScale.s12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _codeCtrl,
                  style: AppTextStyles.body.copyWith(
                      color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary),
                  decoration: InputDecoration(
                    hintText: 'Coupon code',
                    hintStyle: AppTextStyles.bodySm.copyWith(
                        color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
                    filled: true,
                    fillColor: isDark ? AppColors.surface : AppColors.lightSurfaceSecondary,
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.brXl2,
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: SpacingScale.s12, vertical: SpacingScale.s10),
                  ),
                ),
              ),
              const SizedBox(width: SpacingScale.s8),
              Expanded(
                child: TextField(
                  controller: _discountCtrl,
                  style: AppTextStyles.body.copyWith(
                      color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary),
                  decoration: InputDecoration(
                    hintText: 'Discount',
                    hintStyle: AppTextStyles.bodySm.copyWith(
                        color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
                    filled: true,
                    fillColor: isDark ? AppColors.surface : AppColors.lightSurfaceSecondary,
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.brXl2,
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: SpacingScale.s12, vertical: SpacingScale.s10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingScale.s12),
          MouseRegion(
            cursor: _isCreating ? SystemMouseCursors.wait : SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _isCreating ? null : _createCoupon,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: SpacingScale.s12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight]),
                  borderRadius: AppRadius.brXl2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isCreating)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    else
                      const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                    const SizedBox(width: SpacingScale.s8),
                    Text(
                      _isCreating ? 'Creating...' : 'Create Coupon',
                      style: AppTextStyles.label.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponCard({
    required BuildContext context,
    required bool isDark,
    required String docId,
    required String code,
    required String discount,
    required String eligibility,
    required bool isActive,
  }) {
    final statusColor = isActive ? AppColors.success : AppColors.danger;
    return Container(
      margin: const EdgeInsets.only(bottom: SpacingScale.s8),
      padding: const EdgeInsets.all(SpacingScale.s16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl3,
        border: Border.all(
            color: isDark ? AppColors.border : AppColors.lightBorder, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.1),
              borderRadius: AppRadius.brLg,
            ),
            child: const Icon(Icons.local_offer_rounded,
                color: AppColors.gold, size: 22),
          ),
          const SizedBox(width: SpacingScale.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(code,
                        style: AppTextStyles.title3.copyWith(
                            color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1)),
                    const SizedBox(width: SpacingScale.s8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: SpacingScale.s6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: AppRadius.brSm,
                      ),
                      child: Text(isActive ? 'Active' : 'Expired',
                          style: AppTextStyles.labelSm.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: SpacingScale.s2),
                Text('$discount · $eligibility',
                    style: AppTextStyles.body.copyWith(
                        color: isDark
                            ? AppColors.textSecondary
                            : AppColors.lightTextSecondary)),
              ],
            ),
          ),
          if (isActive)
            Switch(
              value: true,
              onChanged: (val) {
                ref.read(authServiceProvider).toggleCouponStatus(docId, val);
              },
              activeThumbColor: AppColors.success,
              activeTrackColor: AppColors.success.withValues(alpha: 0.3),
              inactiveTrackColor: isDark
                  ? AppColors.surface
                  : AppColors.lightSurfaceSecondary,
            ),
        ],
      ),
    );
  }
}
