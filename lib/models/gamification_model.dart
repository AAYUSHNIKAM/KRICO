class LevelModel {
  const LevelModel({
    required this.level,
    required this.title,
    required this.minPoints,
    required this.maxPoints,
    required this.icon,
  });

  final int level;
  final String title;
  final int minPoints;
  final int maxPoints;
  final String icon;

  static const List<LevelModel> levels = [
    LevelModel(level: 1, title: 'Rookie', minPoints: 0, maxPoints: 99, icon: '🥚'),
    LevelModel(level: 2, title: 'Starter', minPoints: 100, maxPoints: 499, icon: '🌱'),
    LevelModel(level: 3, title: 'Contender', minPoints: 500, maxPoints: 999, icon: '⚡'),
    LevelModel(level: 4, title: 'Challenger', minPoints: 1000, maxPoints: 1499, icon: '🎯'),
    LevelModel(level: 5, title: 'Competitor', minPoints: 1500, maxPoints: 1999, icon: '🔥'),
    LevelModel(level: 6, title: 'Striker', minPoints: 2000, maxPoints: 2499, icon: '⚔️'),
  ];

  static LevelModel getLevel(int points) {
    if (points < 100) {
      return const LevelModel(level: 1, title: 'Rookie', minPoints: 0, maxPoints: 99, icon: '🥚');
    }
    final lvlNum = 2 + ((points - 100) ~/ 500);
    final minPts = 100 + ((lvlNum - 2) * 500);
    final maxPts = minPts + 499;

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
    } else if (lvlNum <= 10) {
      title = 'Warrior (T$lvlNum)';
      icon = '⚔️';
    } else if (lvlNum <= 20) {
      title = 'Champion (T$lvlNum)';
      icon = '🏆';
    } else if (lvlNum <= 40) {
      title = 'Grandmaster (T$lvlNum)';
      icon = '💎';
    } else {
      title = 'Hall of Fame (T$lvlNum)';
      icon = '👑';
    }

    return LevelModel(
      level: lvlNum,
      title: title,
      minPoints: minPts,
      maxPoints: maxPts,
      icon: icon,
    );
  }

  static double getProgress(int points) {
    final level = getLevel(points);
    final range = level.maxPoints - level.minPoints;
    if (range <= 0) return 1.0;
    final progress = (points - level.minPoints) / range;
    return progress.clamp(0.0, 1.0);
  }
}

class RankModel {
  const RankModel({
    required this.rank,
    required this.title,
    required this.icon,
  });

  final int rank;
  final String title;
  final String icon;

  static const List<RankModel> ranks = [
    RankModel(rank: 1, title: 'Bronze', icon: '🥉'),
    RankModel(rank: 2, title: 'Silver', icon: '🥈'),
    RankModel(rank: 3, title: 'Gold', icon: '🥇'),
    RankModel(rank: 4, title: 'Platinum', icon: '💎'),
    RankModel(rank: 5, title: 'Diamond', icon: '🔷'),
  ];
}

class AchievementModel {
  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.pointsRequired,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  final String id;
  final String title;
  final String description;
  final String icon;
  final int pointsRequired;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  static const List<AchievementModel> achievements = [
    AchievementModel(
      id: 'first_win',
      title: 'First Victory',
      description: 'Win your first tournament match',
      icon: '🏅',
      pointsRequired: 10,
    ),
    AchievementModel(
      id: 'streak_5',
      title: 'On Fire',
      description: 'Win 5 matches in a row',
      icon: '🔥',
      pointsRequired: 50,
    ),
    AchievementModel(
      id: 'champion_10',
      title: 'Champion Material',
      description: 'Win 10 championship titles',
      icon: '🏆',
      pointsRequired: 100,
    ),
    AchievementModel(
      id: 'coach_hired',
      title: 'Team Up',
      description: 'Hire your first personal coach',
      icon: '🤝',
      pointsRequired: 20,
    ),
    AchievementModel(
      id: 'venue_explorer',
      title: 'Explorer',
      description: 'Visit 5 different venues',
      icon: '🗺️',
      pointsRequired: 30,
    ),
    AchievementModel(
      id: 'social_butterfly',
      title: 'Social Butterfly',
      description: 'Connect with 10 other players',
      icon: '🦋',
      pointsRequired: 40,
    ),
  ];
}
