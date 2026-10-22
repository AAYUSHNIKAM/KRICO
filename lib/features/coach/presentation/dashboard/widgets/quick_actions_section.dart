import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../core/routing/app_router.dart';
import '../../../../../design_system/colors/app_colors.dart';
import '../../../../../design_system/typography/text_styles.dart';
import '../../../../../design_system/spacing/spacing_scale.dart';
import '../../../../../design_system/radius/radius.dart';
import '../../../../../design_system/responsive/responsive_helpers.dart';
import '../../../../../design_system/tokens/duration_tokens.dart';
import '../../../../../services/providers.dart';

class CoachQuickActionsSection extends ConsumerWidget {
  final String coachId;

  const CoachQuickActionsSection({super.key, required this.coachId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;
    final padH = isDesktop ? SpacingScale.s32 : (isTablet ? SpacingScale.s24 : SpacingScale.s16);
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;

    final actions = [
      _ActionData(
        icon: Icons.add_circle_rounded,
        iconBg: AppColors.primary,
        title: 'Create Session',
        subtitle: 'Schedule new training',
        route: '/create-session',
      ),
      _ActionData(
        icon: Icons.request_page_rounded,
        iconBg: AppColors.orange,
        title: 'Requests',
        subtitle: 'Manage bookings',
        function: (context) => context.push(AppRoutes.bookingRequests, extra: coachId),
      ),
      _ActionData(
        icon: Icons.event_available_rounded,
        iconBg: AppColors.success,
        title: 'Availability',
        subtitle: 'Set free slots',
        function: (context) => context.push(AppRoutes.manageAvailability, extra: coachId),
      ),
      _ActionData(
        icon: Icons.message_rounded,
        iconBg: AppColors.emerald,
        title: 'Messages',
        subtitle: 'Chat with students',
        route: '/chat',
      ),
      _ActionData(
        icon: Icons.school_rounded,
        iconBg: AppColors.purple,
        title: 'Academy Jobs',
        subtitle: 'Browse opportunities',
        route: AppRoutes.home,
      ),
      _ActionData(
        icon: Icons.videocam_rounded,
        iconBg: AppColors.orange,
        title: 'Video Tips',
        subtitle: 'Share training videos',
        route: '/video-analysis',
      ),
      _ActionData(
        icon: Icons.analytics_rounded,
        iconBg: AppColors.warning,
        title: 'Reports',
        subtitle: 'View performance data',
        function: (context) => _showCoachReportsModal(context, ref, coachId),
      ),
      _ActionData(
        icon: Icons.people_rounded,
        iconBg: AppColors.emerald,
        title: 'Community',
        subtitle: 'Connect with peers',
        route: '/community',
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
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: AppRadius.brLg,
                ),
                child: const Icon(Icons.flash_on_rounded, size: 18, color: AppColors.primary),
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

  void _showCoachReportsModal(BuildContext context, WidgetRef ref, String coachId) {
    HapticFeedback.lightImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final cardColor = isDark ? AppColors.card : AppColors.lightCard;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final sessionsSnap = ref.watch(coachSessionsProvider(coachId));
        return Padding(
          padding: EdgeInsets.fromLTRB(
            SpacingScale.s20,
            SpacingScale.s20,
            SpacingScale.s20,
            SpacingScale.s28 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: SpacingScale.s16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(SpacingScale.s10),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: AppRadius.brLg,
                    ),
                    child: const Icon(Icons.analytics_rounded, color: AppColors.warning, size: 24),
                  ),
                  const SizedBox(width: SpacingScale.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Coaching Performance Report', style: AppTextStyles.title2.copyWith(color: textPrimary, fontWeight: FontWeight.bold)),
                        Text('Current Cycle \u2022 Pune Pilot Operations', style: AppTextStyles.bodySm.copyWith(color: textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpacingScale.s20),
              sessionsSnap.when(
                data: (snap) {
                  final docs = snap.docs.map((d) => d.data()).toList();
                  final totalSessions = docs.length;
                  final completedSessions = docs.where((d) => d['status'] == 'completed' || d['attendanceVerified'] == true).length;
                  final attendanceRate = totalSessions > 0 ? ((completedSessions / totalSessions) * 100).toInt() : 100;
                  final grossRevenue = docs.fold<double>(0.0, (sum, d) => sum + ((d['price'] as num?)?.toDouble() ?? 0.0));
                  final netEarnings = grossRevenue * 0.90; // 90% net after 10% platform fee
                  final athleteIds = docs.map((d) => d['playerId'] as String?).where((id) => id != null && id.isNotEmpty).toSet().length;

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricTile(
                              title: 'Total Sessions',
                              value: totalSessions.toString(),
                              icon: Icons.sports_rounded,
                              color: AppColors.primary,
                              cardColor: cardColor,
                              borderColor: borderColor,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                            ),
                          ),
                          const SizedBox(width: SpacingScale.s10),
                          Expanded(
                            child: _buildMetricTile(
                              title: 'Attendance Rate',
                              value: '$attendanceRate%',
                              icon: Icons.verified_rounded,
                              color: AppColors.emerald,
                              cardColor: cardColor,
                              borderColor: borderColor,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: SpacingScale.s10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricTile(
                              title: 'Net Payout (₹)',
                              value: '\u20B9${NumberFormat('#,##0').format(netEarnings.toInt())}',
                              icon: Icons.account_balance_wallet_rounded,
                              color: AppColors.gold,
                              cardColor: cardColor,
                              borderColor: borderColor,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                            ),
                          ),
                          const SizedBox(width: SpacingScale.s10),
                          Expanded(
                            child: _buildMetricTile(
                              title: 'Unique Athletes',
                              value: athleteIds > 0 ? athleteIds.toString() : 'Active',
                              icon: Icons.people_alt_rounded,
                              color: AppColors.purple,
                              cardColor: cardColor,
                              borderColor: borderColor,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: Padding(
                  padding: EdgeInsets.all(SpacingScale.s24),
                  child: CircularProgressIndicator(),
                )),
                error: (e, _) => Center(child: Text('Could not load report metrics: $e', style: const TextStyle(color: AppColors.danger))),
              ),
              const SizedBox(height: SpacingScale.s24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.share_rounded, size: 16),
                      label: const Text('Copy Report'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(
                          text: 'KRICO Coaching Report \u2022 Coach: $coachId \u2022 Generated: ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
                        ));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Performance report summary copied to clipboard!'), backgroundColor: AppColors.emerald),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: SpacingScale.s12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.account_balance_wallet_rounded, size: 16),
                      label: const Text('View Earnings'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.push(AppRoutes.home);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color cardColor,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.all(SpacingScale.s16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: AppRadius.brLg,
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.caption.copyWith(color: textSecondary)),
              Icon(icon, color: color, size: 16),
            ],
          ),
          const SizedBox(height: SpacingScale.s6),
          Text(value, style: AppTextStyles.title2.copyWith(color: textPrimary, fontWeight: FontWeight.bold)),
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
  final String? route;
  final void Function(BuildContext)? function;

  const _ActionData({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.route,
    this.function,
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
            if (widget.data.route != null) {
              if (widget.data.route!.startsWith('/')) {
                context.push(widget.data.route!);
              } else {
                context.go(widget.data.route!);
              }
            } else if (widget.data.function != null) {
              widget.data.function!(context);
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
                    ? [BoxShadow(
                        color: widget.data.iconBg.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )]
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
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: widget.data.iconBg.withValues(alpha: 0.12),
                          borderRadius: AppRadius.brLg,
                        ),
                        child: Icon(widget.data.icon, size: 20, color: widget.data.iconBg),
                      ),
                    ),
                    const SizedBox(height: SpacingScale.s10),
                    Text(widget.data.title,
                      style: AppTextStyles.title3.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: SpacingScale.s2),
                    Text(widget.data.subtitle,
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
