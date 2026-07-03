import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../models/coach_model.dart';
import '../../../services/providers.dart';

class CoachAcademyJobsScreen extends ConsumerWidget {
  final String coachId;
  const CoachAcademyJobsScreen({super.key, required this.coachId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coachAsync = ref.watch(coachProvider(coachId));
    final coach = coachAsync.asData?.value;
    final jobsAsync = ref.watch(coachJobsProvider);
    final applicationsAsync = ref.watch(coachApplicationsProvider(coachId));
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.gradientAccent,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Academy Jobs',
                        style: AppTextStyles.headlineMedium.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                    Text('Find coaching opportunities',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.7))),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                jobsAsync.when(
                  data: (snapshot) {
                    final docs = snapshot.docs;
                    if (docs.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.work_off_rounded, size: 48, color: AppColors.textDim),
                            const SizedBox(height: 12),
                            Text('No jobs posted yet',
                                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            Text('Check back later for new opportunities',
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDim)),
                          ],
                        ),
                      );
                    }
                    final appliedJobs = <String>{};
                    final jobStatuses = <String, String>{};
                    final applicationsData = applicationsAsync.asData?.value;
                    if (applicationsData != null) {
                      for (final app in applicationsData.docs) {
                        final appData = app.data();
                        final jobId = appData['jobId'] as String? ?? '';
                        appliedJobs.add(jobId);
                        final status = appData['status'] as String?;
                        if (status != null) jobStatuses[jobId] = status;
                      }
                    }
                    return Column(
                      children: docs.map((doc) {
                        final d = doc.data();
                        final jobId = doc.id;
                        final hasApplied = appliedJobs.contains(jobId);
                        final appStatus = jobStatuses[jobId];
                        return _buildJobCard(context, ref, coach, doc.id, d, hasApplied, appStatus);
                      }).toList(),
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (e, _) {
                    debugPrint('Coach jobs error: $e');
                    return Container(
                      padding: const EdgeInsets.all(40),
                      child: Text('Unable to load jobs right now.',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
                    );
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, WidgetRef ref, CoachModel? coach, String jobId, Map<String, dynamic> d, [bool hasApplied = false, String? appStatus]) {
    final title = d['title'] as String? ?? 'Coaching Position';
    final sport = d['sport'] as String? ?? 'General';
    final location = d['location'] as String? ?? 'Remote';
    final salary = d['salary'] as String? ?? 'Negotiable';
    final experience = d['experience'] as String? ?? 'Fresher';
    final description = d['description'] as String? ?? '';
    final perks = d['perks'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.sports_rounded, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text('$sport \u2022 $location',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(salary,
                    style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.success, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildJobTag(Icons.work_history_rounded, experience, AppColors.info),
              if (perks.isNotEmpty)
                _buildJobTag(Icons.card_giftcard_rounded, perks, AppColors.accent),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(description,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 14),
          hasApplied
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _statusColor(appStatus).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _statusColor(appStatus).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_statusIcon(appStatus), size: 16, color: _statusColor(appStatus)),
                      const SizedBox(width: 6),
                      Text(appStatus != null ? _capitalize(appStatus) : 'Applied',
                          style: AppTextStyles.labelLarge.copyWith(color: _statusColor(appStatus), fontWeight: FontWeight.w600)),
                    ],
                  ),
                )
              : GradientButton(
                  onPressed: coach != null
                      ? () => _applyForJob(context, ref, coach, jobId, title)
                      : null,
                  height: 40,
                  borderRadius: 10,
                  child: Text('Apply Now',
                      style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
                ),
        ],
      ),
    );
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'applied': return AppColors.info;
      case 'under_review': return AppColors.warning;
      case 'interview_scheduled': return AppColors.accent;
      case 'accepted': return AppColors.success;
      case 'rejected': return AppColors.error;
      case 'need_more_info': return AppColors.warning;
      default: return AppColors.textSecondary;
    }
  }

  IconData _statusIcon(String? status) {
    switch (status) {
      case 'applied': return Icons.send_rounded;
      case 'under_review': return Icons.visibility_rounded;
      case 'interview_scheduled': return Icons.calendar_today_rounded;
      case 'accepted': return Icons.check_circle_rounded;
      case 'rejected': return Icons.cancel_rounded;
      case 'need_more_info': return Icons.info_rounded;
      default: return Icons.hourglass_empty_rounded;
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s.split('_').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
  }

  Widget _buildJobTag(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: AppTextStyles.caption.copyWith(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _applyForJob(BuildContext context, WidgetRef ref, CoachModel coach, String jobId, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceMid,
        title: const Text('Apply for Position'),
        content: Text('Apply for "$title"? Your profile will be shared with the academy.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          GradientButton(
            onPressed: () {
              ref.read(academyServiceProvider).applyForJob(
                jobId,
                coach.coachId,
                coach.name,
                coach.email,
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Applied for "$title" successfully!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            height: 38,
            child: const Text('Confirm Apply', style: TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}