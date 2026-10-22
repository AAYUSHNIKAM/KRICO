import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../colors/app_colors.dart';
import '../../typography/text_styles.dart';
import '../../spacing/spacing_scale.dart';
import '../../radius/radius.dart';
import '../../tokens/duration_tokens.dart';

class PremiumHeroCard extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final Widget? child;
  final VoidCallback? onTap;

  const PremiumHeroCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.child,
    this.onTap,
  });

  @override
  State<PremiumHeroCard> createState() => _PremiumHeroCardState();
}

class _PremiumHeroCardState extends State<PremiumHeroCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.card : AppColors.lightCard;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final secColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final borderBase = isDark ? AppColors.border : AppColors.lightBorder;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Transform.translate(
          offset: _hovered ? const Offset(0, -4) : Offset.zero,
          child: AnimatedContainer(
            duration: DurationTokens.fast,
            padding: const EdgeInsets.all(SpacingScale.s20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.color.withValues(alpha: _hovered ? 0.08 : 0.04),
                  widget.color.withValues(alpha: 0.02),
                ],
              ),
              color: bgColor,
              borderRadius: AppRadius.brXl2,
              border: Border.all(
                color: _hovered
                    ? widget.color.withValues(alpha: 0.3)
                    : borderBase,
                width: _hovered ? 1 : 0.5,
              ),
              boxShadow: _hovered
                  ? [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.18),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : (isDark
                      ? null
                      : const [
                          BoxShadow(
                            color: Color(0x0A0F172A),
                            blurRadius: 14,
                            offset: Offset(0, 4),
                          ),
                        ]),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.12),
                    borderRadius: AppRadius.brLg,
                  ),
                  child: Icon(widget.icon, size: 20, color: widget.color),
                ),
                const SizedBox(height: SpacingScale.s12),
                Text(
                  widget.title,
                  style: AppTextStyles.title3.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: SpacingScale.s2),
                  Text(
                    widget.subtitle!,
                    style: AppTextStyles.captionXs.copyWith(color: secColor),
                  ),
                ],
                if (widget.child != null) ...[
                  const SizedBox(height: SpacingScale.s12),
                  widget.child!,
                ],
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, curve: Curves.easeOut);
  }
}
