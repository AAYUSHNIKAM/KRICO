import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/utils/date_parser.dart';

class ReviewModel {
  const ReviewModel({
    required this.reviewId,
    required this.coachId,
    required this.playerId,
    required this.playerName,
    this.playerPhotoUrl,
    required this.rating,
    required this.comment,
    this.createdAt,
  });

  final String reviewId;
  final String coachId;
  final String playerId;
  final String playerName;
  final String? playerPhotoUrl;
  final double rating;
  final String comment;
  final DateTime? createdAt;

  factory ReviewModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ReviewModel(
      reviewId: doc.id,
      coachId: data['coachId'] as String? ?? '',
      playerId: data['playerId'] as String? ?? '',
      playerName: data['playerName'] as String? ?? '',
      playerPhotoUrl: data['playerPhotoUrl'] as String?,
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      comment: data['comment'] as String? ?? '',
      createdAt: parseTimestamp(data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'coachId': coachId,
    'playerId': playerId,
    'playerName': playerName,
    'playerPhotoUrl': playerPhotoUrl,
    'rating': rating,
    'comment': comment,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
