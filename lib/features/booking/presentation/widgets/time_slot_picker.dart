import 'package:flutter/material.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/typography/text_styles.dart';
import '../../../../design_system/radius/radius.dart';
import '../../../../design_system/spacing/spacing_scale.dart';

class TimeSlotPicker extends StatelessWidget {
  final List<String> availableSlots;
  final String? selectedSlot;
  final ValueChanged<String> onSlotSelected;

  const TimeSlotPicker({
    super.key,
    required this.availableSlots,
    required this.selectedSlot,
    required this.onSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    if (availableSlots.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(SpacingScale.s24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.card : AppColors.lightCard,
          borderRadius: AppRadius.brXl2,
          border: Border.all(color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Icon(Icons.access_time_rounded, size: 32, color: textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: SpacingScale.s8),
            Text('No available slots', style: AppTextStyles.body.copyWith(color: textSecondary)),
            const SizedBox(height: SpacingScale.s4),
            Text('Try a different date', style: AppTextStyles.caption.copyWith(color: textSecondary)),
          ],
        ),
      );
    }

    return Wrap(
      spacing: SpacingScale.s8,
      runSpacing: SpacingScale.s8,
      children: availableSlots.map((slot) {
        final isSelected = slot == selectedSlot;
        return GestureDetector(
          onTap: () => onSlotSelected(slot),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s16, vertical: SpacingScale.s10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : isDark
                      ? AppColors.card
                      : AppColors.lightCard,
              borderRadius: AppRadius.brLg,
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              _formatSlot(slot),
              style: AppTextStyles.button.copyWith(
                color: isSelected ? Colors.white : (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatSlot(String slot) {
    final parts = slot.split(':');
    if (parts.length != 2) return slot;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:$minute $period';
  }
}
