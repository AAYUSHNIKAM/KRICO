import 'package:flutter/material.dart';
import '../../../../../design_system/colors/app_colors.dart';
import '../../../../../design_system/radius/radius.dart';
import '../../../../../design_system/spacing/spacing_scale.dart';
import '../../../../../design_system/widgets/surfaces/shimmer_widget.dart';

class AcademyDashboardHeaderShimmer extends StatelessWidget {
  const AcademyDashboardHeaderShimmer({super.key});

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
              const ShimmerLoading(width: 56, height: 56, borderRadius: 12),
              const SizedBox(width: SpacingScale.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerLoading(width: 100, height: 12),
                    SizedBox(height: SpacingScale.s8),
                    ShimmerLoading(width: 160, height: 24),
                    SizedBox(height: SpacingScale.s4),
                    ShimmerLoading(width: 120, height: 14),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingScale.s20),
          const Row(
            children: [
              ShimmerLoading(width: 100, height: 24, borderRadius: 12),
              SizedBox(width: SpacingScale.s8),
              ShimmerLoading(width: 80, height: 24, borderRadius: 12),
            ],
          ),
        ],
      ),
    );
  }
}

class AcademyDashboardSectionShimmer extends StatelessWidget {
  final double height;
  const AcademyDashboardSectionShimmer({super.key, this.height = 200});

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

class AcademyDashboardKpiShimmer extends StatelessWidget {
  const AcademyDashboardKpiShimmer({super.key});

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
