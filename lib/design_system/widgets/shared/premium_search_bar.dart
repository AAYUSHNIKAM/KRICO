import 'package:flutter/material.dart';
import '../../colors/app_colors.dart';
import '../../typography/text_styles.dart';
import '../../spacing/spacing_scale.dart';
import '../../radius/radius.dart';
import '../../tokens/duration_tokens.dart';

class PremiumSearchBar extends StatefulWidget {
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final VoidCallback? onClear;

  const PremiumSearchBar({
    super.key,
    this.hintText,
    this.onChanged,
    this.controller,
    this.onClear,
  });

  @override
  State<PremiumSearchBar> createState() => _PremiumSearchBarState();
}

class _PremiumSearchBarState extends State<PremiumSearchBar> {
  late final TextEditingController _controller;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary;
    final borderColor = _focused
        ? AppColors.primary
        : (isDark ? AppColors.border : AppColors.lightBorder);
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final hintColor = isDark ? AppColors.textTertiary : AppColors.lightTextTertiary;

    return AnimatedContainer(
      duration: DurationTokens.medium,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.brXl2,
        border: Border.all(
          color: borderColor,
          width: _focused ? 1.5 : 0.5,
        ),
      ),
      child: Focus(
        onFocusChange: (v) => setState(() => _focused = v),
        child: TextField(
          controller: _controller,
          style: AppTextStyles.body.copyWith(color: textColor),
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'Search...',
            hintStyle: AppTextStyles.body.copyWith(color: hintColor),
            prefixIcon: Icon(Icons.search_rounded, size: 18, color: hintColor),
            suffixIcon: _controller.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _controller.clear();
                      widget.onChanged?.call('');
                      widget.onClear?.call();
                      setState(() {});
                    },
                    child: Icon(Icons.close_rounded, size: 16, color: hintColor),
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
