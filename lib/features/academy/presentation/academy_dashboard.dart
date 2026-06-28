import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/stats_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/providers.dart';
import '../../../models/academy_model.dart';

class AcademyDashboard extends ConsumerWidget {
  const AcademyDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateProvider);
    return authAsync.when(
      data: (firebaseUser) {
        if (firebaseUser == null) {
          return Scaffold(
            body: Center(
              child: Text('Please sign in to view your dashboard',
                  style: AppTextStyles.bodyLarge),
            ),
          );
        }
        final academyAsync =
            ref.watch(academyProvider(firebaseUser.uid));
        return academyAsync.when(
          data: (academy) =>
              _AcademyDashboardContent(academy: academy),
          loading: () => const _DashboardLoading(),
          error: (e, _) => Scaffold(
            body: Center(
                child: Text('Error: $e', style: AppTextStyles.bodyLarge)),
          ),
        );
      },
      loading: () => const _DashboardLoading(),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e', style: AppTextStyles.bodyLarge)),
      ),
    );
  }
}

class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _AcademyDashboardContent extends ConsumerWidget {
  const _AcademyDashboardContent({required this.academy});

  final AcademyModel academy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.of(context).size.width > 600;
    final batchesStream =
        ref.watch(academyServiceProvider).getBatches(academy.academyId);
    final activeCoachesAsync = ref.watch(activeCoachesCountProvider(academy.academyId));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.gradientAccent,
                  ),
                ),
                padding: EdgeInsets.fromLTRB(
                    20, MediaQuery.of(context).padding.top + 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 2),
                          ),
                          child: academy.logoUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(academy.logoUrl!,
                                      fit: BoxFit.cover),
                                )
                              : Icon(Icons.business_rounded,
                                  size: 26,
                                  color: Colors.white.withValues(alpha: 0.8)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Academy Dashboard',
                                  style: AppTextStyles.bodySmall.copyWith(
                                      color: Colors.white
                                          .withValues(alpha: 0.7))),
                              const SizedBox(height: 2),
                              Text(academy.name,
                                  style: AppTextStyles.headlineMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700)),
                              if (academy.sports != null &&
                                  academy.sports!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                      academy.sports!.join(', '),
                                      style: AppTextStyles.bodySmall.copyWith(
                                          color: Colors.white
                                              .withValues(alpha: 0.7))),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (academy.isVerified)
                            Icon(Icons.verified_rounded,
                                size: 16, color: AppColors.primary),
                          if (academy.isVerified) const SizedBox(width: 6),
                          Text(
                            academy.isVerified
                                ? 'Verified Academy'
                                : 'Pending Verification',
                            style: AppTextStyles.labelMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildStatsSection(isWide, activeCoachesAsync),
                const SizedBox(height: 8),
                const SectionHeader(
                    title: 'Active Batches', actionLabel: 'Manage'),
                const SizedBox(height: 8),
                Animate(
                  effects: const [
                    FadeEffect(duration: Duration(milliseconds: 400), delay: Duration(milliseconds: 100)),
                    SlideEffect(begin: Offset(0, 0.05), end: Offset.zero, duration: Duration(milliseconds: 400), delay: Duration(milliseconds: 100)),
                  ],
                  child: _buildBatchesList(context, ref, batchesStream),
                ),
                const SizedBox(height: 8),
                const SectionHeader(title: 'Advertising Suite'),
                const SizedBox(height: 8),
                Animate(
                  effects: const [
                    FadeEffect(duration: Duration(milliseconds: 400), delay: Duration(milliseconds: 200)),
                    SlideEffect(begin: Offset(0, 0.05), end: Offset.zero, duration: Duration(milliseconds: 400), delay: Duration(milliseconds: 200)),
                  ],
                  child: _buildAdCard(context, ref),
                ),
                const SizedBox(height: 8),
                const SectionHeader(title: 'Coach Placements'),
                const SizedBox(height: 8),
                Animate(
                  effects: const [
                    FadeEffect(duration: Duration(milliseconds: 400), delay: Duration(milliseconds: 300)),
                    SlideEffect(begin: Offset(0, 0.05), end: Offset.zero, duration: Duration(milliseconds: 400), delay: Duration(milliseconds: 300)),
                  ],
                  child: _buildPlacementCard(context, ref),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(bool isWide, AsyncValue<int> activeCoachesAsync) {
    return Animate(
      effects: const [
        FadeEffect(duration: Duration(milliseconds: 400)),
        SlideEffect(begin: Offset(0, 0.05), end: Offset.zero, duration: Duration(milliseconds: 400)),
      ],
      child: activeCoachesAsync.when(
        data: (activeCoaches) => isWide
            ? _buildWideStatsRow(activeCoaches)
            : _buildMobileStats(activeCoaches),
        loading: () => isWide
            ? _buildWideStatsRow(0)
            : _buildMobileStats(0),
        error: (_, __) => isWide
            ? _buildWideStatsRow(0)
            : _buildMobileStats(0),
      ),
    );
  }

  Widget _buildWideStatsRow(int activeCoaches) {
    return Row(
      children: [
        Expanded(child: StatsCard(label: 'Total Students', value: academy.totalStudents.toString(), icon: Icons.people_rounded, iconColor: AppColors.primary)),
        const SizedBox(width: 12),
        Expanded(child: StatsCard(label: 'Active Coaches', value: '$activeCoaches', icon: Icons.sports_rounded, iconColor: AppColors.success)),
        const SizedBox(width: 12),
        Expanded(child: StatsCard(label: 'Reputation Points', value: academy.reputationPoints.toString(), icon: Icons.workspace_premium_rounded, iconColor: AppColors.gold, gradient: AppColors.gradientAccent)),
        const SizedBox(width: 12),
        Expanded(child: StatsCard(label: 'Placements', value: academy.coachPlacements.toString(), icon: Icons.work_rounded, iconColor: AppColors.info)),
      ],
    );
  }

  Widget _buildMobileStats(int activeCoaches) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: StatsCard(label: 'Total Students', value: academy.totalStudents.toString(), icon: Icons.people_rounded, iconColor: AppColors.primary)),
            const SizedBox(width: 12),
            Expanded(child: StatsCard(label: 'Active Coaches', value: '$activeCoaches', icon: Icons.sports_rounded, iconColor: AppColors.success)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: StatsCard(label: 'Reputation Points', value: academy.reputationPoints.toString(), icon: Icons.workspace_premium_rounded, iconColor: AppColors.gold, gradient: AppColors.gradientAccent)),
            const SizedBox(width: 12),
            Expanded(child: StatsCard(label: 'Placements', value: academy.coachPlacements.toString(), icon: Icons.work_rounded, iconColor: AppColors.info)),
          ],
        ),
      ],
    );
  }

  Widget _buildBatchesList(BuildContext context, WidgetRef ref, Stream<QuerySnapshot<Map<String, dynamic>>> batchesStream) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: batchesStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text('Failed to load batches',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
            ),
          );
        }
        if (!snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              ),
            ),
          );
        }
        final batches = snapshot.data!.docs;
        if (batches.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.sports_kabaddi_rounded, size: 40, color: AppColors.textSecondary),
                  const SizedBox(height: 8),
                  Text('No active batches yet',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          );
        }
        return Column(
          children: batches.map((doc) {
            final data = doc.data();
            return _buildBatchCard(
              context, ref,
              data['name'] as String? ?? 'Untitled',
              '${data['enrolled'] ?? 0}/${data['capacity'] ?? 0}',
              data['schedule'] as String? ?? 'TBD',
              data['sport'] as String? ?? '',
              doc.id,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildBatchCard(BuildContext context, WidgetRef ref, String name,
      String students, String time, String sport, String batchId) {
    final colorMap = {
      'Cricket': AppColors.primary,
      'Swimming': AppColors.success,
      'Tennis': AppColors.warning,
      'Football': AppColors.info,
      'Basketball': AppColors.accent,
    };
    final color = colorMap.entries.firstWhere(
      (e) => sport.toLowerCase().contains(e.key.toLowerCase()),
      orElse: () => MapEntry('', AppColors.primary),
    ).value;
    final iconMap = {
      'Cricket': Icons.sports_cricket_rounded,
      'Swimming': Icons.pool_rounded,
      'Tennis': Icons.sports_tennis_rounded,
      'Football': Icons.sports_football_rounded,
      'Basketball': Icons.sports_basketball_rounded,
    };
    final icon = iconMap.entries.firstWhere(
      (e) => sport.toLowerCase().contains(e.key.toLowerCase()),
      orElse: () => MapEntry('', Icons.sports_kabaddi_rounded),
    ).value;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('$students students · $time',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          InkWell(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Viewing batch: $name')),
            ),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('View',
                  style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdCard(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondary.withValues(alpha: 0.08),
            AppColors.secondaryLight.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.campaign_rounded, color: AppColors.secondary),
              const SizedBox(width: 8),
              Text('Promote Your Academy',
                  style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildAdOption(context, 'Product Ads', Icons.shopping_bag_rounded, AppColors.secondary)),
              const SizedBox(width: 8),
              Expanded(child: _buildAdOption(context, 'Social Boost', Icons.share_rounded, AppColors.info)),
              const SizedBox(width: 8),
              Expanded(child: _buildAdOption(context, 'Community', Icons.groups_rounded, AppColors.success)),
            ],
          ),
          const SizedBox(height: 12),
          GradientButton(
            onPressed: () => _showCreateCampaignDialog(context, ref),
            height: 42,
            gradient: AppColors.gradientSecondary,
            child: const Text('Create Campaign',
                style: TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildAdOption(BuildContext context, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showCreateCampaignDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final budgetCtrl = TextEditingController();
    String selectedType = 'Product Ads';
    final service = ref.read(academyServiceProvider);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceMid,
          title: const Text('Create Campaign'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedType,
                  dropdownColor: AppColors.surfaceMid,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Campaign Type',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Product Ads', 'Social Boost', 'Community']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedType = v ?? 'Product Ads'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Campaign Name',
                    hintText: 'e.g. Summer Cricket Camp',
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: budgetCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Budget (₹)',
                    hintText: 'e.g. 5000',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            GradientButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty && budgetCtrl.text.isNotEmpty) {
                  service.createCampaign(
                    academyId: academy.academyId,
                    name: nameCtrl.text.trim(),
                    budget: double.tryParse(budgetCtrl.text) ?? 0,
                    type: selectedType,
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Campaign "${nameCtrl.text}" created!')),
                  );
                }
              },
              height: 38,
              child: const Text('Create', style: TextStyle(color: Colors.white, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlacementCard(BuildContext context, WidgetRef ref) {
    final placementsAsync = ref.watch(academyPlacementsProvider(academy.academyId));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.work_history_rounded, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Recent Placements',
                  style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('Total: ${academy.coachPlacements}',
                  style: AppTextStyles.caption.copyWith(
                      color: AppColors.success, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          placementsAsync.when(
            data: (snapshot) {
              final docs = snapshot.docs;
              if (docs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text('No placements yet. Start promoting your coaches!',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                );
              }
              return Column(
                children: docs.take(5).map((doc) {
                  final d = doc.data();
                  final coachId = d['coachId'] as String? ?? '';
                  final ts = d['placedAt'] as Timestamp?;
                  final timeStr = ts != null ? _formatPlacementTime(ts.toDate()) : '';
                  return _PlacementRow(coachId: coachId, timeStr: timeStr);
                }).toList(),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('Failed to load placements',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPlacementTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 30) return '${diff.inDays} days ago';
    if (diff.inDays < 60) return '1 month ago';
    return '${diff.inDays ~/ 30} months ago';
  }
}

class _PlacementRow extends ConsumerWidget {
  final String coachId;
  final String timeStr;

  const _PlacementRow({required this.coachId, required this.timeStr});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coachAsync = coachId.isNotEmpty ? ref.watch(coachProvider(coachId)) : null;
    String displayName = coachId.isEmpty ? 'Unknown' : coachId;
    if (coachAsync != null) {
      final coach = coachAsync.asData?.value;
      if (coach != null) {
        displayName = coach.name;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.person_rounded, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName,
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
                if (timeStr.isNotEmpty)
                  Text(timeStr,
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
