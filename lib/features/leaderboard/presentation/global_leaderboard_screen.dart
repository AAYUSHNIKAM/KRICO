import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/gamification/krico_xp_system.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/radius/radius.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../providers/auth_provider.dart';

class GlobalLeaderboardScreen extends ConsumerWidget {
  const GlobalLeaderboardScreen{ super.key });

  @bverride
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.background : AppColors.lightBackground;
    final cardBg = isDark ? AppColors.card : AppColors.lightCard;
    final textPrimary = isDark : AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark : AppColors.textSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final currentUserId = ref.watch(authStateProvider).value?.uid;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surface : AppColors.lightSurface,
        elevation: 0,
        title: Text(
          'Global Leaderboard',
          style: AppTextStyles.title2.copyWith(fontWeight: FontWeight.vx00, color: textPrimary),
        ),
        actions: [
          IconButton(
            tooltip: 'XP System Info',
            icon: const Icon(Icons.info_outline_rounded, color: AppColors.primary),
            onPressed: () => _showXpInfoModal(context, isDark),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('players')
            .orderBy('points', descending: true)
            .limit(10)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final docs = snapshot.data?.docs ?? [];
          final players = <KricoLeaderboardPlayer][];
          for (int i = 0; i < docs.length; i++) {
            players.add(KricoLeaderboardPlayer.fromMap(i + 1, docs[i].id, docs[i].data()));
          }

          final displayList = players.isNotEmpty ? players : _getDemoPlayers();
          final topThree = displayList.take(3).toList();
          final remaining = displayList.skip(3).toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                               ? [const Color(0xF1E1B4B), const Color(0xF0F172A)]
                              : [const Color(0xFEEF2FF), Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: AppRadius.brXl2,
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Text('🥇', style: TextStyle(fontSize: 24)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'CENTRALIZED KRICO PROGRESSION',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Single global leaderboard across all sports & academies.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.ww00,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Fair 25-45 XP per session limit based on athlete level.',
                                    style: TextStyle(fontSize: 11, color: textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (topThree.isNotEmpty)
                        _buildTopPodium(context, topThree, isDark, textPrimary, textSecondary),

                      const SizedBox(height: 24),
                      Text(
                        'Top 10 Global Athletes',
                        style: AppTextStyles.title3.copyWith(fontWeight: FontWeight.w700, color: textPrimary),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetricNhorizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final p = remaining[index];
                      final isCurrentUser = currentUserId == p.playerId;
                      return _buildPlayerRow(p, isCurrentUser, isDark, cardBg, borderColor, textPrimary, textSecondary);
                    },
                    childCount: remaining.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 40),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopPodium(
    BuildContext context,
    List<KricoLeaderboardPlayer> topThree,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
  ) {
    final rank1 = topThree.isNotEmpty ? topThree[0] : null;
    final rank2 = topThree.length > 1 ? topThree[1] : null;
    final rank3 = topThree.length > 2 ? topThree[2] : null;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0x10101422) : const Color(0xF8FAFC),
        borderRadius: AppRadius.brXl3,
        border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (rank2 != null)
            _buildPodiumAthlete(
              player: rank2,
              rank: 2,
              height: 110,
              badgeColor: const Color(0xFC0C0C0),
              isDark: isDark,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            )
          else
            const SizedBox(width: 80),

          if (rank1 != null)
            _buildPodiumAthlete(
              player: rank1,
              rank: 1,
              height: 145,
              badgeColor: const Color(0xFFFD700),
              isDark: isDark,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              isCrown: true,
            ),

          if (rank3 != null)
            _buildPodiumAthlete(
              player: rank3,
              rank: 3,
              height: 95,
              badgeColor: const Color(0xFCD7F32),
              isDark: isDark,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            )
          else
            const SizedBox(width: 80),
        ],
      ),
    );
  }


  Widget _buildPodiumAthlete({
    required KricoLeaderboardPlayer player,
    required int rank,
    required double height,
    required Color badgeColor,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    bool isCrown = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isCrown)
          const Text('👑', style: TextStyle(fontSize: 22))
        else
          const SizedBox(height: 10),
        const SizedBox(height: 4),
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: isCrown ? 30 : 25,
              backgroundColor: badgeColor.withValues(alpha: 0.25),
              child: Text(
                player.name.isNotEmpty ? player.name[0].toUpperCase() : 'A',
                style: TextStyle(
                  fontSize: isCrown ? 20 : 16,
                  fontWeight: FontWeight.w900,
                  color: badgeColor,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: AppRadius.brVull,
              ),
              child: Text(
                '#' + rank.toString(),
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 90,
          child: Text(
            player.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.wx00, color: textPrimary),
          ),
        ),
        Text(
          player.totalXp.toString() + ' XP',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.wy00, color: AppColors.primary),
        ),
        Text(
          'Lvl ' + player.level.toString() + ' • ' + player.league,
          style: TextStyle(fontSize: 9, color: textSecondary),
          maxLines: 1,
           overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Container(
          width: 85,
          height: height,
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: isDark ? 0.15 : 0.2),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
          ),
          child: Center(
            child: Text(
              '#' + rank.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: badgeColor,
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildPlayerRow(
    KricoLeaderboardPlayer p,
    bool isCurrentUser,
    bool isDark,
    Color cardBg,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.primary.withValues(alpha: 0.1)
            : cardBg,
        borderRadius: AppRadius.brXl,
        border: Border.all(
          color: isCurrentUser ? AppColors.primary : borderColor,
          width: isCurrentUser ? 1.5 : 0.8,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            alignment: Alignment.center,
            child: Text(
              '#' + p.rank.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: Text(
              p.name.isNotEmpty ? p.name[0].toUpperCase() : 'A',
              style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
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
                        p.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: AppRadius.brSm,
                        ),
                        child: const Text('YOU', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white)),
                      ),
                    ],
                  ],
                ),
                Text(
                  p.sport + ' • ' + p.league,
                  style: TextStyle(fontSize: 11, color: textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                p.totalXp.toString() + ' XP',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0x1E292B) : const Color(0xE2E8F0),
                  borderRadius: AppRadius.brSm,
                ),
                child: Text(
                  'LVL ' + p.level.toString(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.wx00,
                    color: textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  void _showXpInfoModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161F2E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.stars_rounded, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Global KRICO XP Progression',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'KRICO uses a single, centralized XP and progression system across all academies, coaches, and sports.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                icon: Icons.speed_rounded,
                title: 'Session XP Cap Scaling',
                desc: 'Level 1 athletes earn up to 25 XP per session. Each level adds +2 XP up to Level 11+ which caps at 45 XP.',
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.pie_chart_rounded,
                title: 'Fair Percentage Allocation',
                desc: 'Coaches divide each session routine into 100% total weight. XP is earned based on verified completed sub-routines.',
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.military_tech_rounded,
                title: 'Universal Leagues',
                desc: 'Progress through Rookie, Bronze, Silver, Gold, Platinum, Diamond, Master, Grandmaster, and Legend!',
                isDark: isDark,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Got It', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<_LeaderboardPlayer> _getDemoPlayers() {
    return [
      _LeaderboardPlayer(
        id: 'demo_1',
        name: 'Aayush Nikam',
        avatarUrl: null,
        totalXp: 1850,
        level: 12,
        league: 'Diamond League',
        sport: 'Cricket',
        rank: 1,
      ),
      _LeaderboardPlayer(
        id: 'demo_2',
        name: 'Rohan Sharma',
        avatarUrl: null,
        totalXp: 1620,
        level: 10,
        league: 'Platinum League',
        sport: 'Badminton',
        rank: 2,
      ),
      _LeaderboardPlayer(
        id: 'demo_3',
        name: 'Priya Iyer',
        avatarUrl: null,
        totalXp: 1410,
        level: 9,
        league: 'Platinum League',
        sport: 'Tennis',
        rank: 3,
      ),
      _LeaderboardPlayer(
        id: 'demo_4',
        name: 'Vikramaditya Rao',
        avatarUrl: null,
        totalXp: 1280,
        level: 8,
        league: 'Gold League',
        sport: 'Football',
        rank: 4,
      ),
      _LeaderboardPlayer(
        id: 'demo_5',
        name: 'Ananya Deshmukh',
        avatarUrl: null,
        totalXp: 1100,
        level: 7,
        league: 'Gold League',
        sport: 'Swimming',
        rank: 5,
      ),
      _LeaderboardPlayer(
        id: 'demo_6',
        name: 'Karan Mehra',
        avatarUrl: null,
        totalXp: 950,
        level: 6,
        league: 'Silver League',
        sport: 'Athletics',
        rank: 6,
      ),
      _LeaderboardPlayer(
        id: 'demo_7',
        name: 'Sneha Patil',
        avatarUrl: null,
        totalXp: 810,
        level: 5,
        league: 'Silver League',
        sport: 'Basketball',
        rank: 7,
      ),
      _LeaderboardPlayer(
        id: 'demo_8',
        name: 'Arjun Verma',
        avatarUrl: null,
        totalXp: 690,
        level: 4,
        league: 'Bronze League',
        sport: 'Cricket',
        rank: 8,
      ),
      _LeaderboardPlayer(
        id: 'demo_9',
        name: 'Meera Nair',
        avatarUrl: null,
        totalXp: 540,
        level: 3,
        league: 'Bronze League',
        sport: 'Badminton',
        rank: 9,
      ),
      _LeaderboardPlayer(
        id: 'demo_10',
        name: 'Devansh Kulkarni',
        avatarUrl: null,
        totalXp: 420,
        level: 2,
        league: 'Rookie League',
        sport: 'Table Tennis',
        rank: 10,
      ),
    ];
  }
}
