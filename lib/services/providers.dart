import 'media_upload_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/academy_model.dart';
import '../models/chat_model.dart';
import '../models/coach_model.dart';
import '../models/contract_model.dart';
import '../models/player_model.dart';
import '../models/review_model.dart';
import '../models/notification_model.dart';
import '../models/venue_model.dart';
import '../models/session_model.dart';
import '../models/batch_model.dart';
import '../models/player_metric_model.dart';
import '../models/milestone_model.dart';
import '../models/job_model.dart';
import '../models/post_model.dart';
import 'firebase_service.dart';
import 'venue_service.dart';
import 'notification_service.dart';
import 'chat_service.dart';
import 'contract_service.dart';
import 'coach_service.dart';
import 'academy_service.dart';
import 'player_service.dart';
import 'review_service.dart';
import 'parent_service.dart';

final reviewServiceProvider = Provider<ReviewService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return ReviewService(firestore);
});

final venueServiceProvider = Provider<VenueService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return VenueService(firestore);
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return NotificationService(firestore);
});

final userNotificationsProvider = StreamProvider.family.autoDispose<List<AppNotification>, String>((ref, String userId) {
  final service = ref.watch(notificationServiceProvider);
  return service.getUserNotifications(userId);
});

final unreadNotificationsProvider = Provider.family.autoDispose<int, String>((ref, String userId) {
  final notifications = ref.watch(userNotificationsProvider(userId)).value ?? const <AppNotification>[];
  return notifications.where((n) => !n.isRead).length;
});

final chatServiceProvider = Provider<ChatService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return ChatService(firestore);
});

final contractServiceProvider = Provider<ContractService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return ContractService(firestore);
});

final coachServiceProvider = Provider<CoachService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return CoachService(firestore);
});

final academyServiceProvider = Provider<AcademyService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return AcademyService(firestore);
});

final playerServiceProvider = Provider<PlayerService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return PlayerService(firestore);
});

final parentServiceProvider = Provider<ParentService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return ParentService(firestore);
});

final venuesStreamProvider = StreamProvider.autoDispose<List<VenueModel>>((ref) {
  final service = ref.watch(venueServiceProvider);
  return service.getVenues();
});

final venueProvider = StreamProvider.family.autoDispose<VenueModel, String>((ref, String id) {
  final service = ref.watch(venueServiceProvider);
  return service.getVenue(id);
});

final venueBookingsProvider = StreamProvider.family.autoDispose<List<VenueBookingModel>, String>((ref, String venueId) {
  final service = ref.watch(venueServiceProvider);
  return service.getVenueBookings(venueId);
});

final venueBookedSlotsProvider = Provider.family.autoDispose<Set<String>, ({String venueId, String dateKey})>(
  (ref, params) {
    final bookings = ref.watch(venueBookingsProvider(params.venueId)).value ?? const [];
    return bookings
        .where((b) => b.status == 'booked' && b.dateKey == params.dateKey)
        .map((b) => b.startTime)
        .toSet();
  },
);

final userChatsProvider = StreamProvider.family.autoDispose<List<ChatModel>, String>((ref, String userId) {
  final service = ref.watch(chatServiceProvider);
  return service.getUserChats(userId);
});

final chatMessagesProvider = StreamProvider.family.autoDispose<List<ChatMessage>, String>((ref, String chatId) {
  final service = ref.watch(chatServiceProvider);
  return service.getChatMessages(chatId);
});

final userContractsProvider = StreamProvider.family.autoDispose<List<ContractModel>, String>((ref, String userId) {
  final service = ref.watch(contractServiceProvider);
  return service.getUserContracts(userId);
});

final contractProvider = StreamProvider.family.autoDispose<ContractModel, String>((ref, String contractId) {
  final service = ref.watch(contractServiceProvider);
  return service.getContract(contractId);
});

final coachesStreamProvider = StreamProvider.autoDispose<List<CoachModel>>((ref) {
  final service = ref.watch(coachServiceProvider);
  return service.getCoaches();
});

final coachProvider = StreamProvider.family.autoDispose<CoachModel, String>((ref, String coachId) {
  final service = ref.watch(coachServiceProvider);
  return service.getCoach(coachId);
});

final coachReviewsProvider = StreamProvider.family.autoDispose<List<ReviewModel>, String>((ref, String coachId) {
  final service = ref.watch(reviewServiceProvider);
  return service.getCoachReviews(coachId);
});

final academyProvider = StreamProvider.family.autoDispose<AcademyModel, String>((ref, String academyId) {
  final service = ref.watch(academyServiceProvider);
  return service.getAcademy(academyId);
});

