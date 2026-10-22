import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/constants/sports_registry.dart';
import '../../../../../design_system/colors/app_colors.dart';
import '../../../../../design_system/typography/text_styles.dart';
import '../../../../../design_system/spacing/spacing_scale.dart';
import '../../../../../design_system/radius/radius.dart';
import '../../../../../design_system/responsive/responsive_helpers.dart';
import '../../../../../services/providers.dart';
import 'dashboard_loading.dart';
import 'dashboard_empty_state.dart';

class AcademyBatchesSection extends ConsumerWidget {
  final String academyId;

  const AcademyBatchesSection({super.key, required this.academyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchesAsync = ref.watch(academyBatchesProvider(academyId));
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
            title: 'Active Batches',
            icon: Icons.view_list_rounded,
            color: AppColors.primary,
            actionLabel: 'Manage',
            isDark: Theme.of(context).brightness == Brightness.dark,
            onActionTap: () => _showCreateBatchDialog(context, ref),
          ),
          const SizedBox(height: SpacingScale.s12),
          batchesAsync.when(
            data: (snapshot) {
              final batches = snapshot.docs;
              if (batches.isEmpty) {
                return AcademyDashboardEmptyState(
                  icon: Icons.sports_kabaddi_rounded,
                  title: 'No batches yet',
                  subtitle: 'Create your first batch to start enrolling students.',
                  actionLabel: 'Create Batch',
                  onActionTap: () => _showCreateBatchDialog(context, ref),
                );
              }
              return Column(
                children: batches.map((doc) {
                  final data = doc.data();
                  final batchName = data['name'] as String? ?? 'Untitled';
                  final sport = data['sport'] as String? ?? 'General';
                  final capacity = (data['capacity'] as num?)?.toInt() ?? 10;
                  return _BatchCard(
                    name: batchName,
                    students: '${data['enrolled'] ?? 0}/$capacity',
                    schedule: data['schedule'] as String? ?? 'TBD',
                    sport: sport,
                    batchId: doc.id,
                    onDelete: () => _deleteBatch(ref, doc.id),
                    onView: () => _showBatchRoster(context, ref, doc.id, batchName, sport, capacity),
                  );
                }).toList(),
              ).animate(delay: 200.ms).fadeIn(duration: 350.ms).slideY(begin: 0.06, end: 0);
            },
            loading: () => const AcademyDashboardSectionShimmer(height: 200),
            error: (e, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: SpacingScale.s16),
              child: Center(
                child: Text('Failed to load batches',
                    style: AppTextStyles.body.copyWith(color: AppColors.danger)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBatchRoster(BuildContext context, WidgetRef ref, String batchId, String batchName, String sport, int capacity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DashboardBatchRosterSheet(
        academyId: academyId,
        batchId: batchId,
        batchName: batchName,
        sport: sport,
        capacity: capacity,
      ),
    );
  }

  void _showCreateBatchDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    String selectedSport = SportsRegistry.sports.first.name;
    final capacityCtrl = TextEditingController(text: '15');
    final scheduleCtrl = TextEditingController(text: 'Mon, Wed, Fri 4:00 PM');

    showDialog(
      context: context,
      builder: (ctx) => _BatchFormDialog(
        title: 'Create Squad Batch',
        nameCtrl: nameCtrl,
        initialSport: selectedSport,
        capacityCtrl: capacityCtrl,
        scheduleCtrl: scheduleCtrl,
        onSportChanged: (s) => selectedSport = s,
        onSubmit: () {
          if (nameCtrl.text.isNotEmpty) {
            ref.read(academyServiceProvider).createBatch(
              academyId: academyId,
              name: nameCtrl.text.trim(),
              sport: selectedSport,
              capacity: int.tryParse(capacityCtrl.text) ?? 15,
              schedule: scheduleCtrl.text.trim(),
            );
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Squad batch "${nameCtrl.text}" created!'), backgroundColor: AppColors.success),
            );
          }
        },
      ),
    );
  }

  void _deleteBatch(WidgetRef ref, String batchId) {
    ref.read(academyServiceProvider).deleteBatch(batchId);
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String? actionLabel;
  final bool isDark;
  final VoidCallback? onActionTap;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
    this.actionLabel,
    required this.isDark,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onActionTap,
      child: Row(children: [
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
        if (actionLabel != null)
          Text(actionLabel!, style: AppTextStyles.buttonLg.copyWith(color: AppColors.primary)),
      ]),
    );
  }
}

