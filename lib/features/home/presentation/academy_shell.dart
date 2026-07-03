import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/profile_page.dart';
import '../../../models/user_model.dart';
import '../../../design_system/layouts/premium_nav_item.dart';
import '../../../design_system/layouts/premium_shell.dart';
import '../../academy/presentation/academy_dashboard.dart';
import 'batches_tab.dart';
import 'academy_coaches_tab.dart';
import 'advertising_tab.dart';
import 'academy_jobs_tab.dart';
import '../../chat/presentation/chat_list_screen.dart';

class AcademyShell extends ConsumerWidget {
  final UserModel userModel;
  const AcademyShell({super.key, required this.userModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const navItems = [
      PremiumNavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
      PremiumNavItem(icon: Icons.group_rounded, label: 'Batches'),
      PremiumNavItem(icon: Icons.sports_rounded, label: 'Coaches'),
      PremiumNavItem(icon: Icons.campaign_rounded, label: 'Advertising'),
      PremiumNavItem(icon: Icons.work_rounded, label: 'Jobs'),
      PremiumNavItem(icon: Icons.chat_rounded, label: 'Chat'),
      PremiumNavItem(icon: Icons.person_rounded, label: 'Profile'),
    ];
    final screens = [
      const AcademyDashboard(),
      BatchesTab(academyId: userModel.uid),
      AcademyCoachesTab(academyId: userModel.uid),
      AdvertisingTab(academyId: userModel.uid),
      AcademyJobsTab(academyId: userModel.uid),
      const ChatListScreen(),
      ProfilePage(userModel: userModel, role: 'Academy'),
    ];

    return PremiumShell(
      navItems: navItems,
      screens: screens,
      userModel: userModel,
      roleLabel: 'Academy',
      bottomNavIndices: const [0, 1, 2, 3, 4],
    );
  }
}
