import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/utils/date_parser.dart';

class BatchModel {
  final String id;
  final String academyId;
  final String name;
  final String sport;
  final String ageGroup;
  final int maxStudents;
  final int currentStudents;
  final String? coachId;
  final String? coachName;
  final List<String> playerIds;
  final String schedule;
  final List<String> days;
  final String? startTime;
  final String? endTime;
  final double feeMonthly;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BatchModel({
    required this.id,
    required this.academyId,
    required this.name,
    required this.sport,
    required this.ageGroup,
    this.maxStudents = 20,
    this.currentStudents = 0,
    this.coachId,
    this.coachName,
    this.playerIds = const [],
    required this.schedule,
    this.days = const [],
    this.startTime,
    this.endTime,
    required this.feeMonthly,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory BatchModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final pIds = (data['playerIds'] as List<dynamic>?)?.cast<String>() ?? <String>[];
    return BatchModel(
      id: doc.id,
      academyId: data['academyId'] as String? ?? '',
      name: data['name'] as String? ?? 'Training Batch',
      sport: data['sport'] as String? ?? 'General',
      ageGroup: data['ageGroup'] as String? ?? 'Open',
      maxStudents: (data['maxStudents'] as num?)?.toInt() ?? 20,
      currentStudents: pIds.isNotEmpty ? pIds.length : ((data['currentStudents'] as num?)?.toInt() ?? 0),
      coachId: data['coachId'] as String?,
      coachName: data['coachName'] as String?,
      playerIds: pIds,
      schedule: data['schedule'] as String? ?? 'Mon/Wed/Fri',
      days: (data['days'] as List<dynamic>?)?.cast<String>() ?? <String>[],
      startTime: data['startTime'] as String?,
      endTime: data['endTime'] as String?,
      feeMonthly: (data['feeMonthly'] as num?)?.toDouble() ?? 0.0,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: parseTimestamp(data['createdAt']),
      updatedAt: parseTimestamp(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'academyId': academyId,
    'name': name,
    'sport': sport,
    'ageGroup': ageGroup,
    'maxStudents': maxStudents,
    'currentStudents': playerIds.isNotEmpty ? playerIds.length : currentStudents,
    'coachId': coachId,
    'coachName': coachName,
    'playerIds': playerIds,
    'schedule': schedule,
    'days': days,
    'startTime': startTime,
    'endTime': endTime,
    'feeMonthly': feeMonthly,
    'isActive': isActive,
    'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
