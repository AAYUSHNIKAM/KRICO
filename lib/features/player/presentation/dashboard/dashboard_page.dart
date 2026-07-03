import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/typography/text_styles.dart';
import '../../../../design_system/spacing/spacing_scale.dart';
import '../../../../design_system/responsive/responsive_helpers.dart';
import '../../../../design_system/radius/radius.dart';
import '../../../../design_system/widgets/buttons/primary_button.dart';
import '../../../../models/user_model.dart';
import '../../../../services/providers.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/dashboard_kpi_section.dart';
import 'widgets/dashboard_performance_section.dart';
import 'widgets/dashboard_sessions_section.dart';
import 'widgets/dashboard_coach_carousel.dart';
import 'widgets/dashboard_quick_actions.dart';
import 'widgets/dashboard_community_preview.dart';
import 'widgets/dashboard_achievement_section.dart';
import 'widgets/dashboard_activity_timeline.dart';
import 'widgets/dashboard_loading.dart';

class DashboardPage extends ConsumerWidget {
  final UserModel userModel;

  const DashboardPage({super.key, required this.userModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerId = userModel.uid;
    final playerAsync = ref.watch(playerProvider(playerId));

    return Scaffold(
      body: playerAsync.when(
        data: (_) => _DashboardLayout(playerId: playerId),
        loading: () => const _LoadingLayout(),
        error: (_, __) => _ErrorLayout(
          onRetry: () => ref.invalidate(playerProvider(playerId)),
        ),
      ),
    );
  }
}

class _DashboardLayout extends StatelessWidget {
  final String playerId;

  const _DashboardLayout({required this.playerId});

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: DashboardHeader(playerId: playerId)),
        SliverToBoxAdapter(child: DashboardKpiSection(playerId: playerId)),
        SliverToBoxAdapter(child: DashboardQuickActions()),
        SliverToBoxAdapter(child: DashboardPerformanceSection(playerId: playerId)),
        SliverToBoxAdapter(child: DashboardSessionsSection(playerId: playerId)),
        SliverToBoxAdapter(child: DashboardCoachCarousel(playerId: playerId)),
        SliverToBoxAdapter(child: DashboardAchievementSection(playerId: playerId)),
        SliverToBoxAdapter(child: DashboardCommunityPreview()),
        SliverToBoxAdapter(child: DashboardActivityTimeline(playerId: playerId)),
        SliverToBoxAdapter(child: SizedBox(height: isDesktop ? SpacingScale.s48 : SpacingScale.s32)),
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
        DashboardKpiShimmer(),
        DashboardSectionShimmer(height: 200),
        DashboardSectionShimmer(height: 320),
        DashboardSectionShimmer(height: 200),
        DashboardSectionShimmer(height: 130),
        DashboardSectionShimmer(height: 160),
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
        padding: const EdgeInsets.all(SpacingScale.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                borderRadius: AppRadius.brXl2,
              ),
              child: const Icon(Icons.error_outline_rounded, size: 28, color: AppColors.danger),
            ),
            const SizedBox(height: SpacingScale.s16),
            Text('Something went wrong', style: AppTextStyles.heading3.copyWith(
              color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
            )),
            const SizedBox(height: SpacingScale.s8),
            Text("We couldn't load your dashboard. Please try again.", style: AppTextStyles.body.copyWith(
              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
            ), textAlign: TextAlign.center),
            const SizedBox(height: SpacingScale.s24),
            PrimaryButton(onPressed: onRetry, label: 'Retry'),
          ],
        ),
      ),
    );
  }
}
