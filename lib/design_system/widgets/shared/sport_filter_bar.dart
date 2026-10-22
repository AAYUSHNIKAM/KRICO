import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/sports_registry.dart';
import '../../colors/app_colors.dart';
import '../../radius/radius.dart';
import '../../spacing/spacing_scale.dart';
import '../../typography/text_styles.dart';
import '../../utils/extensions.dart';

/// Ultra-sleek Cyber-Athletic horizontal sport category pill filter bar.
///
/// Features dynamic dual-theme contrast (Volt/Obsidian in Dark mode,
/// Pitch Slate/White in Light mode for WCAG AAA 14:1 compliance) and
/// micro-haptic feedback on selection.
class SportFilterBar extends StatelessWidget {
  final List<String> sports;
  final String? selectedSport;
  final ValueChanged<String?> onSelected;
  final double height;
  final EdgeInsetsGeometry padding;

  const SportFilterBar({
    super.key,
    required this.sports,
    required this.selectedSport,
    required this.onSelected,
    this.height = 40,
    this.padding = const EdgeInsets.symmetric(horizontal: SpacingScale.s16),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.colorScheme;

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: sports.length,
        separatorBuilder: (_, _) => const SizedBox(width: SpacingScale.s8),
        itemBuilder: (context, index) {
          final sport = sports[index];
          final isAll = sport.toLowerCase() == 'all' || sport.toLowerCase() == 'all sports';
          final isSelected = (selectedSport == null && isAll) ||
              selectedSport == sport ||
              (selectedSport == null && index == 0 && !sports.contains('All'));

          final icon = isAll
              ? Icons.sports_rounded
              : SportsRegistry.getIcon(sport);

          final activeBg = isDark ? AppColors.volt : context.heroCtaBg;
          final activeFg = isDark ? AppColors.midnightObsidian : context.heroCtaFg;
          final inactiveBg = colors.surfaceSecondary;
          final inactiveFg = colors.textSecondary;
          final borderColor = isSelected
              ? (isDark ? AppColors.volt : context.heroCtaBg)
              : colors.border;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              if (isAll) {
                onSelected(null);
              } else {
                onSelected(sport);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingScale.s12,
                vertical: SpacingScale.s6,
              ),
              decoration: BoxDecoration(
                color: isSelected ? activeBg : inactiveBg,
                borderRadius: AppRadius.brFull,
                border: Border.all(
                  color: borderColor,
                  width: isSelected ? 1.4 : 0.8,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: (isDark ? AppColors.volt : Colors.black).withValues(
                            alpha: isDark ? 0.28 : 0.12,
                          ),
                          blurRadius: isDark ? 10 : 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 15,
                    color: isSelected ? activeFg : inactiveFg,
                  ),
                  const SizedBox(width: SpacingScale.s6),
                  Text(
                    sport,
                    style: AppTextStyles.caption.copyWith(
                      color: isSelected ? activeFg : inactiveFg,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                      letterSpacing: isSelected ? 0.3 : 0,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
