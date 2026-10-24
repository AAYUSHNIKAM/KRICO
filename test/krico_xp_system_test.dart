import 'package:flutter_test/flutter_test.dart';
import 'package:sports_app/core/gamification/krico_xp_system.dart';

void main() {
  group('KRICO Unified XP & Progression System Tests', () {
    test('maxSessionXpForLevel scales correctly from 25 XP by +2 per level up to max 45 XP', () {
      expect(KricoXpSystem.maxSessionXpForLevel(1), 25);
      expect(KricoXpSystem.maxSessionXpForLevel(2), 27);
      expect(KricoXpSystem.maxSessionXpForLevel(3), 29);
      expect(KricoXpSystem.maxSessionXpForLevel(4), 31);
      expect(KricoXpSystem.maxSessionXpForLevel(5), 33);
      expect(KricoXpSystem.maxSessionXpForLevel(10), 43);
      expect(KricoXpSystem.maxSessionXpForLevel(11), 45);
      expect(KricoXpSystem.maxSessionXpForLevel(12), 45);
      expect(KricoXpSystem.maxSessionXpForLevel(50), 45);
    });

    test('validateRoutinePercentages enforces exact 100% total', () {
      expect(KricoXpSystem.validateRoutinePercentages([25, 25, 25, 25]), isNull);
      expect(KricoXpSystem.validateRoutinePercentages([40, 35, 25]), isNull);
      expect(KricoXpSystem.validateRoutinePercentages([100]), isNull);

      // Under 100%
      expect(KricoXpSystem.validateRoutinePercentages([50, 40]), contains('Percentages must total exactly 100%'));

      // Over 100%
      expect(KricoXpSystem.validateRoutinePercentages([60, 50]), contains('Percentages must total exactly 100%'));

      // Zero or negative
      expect(KricoXpSystem.validateRoutinePercentages([100, 0]), contains('must be greater than 0%'));
    });

    test('calculateSubRoutineXpBreakdown allocates cleanly and totals max XP for level 1 (25 XP)', () {
      final subRoutines = [
        {'id': 'sub_1', 'percentage': 30},
        {'id': 'sub_2', 'percentage': 30},
        {'id': 'sub_3', 'percentage': 40},
      ];

      final breakdown = KricoXpSystem.calculateSubRoutineXpBreakdown(
        playerLevel: 1,
        subRoutines: subRoutines,
      );

      final totalBreakdownXp = breakdown.values.reduce((a, b) => a + b);
      expect(totalBreakdownXp, 25);
    });

    test('calculateSubRoutineXpBreakdown allocates cleanly for level 5 (33 XP)', () {
      final subRoutines = [
        {'id': 'sub_1', 'percentage': 33.33},
        {'id': 'sub_2', 'percentage': 33.33},
        {'id': 'sub_3', 'percentage': 33.34},
      ];

      final breakdown = KricoXpSystem.calculateSubRoutineXpBreakdown(
        playerLevel: 5,
        subRoutines: subRoutines,
      );

      final totalBreakdownXp = breakdown.values.reduce((a, b) => a + b);
      expect(totalBreakdownXp, 33);
    });

    test('calculateSessionAward calculates only completed sub-routines', () {
      final breakdown = {'sub_1': 8, 'sub_2': 8, 'sub_3': 9}; // Level 1 total = 25 XP

      // Only 2 of 3 completed
      final earned = KricoXpSystem.calculateSessionAward(
        playerLevel: 1,
        subRoutineXpMap: breakdown,
        completedSubRoutineIds: {'sub_1', 'sub_3'},
      );

      expect(earned, 17);
    });

    test('getLevelInfo and getLeague maps accurately', () {
      final rookie = KricoXpSystem.getLevelInfo(50);
      expect(rookie.level, 1);
      expect(rookie.title, 'Rookie');

      final starter = KricoXpSystem.getLevelInfo(250);
      expect(starter.level, 2);

      final bronzeLeague = KricoXpSystem.getLeague(300);
      expect(bronzeLeague.tier, 'Bronze');

      final silverLeague = KricoXpSystem.getLeague(750);
      expect(silverLeague.tier, 'Silver');

      final diamondLeague = KricoXpSystem.getLeague(6000);
      expect(diamondLeague.tier, 'Diamond');
    });
  });
}
