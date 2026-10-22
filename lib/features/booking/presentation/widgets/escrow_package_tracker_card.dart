import 'package:flutter/material.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/radius/radius.dart';
import '../../../../design_system/spacing/spacing_scale.dart';
import '../../../../design_system/typography/text_styles.dart';
import '../../../../models/coaching_package_model.dart';

class EscrowPackageTrackerCard extends StatelessWidget {
  final CoachingPackageModel package;
  final VoidCallback? onBookNextSession;

  const EscrowPackageTrackerCard({
    super.key,
    required this.package,
    this.onBookNextSession,
  });

  @override
  Widget build(BuildContext context) {
    final isComplete = package.completedSessions >= package.totalSessions;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SpacingScale.s20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.brXl2,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
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
                    Row(
                      children: [
                        const Icon(Icons.shield_rounded, size: 16, color: AppColors.emerald),
                        const SizedBox(width: SpacingScale.s6),
                        Text(
                          'ESCROW PROTECTED',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.emerald,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: SpacingScale.s4),
                    Text(
                      package.title,
                      style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s10, vertical: SpacingScale.s4),
                decoration: BoxDecoration(
                  color: isComplete
                      ? AppColors.emerald.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: AppRadius.brFull,
                  border: Border.all(
                    color: isComplete
                        ? AppColors.emerald.withValues(alpha: 0.4)
                        : AppColors.primary.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  package.escrowState.label,
                  style: AppTextStyles.caption.copyWith(
                    color: isComplete ? AppColors.emerald : AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingScale.s16),

          ClipRRect(
            borderRadius: AppRadius.brFull,
            child: LinearProgressIndicator(
              value: package.progressPercentage,
              backgroundColor: AppColors.card,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.emerald),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: SpacingScale.s8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${package.completedSessions} of ${package.totalSessions} Sessions Attended',
                style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
              ),
              Text(
                '${(package.progressPercentage * 100).toInt()}%',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingScale.s16),

          Container(
            padding: const EdgeInsets.all(SpacingScale.s12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: AppRadius.brLg,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Package',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                      ),
                      const SizedBox(height: SpacingScale.s2),
                      Text(
                        '₹${package.totalAmount.toStringAsFixed(0)}',
                        style: AppTextStyles.title3.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 32, color: AppColors.border),
                const SizedBox(width: SpacingScale.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Released to Coach',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                      ),
                      const SizedBox(height: SpacingScale.s2),
                      Text(
                        '₹${package.releasedAmount.toStringAsFixed(0)}',
                        style: AppTextStyles.title3.copyWith(
                          color: AppColors.emerald,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 32, color: AppColors.border),
                const SizedBox(width: SpacingScale.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Held in Escrow',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                      ),
                      const SizedBox(height: SpacingScale.s2),
                      Text(
                        '₹${package.remainingEscrow.toStringAsFixed(0)}',
                        style: AppTextStyles.title3.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (!isComplete && onBookNextSession != null) ...[
            const SizedBox(height: SpacingScale.s16),
            ElevatedButton.icon(
              onPressed: onBookNextSession,
              icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
              label: Text('Book Next Session (${package.remainingSessions} Left)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
