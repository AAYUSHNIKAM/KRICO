import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/responsive/responsive_helpers.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../models/user_model.dart';
import '../../../../services/providers.dart';
import 'widgets/dashboard_loading.dart';
import 'widgets/hero_section.dart';
import 'widgets/todays_focus_section.dart';
import 'widgets/daily_missions_section.dart';
import 'widgets/player_progression_section.dart';
import 'widgets/upcoming_session_section.dart';
import 'widgets/quick_actions_section.dart';
import 'widgets/performance_section.dart';
import 'widgets/community_section.dart';
import 'widgets/achievements_section.dart';
import 'widgets/insights_section.dart';
import 'widgets/bottom_section.dart';

class DashboardPage extends ConsumerWidget {
  final UserModel userModel;

  const DashboardPage({super.key, required this.userModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerId = userModel.uid;
    final playerAsync = ref.watch(playerProvider(playerId));

    return Scaffold(
      body: playerAsync.when(
        data: (player) => _DashboardLayout(
          playerId: playerId,
          playerName: player.name,
        ),
        loading: () => const _LoadingLayout(),
        error: (_, _) => _ErrorLayout(
          onRetry: () => ref.invalidate(playerProvider(playerId)),
        ),
      ),
    );
  }
}

class _DashboardLayout extends StatelessWidget {
  final String playerId;
  final String playerName;

  const _DashboardLayout({
    required this.playerId,
    required this.playerName,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;

    if (isDesktop) {
      return _DesktopLayout(playerId: playerId, playerName: playerName);
    } else if (isTablet) {
      return _TabletLayout(playerId: playerId, playerName: playerName);
    }
    return _PhoneLayout(playerId: playerId, playerName: playerName);
  }
}

class _DesktopLayout extends StatelessWidget {
  final String playerId;
  final String playerName;

  const _DesktopLayout({required this.playerId, required this.playerName});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: HeroSection(playerId: playerId, playerName: playerName)),
        SliverToBoxAdapter(child: TodaysFocusSection(playerId: playerId)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xl6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 7, child: DailyMissionsSection(playerId: playerId)),
                const SizedBox(width: SpacingTokens.xl4),
                Expanded(flex: 5, child: PlayerProgressionSection(playerId: playerId)),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: UpcomingSessionSection(playerId: playerId)),
        SliverToBoxAdapter(child: QuickActionsSection(playerId: playerId)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xl6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: PerformanceSection(playerId: playerId)),
                const SizedBox(width: SpacingTokens.xl4),
                Expanded(flex: 2, child: InsightsSection(playerId: playerId)),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xl6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: CommunitySection(playerId: playerId)),
                const SizedBox(width: SpacingTokens.xl4),
                Expanded(flex: 2, child: AchievementsSection(playerId: playerId)),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: const BottomSection()),
        SliverToBoxAdapter(child: SizedBox(height: SpacingTokens.xl8)),
      ],
    );
  }
}

class _TabletLayout extends StatelessWidget {
  final String playerId;
  final String playerName;

  const _TabletLayout({required this.playerId, required this.playerName});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: HeroSection(playerId: playerId, playerName: playerName)),
        SliverToBoxAdapter(child: TodaysFocusSection(playerId: playerId)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xl4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: DailyMissionsSection(playerId: playerId)),
                const SizedBox(width: SpacingTokens.xl3),
                Expanded(child: PlayerProgressionSection(playerId: playerId)),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: UpcomingSessionSection(playerId: playerId)),
        SliverToBoxAdapter(child: QuickActionsSection(playerId: playerId)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xl4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: PerformanceSection(playerId: playerId)),
                const SizedBox(width: SpacingTokens.xl3),
                Expanded(child: InsightsSection(playerId: playerId)),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xl4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: CommunitySection(playerId: playerId)),
                const SizedBox(width: SpacingTokens.xl3),
                Expanded(child: AchievementsSection(playerId: playerId)),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: const BottomSection()),
        SliverToBoxAdapter(child: SizedBox(height: SpacingTokens.xl8)),
      ],
    );
  }
}

class _PhoneLayout extends StatelessWidget {
  final String playerId;
  final String playerName;

  const _PhoneLayout({required this.playerId, required this.playerName});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: HeroSection(playerId: playerId, playerName: playerName)),
        SliverToBoxAdapter(child: TodaysFocusSection(playerId: playerId)),
        SliverToBoxAdapter(child: DailyMissionsSection(playerId: playerId)),
        SliverToBoxAdapter(child: PlayerProgressionSection(playerId: playerId)),
        SliverToBoxAdapter(child: UpcomingSessionSection(playerId: playerId)),
        SliverToBoxAdapter(child: QuickActionsSection(playerId: playerId)),
        SliverToBoxAdapter(child: PerformanceSection(playerId: playerId)),
        SliverToBoxAdapter(child: InsightsSection(playerId: playerId)),
        SliverToBoxAdapter(child: CommunitySection(playerId: playerId)),
        SliverToBoxAdapter(child: AchievementsSection(playerId: playerId)),
        SliverToBoxAdapter(child: const BottomSection()),
        SliverToBoxAdapter(child: SizedBox(height: SpacingTokens.xl8)),
      ],
    );
  }
}

class _LoadingLayout extends StatelessWidget {
  const _LoadingLayout();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        DashboardHeaderShimmer(),
        DashboardSectionShimmer(height: 140),
        DashboardSectionShimmer(height: 200),
        DashboardSectionShimmer(height: 120),
        DashboardSectionShimmer(height: 320),
        DashboardSectionShimmer(height: 130),
        DashboardSectionShimmer(height: 260),
        DashboardSectionShimmer(height: 160),
        DashboardSectionShimmer(height: 140),
        DashboardSectionShimmer(height: 120),
        DashboardSectionShimmer(height: 80),
      ],
    );
  }
}

class _ErrorLayout extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorLayout({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.xl4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.error_outline_rounded, size: 28, color: Color(0xFFDC2626)),
            ),
            const SizedBox(height: SpacingTokens.xl3),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFF4F4F5) : const Color(0xFF18181B),
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            Text(
              "We couldn't load your dashboard. Please try again.",
              style: TextStyle(
                fontSize: 14,
                color: isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SpacingTokens.xl4),
            _ErrorRetryButton(onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}

class _ErrorRetryButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _ErrorRetryButton({required this.onPressed});

  @override
  State<_ErrorRetryButton> createState() => _ErrorRetryButtonState();
}

class _ErrorRetryButtonState extends State<_ErrorRetryButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xl4, vertical: SpacingTokens.xl),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFF3B82F6) : const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'Retry',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFFF4F4F5),
            ),
          ),
        ),
      ),
    );
  }
}
