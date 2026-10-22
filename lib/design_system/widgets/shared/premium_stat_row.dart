import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../colors/app_colors.dart';
import '../../typography/text_styles.dart';
import '../../spacing/spacing_scale.dart';
import '../../radius/radius.dart';

class PremiumStat {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const PremiumStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}

class PremiumStatRow extends StatelessWidget {
  final List<PremiumStat> stats;

  const PremiumStatRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 600;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final secColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final surfaceColor = isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary;

    if (isMobile) {
      final rows = <Widget>[];
      for (var i = 0; i < stats.length; i += 2) {
        final rowChildren = <Widget>[
          Expanded(child: _StatMiniCard(stat: stats[i], surfaceColor: surfaceColor, textColor: textColor, secColor: secColor)),
        ];
        if (i + 1 < stats.length) {
          rowChildren.add(const SizedBox(width: SpacingScale.s10));
          rowChildren.add(Expanded(child: _StatMiniCard(stat: stats[i + 1], surfaceColor: surfaceColor, textColor: textColor, secColor: secColor)));
        } else {
          rowChildren.add(const Expanded(child: SizedBox.shrink()));
        }
        rows.add(Padding(
          padding: EdgeInsets.only(bottom: i + 2 < stats.length ? SpacingScale.s10 : 0),
          child: Row(children: rowChildren),
        ));
      }
      return Column(children: rows);
    }

    return Row(
      children: [
        for (int i = 0; i < stats.length; i++) ...[
          if (i > 0) const SizedBox(width: SpacingScale.s10),
          Expanded(
            child: _StatMiniCard(stat: stats[i], surfaceColor: surfaceColor, textColor: textColor, secColor: secColor),
          ),
        ],
      ],
    ).animate().fadeIn(duration: 300.ms, curve: Curves.easeOut);
  }
}

class _StatMiniCard extends StatelessWidget {
  final PremiumStat stat;
  final Color surfaceColor;
  final Color textColor;
  final Color secColor;

  const _StatMiniCard({
    required this.stat,
    required this.surfaceColor,
    required this.textColor,
    required this.secColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SpacingScale.s12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: AppRadius.brLg,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: stat.color.withValues(alpha: 0.12),
              borderRadius: AppRadius.brMd,
            ),
            child: Icon(stat.icon, size: 16, color: stat.color),
          ),
          const SizedBox(width: SpacingScale.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  stat.value,
                  style: AppTextStyles.numericXs.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  stat.label,
                  style: AppTextStyles.captionXs.copyWith(color: secColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
