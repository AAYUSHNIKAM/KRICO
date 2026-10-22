import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../colors/app_colors.dart';
import '../../radius/radius.dart';
import '../../spacing/spacing_scale.dart';
import '../../tokens/duration_tokens.dart';

enum SportCardVariant {
  standard,
  hero,
  interactive,
  metric,
  glass,
}

class SportCard extends StatefulWidget {
  final Widget child;
  final SportCardVariant variant;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? accentColor;
  final double? width;
  final double? height;
  final bool enableHaptics;

  const SportCard({
    super.key,
    required this.child,
    this.variant = SportCardVariant.standard,
    this.onTap,
    this.padding,
    this.accentColor,
    this.width,
    this.height,
    this.enableHaptics = true,
  });

  const SportCard.hero({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.accentColor,
    this.width,
    this.height,
    this.enableHaptics = true,
  }) : variant = SportCardVariant.hero;

  const SportCard.interactive({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.accentColor,
    this.width,
    this.height,
    this.enableHaptics = true,
  }) : variant = SportCardVariant.interactive;

  const SportCard.metric({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.accentColor,
    this.width,
    this.height,
    this.enableHaptics = true,
  }) : variant = SportCardVariant.metric;

  @override
  State<SportCard> createState() => _SportCardState();
}

class _SportCardState extends State<SportCard> {
  bool _hovered = false;
  bool _pressed = false;

  void _handleTap() {
    if (widget.onTap != null) {
      if (widget.enableHaptics) {
        HapticFeedback.selectionClick();
      }
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isClickable = widget.onTap != null || widget.variant == SportCardVariant.interactive;
    final accent = widget.accentColor ?? (isDark ? AppColors.volt : AppColors.primary);

    // Color resolution
    final Color bgColor;
    final Border? border;
    final List<BoxShadow>? shadows;

    if (isDark) {
      bgColor = widget.variant == SportCardVariant.hero
          ? AppColors.surfaceElevated
          : AppColors.card;
      final borderColor = _hovered && isClickable
          ? accent.withValues(alpha: 0.4)
          : AppColors.border;
      border = Border.all(
        color: borderColor,
        width: _hovered && isClickable ? 1.0 : 0.5,
      );
      shadows = _hovered && isClickable
          ? [
              BoxShadow(
                color: accent.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ]
          : null;
    } else {
      bgColor = AppColors.lightCard;
      final borderColor = _hovered && isClickable
          ? AppColors.lightTextPrimary
          : AppColors.lightBorder;
      border = Border.all(
        color: borderColor,
        width: 1.0,
      );
      shadows = _hovered && isClickable
          ? [
              BoxShadow(
                color: const Color(0x140F172A),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ]
          : [
              const BoxShadow(
                color: Color(0x0A0F172A),
                blurRadius: 12,
                offset: Offset(0, 3),
              ),
            ];
    }

    final double scale = _pressed ? 0.985 : (_hovered && isClickable ? 1.01 : 1.0);

    return MouseRegion(
      onEnter: (_) {
        if (isClickable && mounted) setState(() => _hovered = true);
      },
      onExit: (_) {
        if (isClickable && mounted) setState(() => _hovered = false);
      },
      child: GestureDetector(
        onTapDown: (_) {
          if (isClickable && mounted) setState(() => _pressed = true);
        },
        onTapUp: (_) {
          if (isClickable && mounted) setState(() => _pressed = false);
        },
        onTapCancel: () {
          if (isClickable && mounted) setState(() => _pressed = false);
        },
        onTap: isClickable ? _handleTap : null,
        child: AnimatedScale(
          scale: scale,
          duration: DurationTokens.fast,
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: DurationTokens.fast,
            width: widget.width,
            height: widget.height,
            padding: widget.padding ?? const EdgeInsets.all(SpacingScale.s16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: AppRadius.brXl2,
              border: border,
              boxShadow: shadows,
              gradient: widget.accentColor != null
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.accentColor!.withValues(alpha: isDark ? (_hovered ? 0.08 : 0.04) : 0.03),
                        bgColor,
                      ],
                      stops: const [0.0, 0.45],
                    )
                  : null,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
