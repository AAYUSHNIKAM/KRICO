import '../../../core/utils/date_parser.dart';

enum BookingFilter { upcoming, requests, history, all }

class BookingEntry {
  const BookingEntry({required this.id, required this.data});
  final String id;
  final Map<String, dynamic> data;

  DateTime? get date => parseTimestamp(data['dateTime']);
  String get status => data['status'] as String? ?? 'booked';
  String get label => switch (status) {
    'booked' || 'pending' => 'Awaiting coach confirmation',
    'confirmed' => 'Confirmed',
    'scheduled' => 'Scheduled',
    'checked_in' => 'In progress',
    'completed' => 'Completed',
    'cancelled' => 'Cancelled',
    'rejected' => 'Declined',
    _ => 'Status unavailable',
  };
  bool get isClosed => const ['completed', 'cancelled', 'rejected'].contains(status);
  bool matches(BookingFilter filter, DateTime now) => switch (filter) {
    BookingFilter.all => true,
    BookingFilter.requests => !isClosed && const ['booked', 'pending'].contains(status),
    BookingFilter.upcoming => !isClosed && date != null && !date!.isBefore(now),
    BookingFilter.history => isClosed || (date != null && date!.isBefore(now)),
  };
}