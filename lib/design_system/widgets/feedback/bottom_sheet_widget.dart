import 'package:flutter/material.dart';
import '../../colors/app_colors.dart';
import '../../radius/radius.dart';
import '../../spacing/spacing_scale.dart';

class AppBottomSheet {
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    String? title,
    double? height,
    bool draggable = true,
    bool useSafeArea = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.card : AppColors.lightCard;

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: AppColors.overlay,
      builder: (ctx) => Container(
        height: height,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl3),
          ),
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.border : AppColors.lightBorder,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          bottom: useSafeArea,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (draggable)
                Padding(
                  padding: const EdgeInsets.only(top: SpacingScale.s8, bottom: SpacingScale.s4),
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              if (title != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SpacingScale.s16,
                    SpacingScale.s8,
                    SpacingScale.s16,
                    SpacingScale.s4,
                  ),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
              Flexible(child: child),
              SizedBox(height: MediaQuery.of(ctx).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }
}
