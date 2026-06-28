import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/academy_model.dart';
import '../models/chat_model.dart';
import '../models/coach_model.dart';
import '../models/contract_model.dart';
import '../models/player_model.dart';
import '../models/user_model.dart';
import '../models/venue_model.dart';
import 'firebase_service.dart';
import 'venue_service.dart';
import 'chat_service.dart';
import 'contract_service.dart';
import 'coach_service.dart';
import 'academy_service.dart';
import 'player_service.dart';

final venueServiceProvider = Provider<VenueService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return VenueService(firestore);
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

final venuesStreamProvider = StreamProvider.autoDispose<List<VenueModel>>((ref) {
  final service = ref.watch(venueServiceProvider);
  return service.getVenues();
});

final venueProvider = StreamProvider.family.autoDispose<VenueModel, String>((ref, String id) {
  final service = ref.watch(venueServiceProvider);
  return service.getVenue(id);
});

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

final coachPlayersProvider = StreamProvider.family.autoDispose<QuerySnapshot<Map<String, dynamic>>, String>((ref, String coachId) {
  final service = ref.watch(playerServiceProvider);
  return service.getCoachPlayers(coachId);
});

final coachStatsProvider = FutureProvider.family.autoDispose<Map<String, dynamic>, String>((ref, String coachId) {
  final service = ref.watch(coachServiceProvider);
  return service.getCoachStats(coachId);
});

final coachMonthlyEarningsProvider = FutureProvider.family.autoDispose<Map<String, int>, String>((ref, String coachId) {
  final service = ref.watch(coachServiceProvider);
  return service.getCoachMonthlyEarnings(coachId);
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
