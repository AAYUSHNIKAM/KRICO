import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../typography/text_styles.dart';
import '../radius/radius.dart';
import '../spacing/spacing_scale.dart';

class PremiumDrawerSection {
  final String? title;
  final List<PremiumDrawerItem> items;

  const PremiumDrawerSection({this.title, required this.items});
}

class PremiumDrawerItem {
  final IconData icon;
  final String label;
  final bool selected;
  final String? badge;
  final VoidCallback? onTap;

  const PremiumDrawerItem({
    required this.icon,
    required this.label,
    this.selected = false,
    this.badge,
    this.onTap,
  });
}

class PremiumDrawer extends StatelessWidget {
  const PremiumDrawer({
    super.key,
    required this.sections,
    this.header,
    this.footer,
  });

  final List<PremiumDrawerSection> sections;
  final Widget? header;
  final Widget? footer;

  static void show(BuildContext context, PremiumDrawer drawer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: AppColors.overlay,
      builder: (_) => drawer,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      width: MediaQuery.of(context).size.width * 0.78,
      height: MediaQuery.of(context).size.height,
      margin: const EdgeInsets.only(left: 0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(AppRadius.xl3),
          bottomRight: Radius.circular(AppRadius.xl3),
        ),
      ),
      child: SafeArea(
        bottom: false,
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
                children: [
                  for (final section in sections) ...[
                    if (section.title != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          SpacingScale.s16,
                          SpacingScale.s12,
                          SpacingScale.s16,
                          SpacingScale.s4,
                        ),
                        child: Text(
                          section.title!,
                          style: AppTextStyles.caption.copyWith(
                            color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ...section.items.map((item) => _buildItem(item, isDark)),
                    const SizedBox(height: SpacingScale.s8),
                  ],
                ],
              ),
            ),
            if (footer != null)
              Container(
                padding: EdgeInsets.fromLTRB(
                  SpacingScale.s16,
                  SpacingScale.s12,
                  SpacingScale.s16,
                  bottomInset + SpacingScale.s12,
                ),
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
      ),
    );
  }

  Widget _buildItem(PremiumDrawerItem item, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s8, vertical: 1),
      child: Material(
        color: item.selected
            ? (isDark ? AppColors.selected : AppColors.lightSelected)
            : Colors.transparent,
        borderRadius: AppRadius.brMd,
        child: InkWell(
          onTap: item.onTap,
          borderRadius: AppRadius.brMd,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingScale.s12,
              vertical: SpacingScale.s10,
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 20,
                  color: item.selected
                      ? AppColors.primary
                      : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
                ),
                const SizedBox(width: SpacingScale.s12),
                Expanded(
                  child: Text(
                    item.label,
                    style: AppTextStyles.body.copyWith(
                      color: item.selected
                          ? (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary)
                          : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
                      fontWeight: item.selected ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
                if (item.badge != null)
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
                      item.badge!,
                      style: AppTextStyles.captionXs.copyWith(color: AppColors.primary),
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
