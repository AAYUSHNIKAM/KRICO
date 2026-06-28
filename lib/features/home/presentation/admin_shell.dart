import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/profile_page.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../venue/presentation/venue_discovery_screen.dart';
import '../../admin/presentation/admin_dashboard.dart';
import 'users_tab.dart';
import 'coupons_tab.dart';

class AdminShell extends ConsumerStatefulWidget {
  final UserModel userModel;
  const AdminShell({super.key, required this.userModel});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  int _currentIndex = 0;

  late final List<Widget> _screens;
  late final List<_NavItem> _navItems;

  @override
  void initState() {
    super.initState();
    _navItems = const [
      _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
      _NavItem(icon: Icons.stadium_rounded, label: 'Venues'),
      _NavItem(icon: Icons.people_rounded, label: 'Users'),
      _NavItem(icon: Icons.local_offer_rounded, label: 'Coupons'),
      _NavItem(icon: Icons.person_rounded, label: 'Profile'),
    ];
    _screens = [
      const AdminDashboard(),
      const VenueDiscoveryScreen(),
      const UsersTab(),
      const CouponsTab(),
      ProfilePage(userModel: widget.userModel, role: 'Admin'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _currentIndex = 0);
      },
      child: Scaffold(
        body: SafeArea(
          child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
        ),
        bottomNavigationBar: isMobile ? _buildBottomNav() : null,
      ),
    );
  }

  Widget _buildMobileLayout() => IndexedStack(index: _currentIndex, children: _screens);

  Widget _buildDesktopLayout() => Row(
    children: [
      _buildSideNav(),
      const VerticalDivider(width: 1, thickness: 1),
      Expanded(child: IndexedStack(index: _currentIndex, children: _screens)),
    ],
  );

  Widget _buildSideNav() => Container(
    width: 220, color: AppColors.surfaceMid,
    child: Column(
      children: [
        _buildNavHeader(),
        const SizedBox(height: 8),
        ...List.generate(_navItems.length, (i) => _buildNavTile(i)),
          const Spacer(),
          _buildThemeTile(),
          _buildLogoutTile(),
        const SizedBox(height: 12),
      ],
    ),
  );

  Widget _buildNavHeader() => Container(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: AppColors.borderLight.withValues(alpha: 0.3))),
    ),
    child: Column(
      children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppColors.gradientGold),
            shape: BoxShape.circle,
          ),
          child: widget.userModel.photoUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(widget.userModel.photoUrl!, fit: BoxFit.cover),
                )
              : const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 10),
        Text(widget.userModel.name, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('Admin', style: AppTextStyles.labelSmall.copyWith(color: AppColors.gold, fontWeight: FontWeight.w600, fontSize: 10)),
        ),
      ],
    ),
  );

  Widget _buildNavTile(int index) {
    final isSelected = _currentIndex == index;
    final item = _navItems[index];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => setState(() => _currentIndex = index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.gold.withValues(alpha: 0.08) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: isSelected ? Border.all(color: AppColors.gold.withValues(alpha: 0.2)) : null,
            ),
            child: Row(
              children: [
                Icon(item.icon, size: 20, color: isSelected ? AppColors.gold : AppColors.textSecondary),
                const SizedBox(width: 12),
                Text(item.label, style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.gold : AppColors.textSecondary,
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeTile() {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => ref.read(themeModeProvider.notifier).toggle(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 12),
                Text(isDark ? 'Light Mode' : 'Dark Mode', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                const Spacer(),
                Icon(isDark ? Icons.toggle_off_outlined : Icons.toggle_on_outlined, size: 20, color: AppColors.textDim),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutTile() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 10),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () async {
          await ref.read(authServiceProvider).signOut();
          if (context.mounted) context.go('/login');
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.logout_rounded, size: 20, color: AppColors.error),
              SizedBox(width: 12),
              Text('Sign Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildBottomNav() => Container(
    decoration: BoxDecoration(
      color: AppColors.surfaceMid,
      border: Border(top: BorderSide(color: AppColors.borderLight.withValues(alpha: 0.3))),
    ),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_navItems.length, (i) {
            final isSelected = _currentIndex == i;
            return GestureDetector(
              onTap: () => setState(() => _currentIndex = i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.gold.withValues(alpha: 0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_navItems[i].icon, size: 22, color: isSelected ? AppColors.gold : AppColors.textSecondary),
                    const SizedBox(height: 2),
                    Text(_navItems[i].label, style: AppTextStyles.labelSmall.copyWith(
                      color: isSelected ? AppColors.gold : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 9,
                    )),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    ),
  );
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}


