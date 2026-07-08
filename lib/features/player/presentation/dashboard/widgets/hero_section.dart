import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../design_system/colors/app_colors.dart';
import '../../../../../design_system/typography/text_styles.dart';
import '../../../../../design_system/spacing/spacing_scale.dart';
import '../../../../../design_system/radius/radius.dart';
import '../../../../../design_system/responsive/responsive_helpers.dart';
import '../../../../../design_system/tokens/duration_tokens.dart';
import '../../../../../services/providers.dart';
import '../../../../../models/player_model.dart';
import '../../../../../models/gamification_model.dart';
import 'dashboard_loading.dart';

class HeroSection extends ConsumerWidget {
  final String playerId;
  final String playerName;

  const HeroSection({
    super.key,
    required this.playerId,
    required this.playerName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerAsync = ref.watch(playerProvider(playerId));
    final sessionsAsync = ref.watch(playerSessionsProvider(playerId));

    return playerAsync.when(
      data: (player) {
        return sessionsAsync.when(
          data: (snap) => _HeroContent(
            player: player,
            sessions: snap.docs.map((d) => d.data()).toList(),
            playerName: playerName,
          ),
          loading: () => _HeroContent(
            player: player,
            sessions: const [],
            playerName: playerName,
          ),
          error: (_, __) => _HeroContent(
            player: player,
            sessions: const [],
            playerName: playerName,
          ),
        );
      },
      loading: () => const DashboardHeaderShimmer(),
      error: (_, __) => const DashboardHeaderShimmer(),
    );
  }
}

class _HeroContent extends StatelessWidget {
  final PlayerModel player;
  final List<Map<String, dynamic>> sessions;
  final String playerName;

  const _HeroContent({
    required this.player,
    required this.sessions,
    required this.playerName,
  });

  int _dayOfYear() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    return now.difference(startOfYear).inDays;
  }

  int _calculateStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;
    int streak = 1;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    for (int i = 0; i < dates.length - 1; i++) {
      final current = DateTime(dates[i].year, dates[i].month, dates[i].day);
      final next = DateTime(dates[i + 1].year, dates[i + 1].month, dates[i + 1].day);
      final diff = current.difference(next).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }

    if (dates.isNotEmpty) {
      final mostRecent = DateTime(dates.first.year, dates.first.month, dates.first.day);
      final diff = todayDate.difference(mostRecent).inDays;
      if (diff > 1) streak = 0;
    }

    return streak;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;
    final padH = isDesktop ? SpacingScale.s32 : (isTablet ? SpacingScale.s24 : SpacingScale.s16);
    final padT = isDesktop ? SpacingScale.s48 : (isTablet ? SpacingScale.s40 : SpacingScale.s32);
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final secColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning' : (hour < 17 ? 'Good Afternoon' : 'Good Evening');
    final level = LevelModel.getLevel(player.points);
    final levelProgress = player.points % 2000;
    final levelThreshold = 2000;
    final xpProgress = levelProgress / levelThreshold;
    final dateStr = DateFormat('EEEE, MMMM d').format(DateTime.now());

    final completedSessions = sessions.where((s) => s['status'] == 'completed').length;
    final trainingDayCount = completedSessions + 1;

    final completedDates = sessions
        .where((s) => s['status'] == 'completed' && s['dateTime'] != null)
        .map((s) => (s['dateTime'] as Timestamp).toDate())
        .toList();
    completedDates.sort((a, b) => b.compareTo(a));
    int streak = 1;
    if (completedDates.isNotEmpty) {
      streak = _calculateStreak(completedDates);
    }

    final upcomingSessions = sessions
        .where((s) => s['status'] == 'scheduled' || s['status'] == 'booked')
        .toList();
    final hasUpcoming = upcomingSessions.isNotEmpty;
    final nextSession = hasUpcoming ? upcomingSessions.first : null;
    final nextSessionTime = nextSession != null
        ? (nextSession['dateTime'] as Timestamp?)?.toDate()
        : null;

    final motivationalQuotes = [
      'Keep your journey moving.',
      'Greatness takes discipline.',
      'Your journey continues.',
      'Stay focused.',
      'Every rep counts.',
      'Champions train.',
    ];
    final quote = motivationalQuotes[_dayOfYear() % motivationalQuotes.length];

