import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sports_app/features/booking/domain/booking_entry.dart';

void main() {
  final now = DateTime(2026, 9, 6, 12);
  BookingEntry entry(String status, DateTime? date) => BookingEntry(
    id: 'session',
    data: {
      'status': status,
      if (date != null) 'dateTime': Timestamp.fromDate(date),
    },
  );
  test('Pending booking is a request, not a confirmation', () {
    final booking = entry('booked', now.add(const Duration(days: 1)));
    expect(booking.label, 'Awaiting coach confirmation');
    expect(booking.matches(BookingFilter.requests, now), isTrue);
    expect(booking.matches(BookingFilter.upcoming, now), isTrue);
    expect(booking.matches(BookingFilter.history, now), isFalse);
  });
  test('Closed bookings never appear as upcoming, even with future dates', () {
    for (final status in ['cancelled', 'rejected', 'completed']) {
      final booking = entry(status, now.add(const Duration(days: 1)));
      expect(booking.matches(BookingFilter.upcoming, now), isFalse);
      expect(booking.matches(BookingFilter.requests, now), isFalse);
      expect(booking.matches(BookingFilter.history, now), isTrue);
    }
  });
  test(
    'Past sessions are in history; missing dates stay accessible in All',
    () {
      expect(
        entry(
          'confirmed',
          now.subtract(const Duration(days: 1)),
        ).matches(BookingFilter.history, now),
        isTrue,
      );
      final missing = entry('confirmed', null);
      expect(missing.matches(BookingFilter.upcoming, now), isFalse);
      expect(missing.matches(BookingFilter.all, now), isTrue);
    },
  );
  test('Legacy ISO date and unknown status are handled without a crash', () {
    final booking = BookingEntry(
      id: 'legacy',
      data: {'dateTime': now.toIso8601String(), 'status': 'legacy'},
    );
    expect(booking.date, now);
    expect(booking.label, 'Status unavailable');
  });
}
