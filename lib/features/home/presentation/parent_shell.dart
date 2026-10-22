import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/presentation/public_profile_screen.dart';
import '../../../models/user_model.dart';
import '../../../design_system/layouts/premium_nav_item.dart';
import '../../../design_system/layouts/premium_shell.dart';
import '../../chat/presentation/chat_list_screen.dart';
import '../../../features/community/presentation/community_screen.dart';
import 'coach_discovery_screen.dart';
import 'parent_dashboard.dart';
import 'parent_progress_screen.dart';

class ParentShell extends ConsumerWidget {
  final UserModel userModel;
  const ParentShell({super.key, required this.userModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const navItems = [
      PremiumNavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
      PremiumNavItem(icon: Icons.person_search_rounded, label: 'Coaches'),
      PremiumNavItem(icon: Icons.show_chart_rounded, label: 'Progress'),
      PremiumNavItem(icon: Icons.people_rounded, label: 'Community'),
      PremiumNavItem(icon: Icons.chat_rounded, label: 'Chat'),
      PremiumNavItem(icon: Icons.person_rounded, label: 'Profile'),
    ];
    final screens = [
      ParentDashboard(userModel: userModel),
      const CoachDiscoveryScreen(),
      ParentProgressScreen(parentId: userModel.uid),
      const CommunityScreen(),
      const ChatListScreen(),
      PublicProfileScreen(userId: userModel.uid, showAppBar: false),
    ];

    return PremiumShell(
      navItems: navItems,
      screens: screens,
      userModel: userModel,
      roleLabel: 'Parent',
      bottomNavIndices: const [0, 1, 2, 3, 4],
    );
  }
}
