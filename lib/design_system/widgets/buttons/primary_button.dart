import 'package:flutter/material.dart';
import '../../colors/app_colors.dart';
import '../../typography/text_styles.dart';
import '../../radius/radius.dart';
import '../../spacing/spacing_scale.dart';
import '../../tokens/duration_tokens.dart';
import 'button_types.dart';

class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.loading = false,
    this.disabled = false,
    this.expanded = false,
    this.size = ButtonSize.lg,
  });

  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final bool loading;
  final bool disabled;
  final bool expanded;
  final ButtonSize size;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDisabled = widget.disabled || widget.loading;
    final bgColor = isDisabled
        ? (isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary)
        : AppColors.primary;
    final fgColor = isDisabled
        ? AppColors.textDisabled
        : AppColors.textInverse;

    final hPad = widget.size == ButtonSize.sm
        ? SpacingScale.s12
        : widget.size == ButtonSize.md
            ? SpacingScale.s16
            : SpacingScale.s20;
    final vPad = widget.size == ButtonSize.sm
        ? SpacingScale.s6
        : widget.size == ButtonSize.md
            ? SpacingScale.s8
            : SpacingScale.s10;
    final textStyle = widget.size == ButtonSize.sm
        ? AppTextStyles.buttonSm
        : widget.size == ButtonSize.md
            ? AppTextStyles.button
            : AppTextStyles.buttonLg;

    return AnimatedContainer(
      duration: DurationTokens.fast,
      curve: Curves.easeOut,
      width: widget.expanded ? double.infinity : null,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: DurationTokens.fast,
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: _hovered && !isDisabled ? AppColors.primaryHover : bgColor,
            borderRadius: AppRadius.brLg,
            border: Border.all(
              color: isDark ? AppColors.border : AppColors.lightBorder,
              width: 0.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isDisabled ? null : widget.onPressed,
              borderRadius: AppRadius.brLg,
              splashColor: AppColors.pressed,
              highlightColor: AppColors.hover,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
                child: AnimatedSwitcher(
                  duration: DurationTokens.medium,
                  child: widget.loading
                      ? SizedBox(
                          width: textStyle.fontSize ?? 14,
                          height: textStyle.fontSize ?? 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(fgColor),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(widget.icon,
                                  size: widget.size == ButtonSize.sm ? 16 : 18,
                                  color: fgColor),
                              SizedBox(width: SpacingScale.s6),
                            ],
                            Flexible(
                              child: Text(
                                widget.label,
                                style: textStyle.copyWith(color: fgColor),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ButtonSize is defined in button_types.dart
