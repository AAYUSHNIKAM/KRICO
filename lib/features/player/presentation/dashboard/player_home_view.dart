import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/design_system/colors/app_colors.dart';
import 'package:sports_app/design_system/radius/radius.dart';
import 'package:sports_app/design_system/spacing/spacing_scale.dart';
import 'package:sports_app/design_system/typography/text_styles.dart';
import 'package:sports_app/design_system/layouts/premium_shell.dart';
import 'package:sports_app/models/coach_model.dart';
import 'package:sports_app/models/user_model.dart';
import 'package:sports_app/services/providers.dart';
import 'package:sports_app/features/home/presentation/workspace_destinations.dart';
import 'hud_widgets/concentric_activity_rings.dart';
import 'hud_widgets/hexagonal_skill_radar.dart';
import 'hud_widgets/live_stadium_ticket_hero.dart';
import 'hud_widgets/ai_biomechanics_lab_capsule.dart';
import 'hud_widgets/escrow_vault_capsule.dart';
import 'hud_widgets/athlete_tier_showcase.dart';
import 'hud_widgets/squad_leaderboard_podium.dart';

class PlayerHomeView extends ConsumerWidget {
  const PlayerHomeView({
    super.key,
    required this.user,
    required this.destinations,
  });

  final UserModel user;
  final List<WorkspaceDestination> destinations;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sessionsAsync = ref.watch(playerSessionsProvider(user.uid));
    final coachesAsync = ref.watch(coachesStreamProvider);

    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final subColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Athlete Command Header with full-width action
                _buildAthleteHeader(context, isDark, textColor, subColor),
                const SizedBox(height: SpacingScale.s24),

                // 1. Live Stadium Ticket & Gate Pass Hero
                sessionsAsync.when(
                  data: (snap) {
                    final now = DateTime.now();
                    final upcomingSessions = snap.docs.where((d) {
                      final time = (d.data()['dateTime'] as Timestamp?)?.toDate();
                      final status = d.data()['status'] as String? ?? '';
                      return time != null && time.isAfter(now) && status != 'cancelled';
                    }).toList();

                    final nextSession = upcomingSessions.isNotEmpty ? upcomingSessions.first.data() : null;
                    return LiveStadiumTicketHero(
                      sessionDoc: nextSession,
                      userName: user.name,
                    );
                  },
                  loading: () => const SizedBox(
                    height: 180,
                    child: Center(child: CircularProgressIndicator(color: AppColors.volt)),
                  ),
                  error: (_, _) => LiveStadiumTicketHero(
                    sessionDoc: null,
                    userName: user.name,
                  ),
                ),
                const SizedBox(height: SpacingScale.s28),

