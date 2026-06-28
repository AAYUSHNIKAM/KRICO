import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/academy_model.dart';

class AcademyService {
  AcademyService(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<AcademyModel> getAcademy(String academyId) {
    return _firestore
        .collection('academies')
        .doc(academyId)
        .snapshots()
        .map((doc) => AcademyModel.fromDoc(doc));
  }

  Future<void> updateAcademy(String academyId, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('academies').doc(academyId).update(data);
  }

  Future<void> createBatch({
    required String academyId,
    required String name,
    required String sport,
    required int capacity,
    required String schedule,
  }) async {
    final batchId = _firestore.collection('batches').doc().id;
    await _firestore.collection('batches').doc(batchId).set({
      'batchId': batchId,
      'academyId': academyId,
      'name': name,
      'sport': sport,
      'capacity': capacity,
      'enrolled': 0,
      'schedule': schedule,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateBatch(String batchId, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('batches').doc(batchId).update(data);
  }

  Future<void> deleteBatch(String batchId) async {
    await _firestore.collection('batches').doc(batchId).update({
      'isActive': false,
      'deletedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getBatches(String academyId) {
    return _firestore
        .collection('batches')
        .where('academyId', isEqualTo: academyId)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getPlacements(String academyId) {
    return _firestore
        .collection('academyPlacements')
        .where('academyId', isEqualTo: academyId)
        .snapshots();
  }

  Future<void> placeCoach(String academyId, String coachId, String batchId) async {
    await _firestore.collection('academyPlacements').add({
      'academyId': academyId,
      'coachId': coachId,
      'batchId': batchId,
      'placedAt': FieldValue.serverTimestamp(),
    });
    await _firestore.collection('academies').doc(academyId).update({
      'coachPlacements': FieldValue.increment(1),
      'reputationPoints': FieldValue.increment(10),
    });
  }

  Future<int> getActiveCoachesCount(String academyId) async {
    final snap = await _firestore
        .collection('coaches')
        .where('academyId', isEqualTo: academyId)
        .get();
    return snap.docs.length;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getCampaigns(String academyId) {
    return _firestore
        .collection('campaigns')
        .where('academyId', isEqualTo: academyId)
        .snapshots();
  }

  Future<void> createCampaign({
    required String academyId,
    required String name,
    required double budget,
    required String type,
  }) async {
    await _firestore.collection('campaigns').add({
      'academyId': academyId,
      'name': name,
      'budget': budget,
      'type': type,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> inviteCoach(String academyId, String coachEmail) async {
    await _firestore.collection('coachInvitations').add({
      'academyId': academyId,
      'coachEmail': coachEmail,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendCoachInvitation({
    required String academyId,
    required String academyName,
    required String coachId,
    required String coachEmail,
    required String coachName,
  }) async {
    await _firestore.collection('coachInvitations').add({
      'academyId': academyId,
      'academyName': academyName,
      'coachId': coachId,
      'coachEmail': coachEmail,
      'coachName': coachName,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateInvitationStatus(String invitationId, String status) async {
    await _firestore.collection('coachInvitations').doc(invitationId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAcademyInvitations(String academyId) {
    return _firestore
        .collection('coachInvitations')
        .where('academyId', isEqualTo: academyId)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getCoachInvitations(String coachId) {
    return _firestore
        .collection('coachInvitations')
        .where('coachId', isEqualTo: coachId)
        .snapshots();
  }

  Future<void> assignCoachToBatch(String batchId, String coachId) async {
    await _firestore.collection('batches').doc(batchId).update({
      'coachId': coachId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> assignStudentToBatch(String batchId, String studentId) async {
    await _firestore.collection('batches').doc(batchId).update({
      'enrolled': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> postJob({
    required String academyId,
    required String title,
    required String sport,
    required String location,
    required String salary,
    required String experience,
    required String description,
    required String perks,
  }) async {
    await _firestore.collection('coachJobs').add({
      'academyId': academyId,
      'title': title,
      'sport': sport,
      'location': location,
      'salary': salary,
      'experience': experience,
      'description': description,
      'perks': perks,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getJobs() {
    return _firestore
        .collection('coachJobs')
        .where('status', isEqualTo: 'active')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAcademyJobs(String academyId) {
    return _firestore
        .collection('coachJobs')
        .where('academyId', isEqualTo: academyId)
        .snapshots();
  }

  Future<void> applyForJob(String jobId, String coachId, String coachName, String coachEmail) async {
    await _firestore.collection('jobApplications').add({
      'jobId': jobId,
      'coachId': coachId,
      'coachName': coachName,
      'coachEmail': coachEmail,
      'status': 'applied',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getJobApplications(String jobId) {
    return _firestore
        .collection('jobApplications')
        .where('jobId', isEqualTo: jobId)
        .snapshots();
  }
}
