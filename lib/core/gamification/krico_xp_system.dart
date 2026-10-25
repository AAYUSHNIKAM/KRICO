import 'dart:math';

/// Unified KRICO Level & Progression details
class KricoLevelInfo {
  final int level;
  final String title;
  final int minXp;
  final int maxXp;
  final String icon;
  final double progressPercent;

  const KricoLevelInfo({
    required this.level,
    required this.title,
    required this.minXp,
    required this.maxXp,
    required this.icon,
    required this.progressPercent,
  });
}

/// Unified KRICO League details
class KricoLeagueInfo {
  final String name;
  final String tier;
  final String icon;
  final int minXp;
  final int? maxXp;
  final int colorHex;

  const KricoLeagueInfo({
    required this.name,
    required this.tier,
    required this.icon,
    required this.minXp,
    this.maxXp,
    required this.colorHex,
  });
}

/// Leaderboard player item representation
class KricoLeaderboardPlayer {
  final int rank;
  final String playerId;
  final String name;
  final String? avatarUrl;
  final String sport;
  final int totalXp;
  final int level;
  final String league;

  const KricoLeaderboardPlayer({
    required this.rank,
    required this.playerId,
    required this.name,
    this.avatarUrl,
    required this.sport,
    required this.totalXp,
    required this.level,
    required this.league,
  });

  factory KricoLeaderboardPlayer.fromMap(int rank, String id, Map<String, dynamic> data) {
    final points = (data['points'] as num?)?.toInt() ?? 0;
    final level = KricoXpSystem.getLevelInfo(points).level;
    final league = KricoXpSystem.getLeague(points).name;

    return KricoLeaderboardPlayer(
      rank: rank,
      playerId: id,
      name: data['name'] as String? ?? 'KRICO Athlete',
      avatarUrl: data['avatarUrl'] as String? ?? data['photoUrl'] as String?,
      sport: data['sport'] as String? ?? 'Athletics',
      totalXp: points,
      level: level,
      league: league,
    );
  }
}

/// Centralized KRICO XP & Progression System
class KricoXpSystem {
  /// Session XP Formula:
  /// - Level 1 beginner: Max 25 XP
  /// - Increases by +2 XP per level: Level 2 = 27, Level 3 = 29, ..., Level 11 = 45
  /// - Strictly stops at max 45 XP for Level 11 and all subsequent levels
  static int maxSessionXpForLevel(int playerLevel) {
    final lvl = max(1, playerLevel);
    if (lvl == 1) return 25;
    final calculated = 25 + (lvl - 1) * 2;
    return calculated > 45 ? 45 : calculated;
  }

  /// Shorthand to get level number
  static int getLevel(int cumulativeXp) => getLevelInfo(cumulativeXp).level;

  /// Global XP-to-Level Mapping (Single source of truth)
  static KricoLevelInfo getLevelInfo(int cumulativeXp) {
    final xp = max(0, cumulativeXp);
    if (xp < 100) {
      final progress = xp / 100.0;
      return KricoLevelInfo(
        level: 1,
        title: 'Rookie',
        minXp: 0,
        maxXp: 99,
        icon: '🐣',
        progressPercent: progress.clamp(0.0, 1.0),
      );
    }

    final lvlNum = 2 + ((xp - 100) ~/ 500);
    final minPts = 100 + ((lvlNum - 2) * 500);
    final maxPts = minPts + 499;
    final range = maxPts - minPts;
    final progress = range > 0 ? (xp - minPts) / range : 1.0;

    String title;
    String icon;
    if (lvlNum == 2) {
      title = 'Starter';
      icon = '🌱';
    } else if (lvlNum == 3) {
      title = 'Contender';
      icon = '⚡';
    } else if (lvlNum == 4) {
      title = 'Challenger';
      icon = '🎯';
    } else if (lvlNum == 5) {
      title = 'Competitor';
      icon = '🔥';
    } else if (lvlNum == 6) {
      title = 'Striker';
      icon = '⚔️';
    } else if (lvlNum <= 10) {
      title = 'Warrior (T)';
      icon = '🛡️';
    } else if (lvlNum <= 15) {
      title = 'Champion (T)';
      icon = '🏆';
    } else if (lvlNum <= 20) {
      title = 'Master (T)';
      icon = '💎';
    } else {
      title = 'Hall of Fame (T)';
      icon = '👑';
    }

    return KricoLevelInfo(
      level: lvlNum,
      title: title,
      minXp: minPts,
      maxXp: maxPts,
      icon: icon,
      progressPercent: progress.clamp(0.0, 1.0),
    );
  }

