import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../colors/app_colors.dart';
import '../../typography/text_styles.dart';
import '../../spacing/spacing_scale.dart';
import '../../radius/radius.dart';
import '../../tokens/duration_tokens.dart';

class PremiumAction {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const PremiumAction({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.onTap,
  });
}

class PremiumActionGrid extends StatelessWidget {
  final List<PremiumAction> actions;
  final int? desktopColumns;
  final int? tabletColumns;
  final int? mobileColumns;

  const PremiumActionGrid({
    super.key,
    required this.actions,
    this.desktopColumns,
    this.tabletColumns,
    this.mobileColumns,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1024;
    final isTablet = width >= 600 && width < 1024;
    final columns = isDesktop
        ? (desktopColumns ?? 6)
        : (isTablet ? (tabletColumns ?? 3) : (mobileColumns ?? 2));

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: SpacingScale.s10,
        mainAxisSpacing: SpacingScale.s10,
        childAspectRatio: isDesktop ? 1.2 : 1.1,
      ),
      itemCount: actions.length,
      itemBuilder: (context, i) => _ActionCard(data: actions[i], index: i),
    );
  }
}

class _ActionCard extends StatefulWidget {
  final PremiumAction data;
  final int index;

  const _ActionCard({required this.data, required this.index});

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final secColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    return Animate(
      delay: Duration(milliseconds: 350 + widget.index * 50),
      effects: [
        FadeEffect(duration: 300.ms),
        SlideEffect(begin: const Offset(0, 0.08), end: Offset.zero),
      ],
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.data.onTap,
          child: Transform.translate(
            offset: _hovered ? const Offset(0, -4) : Offset.zero,
            child: AnimatedContainer(
              duration: DurationTokens.fast,
              decoration: BoxDecoration(
                color: isDark ? AppColors.card : AppColors.lightCard,
                borderRadius: AppRadius.brXl2,
                border: Border.all(
                  color: widget.data.iconBg.withValues(alpha: _hovered ? 0.3 : 0.15),
                  width: _hovered ? 1 : 0.5,
                ),
                boxShadow: _hovered
                    ? [
                        BoxShadow(
                          color: widget.data.iconBg.withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(SpacingScale.s12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.scale(
                      scale: _hovered ? 1.1 : 1.0,
                      child: AnimatedContainer(
                        duration: DurationTokens.fast,
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: widget.data.iconBg.withValues(alpha: 0.12),
                          borderRadius: AppRadius.brLg,
                        ),
                        child: Icon(widget.data.icon, size: 20, color: widget.data.iconBg),
                      ),
                    ),
                    const SizedBox(height: SpacingScale.s10),
                    Text(
                      widget.data.title,
                      style: AppTextStyles.title3.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: SpacingScale.s2),
                    Text(
                      widget.data.subtitle,
                      style: AppTextStyles.captionXs.copyWith(color: secColor),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
