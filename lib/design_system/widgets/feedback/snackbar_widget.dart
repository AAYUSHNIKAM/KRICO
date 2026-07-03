import 'package:flutter/material.dart';
import '../../colors/app_colors.dart';
import '../../typography/text_styles.dart';
import '../../radius/radius.dart';
import '../../spacing/spacing_scale.dart';

class AppSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.body.copyWith(
            color: isDark ? AppColors.textPrimary : Colors.white,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.brXl2),
        backgroundColor: isDark ? AppColors.surfaceElevated : const Color(0xFF18181B),
        duration: duration,
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingScale.s16,
          vertical: SpacingScale.s12,
        ),
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: AppColors.primary,
                onPressed: onAction ?? () {},
              )
            : null,
      ),
    );
  }
}
