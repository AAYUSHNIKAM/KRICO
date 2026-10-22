import 'package:flutter/material.dart';
import '../../colors/app_colors.dart';
import '../../typography/text_styles.dart';
import '../../spacing/spacing_scale.dart';
import '../../radius/radius.dart';
import '../../tokens/duration_tokens.dart';

class PremiumListTile extends StatefulWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? accentColor;

  const PremiumListTile({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.accentColor,
  });

  @override
  State<PremiumListTile> createState() => _PremiumListTileState();
}

class _PremiumListTileState extends State<PremiumListTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.card : AppColors.lightCard;
    final borderBase = isDark ? AppColors.border : AppColors.lightBorder;
    final borderHover = isDark ? AppColors.borderHover : AppColors.lightBorderHover;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final secColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: DurationTokens.fast,
          padding: const EdgeInsets.all(SpacingScale.s12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppRadius.brXl2,
            border: Border.all(
              color: _hovered ? borderHover : borderBase,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              widget.leading,
              const SizedBox(width: SpacingScale.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      style: AppTextStyles.body.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: SpacingScale.s2),
                      Text(
                        widget.subtitle!,
                        style: AppTextStyles.caption.copyWith(color: secColor),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.trailing != null) ...[
                const SizedBox(width: SpacingScale.s12),
                widget.trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
