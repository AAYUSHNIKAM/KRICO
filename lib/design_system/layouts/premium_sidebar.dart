import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../typography/text_styles.dart';
import '../radius/radius.dart';
import '../spacing/spacing_scale.dart';
import '../tokens/duration_tokens.dart';

class PremiumSidebarTile extends StatefulWidget {
  const PremiumSidebarTile({
    super.key,
    required this.icon,
    required this.label,
    this.selected = false,
    this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final String? badge;

  @override
  State<PremiumSidebarTile> createState() => _PremiumSidebarTileState();
}

class _PremiumSidebarTileState extends State<PremiumSidebarTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = widget.selected
        ? (isDark ? AppColors.selected : AppColors.lightSelected)
        : _hovered
            ? (isDark ? AppColors.hover : AppColors.lightHover)
            : Colors.transparent;
    final fgColor = widget.selected
        ? AppColors.primary
        : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary);
    final textColor = widget.selected
        ? (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary)
        : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s8, vertical: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: DurationTokens.medium,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: AppRadius.brMd,
            ),
            child: Stack(
              children: [
                if (widget.selected)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: AnimatedContainer(
                      duration: DurationTokens.medium,
                      width: 3,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(AppRadius.sm),
                          bottomRight: Radius.circular(AppRadius.sm),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingScale.s12,
                    vertical: SpacingScale.s10,
                  ),
                  child: Row(
                    children: [
                      Icon(widget.icon, size: 20, color: fgColor),
                      const SizedBox(width: SpacingScale.s12),
                      Expanded(
                        child: Text(
                          widget.label,
                          style: AppTextStyles.body.copyWith(
                            color: textColor,
                            fontWeight: widget.selected ? FontWeight.w500 : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (widget.badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: SpacingScale.s6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: AppRadius.brFull,
                          ),
                          child: Text(
                            widget.badge!,
                            style: AppTextStyles.captionXs.copyWith(color: AppColors.primary),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PremiumSidebar extends StatelessWidget {
  const PremiumSidebar({
    super.key,
    required this.children,
    this.header,
    this.footer,
    this.width = 260,
  });

  final List<Widget> children;
  final Widget? header;
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
          if (header != null)
            Container(
              padding: const EdgeInsets.all(SpacingScale.s16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.border : AppColors.lightBorder,
                    width: 0.5,
                  ),
                ),
              ),
              child: header,
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: SpacingScale.s8),
              children: children,
            ),
          ),
          if (footer != null)
            Container(
              padding: const EdgeInsets.all(SpacingScale.s12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.border : AppColors.lightBorder,
                    width: 0.5,
                  ),
                ),
              ),
              child: footer,
            ),
        ],
      ),
    );
  }
}

class PremiumCollapsedSidebarTile extends StatefulWidget {
  const PremiumCollapsedSidebarTile({
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
  State<PremiumCollapsedSidebarTile> createState() => _PremiumCollapsedSidebarTileState();
}

class _PremiumCollapsedSidebarTileState extends State<PremiumCollapsedSidebarTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = widget.selected
        ? (isDark ? AppColors.selected : AppColors.lightSelected)
        : _hovered
            ? (isDark ? AppColors.hover : AppColors.lightHover)
            : Colors.transparent;
    final fgColor = widget.selected
        ? AppColors.primary
        : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary);

    final tile = Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: DurationTokens.medium,
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: AppRadius.brMd,
            ),
            child: Center(
              child: Stack(
                children: [
                  Icon(widget.icon, size: 20, color: fgColor),
                  if (widget.badge != null)
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
                            widget.badge!,
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

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: tile);
    }
    return tile;
  }
}

class PremiumCollapsedSidebar extends StatelessWidget {
  const PremiumCollapsedSidebar({
    super.key,
    required this.children,
    this.footer,
    this.width = 80,
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
