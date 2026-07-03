import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../colors/app_colors.dart';
import '../../radius/radius.dart';

class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({
    super.key,
    this.width,
    this.height = 14,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
  });

  final double? width;
  final double height;
  final double? borderRadius;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.shimmerBase : AppColors.lightShimmerBase,
      highlightColor: isDark ? AppColors.shimmerHighlight : AppColors.lightShimmerHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? AppColors.shimmerBase : AppColors.lightShimmerBase,
          borderRadius: shape == BoxShape.rectangle
              ? BorderRadius.circular(borderRadius ?? AppRadius.sm)
              : null,
          shape: shape,
        ),
      ),
    );
  }
}

class CardShimmer extends StatelessWidget {
  const CardShimmer({super.key, this.count = 3});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildRow(),
      ),
    );
  }

  Widget _buildRow() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: AppRadius.brXl2,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const ShimmerLoading(
              width: 44,
              height: 44,
              borderRadius: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerLoading(width: double.infinity, height: 14),
                  SizedBox(height: 8),
                  ShimmerLoading(width: 160, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
