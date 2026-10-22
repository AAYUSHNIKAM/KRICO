import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gamification_model.dart';
import '../models/player_model.dart';

class PlayerService {
  PlayerService(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<PlayerModel>> getParentPlayers(String parentId) {
    return _firestore
        .collection('players')
        .where('parentId', isEqualTo: parentId)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => PlayerModel.fromDoc(doc)).toList());
  }

  Stream<PlayerModel> getPlayer(String playerId) {
    return _firestore
        .collection('players')
        .doc(playerId)
        .snapshots()
        .map((doc) => PlayerModel.fromDoc(doc));
  }

  Future<void> updatePlayer(String playerId, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('players').doc(playerId).update(data);
  }

  /// Awards XP to a player and fires an achievement notification on level-up.
  Future<void> addPoints(String playerId, int amount) async {
    if (amount <= 0) return;
    final docRef = _firestore.collection('players').doc(playerId);
    final snap = await docRef.get();
    final oldPoints = (snap.data()?['points'] as num?)?.toInt() ?? 0;
    final newPoints = oldPoints + amount;
    final oldLevel = LevelModel.getLevel(oldPoints);
    final newLevel = LevelModel.getLevel(newPoints);

    await docRef.update({
      'points': FieldValue.increment(amount),
      'level': newLevel.title,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (newLevel.level > oldLevel.level) {
      await _firestore.collection('notifications').add({
        'userId': playerId,
        'type': 'achievement',
        'title': 'Level Up! ${newLevel.icon}',
        'body':
            'You reached ${newLevel.title} (Level ${newLevel.level}) with $newPoints XP!',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> logMetric({
    required String playerId,
    required String metric,
    required double value,
    required String unit,
  }) async {
    await _firestore.collection('playerMetrics').add({
      'playerId': playerId,
      'metric': metric,
      'value': value,
      'unit': unit,
      'loggedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getPlayerMetrics(String playerId) {
    return _firestore
        .collection('playerMetrics')
        .where('playerId', isEqualTo: playerId)
        .snapshots();
  }

  Future<void> addCoachToPlayer(String playerId, String coachId) async {
    await _firestore.collection('players').doc(playerId).set({
      'coachId': coachId,
      'coachIds': FieldValue.arrayUnion([coachId]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Students linked to a coach. Merges players booked via the new
  /// `coachIds` array with legacy players that only carry a single `coachId`,
  /// plus players recovered from existing `sessions` docs so bookings made
  /// before linking existed still surface in the students list.
  Stream<List<Map<String, dynamic>>> getCoachPlayers(String coachId) {
    return Stream<List<Map<String, dynamic>>>.multi((controller) {
      final players = <String, Map<String, dynamic>>{};

      void emit() {
        final list = players.values.toList()
          ..sort((a, b) => (a['name'] as String? ?? '')
              .toLowerCase()
              .compareTo((b['name'] as String? ?? '').toLowerCase()));
        controller.add(list);
      }

      final byCoachIds = _firestore
          .collection('players')
          .where('coachIds', arrayContains: coachId)
          .snapshots()
          .listen((snap) {
        for (final doc in snap.docs) {
          players[doc.id] = {...doc.data(), 'playerId': doc.id};
        }
        emit();
      }, onError: controller.addError);

      final byLegacyCoach = _firestore
          .collection('players')
          .where('coachId', isEqualTo: coachId)
          .snapshots()
          .listen((snap) {
        for (final doc in snap.docs) {
          players[doc.id] = {...doc.data(), 'playerId': doc.id};
        }
        emit();
      }, onError: controller.addError);

      final bySessions = _firestore
          .collection('sessions')
          .where('coachId', isEqualTo: coachId)
          .snapshots()
          .listen((snap) async {
        final playerIds = <String>{};
        for (final doc in snap.docs) {
          if (doc.data()['status'] == 'cancelled') continue;
          final pid = doc.data()['playerId'] as String?;
          if (pid != null && pid.trim().isNotEmpty) playerIds.add(pid.trim());
        }
        if (playerIds.isEmpty) {
          emit();
          return;
        }
        final ids = playerIds.toList();
        for (var i = 0; i < ids.length; i += 30) {
          final end = (i + 30 < ids.length) ? i + 30 : ids.length;
          try {
            final fetched = await _firestore
                .collection('players')
                .where(FieldPath.documentId, whereIn: ids.sublist(i, end))
                .get();
            for (final doc in fetched.docs) {
              players[doc.id] = {...doc.data(), 'playerId': doc.id};
            }
          } catch (_) {
            // Ignore transient fetch failures; linked players still emit.
          }
        }
        emit();
      }, onError: controller.addError);

      controller.onCancel = () {
        byCoachIds.cancel();
        byLegacyCoach.cancel();
        bySessions.cancel();
      };
    });
  }

  Stream<List<Map<String, dynamic>>> getStudentProgress(String playerId) {
    return _firestore
        .collection('studentProgress')
        .where('playerId', isEqualTo: playerId)
        .snapshots()
        .map((snap) {
      final logs = snap.docs
          .map((doc) => {...doc.data(), 'progressId': doc.id})
          .toList();
      logs.sort((a, b) {
        final aTime = (a['loggedAt'] as Timestamp?)?.toDate() ?? DateTime(0);
        final bTime = (b['loggedAt'] as Timestamp?)?.toDate() ?? DateTime(0);
        return bTime.compareTo(aTime);
      });
      return logs;
    });
  }

  Future<void> logStudentProgress({
    required String coachId,
    required String playerId,
    required String category,
    required String title,
    required int score,
    String? notes,
  }) async {
    await _firestore.collection('studentProgress').add({
      'coachId': coachId,
      'playerId': playerId,
      'category': category,
      'title': title,
      'score': score.clamp(0, 100),
      'notes': notes ?? '',
      'loggedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteStudentProgress(String progressId) async {
    await _firestore.collection('studentProgress').doc(progressId).delete();
  }
}
