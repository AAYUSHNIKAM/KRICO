import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/section_header.dart';
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
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final couponsAsync = ref.watch(couponsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.gradientGold,
                  ),
                ),
                padding: EdgeInsets.fromLTRB(
                    20, MediaQuery.of(context).padding.top + 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Coupons',
                        style: AppTextStyles.headlineMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                    Text('Manage discounts and promotions',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.7))),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildCreateCouponCard(),
                const SizedBox(height: 16),
                Animate(
                  effects: const [
                    FadeEffect(duration: Duration(milliseconds: 400)),
                    SlideEffect(
                        begin: Offset(0, 0.05),
                        end: Offset.zero,
                        duration: Duration(milliseconds: 400)),
                  ],
                  child: const SectionHeader(title: 'Active Coupons'),
                ),
                const SizedBox(height: 8),
                couponsAsync.when(
                  data: (snap) {
                    final docs = snap.docs;
                    if (docs.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Center(
                          child: Text('No coupons yet',
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDim)),
                        ),
                      );
                    }
                    return Column(
                      children: docs.map((doc) {
                        final data = doc.data();
                        return _buildCouponCard(
                          context: context,
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
                    child: Text('Failed to load coupons', style: TextStyle(color: AppColors.error)),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateCouponCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.gold.withValues(alpha: 0.05),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.local_offer_rounded,
                  color: AppColors.gold),
              const SizedBox(width: 8),
              Text('Create New Coupon',
                  style: AppTextStyles.titleSmall
                      .copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _codeCtrl,
                  decoration: InputDecoration(
                    hintText: 'Coupon code',
                    hintStyle: TextStyle(
                        color: AppColors.textDim, fontSize: 13),
                    filled: true,
                    fillColor: AppColors.surfaceDark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _discountCtrl,
                  decoration: InputDecoration(
                    hintText: 'Discount',
                    hintStyle: TextStyle(
                        color: AppColors.textDim, fontSize: 13),
                    filled: true,
                    fillColor: AppColors.surfaceDark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GradientButton(
            onPressed: _isCreating ? null : _createCoupon,
            height: 40,
            isLoading: _isCreating,
            child: const Text('Create Coupon',
                style: TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponCard({
    required BuildContext context,
    required String docId,
    required String code,
    required String discount,
    required String eligibility,
    required bool isActive,
  }) {
    final statusColor = isActive ? AppColors.success : AppColors.error;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.local_offer_rounded,
                color: AppColors.gold, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(code,
                        style: AppTextStyles.titleSmall.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(isActive ? 'Active' : 'Expired',
                          style: AppTextStyles.overline.copyWith(
                              color: statusColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text('$discount · $eligibility',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
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
            ),
        ],
      ),
    );
  }
}
