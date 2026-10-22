import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../colors/app_colors.dart';
import '../../spacing/spacing_scale.dart';
import '../../radius/radius.dart';
import '../../tokens/duration_tokens.dart';

class PremiumCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? accentColor;
  final bool elevated;

  const PremiumCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.accentColor,
    this.elevated = false,
  });

  @override
  State<PremiumCard> createState() => _PremiumCardState();
}

class _PremiumCardState extends State<PremiumCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.card : AppColors.lightCard;
    final accent = widget.accentColor;
    final borderBase = isDark ? AppColors.border : AppColors.lightBorder;
    final borderHover = isDark ? AppColors.borderHover : AppColors.lightBorderHover;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: DurationTokens.fast,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppRadius.brXl3,
            gradient: accent != null
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      accent.withValues(alpha: _hovered ? 0.08 : 0.04),
                      bgColor,
                    ],
                    stops: const [0.0, 0.3],
                  )
                : null,
            border: Border.all(
              color: _hovered ? borderHover : borderBase,
              width: 0.5,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: (accent ?? AppColors.primary).withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : (isDark
                    ? null
                    : const [
                        BoxShadow(
                          color: Color(0x0A0F172A),
                          blurRadius: 12,
                          offset: Offset(0, 3),
                        ),
                      ]),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: AppRadius.brXl3,
              splashColor: AppColors.pressed,
              highlightColor: AppColors.hover,
              child: Padding(
                padding: widget.padding ?? const EdgeInsets.all(SpacingScale.s24),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, curve: Curves.easeOut);
  }
}
