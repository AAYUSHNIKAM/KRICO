import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/theme_provider.dart';
import '../colors/app_colors.dart';
import '../typography/text_styles.dart';
import '../radius/radius.dart';
import '../spacing/spacing_scale.dart';
import '../tokens/duration_tokens.dart';
import '../icons/app_icons.dart';
import '../responsive/responsive_helpers.dart';
import 'premium_nav_item.dart';
import 'premium_top_bar.dart';
import 'premium_sidebar.dart';
import 'premium_drawer.dart';
import 'bottom_nav.dart';

class PremiumShell extends ConsumerStatefulWidget {
  final List<PremiumNavItem> navItems;
  final List<Widget> screens;
  final UserModel userModel;
  final String roleLabel;
  final List<int> bottomNavIndices;
  final int initialIndex;

  const PremiumShell({
    super.key,
    required this.navItems,
    required this.screens,
    required this.userModel,
    required this.roleLabel,
    required this.bottomNavIndices,
    this.initialIndex = 0,
  });

  @override
  ConsumerState<PremiumShell> createState() => _PremiumShellState();
}

class _PremiumShellState extends ConsumerState<PremiumShell> {
  int _currentIndex = 0;
  bool _drawerOpen = false;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _screens = List.from(widget.screens);
  }

  void _onNavChanged(int index) {
    setState(() => _currentIndex = index);
  }

  void _toggleDrawer() {
    setState(() => _drawerOpen = !_drawerOpen);
  }

  void _closeDrawer() {
    setState(() => _drawerOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop) {
      return _buildDesktopLayout();
    } else if (context.isTablet) {
      return _buildTabletLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  Widget _buildDesktopLayout() {
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _currentIndex = 0);
      },
      child: Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              _buildDesktopSidebar(),
              Expanded(
                child: Column(
                  children: [
                    PremiumTopBar(onMenuTap: null),
                    Expanded(
                      child: IndexedStack(
                        index: _currentIndex,
                        children: _screens,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _currentIndex = 0);
      },
      child: Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              _buildCollapsedSidebar(),
              Expanded(
                child: Column(
                  children: [
                    PremiumTopBar(onMenuTap: null),
                    Expanded(
                      child: IndexedStack(
                        index: _currentIndex,
                        children: _screens,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    final bottomNavItems = widget.bottomNavIndices.map((i) {
      final item = widget.navItems[i];
      return BottomNavItem(
        icon: item.icon,
        label: item.label,
        selectedIcon: item.activeIcon,
        badge: item.badge,
      );
    }).toList();

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _currentIndex = 0);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(AppIcons.menu),
            onPressed: _toggleDrawer,
            style: IconButton.styleFrom(
              minimumSize: const Size(48, 48),
            ),
          ),
          title: Text(
            widget.navItems[_currentIndex].label,
            style: AppTextStyles.title1.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textPrimary
                  : AppColors.lightTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
        body: Stack(
          children: [
            IndexedStack(index: _currentIndex, children: widget.screens),
            if (_drawerOpen)
              GestureDetector(
                onTap: _closeDrawer,
                child: AnimatedContainer(
                  duration: DurationTokens.medium,
                  color: _drawerOpen ? AppColors.overlay : Colors.transparent,
                ),
              ),
            AnimatedPositioned(
              duration: DurationTokens.medium,
              left: _drawerOpen ? 0 : -MediaQuery.of(context).size.width * 0.78,
              top: 0,
              bottom: 0,
              child: _buildMobileDrawer(),
            ),
          ],
        ),
        bottomNavigationBar: AppBottomNav(
          items: bottomNavItems,
          selectedIndex: _currentIndex,
          onChanged: (i) => _onNavChanged(widget.bottomNavIndices[i]),
        ),
      ),
    );
  }

  Widget _buildDesktopSidebar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PremiumSidebar(
      width: 260,
      header: _buildSidebarHeader(isDark),
      footer: _buildSidebarFooter(isDark),
      children: [
        ...List.generate(widget.navItems.length, (i) => PremiumSidebarTile(
          icon: widget.navItems[i].icon,
          label: widget.navItems[i].label,
          selected: _currentIndex == i,
          badge: widget.navItems[i].badge,
          onTap: () => _onNavChanged(i),
        )),
      ],
    );
  }

  Widget _buildCollapsedSidebar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PremiumCollapsedSidebar(
      width: 80,
      footer: _buildCollapsedFooter(isDark),
      children: [
        ...List.generate(widget.navItems.length, (i) => PremiumCollapsedSidebarTile(
          icon: widget.navItems[i].icon,
          selected: _currentIndex == i,
          badge: widget.navItems[i].badge,
          tooltip: widget.navItems[i].label,
          onTap: () => _onNavChanged(i),
        )),
      ],
    );
  }

  Widget _buildSidebarHeader(bool isDark) {
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final subColor = isDark ? AppColors.textTertiary : AppColors.lightTextTertiary;

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppRadius.brLg,
              ),
              child: const Icon(AppIcons.sports, size: 20, color: Colors.white),
            ),
            const SizedBox(width: SpacingScale.s10),
            Text(
              'SportsEco',
              style: AppTextStyles.title2.copyWith(color: textColor),
            ),
          ],
        ),
        const SizedBox(height: SpacingScale.s16),
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary,
                borderRadius: AppRadius.brFull,
              ),
              child: widget.userModel.photoUrl != null
                  ? ClipRRect(
                      borderRadius: AppRadius.brFull,
                      child: Image.network(widget.userModel.photoUrl!, fit: BoxFit.cover),
                    )
                  : Icon(AppIcons.person, size: 20, color: subColor),
            ),
            const SizedBox(width: SpacingScale.s10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userModel.name,
                    style: AppTextStyles.body.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.roleLabel,
                    style: AppTextStyles.captionXs.copyWith(color: subColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSidebarFooter(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFooterTile(
          icon: AppIcons.settings,
          label: 'Settings',
          onTap: () {},
          isDark: isDark,
        ),
        const SizedBox(height: 2),
        _buildThemeToggleTile(isDark),
        const SizedBox(height: 2),
        _buildFooterTile(
          icon: AppIcons.logOut,
          label: 'Sign Out',
          onTap: () async {
            await ref.read(authServiceProvider).signOut();
            if (context.mounted) context.go('/login');
          },
          isDark: isDark,
          isDanger: true,
        ),
      ],
    );
  }

  Widget _buildCollapsedFooter(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PremiumCollapsedSidebarTile(
          icon: AppIcons.settings,
          tooltip: 'Settings',
          onTap: () {},
        ),
        const SizedBox(height: 2),
        PremiumCollapsedSidebarTile(
          icon: AppIcons.light,
          tooltip: 'Toggle Theme',
          onTap: () => ref.read(themeModeProvider.notifier).toggle(),
        ),
        const SizedBox(height: 2),
        PremiumCollapsedSidebarTile(
          icon: AppIcons.logOut,
          tooltip: 'Sign Out',
          onTap: () async {
            await ref.read(authServiceProvider).signOut();
            if (context.mounted) context.go('/login');
          },
        ),
      ],
    );
  }

  Widget _buildFooterTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    bool isDanger = false,
  }) {
    final fgColor = isDanger
        ? AppColors.danger
        : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary);
    final textColor = isDanger
        ? AppColors.danger
        : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s8, vertical: 1),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingScale.s12,
            vertical: SpacingScale.s10,
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: fgColor),
              const SizedBox(width: SpacingScale.s12),
              Text(
                label,
                style: AppTextStyles.body.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggleTile(bool isDark) {
    final themeMode = ref.watch(themeModeProvider);
    final isCurrentlyDark = themeMode == ThemeMode.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s8, vertical: 1),
      child: GestureDetector(
        onTap: () => ref.read(themeModeProvider.notifier).toggle(),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingScale.s12,
            vertical: SpacingScale.s10,
          ),
          child: Row(
            children: [
              Icon(
                isCurrentlyDark ? AppIcons.light : AppIcons.dark,
                size: 20,
                color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
              ),
              const SizedBox(width: SpacingScale.s12),
              Expanded(
                child: Text(
                  isCurrentlyDark ? 'Light Mode' : 'Dark Mode',
                  style: AppTextStyles.body.copyWith(
                    color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ),
              Icon(
                isCurrentlyDark ? Icons.toggle_off_outlined : Icons.toggle_on_outlined,
                size: 20,
                color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileDrawer() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final subColor = isDark ? AppColors.textTertiary : AppColors.lightTextTertiary;

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.78,
      child: PremiumDrawer(
        header: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppRadius.brLg,
                  ),
                  child: const Icon(AppIcons.sports, size: 20, color: Colors.white),
                ),
                const SizedBox(width: SpacingScale.s10),
                Text(
                  'SportsEco',
                  style: AppTextStyles.title2.copyWith(color: textColor),
                ),
              ],
            ),
            const SizedBox(height: SpacingScale.s16),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary,
                    borderRadius: AppRadius.brFull,
                  ),
                  child: widget.userModel.photoUrl != null
                      ? ClipRRect(
                          borderRadius: AppRadius.brFull,
                          child: Image.network(widget.userModel.photoUrl!, fit: BoxFit.cover),
                        )
                      : Icon(AppIcons.person, size: 22, color: subColor),
                ),
                const SizedBox(width: SpacingScale.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userModel.name,
                        style: AppTextStyles.body.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.roleLabel,
                        style: AppTextStyles.captionXs.copyWith(color: subColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        sections: [
          PremiumDrawerSection(
            title: 'Navigation',
            items: List.generate(widget.navItems.length, (i) {
              return PremiumDrawerItem(
                icon: widget.navItems[i].icon,
                label: widget.navItems[i].label,
                selected: _currentIndex == i,
                badge: widget.navItems[i].badge,
                onTap: () {
                  _onNavChanged(i);
                  _closeDrawer();
                },
              );
            }),
          ),
          PremiumDrawerSection(
            title: 'Preferences',
            items: [
              PremiumDrawerItem(
                icon: AppIcons.settings,
                label: 'Settings',
                onTap: () {},
              ),
            ],
          ),
        ],
        footer: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeToggleTile(isDark),
            const SizedBox(height: SpacingScale.s8),
            _buildFooterTile(
              icon: AppIcons.logOut,
              label: 'Sign Out',
              onTap: () async {
                await ref.read(authServiceProvider).signOut();
                if (context.mounted) context.go('/login');
              },
              isDark: isDark,
              isDanger: true,
            ),
          ],
        ),
      ),
    );
  }
}
