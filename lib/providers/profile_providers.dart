import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../services/profile_service.dart';

final profileServiceProvider = Provider<ProfileService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final auth = ref.watch(firebaseAuthProvider);
  return ProfileService(firestore, auth);
});

/// Public profile of any user, fetched by UID.
final publicUserProfileProvider = FutureProvider.family<UserModel?, String>((ref, uid) {
  final service = ref.watch(profileServiceProvider);
  return service.getUserProfile(uid);
});

/// Role-specific document (players / coaches / academies) for a user.
final publicRoleProfileProvider =
    FutureProvider.family<Map<String, dynamic>?, ({String uid, String role})>((ref, params) {
  final service = ref.watch(profileServiceProvider);
  return service.getRoleProfile(params.uid, params.role);
});

final userPostsProvider = StreamProvider.family.autoDispose<List<Map<String, dynamic>>, String>((ref, uid) {
  final service = ref.watch(profileServiceProvider);
  return service.getUserPosts(uid);
});

final userMetricsProvider = StreamProvider.family.autoDispose<List<Map<String, dynamic>>, String>((ref, uid) {
  final service = ref.watch(profileServiceProvider);
  return service.getUserMetrics(uid);
});

final userAchievementsProvider = StreamProvider.family.autoDispose<List<Map<String, dynamic>>, String>((ref, uid) {
  final service = ref.watch(profileServiceProvider);
  return service.getUserAchievements(uid);
});

final userSessionsProvider = StreamProvider.family.autoDispose<QuerySnapshot<Map<String, dynamic>>, String>((ref, uid) {
  final service = ref.watch(profileServiceProvider);
  return service.getUserSessions(uid);
});

final userStreakProvider = FutureProvider.family<int, String>((ref, uid) {
  final service = ref.watch(profileServiceProvider);
  return service.getCurrentStreak(uid);
});

final isFollowingProvider = FutureProvider.family.autoDispose<bool, ({String followerId, String followedId})>(
  (ref, params) {
    final service = ref.watch(profileServiceProvider);
    return service.isFollowing(params.followerId, params.followedId);
  },
);

final userFollowersProvider = StreamProvider.family.autoDispose<List<UserModel>, String>((ref, uid) {
  final service = ref.watch(profileServiceProvider);
  return service.getFollowers(uid);
});

final userFollowingProvider = StreamProvider.family.autoDispose<List<UserModel>, String>((ref, uid) {
  final service = ref.watch(profileServiceProvider);
  return service.getFollowing(uid);
});
