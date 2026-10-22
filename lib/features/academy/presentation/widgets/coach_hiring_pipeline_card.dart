import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/radius/radius.dart';
import '../../../../design_system/spacing/spacing_scale.dart';
import '../../../../design_system/typography/text_styles.dart';
import '../../../../models/job_model.dart';

class CoachHiringPipelineCard extends StatelessWidget {
  final JobApplicationModel application;
  final bool isAcademy;
  final VoidCallback? onStatusUpdated;

  const CoachHiringPipelineCard({
    super.key,
    required this.application,
    this.isAcademy = false,
    this.onStatusUpdated,
  });

  int get _currentStageIndex {
    switch (application.status) {
      case 'interview_scheduled':
        return 1;
      case 'offer_extended':
        return 2;
      case 'accepted':
      case 'hired':
        return 3;
      case 'declined':
        return -1;
      default:
        return 0;
    }
  }

  Future<void> _updateStatus(BuildContext context, String status, {Map<String, dynamic>? extra}) async {
    try {
      final updates = <String, dynamic>{
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (extra != null) updates.addAll(extra);

      await FirebaseFirestore.instance
          .collection('job_applications')
          .doc(application.id)
          .set(updates, SetOptions(merge: true));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Application updated to: ${status.replaceAll('_', ' ')}'),
            backgroundColor: AppColors.emerald,
            behavior: SnackBarBehavior.floating,
          ),
        );
        onStatusUpdated?.call();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  void _showOfferDialog(BuildContext context) {
    final salaryCtrl = TextEditingController(text: '₹45,000 / month');
    final notesCtrl = TextEditingController(text: 'Full-time Head Coach position for U-16 batch.');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.brXl),
        title: Text('Extend Coaching Offer', style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: salaryCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Compensation / Stipend',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(borderRadius: AppRadius.brLg),
              ),
            ),
            const SizedBox(height: SpacingScale.s12),
            TextField(
              controller: notesCtrl,
              maxLines: 2,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Terms & Role Details',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(borderRadius: AppRadius.brLg),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _updateStatus(
                context,
                'offer_extended',
                extra: {
                  'offerSalary': salaryCtrl.text.trim(),
                  'offerNotes': notesCtrl.text.trim(),
                  'offerExtendedAt': FieldValue.serverTimestamp(),
                },
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald, foregroundColor: Colors.black),
            child: const Text('Send Official Offer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stages = ['Applied', 'Interview', 'Offer', 'Hired'];
    final stageIdx = _currentStageIndex;

    return Container(
      padding: const EdgeInsets.all(SpacingScale.s20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.brXl2,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.coachName,
                      style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
                    ),
                    Text(
                      'Applied: ${DateFormat('MMM d, yyyy').format(application.appliedAt)}',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s10, vertical: SpacingScale.s4),
                decoration: BoxDecoration(
                  color: application.status == 'accepted' || application.status == 'hired'
                      ? AppColors.emerald.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: AppRadius.brFull,
                  border: Border.all(
                    color: application.status == 'accepted' || application.status == 'hired'
                        ? AppColors.emerald
                        : AppColors.primary,
                  ),
                ),
                child: Text(
                  application.status.replaceAll('_', ' ').toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    color: application.status == 'accepted' || application.status == 'hired'
                        ? AppColors.emerald
                        : AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingScale.s16),

          Row(
            children: List.generate(stages.length * 2 - 1, (index) {
              if (index.isOdd) {
                final lineIdx = index ~/ 2;
                final isPassed = stageIdx > lineIdx;
                return Expanded(
                  child: Container(
                    height: 2,
                    color: isPassed ? AppColors.emerald : AppColors.card,
                  ),
                );
              }

              final stepIdx = index ~/ 2;
              final isReached = stageIdx >= stepIdx;
              final isCurrent = stageIdx == stepIdx;

              return Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isReached ? AppColors.emerald : AppColors.card,
                      border: Border.all(
                        color: isCurrent ? Colors.white : (isReached ? AppColors.emerald : AppColors.border),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: isReached
                          ? const Icon(Icons.check, size: 16, color: Colors.black)
                          : Text(
                              '${stepIdx + 1}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                    ),
                  ),
                  const SizedBox(height: SpacingScale.s4),
                  Text(
                    stages[stepIdx],
                    style: AppTextStyles.caption.copyWith(
                      color: isReached ? AppColors.textPrimary : AppColors.textTertiary,
                      fontSize: 10,
                      fontWeight: isReached ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              );
            }),
          ),

          if (application.offerSalary != null) ...[
            const SizedBox(height: SpacingScale.s16),
            Container(
              padding: const EdgeInsets.all(SpacingScale.s12),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: AppRadius.brLg,
                border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.monetization_on_rounded, color: AppColors.emerald, size: 18),
                      const SizedBox(width: SpacingScale.s6),
                      Text(
                        'OFFER PACKAGE: ${application.offerSalary}',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.emerald,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (application.offerNotes != null) ...[
                    const SizedBox(height: SpacingScale.s4),
                    Text(
                      application.offerNotes!,
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
          ],

          const SizedBox(height: SpacingScale.s20),

          if (isAcademy) ...[
            Wrap(
              spacing: SpacingScale.s8,
              runSpacing: SpacingScale.s8,
              children: [
                if (application.status == 'applied')
                  ElevatedButton.icon(
                    onPressed: () => _updateStatus(context, 'interview_scheduled', extra: {
                      'interviewDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 2))),
                    }),
                    icon: const Icon(Icons.calendar_today_rounded, size: 16),
                    label: const Text('Schedule Interview'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  ),
                if (application.status == 'interview_scheduled' || application.status == 'applied')
                  ElevatedButton.icon(
                    onPressed: () => _showOfferDialog(context),
                    icon: const Icon(Icons.card_giftcard_rounded, size: 16),
                    label: const Text('Extend Offer'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald, foregroundColor: Colors.black),
                  ),
                if (application.status == 'accepted')
                  ElevatedButton.icon(
                    onPressed: () => _updateStatus(context, 'hired'),
                    icon: const Icon(Icons.verified_rounded, size: 16),
                    label: const Text('Confirm Onboarding'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald, foregroundColor: Colors.black),
                  ),
              ],
            ),
          ] else ...[
            if (application.status == 'offer_extended')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateStatus(context, 'declined'),
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: SpacingScale.s12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateStatus(context, 'accepted'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Accept Offer'),
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }
}