final parentPlayersProvider = StreamProvider.family.autoDispose<List<PlayerModel>, String>((ref, String parentId) {
  final service = ref.watch(playerServiceProvider);
  return service.getParentPlayers(parentId);
});

final playerProvider = StreamProvider.family.autoDispose<PlayerModel, String>((ref, String playerId) {
  final service = ref.watch(playerServiceProvider);
  return service.getPlayer(playerId);
});

final playerMetricsProvider = StreamProvider.family.autoDispose<QuerySnapshot<Map<String, dynamic>>, String>((ref, String playerId) {
  final service = ref.watch(playerServiceProvider);
  return service.getPlayerMetrics(playerId);
});

final playerSessionsProvider = StreamProvider.family.autoDispose<QuerySnapshot<Map<String, dynamic>>, String>((ref, String playerId) {
  final service = ref.watch(coachServiceProvider);
  return service.getPlayerSessions(playerId);
});

final coachSessionsProvider = StreamProvider.family.autoDispose<QuerySnapshot<Map<String, dynamic>>, String>((ref, String coachId) {
  final service = ref.watch(coachServiceProvider);
  return service.getCoachSessions(coachId);
});

final coachPlayersProvider = StreamProvider.family.autoDispose<List<Map<String, dynamic>>, String>((ref, String coachId) {
  final service = ref.watch(playerServiceProvider);
  return service.getCoachPlayers(coachId);
});

final studentProgressProvider = StreamProvider.family.autoDispose<List<Map<String, dynamic>>, String>((ref, String playerId) {
  final service = ref.watch(playerServiceProvider);
  return service.getStudentProgress(playerId);
});

final coachStatsProvider = FutureProvider.family.autoDispose<Map<String, dynamic>, String>((ref, String coachId) {
  final service = ref.watch(coachServiceProvider);
  return service.getCoachStats(coachId);
});

final coachMonthlyEarningsProvider = FutureProvider.family.autoDispose<Map<String, int>, String>((ref, String coachId) {
  final service = ref.watch(coachServiceProvider);
  return service.getCoachMonthlyEarnings(coachId);
});

final pendingBookingsProvider = StreamProvider.family.autoDispose<QuerySnapshot<Map<String, dynamic>>, String>((ref, String coachId) {
  final service = ref.watch(coachServiceProvider);
  return service.getPendingBookings(coachId);
});

final coachMilestonesProvider = StreamProvider.family.autoDispose<QuerySnapshot<Map<String, dynamic>>, String>((ref, String coachId) {
  final service = ref.watch(coachServiceProvider);
  return service.getCoachMilestonesStream(coachId);
});

final academyBatchesProvider = StreamProvider.family.autoDispose<QuerySnapshot<Map<String, dynamic>>, String>((ref, String academyId) {
  final service = ref.watch(academyServiceProvider);
  return service.getBatches(academyId);
});

final academyPlacementsProvider = StreamProvider.family.autoDispose<QuerySnapshot<Map<String, dynamic>>, String>((ref, String academyId) {
  final service = ref.watch(academyServiceProvider);
  return service.getPlacements(academyId);
});

final academyCoachesProvider = StreamProvider.family.autoDispose<QuerySnapshot<Map<String, dynamic>>, String>((ref, String academyId) {
  final service = ref.watch(coachServiceProvider);
  return service.getAcademyCoaches(academyId);
});

final activeCoachesCountProvider = FutureProvider.family.autoDispose<int, String>((ref, String academyId) {
  final service = ref.watch(academyServiceProvider);
  return service.getActiveCoachesCount(academyId);
});

final allUsersProvider = StreamProvider.autoDispose<QuerySnapshot<Map<String, dynamic>>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.getUsers();
});

final coachJobsProvider = StreamProvider.autoDispose<QuerySnapshot<Map<String, dynamic>>>((ref) {
  final service = ref.watch(academyServiceProvider);
  return service.getJobs();
});

final coachApplicationsProvider = StreamProvider.family.autoDispose<QuerySnapshot<Map<String, dynamic>>, String>((ref, String coachId) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('jobApplications')
      .where('coachId', isEqualTo: coachId)
      .snapshots();
});

final academyInvitationsProvider = StreamProvider.family.autoDispose<QuerySnapshot<Map<String, dynamic>>, String>((ref, String academyId) {
  final service = ref.watch(academyServiceProvider);
  return service.getAcademyInvitations(academyId);
});

