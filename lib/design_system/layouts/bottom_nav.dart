import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../typography/text_styles.dart';
import '../spacing/spacing_scale.dart';

class BottomNavItem {
  const BottomNavItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.badge,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final String? badge;
}

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    this.onChanged,
    this.color,
  });

  final List<BottomNavItem> items;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final accentColor = color ?? AppColors.primary;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(color: borderColor, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == selectedIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: isSelected ? null : () => onChanged?.call(index),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 60,
                    padding: const EdgeInsets.only(top: SpacingScale.s6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: isSelected ? 40 : 0,
                              height: 3,
                              decoration: BoxDecoration(
                                color: accentColor,
                                borderRadius: BorderRadius.circular(1.5),
                              ),
                              margin: const EdgeInsets.only(bottom: 8),
                            ),
                            if (isSelected)
                              const SizedBox(height: 0)
                            else
                              const SizedBox(height: 0),
                          ],
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              isSelected
                                  ? (item.selectedIcon ?? item.icon)
                                  : item.icon,
                              size: 24,
                              color: isSelected
                                  ? accentColor
                                  : (isDark
                                      ? AppColors.textTertiary
                                      : AppColors.lightTextTertiary),
                            ),
                            if (item.badge != null)
                              Positioned(
                                right: -8,
                                top: -4,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: const BoxDecoration(
                                    color: AppColors.danger,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      item.badge!,
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: SpacingScale.s4),
                        Text(
                          item.label,
                          style: AppTextStyles.captionXs.copyWith(
                            color: isSelected
                                ? accentColor
                                : (isDark
                                    ? AppColors.textTertiary
                                    : AppColors.lightTextTertiary),
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
