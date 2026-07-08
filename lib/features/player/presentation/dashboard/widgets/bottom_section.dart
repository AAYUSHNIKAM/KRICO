import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../design_system/colors/app_colors.dart';
import '../../../../../design_system/typography/text_styles.dart';
import '../../../../../design_system/spacing/spacing_scale.dart';
import '../../../../../design_system/radius/radius.dart';
import '../../../../../design_system/responsive/responsive_helpers.dart';

class BottomSection extends StatelessWidget {
  const BottomSection({super.key});

  int _dayOfYear() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    return now.difference(startOfYear).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;
    final padH = isDesktop ? SpacingScale.s32 : (isTablet ? SpacingScale.s24 : SpacingScale.s16);
    final secColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    final items = _dailyRotation;
    final today = _dayOfYear() % items.length;
    final item = items[today];

    return Padding(
      padding: EdgeInsets.fromLTRB(padH, SpacingScale.s28, padH, 0),
      child: Container(
        padding: const EdgeInsets.all(SpacingScale.s16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              item.color.withValues(alpha: 0.08),
              item.color.withValues(alpha: 0.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppRadius.brXl2,
          border: Border.all(
            color: item.color.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                borderRadius: AppRadius.brLg,
              ),
              child: Icon(item.icon, size: 20, color: item.color),
            ),
            const SizedBox(width: SpacingScale.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(item.label, style: AppTextStyles.captionXs.copyWith(
                        color: item.color,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      )),
                      const SizedBox(width: SpacingScale.s8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.12),
                          borderRadius: AppRadius.brFull,
                        ),
                        child: Text('Day ${today + 1}/${items.length}', style: AppTextStyles.captionXs.copyWith(
                          color: item.color.withValues(alpha: 0.7),
                          fontSize: 9,
                        )),
                      ),
                    ],
                  ),
                  const SizedBox(height: SpacingScale.s4),
                  Text(
                    item.text,
                    style: AppTextStyles.body.copyWith(
                      color: secColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: SpacingScale.s8),
            Icon(Icons.auto_awesome_rounded, size: 14, color: item.color.withValues(alpha: 0.5)),
          ],
        ),
      ).animate(delay: 550.ms).fadeIn(duration: 400.ms).slideY(begin: 0.06, end: 0),
    );
  }
}

class _DailyItem {
  final IconData icon;
  final Color color;
  final String label;
  final String text;

  const _DailyItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.text,
  });
}

const List<_DailyItem> _dailyRotation = [
  _DailyItem(
    icon: Icons.format_quote_rounded,
    color: AppColors.primary,
    label: 'QUOTE',
    text: 'The only way to prove you are a good sport is to lose.',
  ),
  _DailyItem(
    icon: Icons.lightbulb_rounded,
    color: AppColors.warning,
    label: 'TIP',
    text: 'Stretch for 10 minutes before every training session to reduce injury risk.',
  ),
  _DailyItem(
    icon: Icons.fitness_center_rounded,
    color: AppColors.emerald,
    label: 'FACT',
    text: 'Drinking water can boost your performance by up to 25% during exercise.',
  ),
  _DailyItem(
    icon: Icons.restaurant_rounded,
    color: AppColors.orange,
    label: 'NUTRITION',
    text: 'Eat protein within 30 minutes after training for optimal muscle recovery.',
  ),
  _DailyItem(
    icon: Icons.self_improvement_rounded,
    color: AppColors.purple,
    label: 'MINDSET',
    text: 'Visualization — spend 5 minutes picturing your success before each session.',
  ),
  _DailyItem(
    icon: Icons.nightlight_rounded,
    color: AppColors.primary,
    label: 'RECOVERY',
    text: 'Sleep is when your body repairs. Aim for 8 hours after intense training days.',
  ),
  _DailyItem(
    icon: Icons.directions_run_rounded,
    color: AppColors.emerald,
    label: 'MOTION',
    text: 'Your warm-up should be dynamic, not static. Try leg swings and lunges.',
  ),
  _DailyItem(
    icon: Icons.favorite_rounded,
    color: AppColors.danger,
    label: 'HEALTH',
    text: 'Rest days are productive. Your muscles grow during recovery, not during workouts.',
  ),
];
