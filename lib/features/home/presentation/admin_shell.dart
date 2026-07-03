import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/profile_page.dart';
import '../../../models/user_model.dart';
import '../../../design_system/layouts/premium_nav_item.dart';
import '../../../design_system/layouts/premium_shell.dart';
import '../../venue/presentation/venue_discovery_screen.dart';
import '../../admin/presentation/admin_dashboard.dart';
import 'users_tab.dart';
import 'coupons_tab.dart';

class AdminShell extends ConsumerWidget {
  final UserModel userModel;
  const AdminShell({super.key, required this.userModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const navItems = [
      PremiumNavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
      PremiumNavItem(icon: Icons.stadium_rounded, label: 'Venues'),
      PremiumNavItem(icon: Icons.people_rounded, label: 'Users'),
      PremiumNavItem(icon: Icons.local_offer_rounded, label: 'Coupons'),
      PremiumNavItem(icon: Icons.person_rounded, label: 'Profile'),
    ];
    final screens = [
      const AdminDashboard(),
      const VenueDiscoveryScreen(),
      const UsersTab(),
      const CouponsTab(),
      ProfilePage(userModel: userModel, role: 'Admin'),
    ];

    return PremiumShell(
      navItems: navItems,
      screens: screens,
      userModel: userModel,
      roleLabel: 'Admin',
      bottomNavIndices: const [0, 1, 2, 3, 4],
    );
  }
}
