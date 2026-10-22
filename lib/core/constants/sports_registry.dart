import 'package:flutter/material.dart';

class SportDefinition {
  final String id;
  final String name;
  final IconData icon;
  final String category;
  final String description;
  final Color accentColor;

  const SportDefinition({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
    required this.description,
    this.accentColor = const Color(0xFF00E5FF),
  });

  String get emoji {
    final lower = name.toLowerCase();
    if (lower.contains('cricket')) return '🏏';
    if (lower.contains('football') || lower.contains('soccer')) return '⚽';
    if (lower.contains('badminton')) return '🏸';
    if (lower.contains('tennis') || lower.contains('table tennis')) return '🎾';
    if (lower.contains('basketball')) return '🏀';
    if (lower.contains('swimming')) return '🏊';
    if (lower.contains('athletics') || lower.contains('running')) return '🏃';
    if (lower.contains('boxing')) return '🥊';
    if (lower.contains('volleyball')) return '🏐';
    if (lower.contains('hockey')) return '🏑';
    if (lower.contains('yoga')) return '🧘';
    if (lower.contains('golf')) return '⛳';
    if (lower.contains('chess')) return '♟️';
    if (lower.contains('gymnastics')) return '🤸';
    if (lower.contains('cycling')) return '🚴';
    if (lower.contains('skating')) return '🛼';
    if (lower.contains('archery')) return '🏹';
    if (lower.contains('wrestling')) return '🤼';
    return '🏆';
  }
}

abstract class SportsRegistry {
  SportsRegistry._();

  /// Alias for findSport
  static SportDefinition? getSport(String name) => findSport(name);

