import 'dart:ui';
import 'package:flutter/material.dart';
import '../../colors/app_colors.dart';
import '../../typography/text_styles.dart';
import '../../radius/radius.dart';
import '../../spacing/spacing_scale.dart';
import '../../tokens/duration_tokens.dart';

class GlassButton extends StatefulWidget {
  const GlassButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.loading = false,
    this.disabled = false,
    this.expanded = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final bool loading;
  final bool disabled;
  final bool expanded;

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDisabled = widget.disabled || widget.loading;
    final fgColor = isDisabled
        ? AppColors.textDisabled
        : (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary);

    return AnimatedContainer(
      duration: DurationTokens.fast,
      width: widget.expanded ? double.infinity : null,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: ClipRRect(
          borderRadius: AppRadius.brLg,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: AnimatedContainer(
              duration: DurationTokens.fast,
              decoration: BoxDecoration(
                color: (isDark ? AppColors.glass : AppColors.lightGlass).withValues(
                  alpha: _hovered ? 0.12 : 0.08,
                ),
                borderRadius: AppRadius.brLg,
                border: Border.all(
                  color: isDark
                      ? AppColors.border.withValues(alpha: 0.5)
                      : AppColors.lightBorder,
                  width: 0.5,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isDisabled ? null : widget.onPressed,
                  borderRadius: AppRadius.brLg,
                  splashColor: AppColors.pressed,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingScale.s20,
                      vertical: SpacingScale.s10,
                    ),
                    child: widget.loading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.icon != null) ...[
                                Icon(widget.icon, size: 18, color: fgColor),
                                SizedBox(width: SpacingScale.s6),
                              ],
                              Flexible(
                                child: Text(
                                  widget.label,
                                  style: AppTextStyles.button.copyWith(color: fgColor),
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
      ),
    );
  }
}
