import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/availability_model.dart';
import '../services/availability_service.dart';
import '../services/booking_service.dart';
import '../services/firebase_service.dart';

final bookingServiceProvider = Provider<BookingService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return BookingService(firestore);
});

final availabilityServiceProvider = Provider<AvailabilityService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return AvailabilityService(firestore);
});

final coachAvailabilityProvider = StreamProvider.family.autoDispose<List<AvailabilityModel>, String>(
  (ref, coachId) {
    final service = ref.watch(availabilityServiceProvider);
    return service.getCoachAvailability(coachId);
  },
);

final availableTimeSlotsProvider = FutureProvider.family.autoDispose<List<String>, ({String coachId, DateTime date})>(
  (ref, params) {
    final service = ref.watch(availabilityServiceProvider);
    final normalizedDate = DateTime(params.date.year, params.date.month, params.date.day);
    return service.getAvailableTimeSlots(params.coachId, normalizedDate);
  },
);

final availableDatesProvider = FutureProvider.family.autoDispose<Set<DateTime>, ({String coachId, int monthsAhead})>(
  (ref, params) {
    final service = ref.watch(availabilityServiceProvider);
    return service.getAvailableDates(params.coachId, params.monthsAhead);
  },
);

final bookingSummaryProvider = FutureProvider.family.autoDispose<Map<String, dynamic>, ({
  String coachId,
  String playerId,
  DateTime dateTime,
  String sport,
  double amount,
})>(
  (ref, params) {
    final service = ref.watch(bookingServiceProvider);
    return service.getBookingSummary(
      coachId: params.coachId,
      playerId: params.playerId,
      dateTime: params.dateTime,
      sport: params.sport,
      amount: params.amount,
    );
  },
);
