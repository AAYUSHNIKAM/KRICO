import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/design_system/colors/app_colors.dart';
import 'package:sports_app/design_system/radius/radius.dart';
import 'package:sports_app/design_system/spacing/spacing_scale.dart';
import 'package:sports_app/design_system/typography/text_styles.dart';

class EscrowVaultCapsule extends StatelessWidget {
  const EscrowVaultCapsule({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.card : AppColors.lightCard;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final subColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    return Container(
      padding: const EdgeInsets.all(SpacingScale.s20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.brXl3,
        border: Border.all(color: borderColor, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.15),
                  borderRadius: AppRadius.brMd,
                ),
                child: const Icon(Icons.shield_rounded, color: AppColors.emerald, size: 20),
              ),
              const SizedBox(width: SpacingScale.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FINANCIAL PROTECTION',
                      style: AppTextStyles.captionXs.copyWith(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w800,
                        color: AppColors.emerald,
                      ),
                    ),
                    Text(
                      'Coaching Escrow Vault',
                      style: AppTextStyles.title3.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.12),
                  borderRadius: AppRadius.brSm,
                ),
                child: const Text(
                  'ACTIVE VAULT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppColors.emerald,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingScale.s16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SECURED IN VAULT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey)),
                  Text(
                    '₹4,500',
                    style: AppTextStyles.heading1.copyWith(
                      color: AppColors.emerald,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              Flexible(
                child: Text(
                  '3/4 Verified',
                  style: AppTextStyles.labelSm.copyWith(color: subColor),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingScale.s12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildMilestoneNode(number: '1', title: 'Sess 1', status: 'Released', isDone: true, color: AppColors.emerald),
                _buildMilestoneConnector(isDone: true),
                _buildMilestoneNode(number: '2', title: 'Sess 2', status: 'Released', isDone: true, color: AppColors.emerald),
                _buildMilestoneConnector(isDone: true),
                _buildMilestoneNode(number: '3', title: 'Sess 3', status: 'Released', isDone: true, color: AppColors.emerald),
                _buildMilestoneConnector(isDone: false),
                _buildMilestoneNode(number: '4', title: 'Sess 4', status: 'Locked', isDone: false, color: AppColors.cyan),
              ],
            ),
          ),
          const SizedBox(height: SpacingScale.s16),
          InkWell(
            onTap: () => context.push('/contracts'),
            child: Row(
              children: [
                const Icon(Icons.verified_user_outlined, size: 14, color: AppColors.emerald),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '100% Refundable if coach misses attendance. View Escrow Terms →',
                    style: AppTextStyles.captionXs.copyWith(color: AppColors.emerald),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneNode({
    required String number,
    required String title,
    required String status,
    required bool isDone,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? color : color.withValues(alpha: 0.15),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 13, color: Colors.black)
                : Icon(Icons.lock_outline_rounded, size: 11, color: color),
          ),
        ),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildMilestoneConnector({required bool isDone}) {
    return Container(
      width: 28,
      height: 2,
      color: isDone ? AppColors.emerald : Colors.grey.withValues(alpha: 0.3),
      margin: const EdgeInsets.only(bottom: 14),
    );
  }
}
