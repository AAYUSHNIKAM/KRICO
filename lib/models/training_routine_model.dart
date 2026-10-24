import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/utils/date_parser.dart';
import '../core/gamification/krico_xp_system.dart';

class TrainingSubRoutineModel {
  const TrainingSubRoutineModel({
    required this.id,
    required this.name,
    required this.description,
    required this.completionCriteria,
    required this.progressTrackingField,
    required this.percentageAllocation,
  });

  final String id;
  final String name;
  final String description;
  final String completionCriteria;
  final String progressTrackingField;
  final double percentageAllocation;

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'completionCriteria': completionCriteria,
    'progressTrackingField': progressTrackingField,
    'percentageAllocation': percentageAllocation,
  };

  factory TrainingSubRoutineModel.fromMap(Map<String, dynamic> map) {
    return TrainingSubRoutineModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      completionCriteria: map['completionCriteria'] as String? ?? '',
      progressTrackingField: map['progressTrackingField'] as String? ?? 'Completion Status',
      percentageAllocation: (map['percentageAllocation'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class TrainingRoutineModel {
  const TrainingRoutineModel({
    required this.id,
    required this.coachId,
    required this.sport,
    required this.title,
    required this.description,
    required this.subRoutines,
    this.isStandard = true,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String coachId;
  final String sport;
  final String title;
  final String description;
  final List<TrainingSubRoutineModel> subRoutines;
  final bool isStandard;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  double get totalPercentage => subRoutines.fold<double>(
        0.0,
        (sum, item) => sum + item.percentageAllocation,
      );

  bool get isValidPercentage => (totalPercentage - 100.0).abs() <= 0.01;

  String? get validationError => KricoXpSystem.validateRoutinePercentages(
        subRoutines.map((s) => s.percentageAllocation).toList(),
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'coachId': coachId,
    'sport': sport,
    'title': title,
    'description': description,
    'subRoutines': subRoutines.map((s) => s.toMap()).toList(),
    'isStandard': isStandard,
    'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  factory TrainingRoutineModel.fromMap(Map<String, dynamic> map) {
    return TrainingRoutineModel(
      id: map['id'] as String? ?? '',
      coachId: map['coachId'] as String? ?? '',
      sport: map['sport'] as String? ?? 'Athletics',
      title: map['title'] as String? ?? 'Standard Session Curriculum',
      description: map['description'] as String? ?? '',
      subRoutines: (map['subRoutines'] as List<dynamic>?)
              ?.map((e) => TrainingSubRoutineModel.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      isStandard: map['isStandard'] as bool? ?? true,
      createdAt: parseTimestamp(map['createdAt']),
      updatedAt: parseTimestamp(map['updatedAt']),
    );
  }

  factory TrainingRoutineModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return TrainingRoutineModel.fromMap({...data, 'id': doc.id});
  }
}
