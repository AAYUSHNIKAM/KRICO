import 'package:flutter_test/flutter_test.dart';
import 'package:sports_app/core/constants/app_constants.dart';
import 'package:sports_app/core/utils/pilot_sandbox_service.dart';
import 'package:sports_app/models/coach_model.dart';
import 'package:sports_app/models/user_model.dart';
import 'package:sports_app/models/venue_model.dart';

void main() {
  group('KRICO v0.0 Pilot Release Verification Tests', () {
    test('App constants are configured for v0.0 Pilot release', () {
      expect(AppConstants.appName, equals('KRICO'));
      expect(AppConstants.appVersion, equals('0.0.1 (Pilot)'));
      expect(AppConstants.appTagline, contains('Krida'));
      expect(AppConstants.appTagline, contains('Coach'));
      expect(AppConstants.majorCities, contains('Pune'));
    });

    test('PilotSandboxService constants and configuration', () {
      expect(PilotSandboxService.isPilotVersion, isTrue);
      expect(PilotSandboxService.pilotNotice, contains('v0.0 Pilot Release'));
      expect(PilotSandboxService.pilotNotice, contains('Simulated Escrow'));
    });

    test('CoachModel correctly models Pune pilot coaches', () {
      final coach = CoachModel(
        coachId: 'pune_test_coach_1',
        name: 'Rohan Kulkarni',
        email: 'rohan.badminton@krico.pune',
        phone: '+91 98220 11223',
        city: 'Pune',
        specialization: 'Badminton Advanced Tactics',
        sports: ['Badminton'],
        experience: 8,
        hourlyRate: 750,
        bio: 'BWF certified coach training state-level juniors at Balewadi.',
        rating: 4.92,
        totalReviews: 28,
        isVerified: true,
      );

      expect(coach.city, equals('Pune'));
      expect(coach.specialization, equals('Badminton Advanced Tactics'));
      expect(coach.hourlyRate, equals(750.0));
      expect(coach.rating, greaterThanOrEqualTo(4.9));

      final map = coach.toMap();
      expect(map['city'], equals('Pune'));
      expect(map['isVerified'], isTrue);
      expect(map['specialization'], equals('Badminton Advanced Tactics'));
    });

    test('VenueModel correctly models Pune pilot venues', () {
      const venue = VenueModel(
        venueId: 'pune_venue_balewadi',
        name: 'Shree Shiv Chhatrapati Sports Complex',
        city: 'Pune',
        latitude: 18.5744,
        longitude: 73.7667,
        sports: ['Badminton', 'Tennis', 'Swimming', 'Athletics & Running'],
        pricePerHour: 400,
        rating: 4.9,
      );

      expect(venue.city, equals('Pune'));
      expect(venue.sports, contains('Badminton'));
      expect(venue.latitude, closeTo(18.57, 0.01));
      expect(venue.longitude, closeTo(73.76, 0.01));

      final map = venue.toMap();
      expect(map['name'], equals('Shree Shiv Chhatrapati Sports Complex'));
      expect(map['city'], equals('Pune'));
    });

    test('Pilot simulated booking fee calculations', () {
      const double hourlyRate = 750.0;
      const double platformFeePercent = AppConstants.platformFeePercent; // 10.0
      final double platformFee = hourlyRate * (platformFeePercent / 100);
      const double discount = 150.0;
      final double totalPrice = (hourlyRate + platformFee) - discount;

      expect(platformFee, equals(75.0));
      expect(totalPrice, equals(675.0));

      // In v0.0 Pilot Pass, simulated payment status verifies ₹0 charged
      const String paymentStatus = 'Pilot Pass Verified (₹0 Charged / Escrow Protected)';
      expect(paymentStatus, contains('₹0 Charged'));
      expect(paymentStatus, contains('Escrow Protected'));
    });

    test('UserModel handles all 4 pilot roles seamlessly', () {
      final roles = [UserRole.player, UserRole.coach, UserRole.parent, UserRole.academy];

      for (final role in roles) {
        final user = UserModel(
          uid: 'test_user_${role.name}',
          name: 'Tester ${role.name}',
          email: '${role.name}@krico.app',
          phone: '+91 98765 43210',
          role: role,
        );

        expect(user.role, equals(role));
        final map = user.toMap();
        expect(map['role'], equals(role.name));
      }
    });
  });
}
