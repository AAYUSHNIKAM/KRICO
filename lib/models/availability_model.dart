import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/utils/date_parser.dart';

class AvailabilityModel {
  const AvailabilityModel({
    required this.availabilityId,
    required this.coachId,
    required this.date,
    required this.timeSlots,
    this.isRecurring = false,
    this.recurringDays,
    this.createdAt,
  });

  final String availabilityId;
  final String coachId;
  final DateTime date;
  final List<String> timeSlots;
  final bool isRecurring;
  final List<int>? recurringDays;
  final DateTime? createdAt;

  factory AvailabilityModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AvailabilityModel(
      availabilityId: doc.id,
      coachId: data['coachId'] as String? ?? '',
      date: (data['date'] as Timestamp).toDate(),
      timeSlots: (data['timeSlots'] as List<dynamic>?)?.cast<String>() ?? [],
      isRecurring: data['isRecurring'] as bool? ?? false,
      recurringDays: (data['recurringDays'] as List<dynamic>?)?.cast<int>(),
      createdAt: parseTimestamp(data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'coachId': coachId,
    'date': Timestamp.fromDate(date),
    'timeSlots': timeSlots,
    'isRecurring': isRecurring,
    'recurringDays': recurringDays,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
