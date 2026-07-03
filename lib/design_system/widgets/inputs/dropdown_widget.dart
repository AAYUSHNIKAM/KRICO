import 'package:flutter/material.dart';
import '../../colors/app_colors.dart';
import '../../typography/text_styles.dart';
import '../../radius/radius.dart';
import '../../spacing/spacing_scale.dart';
import '../../tokens/duration_tokens.dart';

class AppDropdown<T> extends StatefulWidget {
  const AppDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.label,
    this.hint,
    this.disabled = false,
  });

  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? label;
  final String? hint;
  final bool disabled;

  @override
  State<AppDropdown<T>> createState() => _AppDropdownState<T>();
}

class _AppDropdownState<T> extends State<AppDropdown<T>> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final borderColor = _focused
        ? AppColors.primary
        : (isDark ? AppColors.border : AppColors.lightBorder);
    final textColor = widget.disabled
        ? AppColors.textDisabled
        : (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary);
    final labelColor = widget.disabled
        ? AppColors.textDisabled
        : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: SpacingScale.s6),
            child: Text(
              widget.label!,
              style: AppTextStyles.label.copyWith(color: labelColor),
            ),
          ),
        ],
        AnimatedContainer(
          duration: DurationTokens.medium,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppRadius.brLg,
            border: Border.all(color: borderColor, width: _focused ? 1.5 : 1),
          ),
          child: Focus(
            onFocusChange: (v) => setState(() => _focused = v),
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<T>(
                value: widget.value,
                items: widget.items,
                onChanged: widget.disabled ? null : widget.onChanged,
                hint: widget.hint != null
                    ? Text(widget.hint!, style: AppTextStyles.body.copyWith(
                        color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                      ))
                    : null,
                style: AppTextStyles.body.copyWith(color: textColor),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: SpacingScale.s12,
                    vertical: SpacingScale.s10,
                  ),
                  isDense: true,
                ),
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: labelColor,
                ),
                borderRadius: AppRadius.brLg,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
