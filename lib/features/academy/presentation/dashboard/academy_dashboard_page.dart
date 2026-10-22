import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/responsive/responsive_helpers.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../models/academy_model.dart';
import 'widgets/hero_section.dart';
import 'widgets/stats_section.dart';
import 'widgets/batches_section.dart';
import 'widgets/advertising_section.dart';
import 'widgets/placements_section.dart';

class AcademyDashboardPage extends ConsumerWidget {
  final AcademyModel academy;

  const AcademyDashboardPage({super.key, required this.academy});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: _DashboardLayout(academy: academy),
    );
  }
}

class _DashboardLayout extends StatelessWidget {
  final AcademyModel academy;

  const _DashboardLayout({required this.academy});

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;

    if (isDesktop) {
      return _DesktopLayout(academy: academy);
    } else if (isTablet) {
      return _TabletLayout(academy: academy);
    }
    return _PhoneLayout(academy: academy);
  }
}

class _DesktopLayout extends StatelessWidget {
  final AcademyModel academy;

  const _DesktopLayout({required this.academy});

  @override
  Widget build(BuildContext context) {
    final academyId = academy.academyId;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: AcademyHeroSection(academy: academy)),
        SliverToBoxAdapter(child: AcademyStatsSection(academy: academy)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xl6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 7, child: AcademyBatchesSection(academyId: academyId)),
                const SizedBox(width: SpacingTokens.xl4),
                Expanded(flex: 5, child: AcademyAdvertisingSection(academy: academy)),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: AcademyPlacementsSection(academy: academy)),
        SliverToBoxAdapter(child: SizedBox(height: SpacingTokens.xl8)),
      ],
    );
  }
}

class _TabletLayout extends StatelessWidget {
  final AcademyModel academy;

  const _TabletLayout({required this.academy});

  @override
  Widget build(BuildContext context) {
    final academyId = academy.academyId;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: AcademyHeroSection(academy: academy)),
        SliverToBoxAdapter(child: AcademyStatsSection(academy: academy)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xl4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: AcademyBatchesSection(academyId: academyId)),
                const SizedBox(width: SpacingTokens.xl3),
                Expanded(child: AcademyAdvertisingSection(academy: academy)),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: AcademyPlacementsSection(academy: academy)),
        SliverToBoxAdapter(child: SizedBox(height: SpacingTokens.xl8)),
      ],
    );
  }
}

class _PhoneLayout extends StatelessWidget {
  final AcademyModel academy;

  const _PhoneLayout({required this.academy});

  @override
  Widget build(BuildContext context) {
    final academyId = academy.academyId;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: AcademyHeroSection(academy: academy)),
        SliverToBoxAdapter(child: AcademyStatsSection(academy: academy)),
        SliverToBoxAdapter(child: AcademyBatchesSection(academyId: academyId)),
        SliverToBoxAdapter(child: AcademyAdvertisingSection(academy: academy)),
        SliverToBoxAdapter(child: AcademyPlacementsSection(academy: academy)),
        SliverToBoxAdapter(child: SizedBox(height: SpacingTokens.xl8)),
      ],
    );
  }
}
