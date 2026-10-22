import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/responsive/responsive_helpers.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../models/coach_model.dart';
import 'widgets/hero_section.dart';
import 'widgets/stats_section.dart';
import 'widgets/upcoming_sessions_section.dart';
import 'widgets/milestones_section.dart';
import 'widgets/subscription_section.dart';
import 'widgets/quick_actions_section.dart';

class CoachDashboardPage extends ConsumerWidget {
  final CoachModel coach;

  const CoachDashboardPage({super.key, required this.coach});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coachId = coach.coachId;

    return Scaffold(
      body: _DashboardLayout(coachId: coachId, coach: coach),
    );
  }
}

class _DashboardLayout extends StatelessWidget {
  final String coachId;
  final CoachModel coach;

  const _DashboardLayout({
    required this.coachId,
    required this.coach,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;

    if (isDesktop) {
      return _DesktopLayout(coachId: coachId, coach: coach);
    } else if (isTablet) {
      return _TabletLayout(coachId: coachId, coach: coach);
    }
    return _PhoneLayout(coachId: coachId, coach: coach);
  }
}

class _DesktopLayout extends StatelessWidget {
  final String coachId;
  final CoachModel coach;

  const _DesktopLayout({required this.coachId, required this.coach});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: CoachHeroSection(coachId: coachId, coach: coach)),
        SliverToBoxAdapter(child: CoachStatsSection(coachId: coachId)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xl6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 7, child: CoachUpcomingSessionsSection(coachId: coachId)),
                const SizedBox(width: SpacingTokens.xl4),
                Expanded(flex: 5, child: CoachMilestonesSection(coachId: coachId)),
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
                Expanded(flex: 3, child: CoachSubscriptionSection(coach: coach)),
                const SizedBox(width: SpacingTokens.xl4),
                Expanded(flex: 2, child: CoachQuickActionsSection(coachId: coachId)),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: SpacingTokens.xl8)),
      ],
    );
  }
}

class _TabletLayout extends StatelessWidget {
  final String coachId;
  final CoachModel coach;

  const _TabletLayout({required this.coachId, required this.coach});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: CoachHeroSection(coachId: coachId, coach: coach)),
        SliverToBoxAdapter(child: CoachStatsSection(coachId: coachId)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xl4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: CoachUpcomingSessionsSection(coachId: coachId)),
                const SizedBox(width: SpacingTokens.xl3),
                Expanded(child: CoachMilestonesSection(coachId: coachId)),
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
                Expanded(child: CoachSubscriptionSection(coach: coach)),
                const SizedBox(width: SpacingTokens.xl3),
                Expanded(child: CoachQuickActionsSection(coachId: coachId)),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: SpacingTokens.xl8)),
      ],
    );
  }
}

class _PhoneLayout extends StatelessWidget {
  final String coachId;
  final CoachModel coach;

  const _PhoneLayout({required this.coachId, required this.coach});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: CoachHeroSection(coachId: coachId, coach: coach)),
        SliverToBoxAdapter(child: CoachStatsSection(coachId: coachId)),
        SliverToBoxAdapter(child: CoachUpcomingSessionsSection(coachId: coachId)),
        SliverToBoxAdapter(child: CoachMilestonesSection(coachId: coachId)),
        SliverToBoxAdapter(child: CoachSubscriptionSection(coach: coach)),
        SliverToBoxAdapter(child: CoachQuickActionsSection(coachId: coachId)),
        SliverToBoxAdapter(child: SizedBox(height: SpacingTokens.xl8)),
      ],
    );
  }
}
