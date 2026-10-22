import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

class PilotFeedbackService {
  final FirebaseFirestore _firestore;

  PilotFeedbackService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> submitFeedback({
    required String userId,
    required String? userEmail,
    required String? userName,
    required UserRole? userRole,
    required String category,
    required int rating,
    required String message,
  }) async {
    final docRef = _firestore.collection('pilotFeedback').doc();
    await docRef.set({
      'feedbackId': docRef.id,
      'userId': userId,
      'userEmail': userEmail ?? 'Anonymous',
      'userName': userName ?? 'Pilot User',
      'userRole': userRole?.name ?? 'unknown',
      'category': category,
      'rating': rating,
      'message': message.trim(),
      'appVersion': '0.0.1-pilot (Pune)',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

final pilotFeedbackServiceProvider = Provider<PilotFeedbackService>((ref) {
  return PilotFeedbackService();
});