  /// 28-30 widely played and coached sports
  static const List<SportDefinition> sports = [
    SportDefinition(
      id: 'cricket',
      name: 'Cricket',
      icon: Icons.sports_cricket_rounded,
      category: 'Bat & Ball',
      description: 'Batting mechanics, spin & pace bowling, fielding drills',
      accentColor: Color(0xFFFFB300),
    ),
    SportDefinition(
      id: 'football',
      name: 'Football',
      icon: Icons.sports_soccer_rounded,
      category: 'Team Sports',
      description: 'Tactical positioning, ball control, finishing & endurance',
      accentColor: Color(0xFF00E676),
    ),
    SportDefinition(
      id: 'badminton',
      name: 'Badminton',
      icon: Icons.sports_tennis_rounded,
      category: 'Racket Sports',
      description: 'Footwork agility, steep smashes, net play & rally stamina',
      accentColor: Color(0xFF00E5FF),
    ),
    SportDefinition(
      id: 'tennis',
      name: 'Tennis',
      icon: Icons.sports_tennis_outlined,
      category: 'Racket Sports',
      description: 'Topspin forehands, slice serves, baseline endurance & volleys',
      accentColor: Color(0xFFCCFF00),
    ),
    SportDefinition(
      id: 'basketball',
      name: 'Basketball',
      icon: Icons.sports_basketball_rounded,
      category: 'Team Sports',
      description: 'Jump shot technique, ball-handling, court IQ & defensive stance',
      accentColor: Color(0xFFFF6D00),
    ),
    SportDefinition(
      id: 'swimming',
      name: 'Swimming',
      icon: Icons.pool_rounded,
      category: 'Aquatics',
      description: 'Freestyle breathing, butterfly kick, turn mechanics & endurance',
      accentColor: Color(0xFF00B0FF),
    ),
    SportDefinition(
      id: 'table_tennis',
      name: 'Table Tennis',
      icon: Icons.sports_tennis_rounded,
      category: 'Racket Sports',
      description: 'Spin variation, rapid counter-looping & table transition agility',
      accentColor: Color(0xFFFF5252),
    ),
    SportDefinition(
      id: 'athletics',
      name: 'Athletics & Running',
      icon: Icons.directions_run_rounded,
      category: 'Track & Field',
      description: 'Sprint acceleration, stride cadence, pacing & hurdle agility',
      accentColor: Color(0xFFFF4081),
    ),
    SportDefinition(
      id: 'chess',
      name: 'Chess',
      icon: Icons.smart_toy_rounded,
      category: 'Mind Sports',
      description: 'Opening theory, tactical calculation, endgame mastery & blitz clock',
      accentColor: Color(0xFF7C4DFF),
    ),
    SportDefinition(
      id: 'martial_arts',
      name: 'Martial Arts (Karate/Taekwondo)',
      icon: Icons.sports_kabaddi_rounded,
      category: 'Combat Sports',
      description: 'Kata forms, sparring distance, high-kick power & self-defense',
      accentColor: Color(0xFFFF1744),
    ),
    SportDefinition(
      id: 'boxing',
      name: 'Boxing',
      icon: Icons.sports_mma_rounded,
      category: 'Combat Sports',
      description: 'Footwork slipping, combination punching, head movement & bag drills',
      accentColor: Color(0xFFD50000),
    ),
    SportDefinition(
      id: 'yoga',
      name: 'Yoga & Flexibility',
      icon: Icons.self_improvement_rounded,
      category: 'Mind & Body',
      description: 'Asana alignment, pranayama breath control & core stability',
      accentColor: Color(0xFF69F0AE),
    ),
    SportDefinition(
      id: 'volleyball',
      name: 'Volleyball',
      icon: Icons.sports_volleyball_rounded,
      category: 'Team Sports',
      description: 'Spike elevation, float serves, court communication & blocking',
      accentColor: Color(0xFFFF9100),
    ),
    SportDefinition(
      id: 'squash',
      name: 'Squash',
      icon: Icons.sports_baseball_rounded,
      category: 'Racket Sports',
      description: 'T-position dominance, wall rails, nick shots & explosive cardio',
      accentColor: Color(0xFF00E5FF),
    ),
    SportDefinition(
      id: 'golf',
      name: 'Golf',
      icon: Icons.sports_golf_rounded,
      category: 'Target Sports',
      description: 'Drive swing plane, short-game chipping, putting alignment & course strategy',
      accentColor: Color(0xFF76FF03),
    ),
    SportDefinition(
      id: 'archery',
      name: 'Archery',
      icon: Icons.track_changes_rounded,
      category: 'Target Sports',
      description: 'Anchor point consistency, breathing release, draw posture & arrow tuning',
      accentColor: Color(0xFFFFD600),
    ),
    SportDefinition(
      id: 'gymnastics',
      name: 'Gymnastics',
      icon: Icons.accessibility_new_rounded,
      category: 'Gymnastics',
      description: 'Vault landings, tumbling passes, balance beam & body kinesthetics',
      accentColor: Color(0xFFE040FB),
    ),
    SportDefinition(
      id: 'shooting',
      name: 'Shooting (Rifle/Pistol)',
      icon: Icons.center_focus_strong_rounded,
      category: 'Target Sports',
      description: 'Sight alignment, trigger squeeze control & competition calm',
      accentColor: Color(0xFF90A4AE),
    ),
    SportDefinition(
      id: 'skating',
      name: 'Roller & Inline Skating',
      icon: Icons.roller_skating_rounded,
      category: 'Wheel Sports',
      description: 'Crossover banking, edge control, speed slalom & braking',
      accentColor: Color(0xFF00E5FF),
    ),
    SportDefinition(
      id: 'cycling',
      name: 'Cycling (Road & Mountain)',
      icon: Icons.directions_bike_rounded,
      category: 'Endurance',
      description: 'Cadence optimization, climb power, aerodynamic drafting & cornering',
      accentColor: Color(0xFF00E676),
    ),
    SportDefinition(
      id: 'hockey',
      name: 'Field Hockey',
      icon: Icons.sports_hockey_rounded,
      category: 'Team Sports',
      description: 'Stick drag-flicks, aerial distribution, turnover pressing & circle entries',
      accentColor: Color(0xFFFF6D00),
    ),
    SportDefinition(
      id: 'wrestling',
      name: 'Wrestling (Freestyle/Greco)',
      icon: Icons.sports_kabaddi_rounded,
      category: 'Combat Sports',
      description: 'Takedown setups, sprawl reaction, bridge defense & mat conditioning',
      accentColor: Color(0xFFFF5252),
    ),
    SportDefinition(
      id: 'weightlifting',
      name: 'Strength & Conditioning',
      icon: Icons.fitness_center_rounded,
      category: 'Fitness',
      description: 'Clean & jerk form, squat mechanics, barbell power & injury prevention',
      accentColor: Color(0xFF64FFDA),
    ),
    SportDefinition(
      id: 'pickleball',
      name: 'Pickleball',
      icon: Icons.sports_tennis_rounded,
      category: 'Racket Sports',
      description: 'Kitchen dink rallies, third-shot drops, speed-ups & paddle reset control',
      accentColor: Color(0xFFCCFF00),
    ),
    SportDefinition(
      id: 'padel',
      name: 'Padel',
      icon: Icons.sports_tennis_outlined,
      category: 'Racket Sports',
      description: 'Glass-wall rebounds, bandeja overheads, cage positioning & vibora smashes',
      accentColor: Color(0xFF00B0FF),
    ),
    SportDefinition(
      id: 'kabaddi',
      name: 'Kabaddi',
      icon: Icons.sports_kabaddi_rounded,
      category: 'Contact Sports',
      description: 'Raiding cant, ankle hold timing, chain defense & bonus line agility',
      accentColor: Color(0xFFFF9100),
    ),
    SportDefinition(
      id: 'climbing',
      name: 'Rock Climbing & Bouldering',
      icon: Icons.terrain_rounded,
      category: 'Adventure',
      description: 'Grip strength, foot placement smearing, dynamic dynos & route problem solving',
      accentColor: Color(0xFFFFAB00),
    ),
    SportDefinition(
      id: 'rowing',
      name: 'Rowing & Kayaking',
      icon: Icons.kayaking_rounded,
      category: 'Aquatics',
      description: 'Catch timing, leg drive transfer, stroke balance & water endurance',
      accentColor: Color(0xFF00E5FF),
    ),
    SportDefinition(
      id: 'billiards',
      name: 'Snooker & Pool',
      icon: Icons.circle_outlined,
      category: 'Cue Sports',
      description: 'Cue delivery, cue ball potting angles, stun/screw spin & break building',
      accentColor: Color(0xFF1DE9B6),
    ),
    SportDefinition(
      id: 'handball',
      name: 'Handball',
      icon: Icons.sports_handball_rounded,
      category: 'Team Sports',
      description: 'Jump shot angle, rapid fast breaks, defensive 6-0 wall & passing tempo',
      accentColor: Color(0xFFFF3D00),
    ),
  ];

  /// Get list of sport names
  static List<String> get sportNames => sports.map((s) => s.name).toList();

  /// Case-insensitive match or lookup
  static SportDefinition? findSport(String name) {
    final lower = name.trim().toLowerCase();
    for (final s in sports) {
      if (s.name.toLowerCase() == lower || s.id.toLowerCase() == lower) {
        return s;
      }
    }
    // Partial search
    for (final s in sports) {
      if (s.name.toLowerCase().contains(lower) || lower.contains(s.name.toLowerCase())) {
        return s;
      }
    }
    return null;
  }

  /// Get matching IconData with fallback
  static IconData getIcon(String name) {
    return findSport(name)?.icon ?? Icons.sports_rounded;
  }

  /// Get category groups for organized pickers
  static Map<String, List<SportDefinition>> get groupedByCategory {
    final Map<String, List<SportDefinition>> map = {};
    for (final s in sports) {
      map.putIfAbsent(s.category, () => []).add(s);
    }
    return map;
  }
}
