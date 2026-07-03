import 'package:flutter/material.dart';
import '../../colors/app_colors.dart';
import '../../typography/text_styles.dart';
import '../../radius/radius.dart';
import '../../spacing/spacing_scale.dart';

class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.icon,
    this.iconColor,
    this.confirmColor,
    this.destructive = false,
  });

  final String title;
  final Widget content;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final IconData? icon;
  final Color? iconColor;
  final Color? confirmColor;
  final bool destructive;

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required Widget content,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    VoidCallback? onConfirm,
    IconData? icon,
    bool destructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AppDialog(
        title: title,
        content: content,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: onConfirm,
        icon: icon,
        destructive: destructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.card : AppColors.lightCard;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: SpacingScale.s24),
      child: Container(
        padding: SpacingScale.card,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadius.brXl2,
          border: Border.all(
            color: isDark ? AppColors.border : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
                  borderRadius: AppRadius.brXl2,
                ),
                child: Icon(icon, color: iconColor ?? AppColors.primary, size: 24),
              ),
              SizedBox(height: SpacingScale.s16),
            ],
            Text(
              title,
              style: AppTextStyles.title1.copyWith(
                color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: SpacingScale.s8),
            DefaultTextStyle(
              style: AppTextStyles.body.copyWith(
                color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
              child: content,
            ),
            SizedBox(height: SpacingScale.s24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      onCancel?.call();
                      Navigator.of(context).pop(false);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                      side: BorderSide(
                        color: isDark ? AppColors.border : AppColors.lightBorder,
                      ),
                      foregroundColor: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                    ),
                    child: Text(cancelLabel, style: AppTextStyles.button),
                  ),
                ),
                SizedBox(width: SpacingScale.s12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      onConfirm?.call();
                      Navigator.of(context).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                      backgroundColor: destructive
                          ? AppColors.danger
                          : (confirmColor ?? AppColors.primary),
                      foregroundColor: AppColors.textInverse,
                      elevation: 0,
                    ),
                    child: Text(confirmLabel, style: AppTextStyles.button),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