class _BatchCard extends StatelessWidget {
  final String name;
  final String students;
  final String schedule;
  final String sport;
  final String batchId;
  final VoidCallback onDelete;
  final VoidCallback onView;

  const _BatchCard({
    required this.name,
    required this.students,
    required this.schedule,
    required this.sport,
    required this.batchId,
    required this.onDelete,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sportDef = SportsRegistry.getSport(sport);
    final color = sportDef?.accentColor ?? AppColors.primary;
    final icon = sportDef?.icon ?? Icons.sports_kabaddi_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: SpacingScale.s8),
      padding: const EdgeInsets.all(SpacingScale.s16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl3,
        border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: AppRadius.brLg,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: SpacingScale.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: AppTextStyles.title3.copyWith(fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary)),
                const SizedBox(height: SpacingScale.s2),
                Text('$students students \u00B7 $schedule',
                    style: AppTextStyles.caption.copyWith(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'view') onView();
              if (value == 'delete') onDelete();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'view', child: Text('View Roster')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
            icon: Icon(Icons.more_vert_rounded, size: 18, color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
          ),
        ],
      ),
    );
  }
}

class _BatchFormDialog extends StatefulWidget {
  final String title;
  final TextEditingController nameCtrl;
  final String initialSport;
  final TextEditingController capacityCtrl;
  final TextEditingController scheduleCtrl;
  final ValueChanged<String> onSportChanged;
  final VoidCallback onSubmit;

  const _BatchFormDialog({
    required this.title,
    required this.nameCtrl,
    required this.initialSport,
    required this.capacityCtrl,
    required this.scheduleCtrl,
    required this.onSportChanged,
    required this.onSubmit,
  });

  @override
  State<_BatchFormDialog> createState() => _BatchFormDialogState();
}

class _BatchFormDialogState extends State<_BatchFormDialog> {
  late String _selectedSport;

