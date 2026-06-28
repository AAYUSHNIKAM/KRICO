import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../models/contract_model.dart';
import '../../../services/providers.dart';

class ContractDetailScreen extends ConsumerWidget {
  const ContractDetailScreen({super.key, required this.contractId});
  final String contractId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractAsync = ref.watch(contractProvider(contractId));

    return Scaffold(
      body: contractAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Failed to load contract', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.invalidate(contractProvider(contractId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (contract) => _ContractDetailContent(contract: contract),
      ),
    );
  }
}

class _ContractDetailContent extends StatelessWidget {
  const _ContractDetailContent({required this.contract});
  final ContractModel contract;

  @override
  Widget build(BuildContext context) {
    final typeLabels = {
      ContractType.coaching: 'Coaching Contract',
      ContractType.academy: 'Academy Contract',
      ContractType.subscription: 'Subscription Contract',
    };
    final statusColors = {
      ContractStatus.draft: AppColors.textDim,
      ContractStatus.pending: AppColors.warning,
      ContractStatus.active: AppColors.success,
      ContractStatus.completed: AppColors.info,
      ContractStatus.cancelled: AppColors.error,
      ContractStatus.disputed: AppColors.error,
    };
    final typeIcons = {
      ContractType.coaching: Icons.sports_rounded,
      ContractType.academy: Icons.business_rounded,
      ContractType.subscription: Icons.workspace_premium_rounded,
    };

    final typeLabel = typeLabels[contract.type] ?? 'Contract';
    final statusColor = statusColors[contract.status] ?? AppColors.primary;
    final typeIcon = typeIcons[contract.type] ?? Icons.description_rounded;
    final contractIdDisplay = 'CT-${contract.contractId.length > 8 ? contract.contractId.substring(0, 8).toUpperCase() : contract.contractId.toUpperCase()}';
    final escrowProgress = contract.isEscrowActive ? 0.65 : 0.0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      statusColor.withValues(alpha: 0.3),
                      AppColors.surfaceDark,
                    ],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 60, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(typeIcon, color: statusColor, size: 28),
                      ),
                      const SizedBox(height: 12),
                      Text(typeLabel, style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(contractIdDisplay, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          contract.status.name.toUpperCase(),
                          style: AppTextStyles.labelLarge.copyWith(color: statusColor, fontWeight: FontWeight.w700, letterSpacing: 1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionTitle('Party Information'),
                const SizedBox(height: 12),
                _buildPartyCard(
                  role: contract.partyARole,
                  name: 'Party A (${contract.partyARole})',
                  icon: Icons.person_rounded,
                  color: AppColors.primary,
                  signed: contract.digitalSignatureA != null,
                ),
                const SizedBox(height: 8),
                _buildPartyCard(
                  role: contract.partyBRole,
                  name: 'Party B (${contract.partyBRole})',
                  icon: Icons.person_rounded,
                  color: AppColors.secondary,
                  signed: contract.digitalSignatureB != null,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Financial Breakdown'),
                const SizedBox(height: 12),
                _buildFinanceRow('Session Fee', contract.amount),
                _buildFinanceRow('Platform Fee (10%)', contract.platformFee, isDeduction: true),
                _buildFinanceRow('Opportunity Fee (10%)', contract.opportunityFee, isDeduction: true),
                _buildFinanceRow('Contract Savings (10%)', contract.contractSavings, isSavings: true),
                const Divider(height: 24, color: AppColors.borderLight),
                _buildFinanceRow('Total Amount', contract.totalAmount, isTotal: true),
                const SizedBox(height: 24),
                _buildSectionTitle('Escrow Status'),
                const SizedBox(height: 12),
                _buildEscrowCard(escrowProgress, contract),
                const SizedBox(height: 24),
                _buildSectionTitle('Digital Signatures'),
                const SizedBox(height: 12),
                _buildSignatureRow(
                  name: 'Party A (${contract.partyARole})',
                  signed: contract.digitalSignatureA != null,
                  signedAt: contract.signedAtA,
                ),
                const SizedBox(height: 8),
                _buildSignatureRow(
                  name: 'Party B (${contract.partyBRole})',
                  signed: contract.digitalSignatureB != null,
                  signedAt: contract.signedAtB,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Terms & Conditions'),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    contract.terms ?? 'Standard terms and conditions apply as per platform guidelines.',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.6),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Download PDF',
                          style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GradientButton(
                        onPressed: () {},
                        gradient: AppColors.gradientPrimary,
                        child: Text(
                          'Raise Dispute',
                          style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppColors.gradientPrimary),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildPartyCard({
    required String role,
    required String name,
    required IconData icon,
    required Color color,
    required bool signed,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(role, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                Text(name, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ],
            ),
          ),
          if (signed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_rounded, size: 12, color: AppColors.success),
                  const SizedBox(width: 4),
                  Text('Signed', style: AppTextStyles.labelSmall.copyWith(color: AppColors.success, fontSize: 10)),
                ],
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildFinanceRow(String label, double amount, {bool isDeduction = false, bool isSavings = false, bool isTotal = false}) {
    final color = isTotal
        ? AppColors.primary
        : (isSavings ? AppColors.success : (isDeduction ? AppColors.error : AppColors.textPrimary));
    final sign = isTotal ? '₹' : (isSavings || isDeduction ? '-₹' : '₹');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
              color: isTotal ? AppColors.textPrimary : (isDeduction || isSavings ? AppColors.textSecondary : AppColors.textSecondary),
            ),
          ),
          Text(
            '$sign${amount.toStringAsFixed(0)}',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEscrowCard(double progress, ContractModel contract) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: contract.isEscrowActive ? AppColors.success.withValues(alpha: 0.3) : AppColors.borderLight.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (contract.isEscrowActive ? AppColors.success : AppColors.textDim).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.security_rounded, color: contract.isEscrowActive ? AppColors.success : AppColors.textDim, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contract.isEscrowActive ? 'Escrow Active' : 'Escrow Inactive',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: contract.isEscrowActive ? AppColors.success : AppColors.textDim,
                      ),
                    ),
                    Text(
                      '₹${(contract.totalAmount * 0.3).toStringAsFixed(0)} held',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: contract.isEscrowActive ? AppColors.success : AppColors.textDim,
                ),
              ),
            ],
          ),
          if (contract.isEscrowActive) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.borderLight,
                valueColor: const AlwaysStoppedAnimation(AppColors.success),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${((1 - progress) * 100).toInt()}% remaining',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textDim),
                ),
                Text(
                  contract.escrowReleaseDate != null
                      ? 'Release: ${contract.escrowReleaseDate!.day}/${contract.escrowReleaseDate!.month}/${contract.escrowReleaseDate!.year}'
                      : 'No release date set',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textDim),
                ),
              ],
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildSignatureRow({
    required String name,
    required bool signed,
    required DateTime? signedAt,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.fingerprint_rounded, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text(
                  signed
                      ? (signedAt != null ? 'Signed ${signedAt.day}/${signedAt.month}/${signedAt.year}' : 'Signed')
                      : 'Not signed yet',
                  style: AppTextStyles.caption.copyWith(
                    color: signed ? AppColors.success : AppColors.textDim,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            signed ? Icons.check_circle_rounded : Icons.schedule_rounded,
            color: signed ? AppColors.success : AppColors.warning,
            size: 22,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.05, end: 0);
  }
}
