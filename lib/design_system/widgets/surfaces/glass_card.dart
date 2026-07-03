import 'dart:ui';
import 'package:flutter/material.dart';
import '../../colors/app_colors.dart';
import '../../radius/radius.dart';
import '../../spacing/spacing_scale.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: margin ?? EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.xl2),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: padding ?? SpacingScale.card,
            decoration: BoxDecoration(
              color: (isDark ? AppColors.glass : AppColors.lightGlass).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.xl2),
              border: Border.all(
                color: isDark
                    ? AppColors.border.withValues(alpha: 0.4)
                    : AppColors.lightBorder.withValues(alpha: 0.6),
                width: 0.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
