import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../colors/app_colors.dart';
import '../../spacing/spacing_scale.dart';
import '../../radius/radius.dart';

class PremiumHeaderShimmer extends StatelessWidget {
  const PremiumHeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppColors.shimmerBase : AppColors.lightShimmerBase;
    final highlight = isDark ? AppColors.shimmerHighlight : AppColors.lightShimmerHighlight;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        SpacingScale.s16, SpacingScale.s32, SpacingScale.s16, SpacingScale.s24,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.border : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
      ),
      child: Shimmer.fromColors(
        baseColor: base,
        highlightColor: highlight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 120, height: 12, decoration: BoxDecoration(color: base, borderRadius: AppRadius.brSm)),
                      const SizedBox(height: SpacingScale.s12),
                      Container(width: 140, height: 18, decoration: BoxDecoration(color: base, borderRadius: AppRadius.brSm)),
                      const SizedBox(height: SpacingScale.s8),
                      Container(width: 200, height: 32, decoration: BoxDecoration(color: base, borderRadius: AppRadius.brSm)),
                    ],
                  ),
                ),
                const SizedBox(width: SpacingScale.s16),
                Container(width: 64, height: 64, decoration: BoxDecoration(color: base, shape: BoxShape.circle)),
              ],
            ),
            const SizedBox(height: SpacingScale.s20),
            SizedBox(
              height: 24,
              child: Row(
                children: [
                  Container(width: 80, height: 24, decoration: BoxDecoration(color: base, borderRadius: AppRadius.brFull)),
                  const SizedBox(width: SpacingScale.s8),
                  Container(width: 80, height: 24, decoration: BoxDecoration(color: base, borderRadius: AppRadius.brFull)),
                  const SizedBox(width: SpacingScale.s8),
                  Container(width: 80, height: 24, decoration: BoxDecoration(color: base, borderRadius: AppRadius.brFull)),
                ],
              ),
            ),
            const SizedBox(height: SpacingScale.s20),
            Container(width: double.infinity, height: 6, decoration: BoxDecoration(color: base, borderRadius: AppRadius.brFull)),
            const SizedBox(height: SpacingScale.s8),
            Container(width: 140, height: 12, decoration: BoxDecoration(color: base, borderRadius: AppRadius.brSm)),
          ],
        ),
      ),
    );
  }
}

class PremiumSectionShimmer extends StatelessWidget {
  final double height;

  const PremiumSectionShimmer({super.key, this.height = 200});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppColors.shimmerBase : AppColors.lightShimmerBase;
    final highlight = isDark ? AppColors.shimmerHighlight : AppColors.lightShimmerHighlight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s16),
      child: SizedBox(
        height: height,
        child: Shimmer.fromColors(
          baseColor: base,
          highlightColor: highlight,
          child: Container(
            padding: SpacingScale.card,
            decoration: BoxDecoration(
              color: isDark ? AppColors.card : AppColors.lightCard,
              borderRadius: AppRadius.brXl2,
              border: Border.all(
                color: isDark ? AppColors.border : AppColors.lightBorder,
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 120, height: 16, decoration: BoxDecoration(color: base, borderRadius: AppRadius.brSm)),
                const SizedBox(height: SpacingScale.s16),
                Expanded(child: Container(width: double.infinity, height: 100, decoration: BoxDecoration(color: base, borderRadius: AppRadius.brSm))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PremiumCardShimmer extends StatelessWidget {
  const PremiumCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppColors.shimmerBase : AppColors.lightShimmerBase;
    final highlight = isDark ? AppColors.shimmerHighlight : AppColors.lightShimmerHighlight;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        padding: const EdgeInsets.all(SpacingScale.s16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.card : AppColors.lightCard,
          borderRadius: AppRadius.brXl2,
          border: Border.all(
            color: isDark ? AppColors.border : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: base, borderRadius: AppRadius.brXl)),
            const SizedBox(width: SpacingScale.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: double.infinity, height: 14, decoration: BoxDecoration(color: base, borderRadius: AppRadius.brSm)),
                  const SizedBox(height: SpacingScale.s8),
                  Container(width: 160, height: 12, decoration: BoxDecoration(color: base, borderRadius: AppRadius.brSm)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
