import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../design_system/colors/app_colors.dart';
import '../../../../../design_system/typography/text_styles.dart';
import '../../../../../design_system/spacing/spacing_scale.dart';
import '../../../../../design_system/radius/radius.dart';
import '../../../../../services/providers.dart';

class AdminStatsSection extends ConsumerWidget {
  const AdminStatsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final usersAsync = ref.watch(allUsersProvider);
    final venuesAsync = ref.watch(venuesStreamProvider);
    final revenueAsync = ref.watch(totalRevenueProvider);
    final activeUsersAsync = ref.watch(activeUsersCountProvider);
    final totalUsers = usersAsync.asData?.value.docs.length ?? 0;
    final totalVenues = venuesAsync.asData?.value.length ?? 0;
    final totalRevenue = revenueAsync.asData?.value ?? 0;
    final activeUsers = activeUsersAsync.asData?.value ?? 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _AdminStatCard(
                value: '$totalUsers',
                label: 'Total Users',
                icon: Icons.people_rounded,
                iconColor: AppColors.primary,
                isDark: isDark,
              ).animate().fade(duration: 400.ms).slideX(begin: -0.1),
            ),
            SizedBox(width: SpacingScale.s12),
            Expanded(
              child: _AdminStatCard(
                value: '$totalVenues',
                label: 'Venues',
                icon: Icons.stadium_rounded,
                iconColor: AppColors.success,
                isDark: isDark,
              ).animate().fade(duration: 400.ms, delay: 100.ms).slideX(begin: 0.1),
            ),
          ],
        ),
        SizedBox(height: SpacingScale.s12),
        Row(
          children: [
            Expanded(
              child: _AdminStatCard(
                value: '₹${totalRevenue.toStringAsFixed(0)}',
                label: 'Revenue',
                icon: Icons.account_balance_rounded,
                iconColor: AppColors.gold,
                isDark: isDark,
              ).animate().fade(duration: 400.ms, delay: 200.ms).slideX(begin: -0.1),
            ),
            SizedBox(width: SpacingScale.s12),
            Expanded(
              child: _AdminStatCard(
                value: '$activeUsers',
                label: 'Active Users',
                icon: Icons.trending_up_rounded,
                iconColor: AppColors.primary,
                isDark: isDark,
              ).animate().fade(duration: 400.ms, delay: 300.ms).slideX(begin: 0.1),
            ),
          ],
        ),
      ],
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;
  final bool isDark;

  const _AdminStatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SpacingScale.s16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl3,
        border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: AppRadius.brLg,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          SizedBox(height: SpacingScale.s12),
          Text(value, style: AppTextStyles.heading2.copyWith(fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary)),
          SizedBox(height: SpacingScale.s4),
          Text(label, style: AppTextStyles.label.copyWith(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
        ],
      ),
    );
  }
}
