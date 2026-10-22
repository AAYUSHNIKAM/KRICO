import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../design_system/radius/radius.dart';
import '../../../design_system/widgets/surfaces/shimmer_widget.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/providers.dart';
import 'dashboard/academy_dashboard_page.dart';

class AcademyDashboard extends ConsumerWidget {
  const AcademyDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateProvider);
    return authAsync.when(
      data: (firebaseUser) {
        if (firebaseUser == null) {
          return Scaffold(
            body: Center(
              child: Text('Please sign in to view your dashboard',
                  style: AppTextStyles.bodyLg),
            ),
          );
        }
        final academyAsync = ref.watch(academyProvider(firebaseUser.uid));
        return academyAsync.when(
          data: (academy) => AcademyDashboardPage(academy: academy),
          loading: () => const _DashboardLoading(),
          error: (e, _) => Scaffold(
            body: Center(
                child: Text('Error: $e', style: AppTextStyles.bodyLg)),
          ),
        );
      },
      loading: () => const _DashboardLoading(),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e', style: AppTextStyles.bodyLg)),
      ),
    );
  }
}

class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(SpacingScale.s16, SpacingScale.s32, SpacingScale.s16, SpacingScale.s24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surface : AppColors.lightSurface,
              border: Border(bottom: BorderSide(color: isDark ? AppColors.border : AppColors.lightBorder, width: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const ShimmerLoading(width: 56, height: 56, borderRadius: 12),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          ShimmerLoading(width: 100, height: 12),
                          SizedBox(height: 8),
                          ShimmerLoading(width: 160, height: 24),
                          SizedBox(height: 4),
                          ShimmerLoading(width: 120, height: 14),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: _shimmerCard(isDark)),
                const SizedBox(width: 12),
                Expanded(child: _shimmerCard(isDark)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: _shimmerCard(isDark)),
                const SizedBox(width: 12),
                Expanded(child: _shimmerCard(isDark)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: isDark ? AppColors.card : AppColors.lightCard,
                borderRadius: AppRadius.brXl2,
                border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder, width: 0.5),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLoading(width: 120, height: 16),
                    SizedBox(height: 16),
                    Expanded(child: ShimmerLoading(width: double.infinity, height: 100)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl2,
        border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder, width: 0.5),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoading(width: 36, height: 36, borderRadius: 8),
          SizedBox(height: 12),
          ShimmerLoading(width: 60, height: 24),
          SizedBox(height: 4),
          ShimmerLoading(width: 80, height: 12),
        ],
      ),
    );
  }
}
