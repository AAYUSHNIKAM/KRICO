import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../../design_system/colors/app_colors.dart';
import '../../../../../design_system/typography/text_styles.dart';
import '../../../../../design_system/spacing/spacing_scale.dart';
import '../../../../../design_system/radius/radius.dart';
import '../../../../../design_system/responsive/responsive_helpers.dart';
import '../../../../../design_system/icons/app_icons.dart';
import '../../../../../models/player_model.dart';
import '../../../../../models/gamification_model.dart';
import '../../../../../services/providers.dart';
import 'dashboard_loading.dart';
import 'dashboard_error_state.dart';

class DashboardHeader extends ConsumerWidget {
  final String playerId;

  const DashboardHeader({super.key, required this.playerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerAsync = ref.watch(playerProvider(playerId));

    return playerAsync.when(
      data: (player) => _HeaderContent(player: player),
      loading: () => const DashboardHeaderShimmer(),
      error: (e, _) => DashboardErrorState(message: 'Could not load profile'),
    );
  }
}

class _HeaderContent extends StatelessWidget {
  final PlayerModel player;
  const _HeaderContent({required this.player});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;
    final padH = isDesktop ? SpacingScale.s32 : (isTablet ? SpacingScale.s24 : SpacingScale.s16);
    final padT = isDesktop ? SpacingScale.s48 : (isTablet ? SpacingScale.s40 : SpacingScale.s32);
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final secColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final terColor = isDark ? AppColors.textTertiary : AppColors.lightTextTertiary;
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning' : (hour < 17 ? 'Good Afternoon' : 'Good Evening');
    final level = LevelModel.getLevel(player.points);
    final levelProgress = player.points % 2000;
    final levelThreshold = 2000;
    final xpProgress = levelProgress / levelThreshold;
    const quotes = ['Keep your journey moving.', 'Greatness takes discipline.', 'Your journey continues.', 'Stay focused.'];
    final quote = quotes[DateTime.now().day % quotes.length];
    final dateStr = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return Container(
      padding: EdgeInsets.fromLTRB(padH, padT, padH, SpacingScale.s24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        border: Border(bottom: BorderSide(color: isDark ? AppColors.border : AppColors.lightBorder, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dateStr.toUpperCase(), style: AppTextStyles.captionXs.copyWith(color: terColor, letterSpacing: 1.2, fontWeight: FontWeight.w500))
                        .animate().fadeIn(duration: 200.ms, curve: Curves.easeOut).slideY(begin: -0.04, end: 0),
                    const SizedBox(height: SpacingScale.s12),
                    Text('$greeting,', style: AppTextStyles.title2.copyWith(color: secColor))
                        .animate(delay: 50.ms).fadeIn(duration: 250.ms, curve: Curves.easeOut).slideY(begin: -0.04, end: 0),
                    const SizedBox(height: SpacingScale.s2),
                    Text(player.name, style: AppTextStyles.heading1.copyWith(color: textColor, fontWeight: FontWeight.w700))
                        .animate(delay: 100.ms).fadeIn(duration: 300.ms, curve: Curves.easeOut).slideY(begin: -0.04, end: 0),
                    const SizedBox(height: SpacingScale.s8),
                    Row(
                      children: [
                        Icon(Icons.format_quote_rounded, size: 14, color: AppColors.emerald.withValues(alpha: 0.6)),
                        const SizedBox(width: SpacingScale.s6),
                        Text(quote, style: AppTextStyles.bodyLg.copyWith(color: secColor, fontStyle: FontStyle.italic)),
                      ],
                    ).animate(delay: 150.ms).fadeIn(duration: 250.ms, curve: Curves.easeOut).slideY(begin: -0.03, end: 0),
                  ],
                ),
              ),
              const SizedBox(width: SpacingScale.s16),
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary,
                  borderRadius: AppRadius.brFull,
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: player.avatarUrl != null
                    ? ClipRRect(
                        borderRadius: AppRadius.brFull,
                        child: Image.network(player.avatarUrl!, fit: BoxFit.cover),
                      )
                    : Icon(AppIcons.person, size: 30, color: secColor),
              ).animate(delay: 100.ms).fadeIn(duration: 300.ms, curve: Curves.easeOut).scale(begin: const Offset(0.85, 0.85), end: const Offset(1, 1)),
            ],
          ),
          const SizedBox(height: SpacingScale.s20),
          Row(
            children: [
              _buildPill(context, '${level.icon} ${level.title}', AppColors.emerald),
              const SizedBox(width: SpacingScale.s8),
              _buildPill(context, 'Rank #${player.rank}', AppColors.purple),
            ],
          ).animate(delay: 150.ms).fadeIn(duration: 300.ms, curve: Curves.easeOut),
          const SizedBox(height: SpacingScale.s24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${player.points} XP', style: AppTextStyles.title2.copyWith(color: textColor, fontWeight: FontWeight.w600)),
                  Text('Level ${level.title}', style: AppTextStyles.caption.copyWith(color: secColor)),
                ],
              ),
              const SizedBox(height: SpacingScale.s8),
              ClipRRect(
                borderRadius: AppRadius.brFull,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: xpProgress),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: 6,
                    backgroundColor: isDark ? AppColors.divider : AppColors.lightDivider,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.emerald),
                  ),
                ),
              ),
              const SizedBox(height: SpacingScale.s6),
              Text('$levelProgress / $levelThreshold XP to next level', style: AppTextStyles.captionXs.copyWith(color: terColor)),
            ],
          ).animate(delay: 200.ms).fadeIn(duration: 350.ms, curve: Curves.easeOut).slideY(begin: 0.06, end: 0),
        ],
      ),
    );
  }

  Widget _buildPill(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s10, vertical: SpacingScale.s4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.brFull,
      ),
      child: Text(text, style: AppTextStyles.captionXs.copyWith(color: color, fontWeight: FontWeight.w600)),
    );
  }
}