final coachInvitationsProvider = StreamProvider.family.autoDispose<QuerySnapshot<Map<String, dynamic>>, String>((ref, String coachId) {
  final service = ref.watch(academyServiceProvider);
  return service.getCoachInvitations(coachId);
});

final academyJobsProvider = StreamProvider.family.autoDispose<QuerySnapshot<Map<String, dynamic>>, String>((ref, String academyId) {
  final service = ref.watch(academyServiceProvider);
  return service.getAcademyJobs(academyId);
});

final academyCampaignsProvider = StreamProvider.family.autoDispose<QuerySnapshot<Map<String, dynamic>>, String>((ref, String academyId) {
  final service = ref.watch(academyServiceProvider);
  return service.getCampaigns(academyId);
});

final jobApplicationsProvider = StreamProvider.family.autoDispose<QuerySnapshot<Map<String, dynamic>>, String>((ref, String jobId) {
  final service = ref.watch(academyServiceProvider);
  return service.getJobApplications(jobId);
});

// --- Coupon Providers ---

final couponsProvider = StreamProvider.autoDispose<QuerySnapshot<Map<String, dynamic>>>((ref) {
  final service = ref.watch(authServiceProvider);
  return service.getCoupons();
});

// --- Admin Task Providers ---

final adminTasksProvider = StreamProvider.autoDispose<QuerySnapshot<Map<String, dynamic>>>((ref) {
  final service = ref.watch(authServiceProvider);
  return service.getAdminTasks();
});

// --- Revenue Provider ---

final totalRevenueProvider = StreamProvider.autoDispose<double>((ref) {
  final service = ref.watch(contractServiceProvider);
  return service.getTotalRevenueStream();
});

// --- Active Users Provider ---

final activeUsersCountProvider = StreamProvider.autoDispose<int>((ref) {
  final service = ref.watch(authServiceProvider);
  return service.activeUsersStream();
});

// --- Player Achievements Provider (moved from achievement_tab.dart) ---

final playerAchievementsProvider = StreamProvider.family.autoDispose<List<Map<String, dynamic>>, String>(
  (ref, playerId) {
    final firestore = ref.watch(firestoreProvider);
    return firestore
        .collection('playerAchievements')
        .where('playerId', isEqualTo: playerId)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => {...doc.data(), 'docId': doc.id}).toList());
  },
);

final communityPostsProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('posts')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => {...doc.data(), 'docId': doc.id}).toList());
});

final communityCommentsProvider = StreamProvider.family.autoDispose<List<Map<String, dynamic>>, String>((ref, String postId) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('posts')
      .doc(postId)
      .collection('comments')
      .orderBy('createdAt', descending: false)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => {...doc.data(), 'docId': doc.id}).toList());
});

// --- Strongly-Typed Domain Providers ---

final typedCommunityPostsProvider = StreamProvider.autoDispose<List<CommunityPostModel>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('posts')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => CommunityPostModel.fromDoc(doc)).toList());
});

final typedPlayerSessionsProvider = StreamProvider.family.autoDispose<List<SessionModel>, String>((ref, String playerId) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('sessions')
      .where('playerId', isEqualTo: playerId)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => SessionModel.fromDoc(doc)).toList());
});

final typedCoachSessionsProvider = StreamProvider.family.autoDispose<List<SessionModel>, String>((ref, String coachId) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('sessions')
      .where('coachId', isEqualTo: coachId)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => SessionModel.fromDoc(doc)).toList());
});

final typedBatchesProvider = StreamProvider.family.autoDispose<List<BatchModel>, String>((ref, String academyId) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('batches')
      .where('academyId', isEqualTo: academyId)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => BatchModel.fromDoc(doc)).toList());
});

final typedCoachMilestonesProvider = StreamProvider.family.autoDispose<List<CoachMilestoneModel>, String>((ref, String coachId) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('coachMilestones')
      .where('coachId', isEqualTo: coachId)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => CoachMilestoneModel.fromDoc(doc)).toList());
});

final typedPlayerMetricsProvider = StreamProvider.family.autoDispose<List<PlayerMetricModel>, String>((ref, String playerId) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('playerMetrics')
      .where('playerId', isEqualTo: playerId)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => PlayerMetricModel.fromDoc(doc)).toList());
});

final typedJobsProvider = StreamProvider.autoDispose<List<JobModel>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('jobs')
      .orderBy('postedAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => JobModel.fromDoc(doc)).toList());
});


final mediaUploadServiceProvider = Provider<MediaUploadService>((ref) {
  final storage = ref.watch(storageProvider);
  final firestore = ref.watch(firestoreProvider);
  return MediaUploadService(storage, firestore);
});
