import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../design_system/colors/app_colors.dart';
import '../../../../../design_system/typography/text_styles.dart';
import '../../../../../design_system/spacing/spacing_scale.dart';
import '../../../../../design_system/radius/radius.dart';
import '../../../../../design_system/responsive/responsive_helpers.dart';
import '../../../../../design_system/widgets/buttons/primary_button.dart';
import '../../../../../models/coach_model.dart';

class CoachSubscriptionSection extends ConsumerWidget {
  final CoachModel coach;

  const CoachSubscriptionSection({super.key, required this.coach});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;
    final padH = isDesktop ? SpacingScale.s32 : (isTablet ? SpacingScale.s24 : SpacingScale.s16);
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final secColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    final price = coach.subscriptionTier == 'Professional'
        ? 499
        : coach.subscriptionTier == 'Premium'
            ? 999
            : 0;
    final expiryStr = coach.subscriptionExpiry != null
        ? 'Renewal: ${_formatDate(coach.subscriptionExpiry!)}'
        : 'No expiry date';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: isDesktop ? SpacingScale.s28 : SpacingScale.s24),
          Container(
            decoration: BoxDecoration(
              borderRadius: AppRadius.brXl3,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.05),
                  AppColors.primaryLight.withValues(alpha: 0.08),
                ],
              ),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 0.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(SpacingScale.s24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: AppRadius.brLg,
                        ),
                        child: const Icon(Icons.workspace_premium_rounded, size: 18, color: AppColors.primary),
                      ),
                      const SizedBox(width: SpacingScale.s10),
                      Text('Subscription', style: AppTextStyles.title2.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      )),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s8, vertical: SpacingScale.s4),
                        decoration: BoxDecoration(
                          color: (coach.isSubscribed ? AppColors.emerald : AppColors.warning).withValues(alpha: 0.1),
                          borderRadius: AppRadius.brFull,
                        ),
                        child: Text(
                          coach.isSubscribed ? 'Active' : 'Inactive',
                          style: AppTextStyles.labelSm.copyWith(
                            color: coach.isSubscribed ? AppColors.emerald : AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SpacingScale.s20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(coach.subscriptionTier,
                        style: AppTextStyles.heading1.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                        )),
                      const SizedBox(width: SpacingScale.s8),
                      if (price > 0) ...[
                        Text('\u20B9$price/mo',
                          style: AppTextStyles.title2.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          )),
                      ] else
                        Text('Free Tier',
                          style: AppTextStyles.title2.copyWith(color: secColor)),
                    ],
                  ),
                  const SizedBox(height: SpacingScale.s4),
                  Text(expiryStr, style: AppTextStyles.body.copyWith(color: secColor)),
                  const SizedBox(height: SpacingScale.s20),
                  PrimaryButton(
                    onPressed: () => _showManageSubscription(context),
                    label: 'Manage Plan',
                    icon: Icons.settings_rounded,
                  ),
                ],
              ),
            ),
          ).animate(delay: 350.ms).fadeIn(duration: 350.ms).slideY(begin: 0.06, end: 0),
        ],
      ),
    );
  }

  void _showManageSubscription(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(SpacingScale.s20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.border : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: SpacingScale.s20),
            Text('Manage Plan', style: AppTextStyles.title1.copyWith(
              color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
            )),
            const SizedBox(height: SpacingScale.s16),
            _planOption(ctx, 'Starter', '\u20B90/mo', 'Basic features', coach.subscriptionTier == 'Starter', isDark),
            const SizedBox(height: SpacingScale.s8),
            _planOption(ctx, 'Professional', '\u20B9499/mo', 'Advanced analytics, priority support', coach.subscriptionTier == 'Professional', isDark),
            const SizedBox(height: SpacingScale.s8),
            _planOption(ctx, 'Premium', '\u20B9999/mo', 'All features, unlimited sessions, dedicated manager', coach.subscriptionTier == 'Premium', isDark),
            const SizedBox(height: SpacingScale.s20),
          ],
        ),
      ),
    );
  }

  Widget _planOption(BuildContext context, String name, String price, String desc, bool isCurrent, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(SpacingScale.s16),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppColors.primary.withValues(alpha: 0.1)
            : (isDark ? AppColors.card : AppColors.lightCard),
        borderRadius: AppRadius.brXl2,
        border: isCurrent
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
            : Border.all(color: isDark ? AppColors.border : AppColors.lightBorder, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.title3.copyWith(
                  color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                  fontWeight: FontWeight.w600,
                )),
                const SizedBox(height: SpacingScale.s2),
                Text(desc, style: AppTextStyles.caption.copyWith(
                  color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                )),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: AppTextStyles.buttonLg.copyWith(color: AppColors.primary)),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: AppRadius.brFull,
                  ),
                  child: Text('Current', style: AppTextStyles.caption.copyWith(
                    color: AppColors.success,
                    fontSize: 9,
                  )),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
}
