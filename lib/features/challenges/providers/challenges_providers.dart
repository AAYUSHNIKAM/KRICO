import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/firebase_service.dart';
import '../data/challenges_service.dart';

final challengesServiceProvider = Provider<ChallengesService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return ChallengesService(firestore);
});

/// All challenges the user is part of (creator or participant), newest first.
final userChallengesProvider =
    StreamProvider.family.autoDispose<List<Challenge>, String>((ref, userId) {
  final service = ref.watch(challengesServiceProvider);
  return service.getUserChallenges(userId);
});
