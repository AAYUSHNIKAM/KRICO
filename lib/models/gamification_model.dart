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
    LevelModel(
      level: 1,
      title: 'Rookie',
      minPoints: 0,
      maxPoints: 100,
      icon: '🥚',
    ),
    LevelModel(
      level: 2,
      title: 'Amateur',
      minPoints: 101,
      maxPoints: 300,
      icon: '🌱',
    ),
    LevelModel(
      level: 3,
      title: 'Contender',
      minPoints: 301,
      maxPoints: 600,
      icon: '⚡',
    ),
    LevelModel(
      level: 4,
      title: 'Champion',
      minPoints: 601,
      maxPoints: 1000,
      icon: '🏆',
    ),
    LevelModel(
      level: 5,
      title: 'Legend',
      minPoints: 1001,
      maxPoints: 2000,
      icon: '👑',
    ),
    LevelModel(
      level: 6,
      title: 'Mythic',
      minPoints: 2001,
      maxPoints: 5000,
      icon: '🌟',
    ),
  ];

  static LevelModel getLevel(int points) {
    LevelModel current = levels.first;
    for (final level in levels) {
      if (points >= level.minPoints && points <= level.maxPoints) {
        current = level;
      } else if (points > level.maxPoints) {
        current = level;
      }
    }
    return current;
  }

  static double getProgress(int points) {
    final level = getLevel(points);
    final range = level.maxPoints - level.minPoints;
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
