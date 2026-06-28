import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/home/presentation/role_router.dart';
import '../../features/venue/presentation/venue_discovery_screen.dart';
import '../../features/venue/presentation/venue_detail_screen.dart';
import '../../features/chat/presentation/chat_list_screen.dart';
import '../../features/chat/presentation/chat_detail_screen.dart';
import '../../features/contracts/presentation/contract_list_screen.dart';
import '../../features/contracts/presentation/contract_detail_screen.dart';
import '../../features/home/presentation/coach_discovery_screen.dart';
import '../../features/coach/presentation/create_session_screen.dart';
import '../../providers/auth_provider.dart';

abstract class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String parentDashboard = '/parent';
  static const String playerDashboard = '/player';
  static const String coachDashboard = '/coach';
  static const String academyDashboard = '/academy';
  static const String adminDashboard = '/admin';
  static const String venueDiscovery = '/venues';
  static const String venueDetail = '/venues/:id';
  static const String chat = '/chat';
  static const String chatDetail = '/chat/:id';
  static const String contracts = '/contracts';
  static const String contractDetail = '/contracts/:id';
  static const String coachDiscovery = '/coach-discovery';
}

GoRouter buildRouter(WidgetRef ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final currentUser = FirebaseAuth.instance.currentUser;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
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
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surfaceContainerHighest],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 80, color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(height: 16),
              Text('Page Not Found', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 8),
              Text('The page you\'re looking for doesn\'t exist', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
