import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/utils/date_parser.dart';

class SessionModel {
  final String id;
  final String? title;
  final String coachId;
  final String playerId;
  final String? bookedBy;
  final String sport;
  final DateTime dateTime;
  final int durationMinutes;
  final double amount;
  final String status; // 'requested', 'confirmed', 'completed', 'cancelled'
  final String? notes;
  final bool isOnline;
  final String? venueId;
  final String? venueName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SessionModel({
    required this.id,
    this.title,
    required this.coachId,
    required this.playerId,
    this.bookedBy,
    required this.sport,
    required this.dateTime,
    this.durationMinutes = 60,
    required this.amount,
    this.status = 'requested',
    this.notes,
    this.isOnline = false,
    this.venueId,
    this.venueName,
    this.createdAt,
    this.updatedAt,
  });

  factory SessionModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return SessionModel(
      id: doc.id,
      title: data['title'] as String?,
      coachId: data['coachId'] as String? ?? '',
      playerId: data['playerId'] as String? ?? '',
      bookedBy: data['bookedBy'] as String?,
      sport: data['sport'] as String? ?? 'General',
      dateTime: parseTimestamp(data['dateTime']) ?? DateTime.now(),
      durationMinutes: (data['durationMinutes'] as num?)?.toInt() ?? 60,
      amount: (data['amount'] as num?)?.toDouble() ?? ((data['price'] as num?)?.toDouble() ?? 0.0),
      status: data['status'] as String? ?? 'requested',
      notes: data['notes'] as String?,
      isOnline: data['isOnline'] as bool? ?? false,
      venueId: data['venueId'] as String?,
      venueName: data['venue'] as String? ?? data['venueName'] as String?,
      createdAt: parseTimestamp(data['createdAt']),
      updatedAt: parseTimestamp(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'coachId': coachId,
    'playerId': playerId,
    'bookedBy': bookedBy,
    'sport': sport,
    'dateTime': Timestamp.fromDate(dateTime),
    'durationMinutes': durationMinutes,
    'amount': amount,
    'status': status,
    'notes': notes,
    'isOnline': isOnline,
    'venueId': venueId,
    'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  SessionModel copyWith({
    String? id,
    String? coachId,
    String? playerId,
    String? bookedBy,
    String? sport,
    DateTime? dateTime,
    int? durationMinutes,
    double? amount,
    String? status,
    String? notes,
    bool? isOnline,
    String? venueId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SessionModel(
      id: id ?? this.id,
      coachId: coachId ?? this.coachId,
      playerId: playerId ?? this.playerId,
      bookedBy: bookedBy ?? this.bookedBy,
      sport: sport ?? this.sport,
      dateTime: dateTime ?? this.dateTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      isOnline: isOnline ?? this.isOnline,
      venueId: venueId ?? this.venueId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
