import 'package:flutter_test/flutter_test.dart';
import 'package:sports_app/models/coaching_package_model.dart';

void main() {
  group('CoachingPackageModel Pricing & Escrow Calculations', () {
    test('Calculates 10% platform fee and net coach payout correctly', () {
      final package = CoachingPackageModel(
        id: 'pkg_123',
        title: '10-Session Batting Masterclass',
        coachId: 'coach_pune_1',
        coachName: 'Coach Vikram',
        playerId: 'player_456',
        playerName: 'Aryan',
        sport: 'Cricket',
        totalSessions: 10,
        completedSessions: 0,
        totalAmount: 10000.0,
        platformFeeRate: 0.10,
        createdAt: DateTime.now(),
      );

      expect(package.platformFee, 1000.0);
      expect(package.netCoachAmount, 9000.0);
      expect(package.payoutPerSession, 900.0);
      expect(package.releasedAmount, 0.0);
      expect(package.remainingEscrow, 9000.0);
      expect(package.progressPercentage, 0.0);
      expect(package.remainingSessions, 10);
    });

    test('Progresses escrow releases accurately after 4 sessions attended', () {
      final package = CoachingPackageModel(
        id: 'pkg_123',
        title: '10-Session Batting Masterclass',
        coachId: 'coach_pune_1',
        coachName: 'Coach Vikram',
        playerId: 'player_456',
        playerName: 'Aryan',
        sport: 'Cricket',
        totalSessions: 10,
        completedSessions: 4,
        totalAmount: 10000.0,
        platformFeeRate: 0.10,
        escrowState: EscrowState.partiallyReleased,
        createdAt: DateTime.now(),
      );

      expect(package.releasedAmount, 3600.0);
      expect(package.remainingEscrow, 5400.0);
      expect(package.progressPercentage, 0.4);
      expect(package.remainingSessions, 6);
      expect(package.escrowState.label, 'In Progress');
    });

    test('Full completion releases 100% of coach escrow funds', () {
      final package = CoachingPackageModel(
        id: 'pkg_123',
        title: '5-Session Tennis Intensive',
        coachId: 'coach_pune_2',
        coachName: 'Coach Sania',
        playerId: 'player_789',
        playerName: 'Rhea',
        sport: 'Tennis',
        totalSessions: 5,
        completedSessions: 5,
        totalAmount: 6000.0,
        platformFeeRate: 0.10,
        escrowState: EscrowState.completed,
        createdAt: DateTime.now(),
      );

      expect(package.platformFee, 600.0);
      expect(package.netCoachAmount, 5400.0);
      expect(package.payoutPerSession, 1080.0);
      expect(package.releasedAmount, 5400.0);
      expect(package.remainingEscrow, 0.0);
      expect(package.progressPercentage, 1.0);
      expect(package.remainingSessions, 0);
      expect(package.escrowState.label, 'Package Completed');
    });

    test('Escrow state parsing correctly handles raw string statuses', () {
      expect(EscrowState.fromString('escrow_held'), EscrowState.escrowHeld);
      expect(EscrowState.fromString('partially_released'), EscrowState.partiallyReleased);
      expect(EscrowState.fromString('completed'), EscrowState.completed);
      expect(EscrowState.fromString('refunded'), EscrowState.refunded);
      expect(EscrowState.fromString('disputed'), EscrowState.disputed);
      expect(EscrowState.fromString('unknown_status'), EscrowState.paymentPending);
    });
  });
}
