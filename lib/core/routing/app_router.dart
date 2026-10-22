import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/home/presentation/role_router.dart';
import '../../features/venue/presentation/venue_discovery_screen.dart';
import '../../features/venue/presentation/venue_detail_screen.dart';
import '../../features/venue/presentation/venue_booking_screen.dart';
import '../../features/chat/presentation/chat_list_screen.dart';
import '../../features/chat/presentation/chat_detail_screen.dart';
import '../../features/contracts/presentation/contract_list_screen.dart';
import '../../features/contracts/presentation/contract_detail_screen.dart';
import '../../features/home/presentation/coach_discovery_screen.dart';
import '../../features/booking/presentation/booking_flow_screen.dart';
import '../../features/coach/presentation/coach_detail_screen.dart';
import '../../features/coach/presentation/create_session_screen.dart';
import '../../features/coach/presentation/manage_availability_screen.dart';
import '../../features/schedule/presentation/booking_requests_screen.dart';
import '../../features/schedule/presentation/session_detail_screen.dart';
import '../../features/profile/presentation/public_profile_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/home/presentation/student_progress_screen.dart';
import '../../features/player/presentation/certificates/athlete_certificates_screen.dart';
import '../../features/search/presentation/user_search_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/parent_player/presentation/add_child_screen.dart';
import '../../features/parent_player/presentation/child_profile_screen.dart';
import '../../models/coach_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/providers.dart';
import '../../features/community/presentation/community_screen.dart';
import '../../features/squad_goals/presentation/squad_goals_screen.dart';
import '../../features/video_analysis/presentation/video_analysis_screen.dart';
import '../../features/home/presentation/performance_tab.dart';
import '../../features/booking/presentation/my_bookings_screen.dart';


