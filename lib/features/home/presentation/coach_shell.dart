import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/presentation/public_profile_screen.dart';
import '../../../models/user_model.dart';
import '../../../design_system/layouts/premium_nav_item.dart';
import '../../../design_system/layouts/premium_shell.dart';
import '../../coach/presentation/coach_dashboard.dart';
import '../../chat/presentation/chat_list_screen.dart';
import 'schedule_tab.dart';
import 'students_tab.dart';
import 'earnings_tab.dart';
import 'coach_academy_jobs_screen.dart';
import 'coach_offers_screen.dart';
import '../../community/presentation/community_screen.dart';

class CoachShell extends ConsumerWidget {
  final UserModel userModel;
  const CoachShell({super.key, required this.userModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const navItems = [
      PremiumNavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
      PremiumNavItem(icon: Icons.calendar_month_rounded, label: 'Schedule'),
      PremiumNavItem(icon: Icons.people_rounded, label: 'Students'),
      PremiumNavItem(icon: Icons.account_balance_wallet_rounded, label: 'Earnings'),
      PremiumNavItem(icon: Icons.work_rounded, label: 'Jobs'),
      PremiumNavItem(icon: Icons.email_rounded, label: 'Offers'),
      PremiumNavItem(icon: Icons.groups_rounded, label: 'Community'),
      PremiumNavItem(icon: Icons.chat_rounded, label: 'Chat'),
      PremiumNavItem(icon: Icons.person_rounded, label: 'Profile'),
    ];
    final screens = [
      const CoachDashboard(),
      ScheduleTab(coachId: userModel.uid),
      StudentsTab(coachId: userModel.uid),
      EarningsTab(coachId: userModel.uid),
      CoachAcademyJobsScreen(coachId: userModel.uid),
      CoachOffersScreen(coachId: userModel.uid),
      const CommunityScreen(),
      const ChatListScreen(),
      PublicProfileScreen(userId: userModel.uid, showAppBar: false),
    ];

    return PremiumShell(
      navItems: navItems,
      screens: screens,
      userModel: userModel,
      roleLabel: 'Coach',
      bottomNavIndices: const [0, 1, 2, 3, 4],
    );
  }
}
