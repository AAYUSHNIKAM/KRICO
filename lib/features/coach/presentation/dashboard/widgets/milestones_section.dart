import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../design_system/colors/app_colors.dart';
import '../../../../../design_system/typography/text_styles.dart';
import '../../../../../design_system/spacing/spacing_scale.dart';
import '../../../../../design_system/radius/radius.dart';
import '../../../../../design_system/responsive/responsive_helpers.dart';
import '../../../../../design_system/tokens/duration_tokens.dart';
import '../../../../../design_system/widgets/buttons/primary_button.dart';
import '../../../../../design_system/widgets/buttons/button_types.dart';
import '../../../../../services/providers.dart';
import 'dashboard_loading.dart';
import 'dashboard_empty_state.dart';

class CoachMilestonesSection extends ConsumerWidget {
  final String coachId;

  const CoachMilestonesSection({super.key, required this.coachId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final milestonesAsync = ref.watch(coachMilestonesProvider(coachId));
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;
    final padH = isDesktop ? SpacingScale.s32 : (isTablet ? SpacingScale.s24 : SpacingScale.s16);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: isDesktop ? SpacingScale.s28 : SpacingScale.s24),
          milestonesAsync.when(
            data: (snap) {
              final milestones = snap.docs;
              return _MilestonesContent(coachId: coachId, milestones: milestones);
            },
            loading: () => const CoachDashboardSectionShimmer(height: 200),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _MilestonesContent extends ConsumerWidget {
  final String coachId;
  final List<dynamic> milestones;

  const _MilestonesContent({
    required this.coachId,
    required this.milestones,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl3,
        border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(SpacingScale.s24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: AppRadius.brLg,
                  ),
                  child: const Icon(Icons.timeline_rounded, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: SpacingScale.s10),
                Expanded(
                  child: Text('Career Milestones', style: AppTextStyles.title2.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  )),
                ),
                PrimaryButton(
                  onPressed: () => _showAddMilestoneDialog(context, ref),
                  label: 'Add',
                  icon: Icons.add_rounded,
                  size: ButtonSize.sm,
                ),
              ],
            ),
            const SizedBox(height: SpacingScale.s20),
            if (milestones.isEmpty)
              CoachDashboardEmptyState(
                icon: Icons.flag_outlined,
                title: 'No Milestones Yet',
                subtitle: 'Add your first career milestone to track your progress.',
                actionLabel: 'Add Milestone',
                onActionTap: () => _showAddMilestoneDialog(context, ref),
                accentColor: AppColors.primary,
              )
            else
              Column(
                children: milestones.map((doc) {
                  final d = (doc as QueryDocumentSnapshot).data() as Map<String, dynamic>;
                  final label = d['label'] as String? ?? '';
                  final done = d['done'] as bool? ?? false;
                  return _MilestoneItem(
                    id: doc.id,
                    label: label,
                    done: done,
                    coachId: coachId,
                    index: milestones.indexOf(doc),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    ).animate(delay: 300.ms).fadeIn(duration: 350.ms).slideY(begin: 0.06, end: 0);
  }

  void _showAddMilestoneDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surface : AppColors.lightSurface,
        title: Text('Add Milestone', style: TextStyle(
          color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
        )),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'e.g., Complete 100 Sessions',
            hintStyle: TextStyle(
              color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
            ),
            border: const OutlineInputBorder(),
          ),
          style: TextStyle(
            color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(
              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
            )),
          ),
          PrimaryButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(coachServiceProvider).addMilestone(coachId, controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            label: 'Add',
          ),
        ],
      ),
    );
  }
}

class _MilestoneItem extends ConsumerWidget {
  final String id;
  final String label;
  final bool done;
  final String coachId;
  final int index;

  const _MilestoneItem({
    required this.id,
    required this.label,
    required this.done,
    required this.coachId,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final secColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingScale.s10),
      child: Row(
        children: [
          GestureDetector(
            onTap: done ? null : () => ref.read(coachServiceProvider).completeMilestone(id),
            child: AnimatedContainer(
              duration: DurationTokens.medium,
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: done ? AppColors.emerald : (isDark ? AppColors.border : AppColors.lightBorder),
                shape: BoxShape.circle,
              ),
              child: Icon(
                done ? Icons.check : Icons.close,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: SpacingScale.s12),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: done ? AppColors.emerald : textColor,
                fontWeight: FontWeight.w500,
                decoration: done ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, size: 18, color: secColor),
            onPressed: () => ref.read(coachServiceProvider).deleteMilestone(id),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 300 + index * 60))
      .fadeIn(duration: 300.ms)
      .slideY(begin: 0.04, end: 0);
  }
}
