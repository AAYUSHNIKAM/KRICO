import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../design_system/colors/app_colors.dart';
import '../../../../../design_system/typography/text_styles.dart';
import '../../../../../design_system/spacing/spacing_scale.dart';
import '../../../../../design_system/radius/radius.dart';
import '../../../../../design_system/responsive/responsive_helpers.dart';
import '../../../../../services/providers.dart';
import '../../../../../models/academy_model.dart';
import 'dashboard_loading.dart';
import 'dashboard_empty_state.dart';

class AcademyPlacementsSection extends ConsumerWidget {
  final AcademyModel academy;

  const AcademyPlacementsSection({super.key, required this.academy});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placementsAsync = ref.watch(academyPlacementsProvider(academy.academyId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;
    final padH = isDesktop ? SpacingScale.s32 : (isTablet ? SpacingScale.s24 : SpacingScale.s16);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: SpacingScale.s24),
          _SectionHeader(
            title: 'Coach Placements',
            icon: Icons.work_history_rounded,
            color: AppColors.success,
            isDark: isDark,
            total: academy.coachPlacements,
          ),
          const SizedBox(height: SpacingScale.s12),
          placementsAsync.when(
            data: (snapshot) {
              final docs = snapshot.docs;
              if (docs.isEmpty) {
                return AcademyDashboardEmptyState(
                  icon: Icons.work_history_rounded,
                  title: 'No placements yet',
                  subtitle: 'Start promoting your coaches to get placements!',
                  accentColor: AppColors.success,
                );
              }
              return Container(
                padding: const EdgeInsets.all(SpacingScale.s16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.card : AppColors.lightCard,
                  borderRadius: AppRadius.brXl3,
                  border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder, width: 0.5),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.work_history_rounded, color: AppColors.primary),
                        const SizedBox(width: SpacingScale.s8),
                        Text('Recent Placements',
                            style: AppTextStyles.title3.copyWith(fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary)),
                        const Spacer(),
                        Text('Total: ${academy.coachPlacements}',
                            style: AppTextStyles.caption.copyWith(
                                color: AppColors.success, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: SpacingScale.s16),
                    Column(
                      children: docs.take(5).map((doc) {
                        final d = doc.data();
                        final coachId = d['coachId'] as String? ?? '';
                        final ts = d['placedAt'] as Timestamp?;
                        final timeStr = ts != null ? _formatPlacementTime(ts.toDate()) : '';
                        return _PlacementRow(coachId: coachId, timeStr: timeStr);
                      }).toList(),
                    ),
                  ],
                ),
              ).animate(delay: 400.ms).fadeIn(duration: 350.ms).slideY(begin: 0.06, end: 0);
            },
            loading: () => const AcademyDashboardSectionShimmer(height: 200),
            error: (e, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: SpacingScale.s8),
              child: Text('Failed to load placements',
                  style: AppTextStyles.body.copyWith(color: AppColors.danger)),
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool isDark;
  final int? total;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
    required this.isDark,
    this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: AppRadius.brLg,
        ),
        child: Icon(icon, size: 18, color: color),
      ),
      SizedBox(width: SpacingScale.s10),
      Expanded(
        child: Text(title, style: AppTextStyles.title2.copyWith(
          color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
          fontWeight: FontWeight.w600,
        )),
      ),
      if (total != null)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s8, vertical: SpacingScale.s2),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: AppRadius.brFull,
          ),
          child: Text('$total',
              style: AppTextStyles.labelSm.copyWith(color: AppColors.success, fontWeight: FontWeight.w600)),
        ),
    ]);
  }
}

class _PlacementRow extends ConsumerWidget {
  final String coachId;
  final String timeStr;

  const _PlacementRow({required this.coachId, required this.timeStr});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final coachAsync = coachId.isNotEmpty ? ref.watch(coachProvider(coachId)) : null;
    String displayName = coachId.isEmpty ? 'Unknown' : coachId;
    if (coachAsync != null) {
      final coach = coachAsync.asData?.value;
      if (coach != null) {
        displayName = coach.name;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingScale.s10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: AppRadius.brLg,
            ),
            child: const Icon(Icons.person_rounded, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: SpacingScale.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName,
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500, color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary)),
                if (timeStr.isNotEmpty)
                  Text(timeStr,
                      style: AppTextStyles.caption.copyWith(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
        ],
      ),
    );
  }
}
