import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/utils/date_parser.dart';

class PlayerMetricModel {
  final String id;
  final String playerId;
  final String metricName;
  final double value;
  final String unit;
  final String sport;
  final double? percentile;
  final DateTime recordedAt;
  final String? coachId;
  final String? notes;

  const PlayerMetricModel({
    required this.id,
    required this.playerId,
    required this.metricName,
    required this.value,
    required this.unit,
    required this.sport,
    this.percentile,
    required this.recordedAt,
    this.coachId,
    this.notes,
  });

  factory PlayerMetricModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return PlayerMetricModel(
      id: doc.id,
      playerId: data['playerId'] as String? ?? '',
      metricName: data['metricName'] as String? ?? '',
      value: (data['value'] as num?)?.toDouble() ?? 0.0,
      unit: data['unit'] as String? ?? '',
      sport: data['sport'] as String? ?? 'General',
      percentile: (data['percentile'] as num?)?.toDouble(),
      recordedAt: parseTimestamp(data['recordedAt']) ?? DateTime.now(),
      coachId: data['coachId'] as String?,
      notes: data['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'playerId': playerId,
    'metricName': metricName,
    'value': value,
    'unit': unit,
    'sport': sport,
    'percentile': percentile,
    'recordedAt': Timestamp.fromDate(recordedAt),
    'coachId': coachId,
    'notes': notes,
  };
}