  @override
  void initState() {
    super.initState();
    _selectedSport = widget.initialSport;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogTextColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final dialogSecondaryColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.surface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(widget.title, style: TextStyle(color: dialogTextColor, fontWeight: FontWeight.w700)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: widget.nameCtrl,
              decoration: InputDecoration(
                labelText: 'Batch Name',
                hintText: 'e.g. Under-17 Elite Squad',
                labelStyle: TextStyle(color: dialogSecondaryColor),
                border: const OutlineInputBorder(),
              ),
              style: TextStyle(color: dialogTextColor),
            ),
            const SizedBox(height: SpacingScale.s12),
            DropdownButtonFormField<String>(
              initialValue: SportsRegistry.sports.any((s) => s.name == _selectedSport)
                  ? _selectedSport
                  : SportsRegistry.sports.first.name,
              dropdownColor: isDark ? AppColors.surface : AppColors.lightSurface,
              decoration: InputDecoration(
                labelText: 'Sport / Discipline (30 Sports)',
                labelStyle: TextStyle(color: dialogSecondaryColor),
                border: const OutlineInputBorder(),
              ),
              style: TextStyle(color: dialogTextColor),
              items: SportsRegistry.sports.map((s) {
                return DropdownMenuItem<String>(
                  value: s.name,
                  child: Text('${s.name} (${s.category})', style: TextStyle(color: dialogTextColor)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedSport = val);
                  widget.onSportChanged(val);
                }
              },
            ),
            const SizedBox(height: SpacingScale.s12),
            TextField(
              controller: widget.capacityCtrl,
              decoration: InputDecoration(
                labelText: 'Max Capacity',
                hintText: 'e.g. 20',
                labelStyle: TextStyle(color: dialogSecondaryColor),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              style: TextStyle(color: dialogTextColor),
            ),
            const SizedBox(height: SpacingScale.s12),
            TextField(
              controller: widget.scheduleCtrl,
              decoration: InputDecoration(
                labelText: 'Schedule',
                hintText: 'e.g. Mon-Wed-Fri 4-5:30 PM',
                labelStyle: TextStyle(color: dialogSecondaryColor),
                border: const OutlineInputBorder(),
              ),
              style: TextStyle(color: dialogTextColor),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: dialogSecondaryColor)),
        ),
        ElevatedButton(
          onPressed: widget.onSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Create Batch', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

class _DashboardBatchRosterSheet extends ConsumerWidget {
  final String academyId;
  final String batchId;
  final String batchName;
  final String sport;
  final int capacity;

  const _DashboardBatchRosterSheet({
    required this.academyId,
    required this.batchId,
    required this.batchName,
    required this.sport,
    required this.capacity,
  });

  void _showEnrollDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surface : AppColors.lightSurface,
        title: Text('Enroll Athlete in $batchName', style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: const InputDecoration(labelText: 'Athlete Full Name *', prefixIcon: Icon(Icons.person_rounded)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_rounded)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_rounded)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contactCtrl,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: const InputDecoration(labelText: 'Parent / Emergency Contact', prefixIcon: Icon(Icons.contact_phone_rounded)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              try {
                await ref.read(academyServiceProvider).enrollStudentInBatch(
                  batchId: batchId,
                  academyId: academyId,
                  studentName: nameCtrl.text.trim(),
                  studentPhone: phoneCtrl.text.trim(),
                  studentEmail: emailCtrl.text.trim(),
                  emergencyContact: contactCtrl.text.trim(),
                );
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${nameCtrl.text.trim()} enrolled!'), backgroundColor: AppColors.success),
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger));
                }
              }
            },
            child: const Text('Enroll Athlete', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.white60 : Colors.black54;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(SpacingScale.s16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: SpacingScale.s12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(batchName, style: AppTextStyles.title2.copyWith(color: textPrimary, fontWeight: FontWeight.w700)),
                    Text('$sport \u2022 Capacity: $capacity Athletes', style: AppTextStyles.caption.copyWith(color: textSecondary)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.person_add_rounded, size: 16),
                label: const Text('Enroll Athlete', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                onPressed: () => _showEnrollDialog(context, ref),
              ),
            ],
          ),
          const Divider(height: 24),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: ref.watch(academyServiceProvider).getBatchStudents(batchId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off_rounded, size: 40, color: textSecondary),
                        const SizedBox(height: 8),
                        Text('No Athletes Enrolled Yet', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text('Tap "Enroll Athlete" to register members.', style: TextStyle(color: textSecondary, fontSize: 12)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    final name = data['name'] as String? ?? 'Athlete';
                    final phone = data['phone'] as String? ?? '';
                    final email = data['email'] as String? ?? '';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.card : AppColors.lightCard,
                        borderRadius: AppRadius.brLg,
                        border: Border.all(color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                            foregroundColor: AppColors.primary,
                            child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'A', style: const TextStyle(fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                                if (phone.isNotEmpty || email.isNotEmpty)
                                  Text([if (phone.isNotEmpty) phone, if (email.isNotEmpty) email].join(' \u2022 '),
                                      style: TextStyle(color: textSecondary, fontSize: 11)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.danger, size: 20),
                            onPressed: () async {
                              await ref.read(academyServiceProvider).removeStudentFromBatch(batchId: batchId, studentId: docs[index].id);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
