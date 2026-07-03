import 'package:flutter/material.dart';
import '../../colors/app_colors.dart';
import '../../radius/radius.dart';
import '../../tokens/duration_tokens.dart';

class AppIconButton extends StatefulWidget {
  const AppIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size = 36,
    this.iconSize,
    this.tooltip,
    this.color,
    this.disabled = false,
    this.backgroundColor,
    this.outlined = false,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final double size;
  final double? iconSize;
  final String? tooltip;
  final Color? color;
  final bool disabled;
  final Color? backgroundColor;
  final bool outlined;

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDisabled = widget.disabled;
    final fgColor = isDisabled
        ? AppColors.textDisabled
        : widget.color ?? (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary);
    final bgColor = widget.backgroundColor ??
        (widget.outlined
            ? Colors.transparent
            : isDark
                ? AppColors.surfaceSecondary
                : AppColors.lightSurfaceSecondary);

    final border = widget.outlined
        ? Border.all(
            color: _hovered && !isDisabled ? AppColors.borderHover : AppColors.border,
            width: 1,
          )
        : null;

    final iconSize = widget.iconSize ?? widget.size * 0.5;

    final button = MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: DurationTokens.fast,
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: _hovered && !isDisabled
              ? (isDark ? AppColors.hover : AppColors.lightHover)
              : bgColor,
          borderRadius: AppRadius.brMd,
          border: border,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled ? null : widget.onPressed,
            borderRadius: AppRadius.brMd,
            splashColor: AppColors.pressed,
            child: Icon(widget.icon, size: iconSize, color: fgColor),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: button);
    }
    return button;
  }
}
