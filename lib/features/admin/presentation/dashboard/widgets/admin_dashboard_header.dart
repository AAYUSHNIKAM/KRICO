import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../design_system/colors/app_colors.dart';
import '../../../../../design_system/typography/text_styles.dart';
import '../../../../../design_system/spacing/spacing_scale.dart';
import '../../../../../design_system/radius/radius.dart';
import '../../../../../design_system/responsive/responsive_helpers.dart';
import '../../../../../services/providers.dart';

class AdminDashboardHeader extends ConsumerWidget {
  const AdminDashboardHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tasksAsync = ref.watch(adminTasksProvider);
    final taskList = tasksAsync.asData?.value.docs ?? [];

    if (context.isPhone) {
      return SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surface : AppColors.lightSurface,
            border: Border(
              bottom: BorderSide(color: isDark ? AppColors.border : AppColors.lightBorder, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Platform Control', style: AppTextStyles.caption.copyWith(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
                    const SizedBox(height: 2),
                    Text('Admin Dashboard',
                        style: AppTextStyles.title2.copyWith(
                          color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if (taskList.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: AppRadius.brFull,
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 14, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text('${taskList.length} Tasks', style: AppTextStyles.labelSm.copyWith(color: AppColors.warning, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: isDark ? AppColors.surface : AppColors.lightSurface,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: isDark ? AppColors.surface : AppColors.lightSurface,
          padding: EdgeInsets.fromLTRB(SpacingScale.s20, SpacingScale.s56, SpacingScale.s20, SpacingScale.s20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Admin Dashboard', style: AppTextStyles.body.copyWith(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
                      SizedBox(height: SpacingScale.s4),
                      Text('Platform Control', style: AppTextStyles.heading2.copyWith(color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary).withValues(alpha: 0.12),
                      borderRadius: AppRadius.brLg,
                      border: Border.all(color: (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary).withValues(alpha: 0.08)),
                    ),
                    child: Icon(Icons.admin_panel_settings_rounded, color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: SpacingScale.s12, vertical: SpacingScale.s6),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: AppRadius.brXl2,
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 16, color: AppColors.warning),
                    SizedBox(width: SpacingScale.s6),
                    Text('${taskList.length} Pending Tasks', style: AppTextStyles.label.copyWith(color: AppColors.warning, fontWeight: FontWeight.w600)),
                  ],
                ),
              ).animate().shake(duration: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}
