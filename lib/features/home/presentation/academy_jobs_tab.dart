import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../design_system/radius/radius.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../design_system/responsive/responsive_helpers.dart';
import '../../../services/providers.dart';

class AcademyJobsTab extends ConsumerWidget {
  final String academyId;
  const AcademyJobsTab({super.key, required this.academyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(academyJobsProvider(academyId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final jobsCount = jobsAsync.asData?.value.docs.length ?? 0;

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          _AcademyJobsHeroHeader(
            activeCount: jobsCount,
            onPostJob: () => _showPostJobDialog(context, ref),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              context.responsiveSpacing(SpacingScale.s16),
              SpacingScale.s16,
              context.responsiveSpacing(SpacingScale.s16),
              SpacingScale.s32,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Header with action bar
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.cyan,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'ACTIVE LISTINGS',
                            style: AppTextStyles.captionXs.copyWith(
                              color: AppColors.cyan,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => _showPostJobDialog(context, ref),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.volt, Color(0xFF99E600)],
                            ),
                            borderRadius: AppRadius.brFull,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.volt.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add_rounded, size: 16, color: Color(0xFF0F172A)),
                              const SizedBox(width: 6),
                              Text(
                                'Post Position',
                                style: AppTextStyles.labelSm.copyWith(
                                  color: const Color(0xFF0F172A),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                jobsAsync.when(
                  data: (snapshot) {
                    final docs = snapshot.docs;
                    if (docs.isEmpty) {
                      return _buildEmptyState(context, ref, isDark);
                    }
                    return Column(
                      children: docs.asMap().entries.map((entry) {
                        final i = entry.key;
                        final doc = entry.value;
                        final d = doc.data();
                        return _buildJobCard(context, ref, doc.id, d, isDark, academyId)
                            .animate()
                            .fadeIn(
                              duration: const Duration(milliseconds: 300),
                              delay: Duration(milliseconds: i * 50),
                            );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(color: AppColors.cyan),
                    ),
                  ),
                  error: (e, _) {
                    debugPrint('Academy jobs error: $e');
                    return Container(
                      padding: SpacingScale.cardLoose,
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.08),
                        borderRadius: AppRadius.brXl2,
                        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        'Unable to load vacancies right now.',
                        style: AppTextStyles.bodySm.copyWith(color: AppColors.danger),
                      ),
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

  Widget _buildEmptyState(BuildContext context, WidgetRef ref, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl3,
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cyan.withValues(alpha: 0.1),
              border: Border.all(color: AppColors.cyan.withValues(alpha: 0.25)),
            ),
            child: const Icon(Icons.work_outline_rounded, size: 34, color: AppColors.cyan),
          ),
          const SizedBox(height: 16),
          Text(
            'No Vacancies Active',
            style: AppTextStyles.title3.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Recruit qualified coaches and athletic specialists to grow your academy.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySm.copyWith(
              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 20),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _showPostJobDialog(context, ref),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.volt, Color(0xFF99E600)],
                  ),
                  borderRadius: AppRadius.brFull,
                ),
                child: Text(
                  'Create First Job Posting',
                  style: AppTextStyles.label.copyWith(
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(
    BuildContext context,
    WidgetRef ref,
    String jobId,
    Map<String, dynamic> d,
    bool isDark,
    String academyId,
  ) {
    final title = d['title'] as String? ?? 'Coaching Position';
    final sport = d['sport'] as String? ?? 'General';
    final location = d['location'] as String? ?? 'Remote';
    final salary = d['salary'] as String? ?? 'Negotiable';
    final experience = d['experience'] as String? ?? 'Fresher';
    final description = d['description'] as String? ?? '';
    final perks = d['perks'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl3,
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.lightBorder,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.cyan.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppRadius.brXl,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.sports_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTextStyles.title3.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'delete') {
                              ref.read(academyServiceProvider).deleteJob(jobId);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('"$title" closed'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_rounded, size: 16, color: AppColors.danger),
                                  SizedBox(width: 8),
                                  Text('Close Vacancy'),
                                ],
                              ),
                            ),
                          ],
                          icon: Icon(
                            Icons.more_vert_rounded,
                            size: 18,
                            color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$sport \u2022 $location',
                          style: AppTextStyles.bodySm.copyWith(
                            color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Telemetry and perks tags
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.volt.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.volt.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.payments_outlined, size: 13, color: AppColors.volt),
                    const SizedBox(width: 5),
                    Text(
                      salary,
                      style: AppTextStyles.captionXs.copyWith(
                        color: AppColors.volt,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _buildTag(Icons.work_history_rounded, experience, AppColors.cyan),
              if (perks.isNotEmpty)
                _buildTag(Icons.card_giftcard_rounded, perks, AppColors.primary),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              description,
              style: AppTextStyles.bodySm.copyWith(
                color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 14),
          _ApplicantsButton(jobId: jobId, jobTitle: title, academyId: academyId),
        ],
      ),
    );
  }

  Widget _buildTag(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.captionXs.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: SpacingScale.s16,
          vertical: SpacingScale.s24,
        ),
        child: Container(
          width: 520,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: isDark ? AppColors.card : AppColors.lightCard,
            borderRadius: AppRadius.brXl3,
            border: Border.all(
              color: isDark ? AppColors.border : AppColors.lightBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add_business_rounded, color: AppColors.cyan, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Post Coaching Vacancy',
                            style: AppTextStyles.title2.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'Reach registered coaches and athletic trainers',
                            style: AppTextStyles.caption.copyWith(
                              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                      color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDialogField(
                  controller: titleController,
                  label: 'Position Title *',
                  hint: 'e.g. Head Tennis Coach / Performance Analyst',
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDialogField(
                        controller: sportController,
                        label: 'Sport Discipline *',
                        hint: 'e.g. Cricket, Football',
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDialogField(
                        controller: locationController,
                        label: 'Location *',
                        hint: 'e.g. Mumbai / Arena A',
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDialogField(
                        controller: salaryController,
                        label: 'Compensation',
                        hint: 'e.g. ₹45,000/mo or Negotiable',
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDialogField(
                        controller: experienceController,
                        label: 'Experience Required',
                        hint: 'e.g. 2+ Years / Certified',
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDialogField(
                  controller: perksController,
                  label: 'Benefits & Perks',
                  hint: 'e.g. Accommodation, Equipment Allowance',
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _buildDialogField(
                  controller: descController,
                  label: 'Job Description',
                  hint: 'Detail the role responsibilities, training curriculum, and schedules...',
                  isDark: isDark,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary,
                              borderRadius: AppRadius.brXl,
                            ),
                            child: Center(
                              child: Text(
                                'Cancel',
                                style: AppTextStyles.label.copyWith(
                                  color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
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
                                  content: Text('Vacancy "${titleController.text.trim()}" published!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.volt, Color(0xFF99E600)],
                              ),
                              borderRadius: AppRadius.brXl,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.volt.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.send_rounded, size: 16, color: Color(0xFF0F172A)),
                                const SizedBox(width: 8),
                                Text(
                                  'Publish Vacancy',
                                  style: AppTextStyles.buttonLg.copyWith(
                                    color: const Color(0xFF0F172A),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(
            color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
              fontSize: 13,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.brLg,
              borderSide: BorderSide(
                color: isDark ? AppColors.border : AppColors.lightBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.brLg,
              borderSide: const BorderSide(color: AppColors.cyan, width: 1.5),
            ),
            filled: true,
            fillColor: isDark ? AppColors.surface : AppColors.lightSurface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}

class _AcademyJobsHeroHeader extends StatelessWidget {
  final int activeCount;
  final VoidCallback onPostJob;

  const _AcademyJobsHeroHeader({
    required this.activeCount,
    required this.onPostJob,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF090B10),
          image: const DecorationImage(
            image: AssetImage('assets/backgrounds/stadium_floodlights.jpg'),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
          border: Border(
            bottom: BorderSide(
              color: AppColors.cyan.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 44, 16, 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.background.withValues(alpha: 0.94),
                AppColors.background.withValues(alpha: 0.80),
                AppColors.background.withValues(alpha: 0.98),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.cyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.cyan.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.cyan,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'RECRUITMENT & SCOUTING PORTAL',
                        style: AppTextStyles.captionXs.copyWith(
                          color: AppColors.cyan,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Coaching Positions',
                style: AppTextStyles.title1.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Recruit, evaluate, and sign elite sports trainers and staff',
                style: AppTextStyles.bodySm.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.work_rounded, size: 14, color: AppColors.volt),
                        const SizedBox(width: 6),
                        Text(
                          '$activeCount Active Vacanc${activeCount == 1 ? 'y' : 'ies'}',
                          style: AppTextStyles.captionXs.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.cyan.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.flash_on_rounded, size: 14, color: AppColors.cyan),
                        const SizedBox(width: 6),
                        Text(
                          'Instant Scout Broadcast',
                          style: AppTextStyles.captionXs.copyWith(
                            color: AppColors.cyan,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApplicantsButton extends ConsumerWidget {
  final String jobId;
  final String jobTitle;
  final String academyId;

  const _ApplicantsButton({
    required this.jobId,
    required this.jobTitle,
    required this.academyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsAsync = ref.watch(jobApplicationsProvider(jobId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final count = appsAsync.asData?.value.docs.length ?? 0;

    return MouseRegion(
      cursor: count > 0 ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: count > 0 ? () => _showApplicantsSheet(context, ref, jobId, jobTitle) : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: count > 0
                ? AppColors.cyan.withValues(alpha: 0.12)
                : (isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary),
            borderRadius: AppRadius.brXl,
            border: Border.all(
              color: count > 0
                  ? AppColors.cyan.withValues(alpha: 0.35)
                  : (isDark ? AppColors.border : AppColors.lightBorder),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                count > 0 ? Icons.people_alt_rounded : Icons.person_outline_rounded,
                size: 16,
                color: count > 0
                    ? AppColors.cyan
                    : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
              ),
              const SizedBox(width: 8),
              Text(
                count > 0
                    ? 'Review $count Candidate${count == 1 ? '' : 's'}'
                    : 'No applicants yet',
                style: AppTextStyles.labelSm.copyWith(
                  color: count > 0
                      ? (isDark ? Colors.white : AppColors.cyan)
                      : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.cyan),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showApplicantsSheet(BuildContext context, WidgetRef ref, String jobId, String jobTitle) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ApplicantsSheet(
        jobId: jobId,
        jobTitle: jobTitle,
        academyId: academyId,
        isDark: isDark,
      ),
    );
  }
}

class _ApplicantsSheet extends ConsumerWidget {
  final String jobId;
  final String jobTitle;
  final String academyId;
  final bool isDark;

  const _ApplicantsSheet({
    required this.jobId,
    required this.jobTitle,
    required this.academyId,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsAsync = ref.watch(jobApplicationsProvider(jobId));

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(SpacingScale.s16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.card : AppColors.lightCard,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppRadius.xl3),
              topRight: Radius.circular(AppRadius.xl3),
            ),
            border: Border.all(
              color: isDark ? AppColors.border : AppColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                    borderRadius: AppRadius.brFull,
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.people_alt_rounded, size: 20, color: AppColors.cyan),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Candidate Roster',
                          style: AppTextStyles.title2.copyWith(
                            color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          jobTitle,
                          style: AppTextStyles.bodySm.copyWith(
                            color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: appsAsync.when(
                  data: (snapshot) {
                    final docs = snapshot.docs;
                    if (docs.isEmpty) {
                      return Center(
                        child: Text(
                          'No applicants for this position yet.',
                          style: AppTextStyles.body.copyWith(
                            color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      controller: scrollController,
                      itemCount: docs.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final doc = docs[i];
                        final data = doc.data();
                        return _ApplicantRow(
                          applicationId: doc.id,
                          data: data,
                          academyId: academyId,
                          isDark: isDark,
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.cyan),
                  ),
                  error: (_, _) => Center(
                    child: Text(
                      'Error loading applicants',
                      style: AppTextStyles.body.copyWith(color: AppColors.danger),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ApplicantRow extends ConsumerWidget {
  final String applicationId;
  final Map<String, dynamic> data;
  final String academyId;
  final bool isDark;

  const _ApplicantRow({
    required this.applicationId,
    required this.data,
    required this.academyId,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coachName = data['coachName'] as String? ?? 'Candidate Coach';
    final coachEmail = data['coachEmail'] as String? ?? '';
    final status = data['status'] as String? ?? 'applied';
    final createdAt = data['createdAt'] as Timestamp?;
    final timeStr = createdAt != null ? _formatDate(createdAt.toDate()) : '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        borderRadius: AppRadius.brXl2,
        border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.6),
                    ],
                  ),
                  borderRadius: AppRadius.brLg,
                ),
                child: const Icon(Icons.person_rounded, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coachName,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    if (coachEmail.isNotEmpty)
                      Text(
                        coachEmail,
                        style: AppTextStyles.caption.copyWith(
                          color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              if (timeStr.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    timeStr,
                    style: AppTextStyles.captionXs.copyWith(
                      color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatusBadge(status: status),
              const Spacer(),
              _StatusDropdown(
                applicationId: applicationId,
                currentStatus: status,
                academyId: academyId,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    final icon = _statusIcon(status);
    final label = _capitalize(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.brFull,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.captionXs.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'applied':
        return AppColors.cyan;
      case 'under_review':
        return AppColors.warning;
      case 'interview_scheduled':
        return AppColors.orange;
      case 'accepted':
        return AppColors.volt;
      case 'rejected':
        return AppColors.danger;
      case 'need_more_info':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'applied':
        return Icons.send_rounded;
      case 'under_review':
        return Icons.visibility_rounded;
      case 'interview_scheduled':
        return Icons.calendar_today_rounded;
      case 'accepted':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      case 'need_more_info':
        return Icons.info_rounded;
      default:
        return Icons.hourglass_empty_rounded;
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s
        .split('_')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }
}

class _StatusDropdown extends ConsumerWidget {
  final String applicationId;
  final String currentStatus;
  final String academyId;
  final bool isDark;

  const _StatusDropdown({
    required this.applicationId,
    required this.currentStatus,
    required this.academyId,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statuses = [
      'under_review',
      'interview_scheduled',
      'accepted',
      'rejected',
      'need_more_info',
    ];

    return PopupMenuButton<String>(
      onSelected: (newStatus) {
        if (newStatus == 'accepted') {
          ref.read(academyServiceProvider).acceptApplicationAndAssignCoach(applicationId, academyId);
        } else {
          ref.read(academyServiceProvider).updateApplicationStatus(applicationId, newStatus);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to ${_capitalize(newStatus)}'),
            backgroundColor: _statusColor(newStatus),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      itemBuilder: (context) => statuses
          .where((s) => s != currentStatus)
          .map((s) => PopupMenuItem(
                value: s,
                child: Row(
                  children: [
                    Icon(_statusIcon(s), size: 16, color: _statusColor(s)),
                    const SizedBox(width: 8),
                    Text(_capitalize(s)),
                  ],
                ),
              ))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary,
          borderRadius: AppRadius.brLg,
          border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.edit_rounded,
              size: 13,
              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
            ),
            const SizedBox(width: 5),
            Text(
              'Update Status',
              style: AppTextStyles.captionXs.copyWith(
                color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'applied':
        return AppColors.cyan;
      case 'under_review':
        return AppColors.warning;
      case 'interview_scheduled':
        return AppColors.orange;
      case 'accepted':
        return AppColors.volt;
      case 'rejected':
        return AppColors.danger;
      case 'need_more_info':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'applied':
        return Icons.send_rounded;
      case 'under_review':
        return Icons.visibility_rounded;
      case 'interview_scheduled':
        return Icons.calendar_today_rounded;
      case 'accepted':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      case 'need_more_info':
        return Icons.info_rounded;
      default:
        return Icons.hourglass_empty_rounded;
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s
        .split('_')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }
}
