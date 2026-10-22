import 'package:flutter/material.dart';
import '../../colors/app_colors.dart';
import '../../typography/text_styles.dart';
import '../../tokens/duration_tokens.dart';
import 'button_types.dart';

class AppTextButton extends StatefulWidget {
  const AppTextButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.color,
    this.size = TextButtonSize.md,
    this.disabled = false,
    this.underline = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final Color? color;
  final TextButtonSize size;
  final bool disabled;
  final bool underline;

  @override
  State<AppTextButton> createState() => _AppTextButtonState();
}

class _AppTextButtonState extends State<AppTextButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDisabled = widget.disabled;
    final defaultColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final activeColor = widget.color ?? AppColors.primary;
    final fgColor = isDisabled ? AppColors.textDisabled : (_hovered ? activeColor : defaultColor);

    final textStyle = widget.size == TextButtonSize.sm
        ? AppTextStyles.labelSm
        : widget.size == TextButtonSize.md
            ? AppTextStyles.label
            : AppTextStyles.button;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: DurationTokens.fast,
        child: GestureDetector(
          onTap: isDisabled ? null : widget.onPressed,
          child: AnimatedDefaultTextStyle(
            duration: DurationTokens.fast,
            style: textStyle.copyWith(
              color: fgColor,
              decoration: widget.underline && _hovered ? TextDecoration.underline : TextDecoration.none,
              decorationColor: fgColor,
            ),
            child: Text(widget.label),
          ),
        ),
      ),
    );
  }
}

