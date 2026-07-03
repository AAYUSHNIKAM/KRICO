import 'package:flutter/material.dart';
import '../../colors/app_colors.dart';
import '../../typography/text_styles.dart';
import '../../spacing/spacing_scale.dart';

class AppTabBar extends StatelessWidget {
  const AppTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    this.onChanged,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: List.generate(tabs.length, (index) {
        final isSelected = index == selectedIndex;
        return Expanded(
          child: GestureDetector(
            onTap: isSelected ? null : () => onChanged?.call(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                vertical: SpacingScale.s8,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  tabs[index],
                  style: AppTextStyles.button.copyWith(
                    color: isSelected
                        ? (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary)
                        : (isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
