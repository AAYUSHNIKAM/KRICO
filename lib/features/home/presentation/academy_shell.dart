import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/profile_page.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../academy/presentation/academy_dashboard.dart';
import 'batches_tab.dart';
import 'academy_coaches_tab.dart';
import 'advertising_tab.dart';
import 'academy_jobs_tab.dart';
import '../../chat/presentation/chat_list_screen.dart';

class AcademyShell extends ConsumerStatefulWidget {
  final UserModel userModel;
  const AcademyShell({super.key, required this.userModel});

  @override
  ConsumerState<AcademyShell> createState() => _AcademyShellState();
}

class _AcademyShellState extends ConsumerState<AcademyShell> {
  int _currentIndex = 0;

  late final List<Widget> _screens;
  late final List<_NavItem> _navItems;

  @override
  void initState() {
    super.initState();
    _navItems = const [
      _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
      _NavItem(icon: Icons.group_rounded, label: 'Batches'),
      _NavItem(icon: Icons.sports_rounded, label: 'Coaches'),
      _NavItem(icon: Icons.campaign_rounded, label: 'Advertising'),
      _NavItem(icon: Icons.work_rounded, label: 'Jobs'),
      _NavItem(icon: Icons.chat_rounded, label: 'Chat'),
      _NavItem(icon: Icons.person_rounded, label: 'Profile'),
    ];
    _screens = [
      const AcademyDashboard(),
      BatchesTab(academyId: widget.userModel.uid),
      AcademyCoachesTab(academyId: widget.userModel.uid),
      AdvertisingTab(academyId: widget.userModel.uid),
      AcademyJobsTab(academyId: widget.userModel.uid),
      const ChatListScreen(),
      ProfilePage(userModel: widget.userModel, role: 'Academy'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final scaffoldKey = isMobile ? GlobalKey<ScaffoldState>() : null;
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _currentIndex = 0);
      },
      child: Scaffold(
        key: scaffoldKey,
        appBar: isMobile
            ? AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: () => scaffoldKey?.currentState?.openDrawer(),
                ),
                title: Text(_navItems[_currentIndex].label, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600)),
                elevation: 0,
                backgroundColor: Colors.transparent,
              )
            : null,
        drawer: isMobile ? _buildDrawer() : null,
        body: SafeArea(
          child: isMobile ? IndexedStack(index: _currentIndex, children: _screens) : _buildDesktopLayout(),
        ),
        bottomNavigationBar: isMobile ? _buildBottomNav() : null,
      ),
    );
  }

  Widget _buildDrawer() => Drawer(
    backgroundColor: AppColors.surfaceDark,
    child: SafeArea(
      child: Column(
        children: [
          _buildNavHeader(),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: List.generate(_navItems.length, (i) => _buildNavTile(i)),
            ),
          ),
          _buildThemeTile(),
          _buildLogoutTile(),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );

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
            gradient: const LinearGradient(colors: AppColors.gradientAccent),
            shape: BoxShape.circle,
          ),
          child: widget.userModel.photoUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(widget.userModel.photoUrl!, fit: BoxFit.cover),
                )
              : const Icon(Icons.business_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 10),
        Text(widget.userModel.name, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('Academy', style: AppTextStyles.labelSmall.copyWith(color: AppColors.accent, fontWeight: FontWeight.w600, fontSize: 10)),
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
              color: isSelected ? AppColors.accent.withValues(alpha: 0.08) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: isSelected ? Border.all(color: AppColors.accent.withValues(alpha: 0.2)) : null,
            ),
            child: Row(
              children: [
                Icon(item.icon, size: 20, color: isSelected ? AppColors.accent : AppColors.textSecondary),
                const SizedBox(width: 12),
                Text(item.label, style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.accent : AppColors.textSecondary,
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

  void _showMoreNavSheet() {
    final items = _navItems.sublist(5);
    final startIndex = 5;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceMid,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textDim, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            ...List.generate(items.length, (i) {
              final idx = startIndex + i;
              final isSelected = _currentIndex == idx;
              return ListTile(
                leading: Icon(items[i].icon, color: isSelected ? AppColors.accent : AppColors.textSecondary),
                title: Text(items[i].label, style: TextStyle(
                  color: isSelected ? AppColors.accent : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                )),
                trailing: isSelected ? Icon(Icons.check_rounded, color: AppColors.accent, size: 18) : null,
                onTap: () {
                  setState(() => _currentIndex = idx);
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() => Container(
    decoration: BoxDecoration(
      color: AppColors.surfaceMid,
      border: Border(top: BorderSide(color: AppColors.borderLight.withValues(alpha: 0.3))),
    ),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 2),
        child: Row(
          children: [
            ...List.generate(_navItems.take(5).length, (i) {
              final isSelected = _currentIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _currentIndex = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.accent.withValues(alpha: 0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_navItems[i].icon, size: 20, color: isSelected ? AppColors.accent : AppColors.textSecondary),
                        const SizedBox(height: 1),
                        FittedBox(
                          child: Text(_navItems[i].label, style: AppTextStyles.labelSmall.copyWith(
                            color: isSelected ? AppColors.accent : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            fontSize: 9,
                          )),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            Expanded(
              child: GestureDetector(
                onTap: _showMoreNavSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.more_horiz_rounded, size: 20, color: AppColors.textSecondary),
                      const SizedBox(height: 1),
                      Text('More', style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                      )),
                    ],
                  ),
                ),
              ),
            ),
          ],
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


