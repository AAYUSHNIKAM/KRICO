import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class VideoAnalysisResult {
  final String videoId;
  final String playerId;
  final String sport;
  final String videoUrl;
  final double? poseScore;
  final Map<String, double>? jointAngles;
  final String? feedback;
  final String status;
  final DateTime uploadedAt;

  const VideoAnalysisResult({
    required this.videoId,
    required this.playerId,
    required this.sport,
    required this.videoUrl,
    this.poseScore,
    this.jointAngles,
    this.feedback,
    this.status = 'processing',
    required this.uploadedAt,
  });

  factory VideoAnalysisResult.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return VideoAnalysisResult(
      videoId: doc.id,
      playerId: data['playerId'] as String? ?? '',
      sport: data['sport'] as String? ?? '',
      videoUrl: data['videoUrl'] as String? ?? '',
      poseScore: (data['poseScore'] as num?)?.toDouble(),
      jointAngles: (data['jointAngles'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, (v as num).toDouble())),
      feedback: data['feedback'] as String?,
      status: data['status'] as String? ?? 'processing',
      uploadedAt: (data['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class VideoAnalysisService {
  VideoAnalysisService(this._firestore, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  Stream<List<VideoAnalysisResult>> getPlayerVideos(String playerId) {
    return _firestore
        .collection('videoAnalysis')
        .where('playerId', isEqualTo: playerId)
        .snapshots()
        .map((snap) {
          final videos = snap.docs.map((doc) => VideoAnalysisResult.fromDoc(doc)).toList();
          videos.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
          return videos;
        });
  }

  Stream<VideoAnalysisResult?> getLatestVideo(String playerId) {
    return _firestore
        .collection('videoAnalysis')
        .where('playerId', isEqualTo: playerId)
        .snapshots()
        .map((snap) {
          if (snap.docs.isEmpty) return null;
          final videos = snap.docs.map((doc) => VideoAnalysisResult.fromDoc(doc)).toList();
          videos.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
          return videos.first;
        });
  }

  Future<String> uploadVideo({
    required String playerId,
    required String sport,
    required String filePath,
  }) async {
    final videoId = _firestore.collection('videoAnalysis').doc().id;
    final ref = _storage.ref('videos/$playerId/$videoId.mp4');
    await ref.putFile(File(filePath));
    final videoUrl = await ref.getDownloadURL();

    await _firestore.collection('videoAnalysis').doc(videoId).set({
      'videoId': videoId,
      'playerId': playerId,
      'sport': sport,
      'videoUrl': videoUrl,
      'status': 'processing',
      'uploadedAt': FieldValue.serverTimestamp(),
    });

    return videoId;
  }

  Future<void> submitForCoachReview(String videoId, String coachId) async {
    await _firestore.collection('videoAnalysis').doc(videoId).update({
      'coachId': coachId,
      'status': 'pending_review',
    });
  }

  Future<void> provideCoachFeedback({
    required String videoId,
    required double poseScore,
    required String feedback,
    Map<String, double>? jointAngles,
  }) async {
    await _firestore.collection('videoAnalysis').doc(videoId).update({
      'poseScore': poseScore,
      'feedback': feedback,
      'jointAngles': jointAngles,
      'status': 'completed',
      'reviewedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteVideo(String videoId, String playerId) async {
    final doc = await _firestore.collection('videoAnalysis').doc(videoId).get();
    if (doc.exists) {
      final videoUrl = (doc.data()?['videoUrl'] as String?) ?? '';
      if (videoUrl.isNotEmpty) {
        try {
          final ref = _storage.refFromURL(videoUrl);
          await ref.delete();
        } catch (_) {}
      }
    }
    await _firestore.collection('videoAnalysis').doc(videoId).delete();
  }
}
