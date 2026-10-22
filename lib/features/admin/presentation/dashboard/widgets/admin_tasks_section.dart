import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../design_system/colors/app_colors.dart';
import '../../../../../design_system/typography/text_styles.dart';
import '../../../../../design_system/spacing/spacing_scale.dart';
import '../../../../../design_system/radius/radius.dart';
import '../../../../../services/providers.dart';
import 'admin_section_header.dart';

class AdminTasksSection extends ConsumerWidget {
  const AdminTasksSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tasksAsync = ref.watch(adminTasksProvider);
    final taskList = tasksAsync.asData?.value.docs ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminSectionHeader(
          title: 'Task Master',
          subtitle: 'Active Queues',
          showViewAll: true,
          onViewAll: () => _showAllTasksModal(context, taskList, isDark),
        ),
        SizedBox(height: SpacingScale.s12),
        if (taskList.isEmpty)
          Container(
            padding: EdgeInsets.all(SpacingScale.s24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.card : AppColors.lightCard,
              borderRadius: AppRadius.brXl3,
              border: Border.all(color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5)),
            ),
            child: Center(
              child: Text('No tasks pending in admin queue', style: AppTextStyles.body.copyWith(color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary)),
            ),
          )
        else
          ...taskList.map((doc) => _AdminTaskCard(doc: doc, isDark: isDark)).toList().animate(interval: 100.ms).fade(),
      ],
    );
  }

  void _showAllTasksModal(BuildContext context, List<QueryDocumentSnapshot<Map<String, dynamic>>> tasks, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
        padding: const EdgeInsets.all(SpacingScale.s20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.card : AppColors.lightCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('All Admin Tasks (${tasks.length})', style: AppTextStyles.heading3.copyWith(color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary)),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: SpacingScale.s12),
            Expanded(
              child: tasks.isEmpty
                  ? Center(child: Text('No tasks found in queue', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)))
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, i) => _AdminTaskCard(doc: tasks[i], isDark: isDark),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminTaskCard extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  final bool isDark;

  const _AdminTaskCard({required this.doc, required this.isDark});

  void _showTaskDetail(BuildContext context) {
    final data = doc.data();
    final title = data['title'] as String? ?? 'Untitled Task';
    final status = data['status'] as String? ?? 'Pending';
    final desc = data['description'] as String? ?? 'Review this administrative item for the Pune pilot platform.';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(SpacingScale.s20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.card : AppColors.lightCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Task Details', style: AppTextStyles.heading3.copyWith(color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary)),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: SpacingScale.s12),
            Text(title, style: AppTextStyles.title2.copyWith(fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary)),
            const SizedBox(height: SpacingScale.s8),
            Text(desc, style: AppTextStyles.body.copyWith(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
            const SizedBox(height: SpacingScale.s16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: AppRadius.brFull,
              ),
              child: Text('Current Status: $status', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.primary)),
            ),
            const SizedBox(height: SpacingScale.s20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance.collection('adminTasks').doc(doc.id).update({
                    'status': 'Resolved',
                    'updatedAt': FieldValue.serverTimestamp(),
                  });
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Task marked as Resolved!'), backgroundColor: AppColors.success),
                    );
                  }
                } catch (e) {
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating task: $e'), backgroundColor: AppColors.danger),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
              ),
              child: const Text('Mark as Resolved'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = doc.data();
    final title = data['title'] as String? ?? 'Untitled Task';
    final status = data['status'] as String? ?? 'Pending';
    final statusColors = {
      'Pending': AppColors.warning,
      'In Review': AppColors.primary,
      'Open': AppColors.danger,
      'Low': AppColors.success,
      'Resolved': AppColors.emerald,
    };
    final color = statusColors[status] ?? AppColors.primary;
    return Container(
      margin: EdgeInsets.only(bottom: SpacingScale.s8),
      padding: EdgeInsets.all(SpacingScale.s12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl3,
        border: Border.all(color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5)),
      ),
      child: InkWell(
        borderRadius: AppRadius.brXl3,
        onTap: () => _showTaskDetail(context),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: AppRadius.brLg,
              ),
              child: Icon(Icons.task_alt_rounded, color: color, size: 20),
            ),
            SizedBox(width: SpacingScale.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500, color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary)),
                  SizedBox(height: SpacingScale.s4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: SpacingScale.s8, vertical: SpacingScale.s2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: AppRadius.brLg,
                    ),
                    child: Text(status, style: AppTextStyles.caption.copyWith(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
          ],
        ),
      ),
    );
  }
}
