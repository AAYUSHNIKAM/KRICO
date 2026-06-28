import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/coach_model.dart';

class CoachService {
  CoachService(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<CoachModel>> getCoaches() {
    return _firestore
        .collection('coaches')
        .snapshots()
        .map((snap) => snap.docs.map((doc) => CoachModel.fromDoc(doc)).toList());
  }

  Stream<CoachModel> getCoach(String coachId) {
    return _firestore
        .collection('coaches')
        .doc(coachId)
        .snapshots()
        .map((doc) => CoachModel.fromDoc(doc));
  }

  Future<void> updateCoach(String coachId, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('coaches').doc(coachId).update(data);
  }

  Future<List<CoachModel>> searchCoaches(String query) async {
    final snap = await _firestore.collection('coaches').get();
    final coaches = snap.docs.map((doc) => CoachModel.fromDoc(doc)).toList();
    if (query.isEmpty) return coaches;
    final lower = query.toLowerCase();
    return coaches.where((c) =>
      c.name.toLowerCase().contains(lower) ||
      (c.specialization?.toLowerCase().contains(lower) ?? false) ||
      (c.city?.toLowerCase().contains(lower) ?? false)
    ).toList();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAcademyCoaches(String academyId) {
    return _firestore
        .collection('coaches')
        .where('academyId', isEqualTo: academyId)
        .snapshots();
  }

  Future<void> bookSession(String coachId, String playerId, DateTime dateTime, String sport) async {
    final sessionId = _firestore.collection('sessions').doc().id;
    await _firestore.collection('sessions').doc(sessionId).set({
      'sessionId': sessionId,
      'coachId': coachId,
      'playerId': playerId,
      'sport': sport,
      'dateTime': Timestamp.fromDate(dateTime),
      'status': 'booked',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> createSession({
    required String coachId,
    required String title,
    required String sport,
    String? description,
    required DateTime dateTime,
    required int capacity,
    required String venue,
    required double price,
    required bool isOnline,
    String? playerId,
  }) async {
    final sessionId = _firestore.collection('sessions').doc().id;
    await _firestore.collection('sessions').doc(sessionId).set({
      'sessionId': sessionId,
      'coachId': coachId,
      'playerId': playerId ?? coachId,
      'title': title,
      'sport': sport,
      'description': description ?? '',
      'dateTime': Timestamp.fromDate(dateTime),
      'capacity': capacity,
      'venue': venue,
      'price': price,
      'isOnline': isOnline,
      'status': 'scheduled',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getCoachSessions(String coachId) {
    return _firestore
        .collection('sessions')
        .where('coachId', isEqualTo: coachId)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getPlayerSessions(String playerId) {
    return _firestore
        .collection('sessions')
        .where('playerId', isEqualTo: playerId)
        .snapshots();
  }

  Future<Map<String, dynamic>> getCoachStats(String coachId) async {
    final sessionsSnap = await _firestore
        .collection('sessions')
        .where('coachId', isEqualTo: coachId)
        .get();
    final totalSessions = sessionsSnap.docs.length;

    final completedSessions = sessionsSnap.docs
        .where((d) => (d.data()['status'] as String?) == 'completed')
        .length;

    final uniqueStudents = sessionsSnap.docs
        .map((d) => d.data()['playerId'] as String?)
        .where((id) => id != null)
        .toSet()
        .length;

    double totalEarnings = 0;
    for (final doc in sessionsSnap.docs) {
      final d = doc.data();
      totalEarnings += (d['price'] as num?)?.toDouble() ?? 0;
    }

    return {
      'totalSessions': totalSessions,
      'completedSessions': completedSessions,
      'totalStudents': uniqueStudents,
      'totalEarnings': totalEarnings,
    };
  }

  Future<List<Map<String, dynamic>>> getCoachMilestones(String coachId) async {
    final snap = await _firestore
        .collection('coachMilestones')
        .where('coachId', isEqualTo: coachId)
        .get();
    final milestones = snap.docs.map((doc) {
      final d = doc.data();
      return {
        'id': doc.id,
        'label': d['label'] as String? ?? '',
        'done': d['done'] as bool? ?? false,
        'createdAt': (d['createdAt'] as Timestamp?)?.toDate(),
      };
    }).toList();
    milestones.sort((a, b) {
      final aTime = a['createdAt'] as DateTime? ?? DateTime(0);
      final bTime = b['createdAt'] as DateTime? ?? DateTime(0);
      return aTime.compareTo(bTime);
    });
    return milestones;
  }

  Future<void> addMilestone(String coachId, String label) async {
    await _firestore.collection('coachMilestones').add({
      'coachId': coachId,
      'label': label,
      'done': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> completeMilestone(String milestoneId) async {
    await _firestore.collection('coachMilestones').doc(milestoneId).update({
      'done': true,
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteMilestone(String milestoneId) async {
    await _firestore.collection('coachMilestones').doc(milestoneId).delete();
  }

  Future<Map<String, int>> getCoachMonthlyEarnings(String coachId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final snap = await _firestore
        .collection('sessions')
        .where('coachId', isEqualTo: coachId)
        .get();

    double monthlyEarnings = 0;
    int monthlySessions = 0;
    for (final doc in snap.docs) {
      final d = doc.data();
      final dateTime = (d['dateTime'] as Timestamp?)?.toDate();
      if (dateTime != null && dateTime.isAfter(startOfMonth) || 
          (dateTime != null && dateTime.isAtSameMomentAs(startOfMonth))) {
        monthlyEarnings += (d['price'] as num?)?.toDouble() ?? 0;
        monthlySessions++;
      }
    }

    return {
      'monthlyEarnings': monthlyEarnings.toInt(),
      'monthlySessions': monthlySessions,
    };
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getCoachMilestonesStream(String coachId) {
    return _firestore
        .collection('coachMilestones')
        .where('coachId', isEqualTo: coachId)
        .snapshots();
  }
}
