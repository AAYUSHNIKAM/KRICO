import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../../design_system/colors/app_colors.dart';
import '../../../../../design_system/typography/text_styles.dart';
import '../../../../../design_system/spacing/spacing_scale.dart';
import '../../../../../design_system/radius/radius.dart';
import '../../../../../design_system/responsive/responsive_helpers.dart';
import '../../../../../design_system/tokens/duration_tokens.dart';

class QuickActionsSection extends ConsumerWidget {
  final String playerId;

  const QuickActionsSection({super.key, required this.playerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;
    final padH = isDesktop ? SpacingScale.s32 : (isTablet ? SpacingScale.s24 : SpacingScale.s16);
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;

    final actions = [
      _ActionData(
        icon: Icons.sports_tennis_rounded,
        iconBg: AppColors.emerald,
        title: 'Book Venue',
        subtitle: 'Find courts nearby',
        route: '/venues',
      ),
      _ActionData(
        icon: Icons.person_search_rounded,
        iconBg: AppColors.primary,
        title: 'Find Coach',
        subtitle: 'Discover expert coaches',
        route: '/coach-discovery',
      ),
      _ActionData(
        icon: Icons.people_rounded,
        iconBg: AppColors.purple,
        title: 'Community',
        subtitle: 'Connect with athletes',
        route: '/community',
      ),
      _ActionData(
        icon: Icons.show_chart_rounded,
        iconBg: AppColors.orange,
        title: 'Performance',
        subtitle: 'Track your progress',
        route: '/performance',
      ),
      _ActionData(
        icon: Icons.calendar_month_rounded,
        iconBg: AppColors.warning,
        title: 'Sessions',
        subtitle: 'View your schedule',
        route: '/bookings',
      ),
      _ActionData(
        icon: Icons.emoji_events_rounded,
        iconBg: AppColors.emerald,
        title: 'Goals',
        subtitle: 'Set new targets',
        route: '/squad-goals',
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: isDesktop ? SpacingScale.s28 : SpacingScale.s24),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: AppRadius.brLg,
                ),
                child: Icon(Icons.flash_on_rounded, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: SpacingScale.s10),
              Text('Quick Actions', style: AppTextStyles.title2.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              )),
            ],
          ),
          const SizedBox(height: SpacingScale.s16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 6 : (isTablet ? 3 : 2),
              crossAxisSpacing: SpacingScale.s10,
              mainAxisSpacing: SpacingScale.s10,
              childAspectRatio: isDesktop ? 1.2 : 1.1,
            ),
            itemCount: actions.length,
            itemBuilder: (context, i) => _ActionCard(data: actions[i], index: i),
          ),
        ],
      ),
    );
  }
}

class _ActionData {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String route;

  const _ActionData({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.route,
  });
}

class _ActionCard extends StatefulWidget {
  final _ActionData data;
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
          onTap: () {
            if (widget.data.route.startsWith('/')) {
              context.push(widget.data.route);
            } else {
              context.go(widget.data.route);
            }
          },
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
                          color: widget.data.iconBg.withValues(alpha: 0.18),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : (isDark
                        ? null
                        : const [
                            BoxShadow(
                              color: Color(0x0A0F172A),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ]),
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
