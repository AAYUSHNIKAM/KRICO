import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../radius/radius.dart';

class AppNavRail extends StatelessWidget {
  const AppNavRail({
    super.key,
    required this.destinations,
    this.selectedIndex = 0,
    this.onChanged,
    this.leading,
    this.trailing,
    this.extended = false,
    this.labelType = NavigationRailLabelType.all,
  });

  final List<NavigationRailDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;
  final Widget? leading;
  final Widget? trailing;
  final bool extended;
  final NavigationRailLabelType labelType;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          right: BorderSide(color: borderColor, width: 0.5),
        ),
      ),
      child: NavigationRail(
        selectedIndex: selectedIndex,
        onDestinationSelected: onChanged ?? (_) {},
        labelType: labelType,
        extended: extended,
        leading: leading,
        trailing: trailing,
        backgroundColor: Colors.transparent,
        indicatorColor: isDark ? AppColors.selected : AppColors.lightSelected,
        indicatorShape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
        elevation: 0,
        groupAlignment: 0,
        minWidth: 48,
        minExtendedWidth: 160,
        destinations: destinations,
        unselectedIconTheme: IconThemeData(
          size: 22,
          color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
        ),
        selectedIconTheme: const IconThemeData(
          size: 22,
          color: AppColors.primary,
        ),
        unselectedLabelTextStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
        ),
        selectedLabelTextStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
