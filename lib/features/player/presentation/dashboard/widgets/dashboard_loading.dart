import 'package:flutter/material.dart';
import '../../../../../design_system/colors/app_colors.dart';
import '../../../../../design_system/radius/radius.dart';
import '../../../../../design_system/spacing/spacing_scale.dart';
import '../../../../../design_system/widgets/surfaces/shimmer_widget.dart';

class DashboardHeaderShimmer extends StatelessWidget {
  const DashboardHeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerLoading(width: 120, height: 12),
                    SizedBox(height: SpacingScale.s12),
                    ShimmerLoading(width: 140, height: 18),
                    SizedBox(height: SpacingScale.s8),
                    ShimmerLoading(width: 200, height: 32),
                    SizedBox(height: SpacingScale.s8),
                    ShimmerLoading(width: 160, height: 14),
                  ],
                ),
              ),
              const ShimmerLoading(width: 64, height: 64, borderRadius: 32),
            ],
          ),
          const SizedBox(height: SpacingScale.s20),
          SizedBox(
            height: 24,
            child: Row(
              children: const [
                ShimmerLoading(width: 80, height: 24, borderRadius: 12),
                SizedBox(width: SpacingScale.s8),
                ShimmerLoading(width: 80, height: 24, borderRadius: 12),
              ],
            ),
          ),
          const SizedBox(height: SpacingScale.s20),
          const ShimmerLoading(width: double.infinity, height: 6, borderRadius: 3),
          const SizedBox(height: SpacingScale.s8),
          const ShimmerLoading(width: 140, height: 12),
        ],
      ),
    );
  }
}

class DashboardKpiShimmer extends StatelessWidget {
  const DashboardKpiShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerLoading(width: 100, height: 18),
          const SizedBox(height: SpacingScale.s16),
          SizedBox(
            height: 160,
            child: Row(
              children: const [
                Expanded(child: _KpiCardShimmer()),
                SizedBox(width: SpacingScale.s12),
                Expanded(child: _KpiCardShimmer()),
              ],
            ),
          ),
          const SizedBox(height: SpacingScale.s12),
          SizedBox(
            height: 160,
            child: Row(
              children: const [
                Expanded(child: _KpiCardShimmer()),
                SizedBox(width: SpacingScale.s12),
                Expanded(child: _KpiCardShimmer()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiCardShimmer extends StatelessWidget {
  const _KpiCardShimmer();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl2,
        border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 3, color: isDark ? AppColors.divider : AppColors.lightDivider),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(SpacingScale.s12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerLoading(width: 36, height: 36, borderRadius: 8),
                  SizedBox(height: SpacingScale.s8),
                  ShimmerLoading(width: 60, height: 24),
                  SizedBox(height: SpacingScale.s4),
                  ShimmerLoading(width: 80, height: 12),
                  SizedBox(height: SpacingScale.s2),
                  ShimmerLoading(width: 60, height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardSectionShimmer extends StatelessWidget {
  final double height;
  const DashboardSectionShimmer({super.key, this.height = 200});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s16),
      child: SizedBox(
        height: height,
        child: Container(
          padding: SpacingScale.card,
          decoration: BoxDecoration(
            color: isDark ? AppColors.card : AppColors.lightCard,
            borderRadius: AppRadius.brXl2,
            border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder, width: 0.5),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerLoading(width: 120, height: 16),
              SizedBox(height: SpacingScale.s16),
              Expanded(child: ShimmerLoading(width: double.infinity, height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}