  /// Global Leagues shared by all players & coaches
  static KricoLeagueInfo getLeague(int cumulativeXp) {
    final xp = max(0, cumulativeXp);
    if (xp < 500) {
      return const KricoLeagueInfo(
        name: 'Bronze League',
        tier: 'Bronze',
        icon: '🥉',
        minXp: 0,
        maxXp: 499,
        colorHex: 0xFFCD7F32,
      );
    } else if (xp < 1500) {
      return const KricoLeagueInfo(
        name: 'Silver League',
        tier: 'Silver',
        icon: '🥈',
        minXp: 500,
        maxXp: 1499,
        colorHex: 0xFFC0C0C0,
      );
    } else if (xp < 3500) {
      return const KricoLeagueInfo(
        name: 'Gold League',
        tier: 'Gold',
        icon: '🥇',
        minXp: 1500,
        maxXp: 3499,
        colorHex: 0xFFFFD700,
      );
    } else if (xp < 5000) {
      return const KricoLeagueInfo(
        name: 'Platinum League',
        tier: 'Platinum',
        icon: '💠',
        minXp: 3500,
        maxXp: 4999,
        colorHex: 0xFF00CED1,
      );
    } else if (xp < 7500) {
      return const KricoLeagueInfo(
        name: 'Diamond League',
        tier: 'Diamond',
        icon: '💎',
        minXp: 5000,
        maxXp: 7499,
        colorHex: 0xFF00E5FF,
      );
    } else if (xp < 10000) {
      return const KricoLeagueInfo(
        name: 'Master League',
        tier: 'Master',
        icon: '⚡',
        minXp: 7500,
        maxXp: 9999,
        colorHex: 0xFFFF5722,
      );
    } else {
      return const KricoLeagueInfo(
        name: 'Grandmaster League',
        tier: 'Grandmaster',
        icon: '👑',
        minXp: 10000,
        maxXp: null,
        colorHex: 0xFFFFD700,
      );
    }
  }

  /// Validates that a list of sub-routine percentages sums to exactly 100%
  static String? validateRoutinePercentages(List<num> percentages) {
    if (percentages.isEmpty) {
      return 'At least one sub-routine is required.';
    }
    for (int i = 0; i < percentages.length; i++) {
      if (percentages[i] <= 0) {
        return 'Sub-routine # percentage must be greater than 0%.';
      }
    }
    final total = percentages.fold<double>(0.0, (sum, p) => sum + p.toDouble());
    if ((total - 100.0).abs() > 0.01) {
      final formattedTotal = total.toStringAsFixed(total.truncateToDouble() == total ? 0 : 1);
      return 'Percentages must total exactly 100%. Current total: %.';
    }
    return null;
  }

  /// Calculates the exact XP breakdown for each sub-routine based on player level
  /// and coach's configured percentage allocations.
  /// Handles rounding consistently so 100% completed sum equals maxSessionXp exactly.
  static Map<String, int> calculateSubRoutineXpBreakdown({
    required int playerLevel,
    required List<Map<String, dynamic>> subRoutines,
  }) {
    if (subRoutines.isEmpty) return {};

    final maxYp = maxSessionXpForLevel(playerLevel);
    final breakdown = <String, int>{};

    int allocatedTotal = 0;
    for (int i = 0; i < subRoutines.length; i++) {
      final item = subRoutines[i];
      final id = (item['id'] ?? 'sub_').toString();
      final pct = ((item['percentage'] ?? item['percentageAllocation'] ?? 0) as num).toDouble();

      int xp;
      if (i == subRoutines.length - 1) {
        // Last item absorbs remaining rounding difference
        final remaining = maxYp - allocatedTotal;
        xp = max(0, remaining);
      } else {
        xp = (maxYp * (pct / 100.0)).round();
        allocatedTotal += xp;
      }
      breakdown[id] = xp;
    }

    return breakdown;
  }

  /// Calculates the total earned XP from a completed routine progress form.
  /// Caps strictly at maxSessionXpForLevel(playerLevel).
  static int calculateSessionAward({
    required int playerLevel,
    required Map<String, int> subRoutineXpMap,
    required Set<String> completedSubRoutineIds,
  }) {
    final maxYp = maxSessionXpForLevel(playerLevel);
    int total = 0;

    for (final id in completedSubRoutineIds) {
      if (subRoutineXpMap.containsKey(id)) {
        total += subRoutineXpMap[id]!;
      }
    }

    return min(maxYp, max(0, total));
  }
}
