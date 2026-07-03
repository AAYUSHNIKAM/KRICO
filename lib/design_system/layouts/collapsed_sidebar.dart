import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../radius/radius.dart';
import '../spacing/spacing_scale.dart';

class CollapsedSidebarTile extends StatelessWidget {
  const CollapsedSidebarTile({
    super.key,
    required this.icon,
    this.selected = false,
    this.onTap,
    this.tooltip,
    this.badge,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;
  final String? tooltip;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = selected
        ? (isDark ? AppColors.selected : AppColors.lightSelected)
        : Colors.transparent;
    final fgColor = selected
        ? AppColors.primary
        : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary);

    final tile = Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadius.brMd,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.brMd,
            child: Center(
              child: Stack(
                children: [
                  Icon(icon, size: 20, color: fgColor),
                  if (badge != null)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            badge!,
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
            ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: tile);
    }
    return tile;
  }
}

class CollapsedSidebar extends StatelessWidget {
  const CollapsedSidebar({
    super.key,
    required this.children,
    this.footer,
    this.width = 64,
  });

  final List<Widget> children;
  final Widget? footer;
  final double width;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        border: Border(
          right: BorderSide(
            color: isDark ? AppColors.border : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: SpacingScale.s16),
          ...children,
          const Spacer(),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.only(bottom: SpacingScale.s12),
              child: footer,
            ),
        ],
      ),
    );
  }
}
