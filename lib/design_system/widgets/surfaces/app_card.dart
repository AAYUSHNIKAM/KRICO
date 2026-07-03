import 'package:flutter/material.dart';
import '../../colors/app_colors.dart';
import '../../radius/radius.dart';
import '../../spacing/spacing_scale.dart';
import '../../tokens/duration_tokens.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.color,
    this.elevated = false,
    this.border,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final bool elevated;
  final BoxBorder? border;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = color ?? (isDark ? AppColors.card : AppColors.lightCard);
    final borderColor = border ??
        Border.all(
          color: isDark ? AppColors.border : AppColors.lightBorder,
          width: 0.5,
        );

    return AnimatedContainer(
      duration: DurationTokens.medium,
      margin: margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.xl2),
        border: elevated ? null : borderColor,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.xl2),
          splashColor: AppColors.pressed,
          highlightColor: AppColors.hover,
          child: Padding(
            padding: padding ?? SpacingScale.card,
            child: child,
          ),
        ),
      ),
    );
  }
}
