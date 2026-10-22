import 'package:flutter/material.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/typography/text_styles.dart';
import '../../../../design_system/radius/radius.dart';
import '../../../../design_system/spacing/spacing_scale.dart';

class AvailabilityCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final Set<DateTime> availableDates;
  final ValueChanged<DateTime> onDateSelected;

  const AvailabilityCalendar({
    super.key,
    required this.selectedDate,
    required this.availableDates,
    required this.onDateSelected,
  });

  @override
  State<AvailabilityCalendar> createState() => _AvailabilityCalendarState();
}

class _AvailabilityCalendarState extends State<AvailabilityCalendar> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    _month = DateTime(widget.selectedDate.year, widget.selectedDate.month);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final currentMonth = _month;
    final availableDates = widget.availableDates;
    final selectedDate = widget.selectedDate;
    final futureDates = availableDates.toList()..sort();
    final lastDate = futureDates.isEmpty ? now : futureDates.last;
    final lastMonth = DateTime(lastDate.year, lastDate.month);
    final daysInMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    final firstWeekday = currentMonth.weekday;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              tooltip: 'Previous month',
              onPressed: _month.isAfter(DateTime(now.year, now.month))
                  ? () => setState(() => _month = DateTime(_month.year, _month.month - 1)) : null,
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              '${_monthName(currentMonth.month)} ${currentMonth.year}',
              style: AppTextStyles.title2.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
              ),
            ),
            IconButton(
              tooltip: 'Next month',
              onPressed: _month.isBefore(lastMonth)
                  ? () => setState(() => _month = DateTime(_month.year, _month.month + 1)) : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: SpacingScale.s12),
        Row(
          children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
              .map((d) => Expanded(
                    child: Center(
                      child: Text(d, style: AppTextStyles.caption.copyWith(
                        color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                        fontWeight: FontWeight.w600,
                      )),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: SpacingScale.s8),
        ...List.generate((firstWeekday - 1 + daysInMonth + 6) ~/ 7, (weekIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: SpacingScale.s4),
            child: Row(
              children: List.generate(7, (dayIndex) {
                final dayNum = weekIndex * 7 + dayIndex - firstWeekday + 2;
                if (dayNum < 1 || dayNum > daysInMonth) {
                  return const Expanded(child: SizedBox());
                }
                final date = DateTime(currentMonth.year, currentMonth.month, dayNum);
                final isToday = DateUtils.isSameDay(date, now);
                final isAvailable = availableDates.any((d) => DateUtils.isSameDay(d, date));
                final isPast = date.isBefore(DateTime(now.year, now.month, now.day));
                final canSelect = isAvailable && !isPast;
                final isSelected = canSelect && DateUtils.isSameDay(date, selectedDate);

                return Expanded(
                  child: InkWell(
                    onTap: canSelect ? () => widget.onDateSelected(date) : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.all(2),
                      constraints: const BoxConstraints(minHeight: 48),
                      padding: const EdgeInsets.symmetric(vertical: SpacingScale.s6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : canSelect
                                ? AppColors.primary.withValues(alpha: 0.08)
                                : null,
                        borderRadius: AppRadius.brMd,
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$dayNum',
                            style: AppTextStyles.body.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : isToday
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : isPast
                                      ? (isDark ? AppColors.textDisabled : AppColors.lightTextDisabled)
                                      : isDark
                                          ? AppColors.textPrimary
                                          : AppColors.lightTextPrimary,
                            ),
                          ),
                          if (isAvailable && !isSelected)
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isPast
                                    ? (isDark ? AppColors.textDisabled : AppColors.lightTextDisabled)
                                    : AppColors.primary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
