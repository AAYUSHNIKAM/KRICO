import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/presentation/public_profile_screen.dart';
import '../../../models/user_model.dart';
import '../../../design_system/layouts/premium_nav_item.dart';
import '../../../design_system/layouts/premium_shell.dart';
import '../../../features/video_analysis/presentation/video_analysis_screen.dart';
import '../../../features/squad_goals/presentation/squad_goals_screen.dart';
import '../../../features/challenges/presentation/challenges_screen.dart';
import '../../../features/community/presentation/community_screen.dart';
import '../../chat/presentation/chat_list_screen.dart';
import 'player_dashboard.dart';
import 'performance_tab.dart';
import 'coach_discovery_screen.dart';

class PlayerShell extends ConsumerWidget {
  final UserModel userModel;
  const PlayerShell({super.key, required this.userModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const navItems = [
      PremiumNavItem(icon: Icons.speed_rounded, label: 'Dashboard'),
      PremiumNavItem(icon: Icons.show_chart_rounded, label: 'Performance'),
      PremiumNavItem(icon: Icons.videocam_rounded, label: 'AI Coach'),
      PremiumNavItem(icon: Icons.people_rounded, label: 'Community'),
      PremiumNavItem(icon: Icons.chat_rounded, label: 'Chat'),
      PremiumNavItem(icon: Icons.person_search_rounded, label: 'Coaches'),
      PremiumNavItem(icon: Icons.emoji_events_rounded, label: 'Squad Goals'),
      PremiumNavItem(icon: Icons.bolt_rounded, label: 'Challenges'),
      PremiumNavItem(icon: Icons.person_rounded, label: 'Profile'),
    ];
    final screens = [
      PlayerDashboard(userModel: userModel),
      PerformanceTab(playerId: userModel.uid, playerName: userModel.name),
      VideoAnalysisScreen(playerId: userModel.uid, playerName: userModel.name),
      const CommunityScreen(),
      const ChatListScreen(),
      const CoachDiscoveryScreen(),
      SquadGoalsScreen(playerId: userModel.uid, playerName: userModel.name),
      ChallengesScreen(playerId: userModel.uid, playerName: userModel.name),
      PublicProfileScreen(userId: userModel.uid, showAppBar: false),
    ];

    return PremiumShell(
      navItems: navItems,
      screens: screens,
      userModel: userModel,
      roleLabel: 'Player',
      bottomNavIndices: const [0, 1, 2, 3, 4],
    );
  }
}
