import 'package:flutter/material.dart';
import '../../colors/app_colors.dart';
import '../../typography/text_styles.dart';
import '../../radius/radius.dart';
import '../../spacing/spacing_scale.dart';
import '../../tokens/duration_tokens.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscure = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.minLines,
    this.autofocus = false,
    this.readOnly = false,
    this.enabled = true,
    this.suffixIcon,
    this.prefixIcon,
    this.initialValue,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscure;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int maxLines;
  final int? minLines;
  final bool autofocus;
  final bool readOnly;
  final bool enabled;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? initialValue;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final TextEditingController _controller;
  bool _focused = false;
  bool _obscured = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _obscured = widget.obscure;
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final borderColor = !widget.enabled
        ? (isDark ? AppColors.divider : AppColors.lightDivider)
        : _focused
            ? AppColors.primary
            : (isDark ? AppColors.border : AppColors.lightBorder);
    final textColor = !widget.enabled
        ? AppColors.textDisabled
        : (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary);
    final labelColor = !widget.enabled
        ? AppColors.textDisabled
        : _focused
            ? AppColors.primary
            : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary);
    final hintColor = isDark ? AppColors.textTertiary : AppColors.lightTextTertiary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: SpacingScale.s6),
            child: Text(
              widget.label,
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
            child: TextField(
              controller: _controller,
              obscureText: _obscured,
              keyboardType: widget.keyboardType,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              maxLines: widget.obscure ? 1 : widget.maxLines,
              minLines: widget.minLines,
              autofocus: widget.autofocus,
              readOnly: widget.readOnly,
              enabled: widget.enabled,
              style: AppTextStyles.body.copyWith(color: textColor),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: AppTextStyles.body.copyWith(color: hintColor),
                prefixIcon: widget.prefixIcon,
                suffixIcon: widget.obscure
                    ? IconButton(
                        icon: Icon(
                          _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 18,
                          color: hintColor,
                        ),
                        onPressed: () => setState(() => _obscured = !_obscured),
                      )
                    : widget.suffixIcon,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: SpacingScale.s12,
                  vertical: widget.maxLines > 1 ? SpacingScale.s12 : SpacingScale.s10,
                ),
                isDense: true,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
