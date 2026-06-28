import 'package:cloud_firestore/cloud_firestore.dart';

DateTime? _parseTimestamp(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.tryParse(value);
  return null;
}

class SquadGoal {
  final String goalId;
  final String title;
  final String description;
  final String sport;
  final int targetValue;
  final int currentValue;
  final String metric;
  final String metricUnit;
  final List<String> memberIds;
  final Map<String, int> memberContributions;
  final String creatorId;
  final String reward;
  final String status;
  final DateTime deadline;
  final DateTime createdAt;

  const SquadGoal({
    required this.goalId,
    required this.title,
    required this.description,
    required this.sport,
    required this.targetValue,
    required this.currentValue,
    required this.metric,
    required this.metricUnit,
    required this.memberIds,
    required this.memberContributions,
    required this.creatorId,
    required this.reward,
    required this.status,
    required this.deadline,
    required this.createdAt,
  });

  double get progress => targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;
  bool get isCompleted => currentValue >= targetValue;

  factory SquadGoal.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return SquadGoal(
      goalId: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      sport: data['sport'] as String? ?? '',
      targetValue: (data['targetValue'] as num?)?.toInt() ?? 0,
      currentValue: (data['currentValue'] as num?)?.toInt() ?? 0,
      metric: data['metric'] as String? ?? '',
      metricUnit: data['metricUnit'] as String? ?? '',
      memberIds: (data['memberIds'] as List<dynamic>?)?.cast<String>() ?? [],
      memberContributions: (data['memberContributions'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toInt())) ??
          {},
      creatorId: data['creatorId'] as String? ?? '',
      reward: data['reward'] as String? ?? '',
      status: data['status'] as String? ?? 'active',
      deadline: _parseTimestamp(data['deadline']) ?? DateTime.now(),
      createdAt: _parseTimestamp(data['createdAt']) ?? DateTime.now(),
    );
  }
}

class SquadGoalsService {
  SquadGoalsService(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<SquadGoal>> getActiveGoalsBySport(String sport) {
    return _firestore
        .collection('squadGoals')
        .where('sport', isEqualTo: sport)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snap) {
          final goals = snap.docs.map((doc) => SquadGoal.fromDoc(doc)).toList();
          goals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return goals;
        });
  }

  Stream<List<SquadGoal>> getPlayerGoals(String playerId) {
    return _firestore
        .collection('squadGoals')
        .where('memberIds', arrayContains: playerId)
        .snapshots()
        .map((snap) {
          final goals = snap.docs.map((doc) => SquadGoal.fromDoc(doc)).toList();
          goals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return goals;
        });
  }

  Future<void> createGoal({
    required String title,
    required String description,
    required String sport,
    required int targetValue,
    required String metric,
    required String metricUnit,
    required String creatorId,
    required String reward,
    required List<String> memberIds,
    required DateTime deadline,
  }) async {
    final goalId = _firestore.collection('squadGoals').doc().id;
    await _firestore.collection('squadGoals').doc(goalId).set({
      'goalId': goalId,
      'title': title,
      'description': description,
      'sport': sport,
      'targetValue': targetValue,
      'currentValue': 0,
      'metric': metric,
      'metricUnit': metricUnit,
      'memberIds': [creatorId, ...memberIds],
      'memberContributions': {for (final id in [creatorId, ...memberIds]) id: 0},
      'creatorId': creatorId,
      'reward': reward,
      'status': 'active',
      'deadline': Timestamp.fromDate(deadline),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> contribute(String goalId, String playerId, int amount) async {
    await _firestore.runTransaction((transaction) async {
      final ref = _firestore.collection('squadGoals').doc(goalId);
      final snap = await transaction.get(ref);
      if (!snap.exists) return;
      final currentContributions = Map<String, dynamic>.from(
          (snap.data()?['memberContributions'] as Map<String, dynamic>?) ?? {});
      final current = (currentContributions[playerId] as num?)?.toInt() ?? 0;
      currentContributions[playerId] = current + amount;
      transaction.update(ref, {
        'currentValue': FieldValue.increment(amount),
        'memberContributions': currentContributions,
      });
    });
  }

  Future<void> completeGoal(String goalId) async {
    await _firestore.collection('squadGoals').doc(goalId).update({
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
    });
  }
}
