import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewService {
  ReviewService(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<ReviewModel>> getCoachReviews(String coachId) {
    return _firestore
        .collection('reviews')
        .where('coachId', isEqualTo: coachId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => ReviewModel.fromDoc(doc)).toList());
  }

  Future<void> addReview({
    required String coachId,
    required String playerId,
    required String playerName,
    String? playerPhotoUrl,
    required double rating,
    required String comment,
  }) async {
    final reviewId = _firestore.collection('reviews').doc().id;
    await _firestore.collection('reviews').doc(reviewId).set(ReviewModel(
      reviewId: reviewId,
      coachId: coachId,
      playerId: playerId,
      playerName: playerName,
      playerPhotoUrl: playerPhotoUrl,
      rating: rating,
      comment: comment,
    ).toMap());

    final reviewsSnap = await _firestore
        .collection('reviews')
        .where('coachId', isEqualTo: coachId)
        .get();
    final totalReviews = reviewsSnap.docs.length;
    double avgRating = 0;
    for (final doc in reviewsSnap.docs) {
      avgRating += (doc.data()['rating'] as num?)?.toDouble() ?? 0;
    }
    if (totalReviews > 0) avgRating /= totalReviews;

    await _firestore.collection('coaches').doc(coachId).update({
      'rating': double.parse(avgRating.toStringAsFixed(1)),
      'totalReviews': totalReviews,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
