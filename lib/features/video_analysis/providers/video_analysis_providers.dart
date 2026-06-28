import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/firebase_service.dart';
import '../data/video_analysis_service.dart';

final videoAnalysisServiceProvider = Provider<VideoAnalysisService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final storage = ref.watch(storageProvider);
  return VideoAnalysisService(firestore, storage);
});

final playerVideosProvider = StreamProvider.family.autoDispose<List<VideoAnalysisResult>, String>(
  (ref, playerId) {
    final service = ref.watch(videoAnalysisServiceProvider);
    return service.getPlayerVideos(playerId);
  },
);

final latestVideoProvider = StreamProvider.family.autoDispose<VideoAnalysisResult?, String>(
  (ref, playerId) {
    final service = ref.watch(videoAnalysisServiceProvider);
    return service.getLatestVideo(playerId);
  },
);
