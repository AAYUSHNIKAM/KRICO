import '../../coach/presentation/coach_training_routine_setup_screen.dart';
import 'package:flutter/material.dart';
import '../../../design_system/layouts/premium_nav_item.dart';
import '../../../design_system/layouts/premium_shell.dart';
import '../../../models/user_model.dart';
import '../../academy/presentation/academy_dashboard.dart';
import '../../admin/presentation/admin_dashboard.dart';
import '../../booking/presentation/my_bookings_screen.dart';
import '../../challenges/presentation/challenges_screen.dart';
import '../../chat/presentation/chat_list_screen.dart';
import '../../coach/presentation/coach_dashboard.dart';
import '../../coach/presentation/manage_availability_screen.dart';
import '../../community/presentation/community_screen.dart';
import '../../contracts/presentation/contract_list_screen.dart';
import '../../profile/presentation/public_profile_screen.dart';
import '../../schedule/presentation/booking_requests_screen.dart';
import '../../squad_goals/presentation/squad_goals_screen.dart';
import '../../venue/presentation/venue_discovery_screen.dart';
import '../../video_analysis/presentation/video_analysis_screen.dart';
import 'academy_coaches_tab.dart';
import 'academy_jobs_tab.dart';
import 'advertising_tab.dart';
import 'batches_tab.dart';
import 'coach_academy_jobs_screen.dart';
import 'coach_discovery_screen.dart';
import 'coach_offers_screen.dart';
import 'coupons_tab.dart';
import 'earnings_tab.dart';
import 'parent_dashboard.dart';
import 'parent_progress_screen.dart';
import 'performance_tab.dart';
import 'player_dashboard.dart';
import 'schedule_tab.dart';
import 'students_tab.dart';
import 'users_tab.dart';
import 'workspace_destinations.dart';
import 'workspace_home.dart';

class RoleWorkspace extends StatelessWidget {
  const RoleWorkspace({super.key, required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final destinations = workspaceDestinations(user.role);
    return PremiumShell(
      key: ValueKey('${user.uid}:${user.role.name}'),
      userModel: user,
      roleLabel: '${user.role.name[0].toUpperCase()}${user.role.name.substring(1)} workspace',
      bottomNavIndices: const [0, 1, 2, 3, 4],
      navItems: [for (final d in destinations)
        PremiumNavItem(icon: d.icon, label: d.label, section: d.section)],
      screens: [for (final d in destinations)
        d.id == 'home' ? WorkspaceHome(user: user, destinations: destinations) : _screen(d.id)],
    );
  }

  Widget _screen(String id) => switch (id) {
    'discover' => const CoachDiscoveryScreen(),
    'bookings' => MyBookingsScreen(user: user),
    'messages' => const ChatListScreen(),
    'growth' => PlayerDashboard(userModel: user),
    'performance' => PerformanceTab(playerId: user.uid, playerName: user.name),
    'video' => VideoAnalysisScreen(playerId: user.uid, playerName: user.name),
    'squad' => SquadGoalsScreen(playerId: user.uid, playerName: user.name),
    'challenges' => ChallengesScreen(playerId: user.uid, playerName: user.name),
    'children' => ParentDashboard(userModel: user),
    'progress' => ParentProgressScreen(parentId: user.uid),
    'requests' => BookingRequestsScreen(coachId: user.uid),
    'schedule' => ScheduleTab(coachId: user.uid),
    'students' => StudentsTab(coachId: user.uid),
    'routines' => CoachTrainingRoutineSetupScreen(coachId: user.uid, showAppBar: false),
    'availability' => ManageAvailabilityScreen(coachId: user.uid),
    'earnings' => EarningsTab(coachId: user.uid),
    'offers' => CoachOffersScreen(coachId: user.uid),
    'jobs' => user.role == UserRole.coach
        ? CoachAcademyJobsScreen(coachId: user.uid) : AcademyJobsTab(academyId: user.uid),
    'batches' => BatchesTab(academyId: user.uid),
    'coaches' => AcademyCoachesTab(academyId: user.uid),
    'advertising' => AdvertisingTab(academyId: user.uid),
    'overview' => switch (user.role) {
      UserRole.coach => const CoachDashboard(),
      UserRole.academy => const AcademyDashboard(),
      UserRole.admin => const AdminDashboard(),
      _ => throw StateError('Overview is not available for ${user.role.name}'),
    },
    'users' => const UsersTab(),
    'coupons' => const CouponsTab(),
    'venues' => const VenueDiscoveryScreen(),
    'community' => const CommunityScreen(),
    'contracts' => const ContractListScreen(),
    'profile' => PublicProfileScreen(userId: user.uid, showAppBar: false),
    _ => throw StateError('Unknown workspace destination: $id'),
  };
}