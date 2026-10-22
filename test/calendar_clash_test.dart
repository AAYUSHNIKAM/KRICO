import 'package:flutter_test/flutter_test.dart';

class SessionInterval {
  final DateTime start;
  final DateTime end;

  SessionInterval({required this.start, required this.end});

  bool overlapsWith(SessionInterval other) {
    return start.isBefore(other.end) && end.isAfter(other.start);
  }
}

void main() {
  group('Booking Calendar Clash & Overlap Detection', () {
    final baseDate = DateTime(2026, 10, 15, 10, 0); // 10:00 AM

    test('Exact same time interval is flagged as an active collision', () {
      final slot1 = SessionInterval(
        start: baseDate,
        end: baseDate.add(const Duration(hours: 1)),
      );
      final slot2 = SessionInterval(
        start: baseDate,
        end: baseDate.add(const Duration(hours: 1)),
      );

      expect(slot1.overlapsWith(slot2), isTrue);
    });

    test('Partially overlapping interval is flagged as a collision', () {
      final slot1 = SessionInterval(
        start: baseDate,
        end: baseDate.add(const Duration(hours: 1)), // 10:00 - 11:00
      );
      final slot2 = SessionInterval(
        start: baseDate.add(const Duration(minutes: 30)), // 10:30 - 11:30
        end: baseDate.add(const Duration(minutes: 90)),
      );

      expect(slot1.overlapsWith(slot2), isTrue);
    });

    test('Back-to-back adjacent sessions do not clash', () {
      final morningSlot = SessionInterval(
        start: baseDate,
        end: baseDate.add(const Duration(hours: 1)), // 10:00 - 11:00
      );
      final nextSlot = SessionInterval(
        start: baseDate.add(const Duration(hours: 1)), // 11:00 - 12:00
        end: baseDate.add(const Duration(hours: 2)),
      );

      expect(morningSlot.overlapsWith(nextSlot), isFalse);
    });

    test('Completely distinct time periods do not clash', () {
      final morningSlot = SessionInterval(
        start: baseDate,
        end: baseDate.add(const Duration(hours: 1)), // 10:00 - 11:00
      );
      final eveningSlot = SessionInterval(
        start: baseDate.add(const Duration(hours: 6)), // 16:00 - 17:00
        end: baseDate.add(const Duration(hours: 7)),
      );

      expect(morningSlot.overlapsWith(eveningSlot), isFalse);
    });
  });
}
