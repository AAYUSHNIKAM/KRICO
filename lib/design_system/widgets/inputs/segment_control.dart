import 'package:flutter/material.dart';
import '../../colors/app_colors.dart';
import '../../typography/text_styles.dart';
import '../../radius/radius.dart';
import '../../spacing/spacing_scale.dart';
import '../../tokens/duration_tokens.dart';
import '../../tokens/spacing_tokens.dart';

class SegmentControl extends StatefulWidget {
  const SegmentControl({
    super.key,
    required this.segments,
    required this.selectedIndex,
    this.onChanged,
  });

  final List<String> segments;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;

  @override
  State<SegmentControl> createState() => _SegmentControlState();
}

class _SegmentControlState extends State<SegmentControl>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: DurationTokens.medium,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary;
    final selectedBg = isDark ? AppColors.surfaceElevated : AppColors.lightSurface;
    final textColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final selectedTextColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.brLg,
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      padding: const EdgeInsets.all(SpacingTokens.xxs),
      child: Row(
        children: List.generate(widget.segments.length, (index) {
          final isSelected = index == widget.selectedIndex;
          return Expanded(
            child: AnimatedContainer(
              duration: DurationTokens.medium,
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: isSelected ? selectedBg : Colors.transparent,
                borderRadius: AppRadius.brMd,
                border: isSelected
                    ? Border.all(
                        color: isDark ? AppColors.border : AppColors.lightBorder,
                        width: 0.5,
                      )
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isSelected
                      ? null
                      : () => widget.onChanged?.call(index),
                  borderRadius: AppRadius.brMd,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingScale.s12,
                      vertical: SpacingScale.s6,
                    ),
                    child: Text(
                      widget.segments[index],
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelSm.copyWith(
                        color: isSelected ? selectedTextColor : textColor,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
