import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../services/providers.dart';

class AcademyJobsTab extends ConsumerWidget {
  final String academyId;
  const AcademyJobsTab({super.key, required this.academyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(academyJobsProvider(academyId));
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
                padding: EdgeInsets.fromLTRB(
                    20, MediaQuery.of(context).padding.top + 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Job Postings',
                        style: AppTextStyles.headlineMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                    Text('Post and manage coaching positions',
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
                GradientButton(
                  onPressed: () => _showPostJobDialog(context, ref),
                  gradient: AppColors.gradientAccent,
                  child: const Text('Post New Job',
                      style: TextStyle(color: Colors.white, fontSize: 13)),
                ),
                const SizedBox(height: 16),
                Text('Active Listings',
                    style: AppTextStyles.titleMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
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
                            Icon(Icons.work_off_rounded,
                                size: 48, color: AppColors.textDim),
                            const SizedBox(height: 12),
                            Text('No jobs posted yet',
                                style: AppTextStyles.bodyLarge
                                    .copyWith(color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            Text('Post your first coaching position',
                                style: AppTextStyles.bodyMedium
                                    .copyWith(color: AppColors.textDim)),
                          ],
                        ),
                      );
                    }
                    return Column(
                      children: docs.asMap().entries.map((entry) {
                        final i = entry.key;
                        final doc = entry.value;
                        final d = doc.data();
                        return _buildJobCard(context, ref, doc.id, d)
                            .animate()
                            .fadeIn(
                                duration: const Duration(milliseconds: 300),
                                delay: Duration(milliseconds: i * 50));
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
                    debugPrint('Academy jobs error: $e');
                    return Container(
                      padding: const EdgeInsets.all(40),
                      child: Text('Unable to load jobs right now.',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.error)),
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

  Widget _buildJobCard(
      BuildContext context, WidgetRef ref, String jobId, Map<String, dynamic> d) {
    final title = d['title'] as String? ?? 'Coaching Position';
    final sport = d['sport'] as String? ?? 'General';
    final location = d['location'] as String? ?? 'Remote';
    final salary = d['salary'] as String? ?? 'Negotiable';
    final experience = d['experience'] as String? ?? 'Fresher';
    final description = d['description'] as String? ?? '';
    final perks = d['perks'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.sports_rounded,
                    color: AppColors.accent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTextStyles.titleSmall
                            .copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text('$sport \u2022 $location',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(salary,
                    style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildTag(Icons.work_history_rounded, experience, AppColors.info),
              const SizedBox(width: 6),
              if (perks.isNotEmpty)
                _buildTag(Icons.card_giftcard_rounded, perks, AppColors.accent),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(description,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ],
      ),
    );
  }

  Widget _buildTag(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(label,
              style: AppTextStyles.caption.copyWith(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showPostJobDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final sportController = TextEditingController();
    final locationController = TextEditingController();
    final salaryController = TextEditingController();
    final experienceController = TextEditingController();
    final descController = TextEditingController();
    final perksController = TextEditingController();
    final service = ref.read(academyServiceProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceMid,
        title: const Text('Post a Job'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Job Title *',
                  hintText: 'e.g. Cricket Coach',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: sportController,
                decoration: const InputDecoration(
                  labelText: 'Sport *',
                  hintText: 'e.g. Cricket, Football',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location *',
                  hintText: 'e.g. Mumbai',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: salaryController,
                decoration: const InputDecoration(
                  labelText: 'Salary',
                  hintText: 'e.g. ₹30,000/mo',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: experienceController,
                decoration: const InputDecoration(
                  labelText: 'Experience Required',
                  hintText: 'e.g. 2+ years',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe the role...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: perksController,
                decoration: const InputDecoration(
                  labelText: 'Perks',
                  hintText: 'e.g. Accommodation, Transport',
                  border: OutlineInputBorder(),
                ),
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
              if (titleController.text.trim().isNotEmpty &&
                  sportController.text.trim().isNotEmpty &&
                  locationController.text.trim().isNotEmpty) {
                service.postJob(
                  academyId: academyId,
                  title: titleController.text.trim(),
                  sport: sportController.text.trim(),
                  location: locationController.text.trim(),
                  salary: salaryController.text.trim().isNotEmpty
                      ? salaryController.text.trim()
                      : 'Negotiable',
                  experience: experienceController.text.trim().isNotEmpty
                      ? experienceController.text.trim()
                      : 'Fresher',
                  description: descController.text.trim(),
                  perks: perksController.text.trim(),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Job "${titleController.text.trim()}" posted!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            height: 38,
            child: const Text('Post Job',
                style: TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
