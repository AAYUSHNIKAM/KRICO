import 'package:flutter/material.dart';
import '../../colors/app_colors.dart';
import '../../typography/text_styles.dart';
import '../../radius/radius.dart';
import '../../spacing/spacing_scale.dart';
import '../../tokens/duration_tokens.dart';
import '../../icons/app_icons.dart';

class AppSearchBar extends StatefulWidget {
  const AppSearchBar({
    super.key,
    this.onChanged,
    this.onSubmitted,
    this.hint = 'Search...',
    this.initialValue,
    this.autofocus = false,
    this.controller,
  });

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String hint;
  final String? initialValue;
  final bool autofocus;
  final TextEditingController? controller;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late final TextEditingController _controller;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
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
    final borderColor = _focused
        ? AppColors.primary
        : (isDark ? AppColors.border : AppColors.lightBorder);
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final hintColor = isDark ? AppColors.textTertiary : AppColors.lightTextTertiary;

    return AnimatedContainer(
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
          autofocus: widget.autofocus,
          onSubmitted: widget.onSubmitted,
          style: AppTextStyles.body.copyWith(color: textColor),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTextStyles.body.copyWith(color: hintColor),
            prefixIcon: Icon(AppIcons.search, size: 18, color: hintColor),
            suffixIcon: _controller.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _controller.clear();
                      widget.onChanged?.call('');
                      setState(() {});
                    },
                    child: Icon(AppIcons.close, size: 16, color: hintColor),
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: SpacingScale.s12,
              vertical: SpacingScale.s10,
            ),
            isDense: true,
          ),
          onChanged: (v) {
            widget.onChanged?.call(v);
            setState(() {});
          },
        ),
      ),
    );
  }
}
