import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/stats_card.dart';
import '../../../models/coach_model.dart';
import '../../../models/gamification_model.dart';
import '../../../models/user_model.dart';
import '../../../services/providers.dart';

class PlayerDashboard extends ConsumerWidget {
  const PlayerDashboard({super.key, required this.userModel});

  final UserModel userModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final playerAsync = ref.watch(playerProvider(userModel.uid));
    final sessionsAsync = ref.watch(playerSessionsProvider(userModel.uid));
    final achievementsAsync = ref.watch(playerAchievementsProvider(userModel.uid));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.gradientPrimary,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Player Dashboard', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
                            const SizedBox(height: 4),
                            Text(userModel.name, style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        Container(
                          width: 60, height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          child: userModel.photoUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(userModel.photoUrl!, fit: BoxFit.cover),
                                )
                              : const Icon(Icons.person_rounded, color: Colors.white, size: 32),
                        ),
                      ],
                    ),
                    const Spacer(),
                    playerAsync.when(
                      data: (p) => Row(
                        children: [
                          _buildBadge('${LevelModel.getLevel(p.points).icon} ${LevelModel.getLevel(p.points).title}'),
                          const SizedBox(width: 8),
                          _buildBadge('Rank #${p.rank}'),
                          const Spacer(),
                          Text('${p.points} XP',
                              style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      loading: () => const SizedBox(height: 24),
                      error: (_, __) => const SizedBox(height: 24),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                playerAsync.when(
                  data: (player) => Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: StatsCard(
                            label: 'Level',
                            value: LevelModel.getLevel(player.points).title,
                            icon: Icons.military_tech_rounded,
                            iconColor: AppColors.silver,
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: StatsCard(
                            label: 'Rank',
                            value: '#${player.rank}',
                            icon: Icons.leaderboard_rounded,
                            iconColor: AppColors.gold,
                          )),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: StatsCard(
                            label: 'Wins',
                            value: '${player.championshipWins}',
                            icon: Icons.emoji_events_rounded,
                            iconColor: AppColors.gold,
                            gradient: AppColors.gradientAccent,
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: StatsCard(
                            label: 'Tournaments',
                            value: '${(player.tournamentPoints ~/ 100)}',
                            icon: Icons.workspace_premium_rounded,
                            iconColor: AppColors.secondary,
                          )),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('XP Progress', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                                  const Spacer(),
                                  Text('Level ${LevelModel.getLevel(player.points).level}',
                                      style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: LevelModel.getProgress(player.points),
                                  minHeight: 8,
                                  backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.3),
                                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${(LevelModel.getProgress(player.points) * 100).toInt()}% to next level',
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  loading: () => const Center(child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  )),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.all(40),
                    child: Text('Failed to load profile', style: TextStyle(color: AppColors.error)),
                  ),
                ),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Performance', actionLabel: 'Details'),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Recent Activity', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),
                        sessionsAsync.when(
                          data: (snap) {
                            final docs = snap.docs.take(5).toList();
                            if (docs.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: Text('No recent activity', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                                ),
                              );
                            }
                            return Column(
                              children: docs.map((doc) {
                                final data = doc.data();
                                final dateTime = (data['dateTime'] as Timestamp).toDate();
                                final sport = data['sport'] as String? ?? 'Training';
                                final status = data['status'] as String? ?? 'completed';
                                final isCompleted = status == 'completed';
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36, height: 36,
                                        decoration: BoxDecoration(
                                          color: (isCompleted ? AppColors.primary : AppColors.warning).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          Icons.sports_rounded, size: 18,
                                          color: isCompleted ? AppColors.primary : AppColors.warning,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(sport, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                                            Text(DateFormat('MMM d, h:mm a').format(dateTime),
                                                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: (isCompleted ? AppColors.success : AppColors.warning).withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          isCompleted ? 'Done' : 'Upcoming',
                                          style: TextStyle(
                                            color: isCompleted ? AppColors.success : AppColors.warning,
                                            fontSize: 10, fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          },
                          loading: () => const Center(child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )),
                          error: (_, __) => Text('Failed to load activity',
                              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.error)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SectionHeader(title: 'Find a Coach', actionLabel: 'Explore All', onActionTap: () => context.push('/coach-discovery')),
                const SizedBox(height: 8),
                _buildCoachCarousel(context, ref),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Achievements'),
                const SizedBox(height: 12),
                achievementsAsync.when(
                  data: (unlockedList) {
                    final unlockedIds = unlockedList.map((e) => e['achievementId'] as String).toSet();
                    final achievements = AchievementModel.achievements.take(4).toList();
                    return Row(
                      children: achievements.map((a) {
                        final isUnlocked = unlockedIds.contains(a.id);
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Card(
                              margin: EdgeInsets.zero,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                                child: Column(
                                  children: [
                                    Text(a.icon, style: const TextStyle(fontSize: 28)),
                                    const SizedBox(height: 8),
                                    Text(a.title, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                                        maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: (isUnlocked ? AppColors.success : theme.colorScheme.onSurfaceVariant).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isUnlocked ? 'Unlocked' : 'Locked',
                                        style: TextStyle(
                                          color: isUnlocked ? AppColors.success : theme.colorScheme.onSurfaceVariant,
                                          fontSize: 9, fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const SizedBox(height: 80),
                  error: (_, __) => const SizedBox(height: 80),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildCoachCarousel(BuildContext context, WidgetRef ref) {
    final coachesAsync = ref.watch(coachesStreamProvider);
    return coachesAsync.when(
      data: (coaches) {
        if (coaches.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.1)),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.person_search_rounded, size: 48, color: AppColors.textDim),
                  const SizedBox(height: 8),
                  Text('No coaches available', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  GradientButton(
                    onPressed: () => context.push('/coach-discovery'),
                    height: 36,
                    borderRadius: 8,
                    child: const Text('Browse Coaches', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ],
              ),
            ),
          );
        }
        return SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: coaches.length + 1,
            itemBuilder: (ctx, index) {
              if (index == coaches.length) {
                return _buildExploreCard(context);
              }
              return _buildCarouselCard(context, coaches[index]);
            },
          ),
        );
      },
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (e, _) {
        debugPrint('Coach carousel error: $e');
        return Container(
          padding: const EdgeInsets.all(24),
          child: Text('Unable to load coaches', style: TextStyle(color: AppColors.error)),
        );
      },
    );
  }

  Widget _buildCarouselCard(BuildContext context, CoachModel coach) {
    final initials = coach.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
    final colors = [AppColors.primary, AppColors.accent, AppColors.secondary, AppColors.info, AppColors.success];
    final cardColor = colors[coach.coachId.hashCode.abs() % colors.length];

    return Container(
      width: 180,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cardColor.withValues(alpha: 0.15), cardColor.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardColor.withValues(alpha: 0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/coach-discovery'),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [cardColor, cardColor.withValues(alpha: 0.7)]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                  ),
                ),
                const Spacer(),
                Text(coach.name, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(coach.specialization ?? 'Coach', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 14, color: AppColors.gold),
                    const SizedBox(width: 2),
                    Text(coach.rating.toStringAsFixed(1), style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text('₹${coach.hourlyRate.toInt()}', style: AppTextStyles.labelSmall.copyWith(color: cardColor, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExploreCard(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/coach-discovery'),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.explore_rounded, size: 32, color: AppColors.primary),
              SizedBox(height: 8),
              Text('Explore More', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
              SizedBox(height: 2),
              Text('Coaches', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