    return Container(
      padding: EdgeInsets.fromLTRB(padH, padT, padH, SpacingScale.s24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  AppColors.surface,
                  AppColors.surface.withValues(alpha: 0.95),
                ]
              : [
                  AppColors.lightSurface,
                  AppColors.lightSurface,
                ],
        ),
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.border : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
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
                    Text(
                      dateStr.toUpperCase(),
                      style: AppTextStyles.captionXs.copyWith(
                        color: secColor,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w500,
                      ),
                    ).animate().fadeIn(duration: 200.ms, curve: Curves.easeOut).slideY(begin: -0.04, end: 0),
                    const SizedBox(height: SpacingScale.s12),
                    Text(
                      '$greeting,',
                      style: AppTextStyles.title2.copyWith(color: secColor),
                    ).animate(delay: 50.ms).fadeIn(duration: 250.ms, curve: Curves.easeOut).slideY(begin: -0.04, end: 0),
                    const SizedBox(height: SpacingScale.s2),
                    Text(
                      playerName,
                      style: AppTextStyles.heading1.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ).animate(delay: 100.ms).fadeIn(duration: 300.ms, curve: Curves.easeOut).slideY(begin: -0.04, end: 0),
                    const SizedBox(height: SpacingScale.s8),
                    Row(
                      children: [
                        Icon(Icons.format_quote_rounded, size: 14, color: AppColors.emerald.withValues(alpha: 0.6)),
                        const SizedBox(width: SpacingScale.s6),
                        Text(quote, style: AppTextStyles.bodyLg.copyWith(
                          color: secColor,
                          fontStyle: FontStyle.italic,
                        )),
                      ],
                    ).animate(delay: 150.ms).fadeIn(duration: 250.ms, curve: Curves.easeOut).slideY(begin: -0.03, end: 0),
                  ],
                ),
              ),
              const SizedBox(width: SpacingScale.s16),
              _StreakBadge(streak: streak),
            ],
          ),
          const SizedBox(height: SpacingScale.s20),
          Row(
            children: [
              _Pill(text: 'Training Day $trainingDayCount', color: AppColors.primary),
              const SizedBox(width: SpacingScale.s8),
              _Pill(text: '${level.icon} ${level.title}', color: AppColors.emerald),
              const SizedBox(width: SpacingScale.s8),
              _Pill(text: 'Rank #${player.rank}', color: AppColors.purple),
            ],
          ).animate(delay: 150.ms).fadeIn(duration: 300.ms, curve: Curves.easeOut),
          const SizedBox(height: SpacingScale.s24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${player.points} XP', style: AppTextStyles.title2.copyWith(
                    color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                    fontWeight: FontWeight.w600,
                  )),
                  Text('Level ${level.title}', style: AppTextStyles.caption.copyWith(
                    color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                  )),
                ],
              ),
              const SizedBox(height: SpacingScale.s8),
              ClipRRect(
                borderRadius: AppRadius.brFull,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: xpProgress),
                  duration: DurationTokens.long,
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
              Text('$levelProgress / $levelThreshold XP to next level', style: AppTextStyles.captionXs.copyWith(
                color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
              )),
            ],
          ).animate(delay: 200.ms).fadeIn(duration: 350.ms, curve: Curves.easeOut).slideY(begin: 0.06, end: 0),
          if (isDesktop) ...[
            const SizedBox(height: SpacingScale.s20),
            Row(
              children: [
                if (hasUpcoming && nextSessionTime != null) ...[
                  _NextSessionCountdown(nextSessionTime: nextSessionTime),
                  const SizedBox(width: SpacingScale.s16),
                ],
                _StartTrainingButton(),
              ],
            ),
          ] else ...[
            if (hasUpcoming && nextSessionTime != null) ...[
              const SizedBox(height: SpacingScale.s16),
              _NextSessionCountdown(nextSessionTime: nextSessionTime),
            ],
            const SizedBox(height: SpacingScale.s16),
            _StartTrainingButton(),
          ],
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;

  const _Pill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s10, vertical: SpacingScale.s4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.brFull,
      ),
      child: Text(
        text,
        style: AppTextStyles.captionXs.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  final int streak;

  const _StreakBadge({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s12, vertical: SpacingScale.s8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.warning.withValues(alpha: 0.15),
            AppColors.orange.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.brXl2,
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department_rounded, size: 18, color: AppColors.warning),
          const SizedBox(width: SpacingScale.s6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$streak',
                style: AppTextStyles.numericXs.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'day streak',
                style: AppTextStyles.captionXs.copyWith(
                  color: AppColors.warning.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: 100.ms).fadeIn(duration: 300.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }
}

class _NextSessionCountdown extends StatelessWidget {
  final DateTime nextSessionTime;

  const _NextSessionCountdown({required this.nextSessionTime});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final diff = nextSessionTime.difference(now);
    final hours = diff.inHours;
    final minutes = diff.inMinutes.remainder(60);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s12, vertical: SpacingScale.s10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary,
        borderRadius: AppRadius.brXl2,
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.schedule_rounded, size: 16, color: AppColors.primary),
          const SizedBox(width: SpacingScale.s8),
          Text(
            'Next session in ',
            style: AppTextStyles.caption.copyWith(
              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
            ),
          ),
          Text(
            '${hours}h ${minutes}m',
            style: AppTextStyles.label.copyWith(
              color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ).animate(delay: 200.ms).fadeIn(duration: 300.ms);
  }
}

class _StartTrainingButton extends StatefulWidget {
  @override
  State<_StartTrainingButton> createState() => _StartTrainingButtonState();
}

class _StartTrainingButtonState extends State<_StartTrainingButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {},
        child: AnimatedContainer(
          duration: DurationTokens.fast,
          padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s24, vertical: SpacingScale.s12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _hovered
                  ? [AppColors.primaryHover, AppColors.primary]
                  : [AppColors.primary, AppColors.primaryLight],
            ),
            borderRadius: AppRadius.brXl2,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: _hovered ? 0.4 : 0.2),
                blurRadius: _hovered ? 20 : 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.play_arrow_rounded, size: 20, color: Colors.white),
              const SizedBox(width: SpacingScale.s8),
              Text(
                'Start Training',
                style: AppTextStyles.buttonLg.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: 250.ms).fadeIn(duration: 400.ms).slideY(begin: 0.08, end: 0);
  }
}
