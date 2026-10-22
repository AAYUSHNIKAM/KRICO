import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/utils/date_parser.dart';

/// A challenge between players (type: 'player') or a squad/team (type: 'squad').
///
/// Status flow:
///  - player challenges are created as 'pending' until the opponent accepts
///    ('active') or declines ('declined')
///  - squad challenges start as 'active' immediately
///  - reaching the target (1v1: any player reaches it; squad: collective sum
///    reaches it) auto-completes the challenge; it can also be completed
///    manually via [ChallengesService.completeChallenge]
class Challenge {
  final String challengeId;
  final String type;
  final String title;
  final String description;
  final String sport;
  final String metric;
  final String metricUnit;
  final int targetValue;
  final Map<String, int> participants;
  final Map<String, String> participantNames;
  final String creatorId;
  final String reward;
  final String status;
  final String? winnerId;
  final DateTime deadline;
  final DateTime createdAt;
  final DateTime? completedAt;

  const Challenge({
    required this.challengeId,
    required this.type,
    required this.title,
    required this.description,
    required this.sport,
    required this.metric,
    required this.metricUnit,
    required this.targetValue,
    required this.participants,
    required this.participantNames,
    required this.creatorId,
    required this.reward,
    required this.status,
    required this.winnerId,
    required this.deadline,
    required this.createdAt,
    required this.completedAt,
  });

  bool get isPlayerChallenge => type == 'player';
  bool get isSquadChallenge => type == 'squad';
  bool get isPending => status == 'pending';
  bool get isActive => status == 'active';
  bool get isDeclined => status == 'declined';
  bool get isCompleted => status == 'completed';

  int get totalProgress =>
      participants.values.fold<int>(0, (total, value) => total + value);

  int get bestPlayerProgress {
    var best = 0;
    for (final value in participants.values) {
      if (value > best) best = value;
    }
    return best;
  }

  double get progress {
    if (targetValue <= 0) return 0.0;
    final current = isPlayerChallenge ? bestPlayerProgress : totalProgress;
    return (current / targetValue).clamp(0.0, 1.0);
  }

  int get progressPercent => (progress * 100).toInt();

  String creatorName(String fallback) =>
      participantNames[creatorId] ?? fallback;

  factory Challenge.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Challenge(
      challengeId: doc.id,
      type: data['type'] as String? ?? 'player',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      sport: data['sport'] as String? ?? '',
      metric: data['metric'] as String? ?? '',
      metricUnit: data['metricUnit'] as String? ?? '',
      targetValue: (data['targetValue'] as num?)?.toInt() ?? 0,
      participants: (data['participants'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toInt())) ??
          {},
      participantNames: (data['participantNames'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as String)) ??
          {},
      creatorId: data['creatorId'] as String? ?? '',
      reward: data['reward'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      winnerId: data['winnerId'] as String?,
      deadline: parseTimestamp(data['deadline']) ?? DateTime.now(),
      createdAt: parseTimestamp(data['createdAt']) ?? DateTime.now(),
      completedAt: parseTimestamp(data['completedAt']),
    );
  }
}

class ChallengesService {
  ChallengesService(this._firestore);

  final FirebaseFirestore _firestore;

  /// All challenges the given user is part of (creator or participant).
  Stream<List<Challenge>> getUserChallenges(String userId) {
    return _firestore
        .collection('challenges')
        .where('participantIds', arrayContains: userId)
        .snapshots()
        .map((snap) {
          final challenges =
              snap.docs.map((doc) => Challenge.fromDoc(doc)).toList();
          challenges.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return challenges;
        });
  }

  Future<void> createChallenge({
    required String type,
    required String title,
    required String description,
    required String sport,
    required String metric,
    required String metricUnit,
    required int targetValue,
    required String creatorId,
    required String reward,
    required Map<String, String> participants,
    required DateTime deadline,
  }) async {
    final challengeId = _firestore.collection('challenges').doc().id;
    final participantIds = participants.keys.toList();
    await _firestore.collection('challenges').doc(challengeId).set({
      'challengeId': challengeId,
      'type': type,
      'title': title,
      'description': description,
      'sport': sport,
      'metric': metric,
      'metricUnit': metricUnit,
      'targetValue': targetValue,
      'participants': {for (final id in participantIds) id: 0},
      'participantNames': participants,
      'participantIds': participantIds,
      'creatorId': creatorId,
      'reward': reward,
      'status': type == 'player' ? 'pending' : 'active',
      'winnerId': null,
      'deadline': Timestamp.fromDate(deadline),
      'createdAt': FieldValue.serverTimestamp(),
      'completedAt': null,
    });
  }

  Future<void> acceptChallenge(String challengeId) async {
    await _firestore
        .collection('challenges')
        .doc(challengeId)
        .update({'status': 'active'});
  }

  Future<void> declineChallenge(String challengeId) async {
    await _firestore.collection('challenges').doc(challengeId).update({
      'status': 'declined',
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Increments a participant's value. Auto-completes the challenge when the
  /// target is reached (1v1: by that player; squad: by the collective sum).
  Future<void> logProgress(String challengeId, String userId, int amount) async {
    await _firestore.runTransaction((transaction) async {
      final ref = _firestore.collection('challenges').doc(challengeId);
      final snap = await transaction.get(ref);
      if (!snap.exists) return;
      final data = snap.data()!;
      final participants =
          Map<String, dynamic>.from((data['participants'] as Map<String, dynamic>?) ?? {});
      final current = (participants[userId] as num?)?.toInt() ?? 0;
      final updated = current + amount;
      participants[userId] = updated;
      final type = data['type'] as String? ?? 'player';
      final target = (data['targetValue'] as num?)?.toInt() ?? 0;

      if (type == 'player') {
        if (updated >= target) {
          transaction.update(ref, {
            'participants': participants,
            'status': 'completed',
            'winnerId': userId,
            'completedAt': FieldValue.serverTimestamp(),
          });
          return;
        }
      } else {
        final total =
            participants.values.fold<int>(0, (acc, value) => acc + (value as num).toInt());
        if (total >= target) {
          transaction.update(ref, {
            'participants': participants,
            'status': 'completed',
            'completedAt': FieldValue.serverTimestamp(),
          });
          return;
        }
      }
      transaction.update(ref, {'participants': participants});
    });
  }

  Future<void> completeChallenge(String challengeId, {String? winnerId}) async {
    await _firestore.collection('challenges').doc(challengeId).update({
      'status': 'completed',
      'winnerId': ?winnerId,
      'completedAt': FieldValue.serverTimestamp(),
    });
  }
}
