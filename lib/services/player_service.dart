import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> addPlayer(PlayerModel player) async {
    await _firestore.collection('players').doc(player.playerId).set(player.toMap());
  }

  Future<void> updatePlayer(String playerId, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('players').doc(playerId).update(data);
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

  Future<void> addPoints(String playerId, int points) async {
    await _firestore.collection('players').doc(playerId).update({
      'points': FieldValue.increment(points),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getPlayerMetrics(String playerId) {
    return _firestore
        .collection('playerMetrics')
        .where('playerId', isEqualTo: playerId)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getCoachPlayers(String coachId) {
    return _firestore
        .collection('players')
        .where('coachId', isEqualTo: coachId)
        .snapshots();
  }
}
