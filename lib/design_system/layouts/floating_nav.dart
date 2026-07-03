import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../radius/radius.dart';
import '../spacing/spacing_scale.dart';

class FloatingNavItem {
  const FloatingNavItem({
    required this.icon,
    required this.label,
    this.badge,
  });

  final IconData icon;
  final String label;
  final String? badge;
}

class FloatingNav extends StatelessWidget {
  const FloatingNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    this.onChanged,
    this.color,
  });

  final List<FloatingNavItem> items;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surfaceElevated : AppColors.lightSurface;
    final accentColor = color ?? AppColors.primary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: SpacingScale.s24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.brXl2,
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s8, vertical: SpacingScale.s4),
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == selectedIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: isSelected ? null : () => onChanged?.call(index),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(vertical: SpacingScale.s4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          children: [
                            Icon(
                              item.icon,
                              size: 22,
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
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                            color: isSelected
                                ? accentColor
                                : (isDark
                                    ? AppColors.textTertiary
                                    : AppColors.lightTextTertiary),
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
