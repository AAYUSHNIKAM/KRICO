import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/utils/date_parser.dart';

class CoachMilestoneModel {
  final String id;
  final String coachId;
  final String title;
  final String description;
  final int targetValue;
  final int currentValue;
  final String unit;
  final bool isCompleted;
  final DateTime? achievedAt;

  const CoachMilestoneModel({
    required this.id,
    required this.coachId,
    required this.title,
    required this.description,
    required this.targetValue,
    required this.currentValue,
    required this.unit,
    this.isCompleted = false,
    this.achievedAt,
  });

  factory CoachMilestoneModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return CoachMilestoneModel(
      id: doc.id,
      coachId: data['coachId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      targetValue: (data['targetValue'] as num?)?.toInt() ?? 100,
      currentValue: (data['currentValue'] as num?)?.toInt() ?? 0,
      unit: data['unit'] as String? ?? 'pts',
      isCompleted: data['isCompleted'] as bool? ?? false,
      achievedAt: parseTimestamp(data['achievedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'coachId': coachId,
    'title': title,
    'description': description,
    'targetValue': targetValue,
    'currentValue': currentValue,
    'unit': unit,
    'isCompleted': isCompleted,
    'achievedAt': achievedAt != null ? Timestamp.fromDate(achievedAt!) : null,
  };
}