abstract class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String parentDashboard = '/parent';
  static const String playerDashboard = '/player';
  static const String coachDashboard = '/coach';
  static const String academyDashboard = '/academy';
  static const String adminDashboard = '/admin';
  static const String venueDiscovery = '/venues';
  static const String venueDetail = '/venues/:id';
  static const String venueBooking = '/venues/:id/book';
  static const String chat = '/chat';
  static const String chatDetail = '/chat/:id';
  static const String contracts = '/contracts';
  static const String contractDetail = '/contracts/:id';
  static const String coachDiscovery = '/coach-discovery';
  static const String coachDetail = '/coach/:id';
  static const String bookingFlow = '/booking';
  static const String manageAvailability = '/manage-availability';
  static const String bookingRequests = '/booking-requests';
  static const String sessionDetail = '/session/:id';
  static const String profile = '/profile/:id';
  static const String studentProgress = '/student-progress/:playerId';
  static const String playerCertificates = '/player-certificates/:playerId';
  static const String settings = '/settings';
  static const String search = '/search';
  static const String notifications = '/notifications';
  static const String addChild = '/add-child';
  static const String childProfile = '/child/:playerId';
  static const String community = '/community';
  static const String squadGoals = '/squad-goals';
  static const String videoAnalysis = '/video-analysis';
  static const String performance = '/performance';
  static const String myBookings = '/bookings';
  static const String sessions = '/sessions';

}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
    redirect: (context, state) {
      final currentUser = FirebaseAuth.instance.currentUser;
      final isAuthRoute =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signup ||
          state.matchedLocation == AppRoutes.forgotPassword ||
          state.matchedLocation == AppRoutes.splash;
      if (currentUser != null && isAuthRoute) return AppRoutes.home;
      if (currentUser == null && !isAuthRoute) return AppRoutes.login;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: AppRoutes.signup,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SignupScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ForgotPasswordScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const RoleRouter(),
      ),
      GoRoute(
        path: AppRoutes.venueDiscovery,
        builder: (context, state) => const VenueDiscoveryScreen(),
      ),
      GoRoute(
        path: AppRoutes.venueDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return VenueDetailScreen(venueId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.venueBooking,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return VenueBookingScreen(venueId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.chat,
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: AppRoutes.chatDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final otherUserId = state.extra as String?;
          return ChatDetailScreen(chatId: id, otherUserId: otherUserId);
        },
      ),
      GoRoute(
        path: AppRoutes.coachDiscovery,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CoachDiscoveryScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: AppRoutes.coachDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CoachDetailScreen(coachId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.bookingFlow,
        builder: (context, state) {
          final coach = state.extra;
          if (coach is CoachModel) return BookingFlowScreen(coach: coach);
          final coachId = state.uri.queryParameters['coachId'];
          if (coachId != null && coachId.isNotEmpty) {
            return Consumer(
              builder: (context, ref, _) {
                final coachAsync = ref.watch(coachProvider(coachId));
                return coachAsync.when(
                  data: (c) => BookingFlowScreen(coach: c),
                  loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
                  error: (e, _) => const CoachDiscoveryScreen(),
                );
              },
            );
          }
          return const CoachDiscoveryScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.manageAvailability,
        builder: (context, state) {
          final coachId =
              state.extra as String? ??
              FirebaseAuth.instance.currentUser?.uid ??
              '';
          return ManageAvailabilityScreen(coachId: coachId);
        },
      ),
      GoRoute(
        path: AppRoutes.bookingRequests,
        builder: (context, state) {
          final coachId =
              state.extra as String? ??
              FirebaseAuth.instance.currentUser?.uid ??
              '';
          return BookingRequestsScreen(coachId: coachId);
        },
      ),
      GoRoute(
        path: AppRoutes.sessionDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return SessionDetailScreen(sessionId: id);
        },
      ),
      GoRoute(
        path: '/create-session',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CreateSessionScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: AppRoutes.contracts,
        builder: (context, state) => const ContractListScreen(),
      ),
      GoRoute(
        path: AppRoutes.contractDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ContractDetailScreen(contractId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PublicProfileScreen(userId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.studentProgress,
        builder: (context, state) {
          final playerId = state.pathParameters['playerId']!;
          final extra = state.extra as Map<String, dynamic>? ?? const {};
          return StudentProgressScreen(
            playerId: playerId,
            coachId: extra['coachId'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.playerCertificates,
        builder: (context, state) {
          final playerId = state.pathParameters['playerId']!;
          return AthleteCertificatesScreen(playerId: playerId);
        },
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => const UserSearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.addChild,
        builder: (context, state) => const AddChildScreen(),
      ),
      GoRoute(
        path: AppRoutes.childProfile,
        builder: (context, state) {
          final id = state.pathParameters['playerId']!;
          return ChildProfileScreen(playerId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) {
          final user = state.extra as UserModel?;
          if (user != null) return SettingsScreen(userModel: user);
          return Consumer(
            builder: (context, ref, _) {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid == null) {
                return const Scaffold(body: Center(child: Text('Not signed in')));
              }
              final profileAsync = ref.watch(userProfileProvider(uid));
              return profileAsync.when(
                data: (profile) => profile != null
                    ? SettingsScreen(userModel: profile)
                    : const Scaffold(body: Center(child: Text('Profile not found'))),
                loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
                error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
              );
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.community,
        builder: (context, state) => const CommunityScreen(),
      ),
      GoRoute(
        path: AppRoutes.squadGoals,
        builder: (context, state) {
          final currentUser = FirebaseAuth.instance.currentUser;
          final extra = state.extra as Map<String, dynamic>?;
          final playerId = extra?['playerId'] as String? ?? currentUser?.uid ?? '';
          final playerName = extra?['playerName'] as String? ?? currentUser?.displayName ?? 'Athlete';
          return SquadGoalsScreen(playerId: playerId, playerName: playerName);
        },
      ),
      GoRoute(
        path: AppRoutes.videoAnalysis,
        builder: (context, state) {
          final currentUser = FirebaseAuth.instance.currentUser;
          final extra = state.extra as Map<String, dynamic>?;
          final playerId = extra?['playerId'] as String? ?? currentUser?.uid ?? '';
          final playerName = extra?['playerName'] as String? ?? currentUser?.displayName ?? 'Athlete';
          return VideoAnalysisScreen(playerId: playerId, playerName: playerName);
        },
      ),
      GoRoute(
        path: AppRoutes.performance,
        builder: (context, state) {
          final currentUser = FirebaseAuth.instance.currentUser;
          final extra = state.extra as Map<String, dynamic>?;
          final playerId = extra?['playerId'] as String? ?? currentUser?.uid ?? '';
          final playerName = extra?['playerName'] as String? ?? currentUser?.displayName ?? 'Athlete';
          return PerformanceTab(playerId: playerId, playerName: playerName);
        },
      ),
      GoRoute(
        path: AppRoutes.myBookings,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is UserModel) return MyBookingsScreen(user: extra);
          return Consumer(
            builder: (context, ref, _) {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid == null) {
                return const Scaffold(body: Center(child: Text('Not signed in')));
              }
              final profileAsync = ref.watch(userProfileProvider(uid));
              return profileAsync.when(
                data: (user) => user != null
                    ? MyBookingsScreen(user: user)
                    : const Scaffold(body: Center(child: Text('Profile not found'))),
                loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
                error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
              );
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.sessions,
        redirect: (context, state) => AppRoutes.myBookings,
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surfaceContainerHighest,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'Page Not Found',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The page you\'re looking for doesn\'t exist',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