                // 2. Bento Grid 1: Concentric Rings + Hexagonal Skill Radar
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 768;
                    if (isWide) {
                      return const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: ConcentricActivityRings()),
                          SizedBox(width: 16),
                          Expanded(child: HexagonalSkillRadar()),
                        ],
                      );
                    }
                    return const Column(
                      children: [
                        ConcentricActivityRings(),
                        SizedBox(height: 16),
                        HexagonalSkillRadar(),
                      ],
                    );
                  },
                ),
                const SizedBox(height: SpacingScale.s28),

                // 3. Bento Grid 2: AI Biomechanics Lab + Escrow Vault
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 768;
                    if (isWide) {
                      return const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: AiBiomechanicsLabCapsule()),
                          SizedBox(width: 16),
                          Expanded(child: EscrowVaultCapsule()),
                        ],
                      );
                    }
                    return const Column(
                      children: [
                        AiBiomechanicsLabCapsule(),
                        SizedBox(height: 16),
                        EscrowVaultCapsule(),
                      ],
                    );
                  },
                ),
                const SizedBox(height: SpacingScale.s32),

                // 4. Interactive Sport Realm Horizon Bar
                _buildSportCategoryPills(context, isDark, textColor, subColor),
                const SizedBox(height: SpacingScale.s28),

                // 5. Featured & Verified Coaches Carousel
                _buildFeaturedCoaches(context, isDark, textColor, subColor, coachesAsync),
                const SizedBox(height: SpacingScale.s32),

                // 6. Bento Grid 3: 15-Tier Certified Showcase + Squad Podium
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 768;
                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: AthleteTierShowcase(playerId: user.uid)),
                          const SizedBox(width: 16),
                          Expanded(child: SquadLeaderboardPodium(userName: user.name)),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        AthleteTierShowcase(playerId: user.uid),
                        const SizedBox(height: 16),
                        SquadLeaderboardPodium(userName: user.name),
                      ],
                    );
                  },
                ),
                const SizedBox(height: SpacingScale.s40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAthleteHeader(
    BuildContext context,
    bool isDark,
    Color textColor,
    Color subColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.volt, width: 2),
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              ),
              child: Center(
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'A',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.volt : const Color(0xFF0F172A),
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Welcome, ${user.name}',
                          style: AppTextStyles.title2.copyWith(
                            fontWeight: FontWeight.w900,
                            color: textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.volt,
                          borderRadius: AppRadius.brSm,
                        ),
                        child: const Text(
                          'LVL 8 PRO',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: AppColors.midnightObsidian,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Pro-Athletic Telemetry • Ready for Competition',
                    style: AppTextStyles.captionXs.copyWith(color: subColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => WorkspaceNavigation.go(context, 1),
            style: FilledButton.styleFrom(
              backgroundColor: isDark ? AppColors.volt : const Color(0xFF0F172A),
              foregroundColor: isDark ? AppColors.midnightObsidian : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
            ),
            icon: const Icon(Icons.person_search_rounded, size: 16),
            label: Text(
              destinations.length > 1 ? destinations[1].label : 'Find a coach',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSportCategoryPills(
    BuildContext context,
    bool isDark,
    Color textColor,
    Color subColor,
  ) {
    final sports = [
      (title: 'All Sports', icon: Icons.sports_rounded, count: '124 Coaches'),
      (title: 'Badminton', icon: Icons.sports_tennis_rounded, count: '48 Active Courts'),
      (title: 'Cricket', icon: Icons.sports_cricket_rounded, count: '32 Turf Nets'),
      (title: 'Tennis', icon: Icons.sports_tennis_rounded, count: '18 Clay Courts'),
      (title: 'Football', icon: Icons.sports_football_rounded, count: '12 FIFA Pitches'),
      (title: 'Swimming', icon: Icons.pool_rounded, count: '6 Olympic Pools'),
      (title: 'Basketball', icon: Icons.sports_basketball_rounded, count: '8 Indoor Courts'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Sports Arenas & Specialized Coaching',
                style: AppTextStyles.title2.copyWith(color: textColor, fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: () => WorkspaceNavigation.go(context, 1),
              child: const Text('View All (124)'),
            ),
          ],
        ),
        const SizedBox(height: SpacingScale.s10),
        SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: sports.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final s = sports[i];
              final isFirst = i == 0;
              return InkWell(
                onTap: () => WorkspaceNavigation.go(context, 1),
                borderRadius: AppRadius.brLg,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isFirst
                        ? (isDark ? AppColors.volt : const Color(0xFF0F172A))
                        : (isDark ? AppColors.card : AppColors.lightCard),
                    borderRadius: AppRadius.brLg,
                    border: Border.all(
                      color: isFirst
                          ? (isDark ? AppColors.volt : const Color(0xFF0F172A))
                          : (isDark ? AppColors.border : AppColors.lightBorder),
                    ),
                    boxShadow: isFirst
                        ? [
                            BoxShadow(
                              color: AppColors.volt.withValues(alpha: isDark ? 0.25 : 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        s.icon,
                        size: 18,
                        color: isFirst
                            ? (isDark ? AppColors.midnightObsidian : Colors.white)
                            : (isDark ? AppColors.volt : const Color(0xFF0F172A)),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            s.title,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isFirst
                                  ? (isDark ? AppColors.midnightObsidian : Colors.white)
                                  : textColor,
                            ),
                          ),
                          Text(
                            s.count,
                            style: TextStyle(
                              fontSize: 9,
                              color: isFirst
                                  ? (isDark ? AppColors.midnightObsidian.withValues(alpha: 0.8) : Colors.white70)
                                  : subColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCoaches(
    BuildContext context,
    bool isDark,
    Color textColor,
    Color subColor,
    AsyncValue<List<CoachModel>> coachesAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Featured Elite Specialists',
                    style: AppTextStyles.title2.copyWith(color: textColor, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Verified NIS & International certified specialists',
                    style: AppTextStyles.caption.copyWith(color: subColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: () => WorkspaceNavigation.go(context, 1),
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: const Text('Explore'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        coachesAsync.when(
          data: (coaches) {
            if (coaches.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(SpacingScale.s20),
                alignment: Alignment.center,
                child: Text('No coaches available yet', style: AppTextStyles.bodySm),
              );
            }

            final featured = coaches.take(6).toList();
            return SizedBox(
              height: 230,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: featured.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, i) {
                  final coach = featured[i];
                  return _coachCard(context, coach, isDark, textColor, subColor);
                },
              ),
            );
          },
          loading: () => const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator(color: AppColors.volt)),
          ),
          error: (e, _) => Text('Error loading coaches: $e'),
        ),
      ],
    );
  }

  Widget _coachCard(
    BuildContext context,
    CoachModel coach,
    bool isDark,
    Color textColor,
    Color subColor,
  ) {
    final sport = coach.specialization ?? 'Sports Coach';

    return Container(
      width: 230,
      padding: const EdgeInsets.all(SpacingScale.s16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl3,
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.lightBorder,
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.volt.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.volt.withValues(alpha: 0.4)),
                ),
                child: Center(
                  child: Text(
                    coach.name.isNotEmpty ? coach.name[0].toUpperCase() : 'C',
                    style: const TextStyle(
                      color: AppColors.volt,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: SpacingScale.s10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coach.name,
                      style: AppTextStyles.title3.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      sport,
                      style: AppTextStyles.captionXs.copyWith(color: subColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingScale.s12),
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 16, color: AppColors.warning),
              const SizedBox(width: 4),
              Text(
                coach.rating.toStringAsFixed(1),
                style: AppTextStyles.labelSm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const Spacer(),
              Text(
                '₹${coach.hourlyRate.toInt()}/hr',
                style: AppTextStyles.title3.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.emerald,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingScale.s6),
          Text(
            coach.bio?.isNotEmpty == true
                ? coach.bio!
                : 'Specialized 1-on-1 private coaching for athletic mastery.',
            style: AppTextStyles.caption.copyWith(color: subColor),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
              ),
              onPressed: () => context.push('/coach/${coach.coachId}'),
              child: const Text('Book Session', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
