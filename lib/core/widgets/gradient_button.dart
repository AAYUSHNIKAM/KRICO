import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.gradient,
    this.height = 52,
    this.width,
    this.borderRadius = 12,
    this.isLoading = false,
    this.loadingColor = Colors.white,
    this.elevation = 0,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final List<Color>? gradient;
  final double height;
  final double? width;
  final double borderRadius;
  final bool isLoading;
  final Color loadingColor;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: isDisabled
            ? LinearGradient(
                colors: [
                  Colors.grey.shade400,
                  Colors.grey.shade500,
                ],
              )
            : LinearGradient(
                colors: gradient ??
                    (Theme.of(context).brightness == Brightness.dark
                        ? AppColors.gradientPrimary
                        : AppColors.gradientPrimary),
              ),
        boxShadow: isDisabled
            ? []
            : [
                BoxShadow(
                  color: (gradient ?? AppColors.gradientPrimary).first
                      .withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Center(
            child: isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
                    ),
                  )
                : child,
          ),
        ),
      ),
    );
  }
}

class GradientOutlinedButton extends StatelessWidget {
  const GradientOutlinedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.gradient = AppColors.gradientPrimary,
    this.height = 52,
    this.width,
    this.borderRadius = 12,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final List<Color> gradient;
  final double height;
  final double? width;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(colors: gradient),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius - 1),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            margin: const EdgeInsets.all(1.5),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
