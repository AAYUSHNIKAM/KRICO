import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../design_system/radius/radius.dart';
import '../../../design_system/widgets/page_headers/page_hero.dart';
import '../../../design_system/responsive/responsive_helpers.dart';
import '../../../models/contract_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/providers.dart';

class ContractDetailScreen extends ConsumerWidget {
  const ContractDetailScreen({super.key, required this.contractId});
  final String contractId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final contractAsync = ref.watch(contractProvider(contractId));

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
      body: contractAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: AppColors.danger),
              SizedBox(height: SpacingScale.s16),
              Text('Failed to load contract', style: AppTextStyles.bodyLg.copyWith(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
              SizedBox(height: SpacingScale.s12),
              GestureDetector(
                onTap: () => ref.invalidate(contractProvider(contractId)),
                child: Text('Retry', style: AppTextStyles.button.copyWith(color: AppColors.primary)),
              ),
            ],
          ),
        ),
        data: (contract) => _ContractDetailContent(contract: contract),
      ),
    );
  }
}

class _ContractDetailContent extends ConsumerWidget {
  Future<void> _exportContractPdf(BuildContext context, String contractId, String summaryText) async {
    try {
      final pdfDoc = pw.Document();
      pdfDoc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context pwCtx) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('KRICO SPORTS PLATFORM', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                      pw.Text('DIGITAL AGREEMENT', style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
                    ],
                  ),
                ),
                pw.Divider(thickness: 1.5),
                pw.SizedBox(height: 12),
                pw.Text('Contract Reference: $contractId', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
                pw.SizedBox(height: 14),
                pw.Text(
                  summaryText,
                  style: const pw.TextStyle(fontSize: 9.5, lineSpacing: 1.4),
                ),
                pw.Spacer(),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Digitally Verified via KRICO Pune Pilot', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                    pw.Text('Contract ID: $contractId', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                  ],
                ),
              ],
            );
          },
        ),
      );

      final bytes = await pdfDoc.save();
      await Printing.sharePdf(bytes: bytes, filename: 'KRICO_Agreement_$contractId.pdf');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  const _ContractDetailContent({required this.contract});
  final ContractModel contract;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typeLabels = {
      ContractType.coaching: 'Coaching Contract',
      ContractType.academy: 'Academy Contract',
      ContractType.subscription: 'Subscription Contract',
    };
    final statusColors = {
      ContractStatus.draft: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
      ContractStatus.pending: AppColors.warning,
      ContractStatus.active: AppColors.success,
      ContractStatus.completed: AppColors.primary,
      ContractStatus.cancelled: AppColors.danger,
      ContractStatus.disputed: AppColors.danger,
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
      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          if (context.isPhone)
            PageHero(title: typeLabel, showPhoneHeader: true)
          else
            SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surface : AppColors.lightSurface,
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(SpacingScale.s20, MediaQuery.of(context).padding.top + 60, SpacingScale.s20, SpacingScale.s20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: AppRadius.brXl2,
                        ),
                        child: Icon(typeIcon, color: statusColor, size: 28),
                      ),
                      SizedBox(height: SpacingScale.s12),
                      Text(typeLabel, style: AppTextStyles.title1.copyWith(fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary)),
                      SizedBox(height: SpacingScale.s4),
                      Text(contractIdDisplay, style: AppTextStyles.body.copyWith(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
                      SizedBox(height: SpacingScale.s12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s16, vertical: SpacingScale.s6),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: AppRadius.brFull,
                          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          contract.status.name.toUpperCase(),
                          style: AppTextStyles.label.copyWith(color: statusColor, fontWeight: FontWeight.w700, letterSpacing: 1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(SpacingScale.s8),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back_rounded, color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary, size: 20),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(SpacingScale.s16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionHeader(
                  title: 'Party Information',
                  icon: Icons.people_rounded,
                  color: AppColors.primary,
                  isDark: isDark,
                ),
                SizedBox(height: SpacingScale.s12),
                _buildPartyCard(
                  role: contract.partyARole,
                  name: 'Party A (${contract.partyARole})',
                  icon: Icons.person_rounded,
                  color: AppColors.primary,
                  signed: contract.digitalSignatureA != null,
                  isDark: isDark,
                ),
                SizedBox(height: SpacingScale.s8),
                _buildPartyCard(
                  role: contract.partyBRole,
                  name: 'Party B (${contract.partyBRole})',
                  icon: Icons.person_rounded,
                  color: AppColors.purple,
                  signed: contract.digitalSignatureB != null,
                  isDark: isDark,
                ),
                SizedBox(height: SpacingScale.s24),
                _buildSectionHeader(
                  title: 'Financial Breakdown',
                  icon: Icons.account_balance_wallet_rounded,
                  color: AppColors.warning,
                  isDark: isDark,
                ),
                SizedBox(height: SpacingScale.s12),
                _buildFinanceRow('Session Fee', contract.amount, isDark: isDark),
                _buildFinanceRow('Platform Fee (10%)', contract.platformFee, isDeduction: true, isDark: isDark),
                _buildFinanceRow('Opportunity Fee (10%)', contract.opportunityFee, isDeduction: true, isDark: isDark),
                _buildFinanceRow('Contract Savings (10%)', contract.contractSavings, isSavings: true, isDark: isDark),
                Divider(height: 24, color: isDark ? AppColors.border : AppColors.lightBorder),
                _buildFinanceRow('Total Amount', contract.totalAmount, isTotal: true, isDark: isDark),
                SizedBox(height: SpacingScale.s24),
                _buildSectionHeader(
                  title: 'Escrow Status',
                  icon: Icons.security_rounded,
                  color: AppColors.success,
                  isDark: isDark,
                ),
                SizedBox(height: SpacingScale.s12),
                _buildEscrowCard(escrowProgress, contract, isDark),
                SizedBox(height: SpacingScale.s24),
                _buildSectionHeader(
                  title: 'Digital Signatures',
                  icon: Icons.fingerprint_rounded,
                  color: AppColors.primary,
                  isDark: isDark,
                ),
                SizedBox(height: SpacingScale.s12),
                _buildSignatureRow(
                  name: 'Party A (${contract.partyARole})',
                  signed: contract.digitalSignatureA != null,
                  signedAt: contract.signedAtA,
                  isDark: isDark,
                ),
                SizedBox(height: SpacingScale.s8),
                _buildSignatureRow(
                  name: 'Party B (${contract.partyBRole})',
                  signed: contract.digitalSignatureB != null,
                  signedAt: contract.signedAtB,
                  isDark: isDark,
                ),
                SizedBox(height: SpacingScale.s24),
                _buildSectionHeader(
                  title: 'Terms & Conditions',
                  icon: Icons.description_rounded,
                  color: AppColors.purple,
                  isDark: isDark,
                ),
                SizedBox(height: SpacingScale.s8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(SpacingScale.s16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.card : AppColors.lightCard,
                    borderRadius: AppRadius.brXl2,
                    border: Border.all(
                      color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    contract.terms ?? 'Standard terms and conditions apply as per platform guidelines.',
                    style: AppTextStyles.body.copyWith(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary, height: 1.6),
                  ),
                ),
                SizedBox(height: SpacingScale.s24),
                Row(
                  children: [
                    Expanded(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => _showDownloadPdfModal(context),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: AppRadius.brXl2,
                              border: Border.all(color: AppColors.primary, width: 1.5),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.download_rounded, color: AppColors.primary, size: 18),
                                  SizedBox(width: SpacingScale.s8),
                                  Text('Download PDF', style: AppTextStyles.buttonLg.copyWith(color: AppColors.primary)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: SpacingScale.s12),
                    Expanded(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => _showRaiseDisputeModal(context, ref),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [AppColors.danger, AppColors.danger.withValues(alpha: 0.8)]),
                              borderRadius: AppRadius.brXl2,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.danger.withValues(alpha: 0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.report_rounded, color: Colors.white, size: 18),
                                  SizedBox(width: SpacingScale.s8),
                                  Text('Raise Dispute', style: AppTextStyles.buttonLg.copyWith(color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: SpacingScale.s32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showDownloadPdfModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final summaryText = '''SPORTS ECOSYSTEM - OFFICIAL DIGITAL CONTRACT
Contract ID: ${contract.contractId}
Type: ${contract.type.name.toUpperCase()}
Status: ${contract.status.name.toUpperCase()}
Party A: ${contract.partyARole} (${contract.partyAId})
Party B: ${contract.partyBRole} (${contract.partyBId})
Session Fee: INR ${contract.amount.toStringAsFixed(2)}
Platform Fee: INR ${contract.platformFee.toStringAsFixed(2)}
Total Amount: INR ${contract.totalAmount.toStringAsFixed(2)}
Escrow Protected: ${contract.isEscrowActive ? "YES" : "NO"}
Date: ${contract.createdAt != null ? contract.createdAt!.toIso8601String() : "Active"}
Terms:
${contract.terms ?? "Standard platform service agreement apply."}
''';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(SpacingScale.s20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : AppColors.lightSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: SpacingScale.s16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: AppRadius.brLg,
                  ),
                  child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: SpacingScale.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Digital Contract Export', style: AppTextStyles.title2.copyWith(fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary)),
                      Text('Official Legal Summary & PDF Preview', style: AppTextStyles.caption.copyWith(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpacingScale.s16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(SpacingScale.s12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.card : AppColors.lightCard,
                  borderRadius: AppRadius.brXl2,
                  border: Border.all(color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5)),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    summaryText,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      height: 1.5,
                      color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: SpacingScale.s16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('Copy Text'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.brXl2),
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: summaryText));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Contract agreement copied to clipboard!'), backgroundColor: AppColors.success),
                      );
                    },
                  ),
                ),
                const SizedBox(width: SpacingScale.s12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.file_download_rounded, size: 16),
                    label: const Text('Save PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.brXl2),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _exportContractPdf(context, contract.contractId, summaryText);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRaiseDisputeModal(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String selectedReason = 'Session was not conducted / No show';
    final detailsCtrl = TextEditingController();
    bool isSubmitting = false;

    final reasons = [
      'Session was not conducted / No show',
      'Premature session cancellation without notice',
      'Substandard or misleading coaching service',
      'Disagreement on payment / fee release',
      'Unprofessional behavior or code violation',
      'Other dispute reason',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.all(SpacingScale.s20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surface : AppColors.lightSurface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: SpacingScale.s16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.12),
                          borderRadius: AppRadius.brLg,
                        ),
                        child: const Icon(Icons.gavel_rounded, color: AppColors.danger, size: 24),
                      ),
                      const SizedBox(width: SpacingScale.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Raise Contract Dispute', style: AppTextStyles.title2.copyWith(fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary)),
                            Text('Escrow funds will be held in protection', style: AppTextStyles.caption.copyWith(color: AppColors.danger)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SpacingScale.s16),
                  Text('Dispute Category *', style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary)),
                  const SizedBox(height: SpacingScale.s6),
                  DropdownButtonFormField<String>(
                    initialValue: selectedReason,
                    dropdownColor: isDark ? AppColors.card : AppColors.lightCard,
                    style: TextStyle(color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? AppColors.card : AppColors.lightCard,
                      border: OutlineInputBorder(borderRadius: AppRadius.brLg),
                    ),
                    items: reasons.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedReason = val);
                    },
                  ),
                  const SizedBox(height: SpacingScale.s16),
                  Text('Dispute Details & Evidence *', style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary)),
                  const SizedBox(height: SpacingScale.s6),
                  TextField(
                    controller: detailsCtrl,
                    maxLines: 4,
                    style: TextStyle(color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary),
                    decoration: InputDecoration(
                      hintText: 'Describe the issue in detail. Our arbitration team will review within 24 hours...',
                      hintStyle: TextStyle(color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary, fontSize: 12),
                      filled: true,
                      fillColor: isDark ? AppColors.card : AppColors.lightCard,
                      border: OutlineInputBorder(borderRadius: AppRadius.brLg),
                    ),
                  ),
                  const SizedBox(height: SpacingScale.s20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.brXl2),
                      ),
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              if (detailsCtrl.text.trim().isEmpty) return;
                              setModalState(() => isSubmitting = true);
                              try {
                                final user = ref.read(authServiceProvider).currentUser;
                                final userId = user?.uid ?? contract.partyBId;
                                await ref.read(contractServiceProvider).raiseDispute(
                                  contractId: contract.contractId,
                                  userId: userId,
                                  reason: selectedReason,
                                  details: detailsCtrl.text.trim(),
                                );
                                if (ctx.mounted) Navigator.pop(ctx);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Dispute raised. Escrow funds placed on hold for arbitration.'),
                                      backgroundColor: AppColors.danger,
                                    ),
                                  );
                                }
                              } catch (e) {
                                setModalState(() => isSubmitting = false);
                                if (ctx.mounted) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
                                  );
                                }
                              }
                            },
                      child: Text(
                        isSubmitting ? 'Filing Dispute...' : 'Submit Formal Dispute',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required IconData icon, required Color color, required bool isDark}) {
    return Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: AppRadius.brLg,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        SizedBox(width: SpacingScale.s10),
        Text(title, style: AppTextStyles.title2.copyWith(color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildPartyCard({
    required String role,
    required String name,
    required IconData icon,
    required Color color,
    required bool signed,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(SpacingScale.s16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl2,
        border: Border.all(
          color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5),
          width: 0.5,
        ),
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
          SizedBox(width: SpacingScale.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(role, style: AppTextStyles.caption.copyWith(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
                Text(name, style: AppTextStyles.title2.copyWith(fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary)),
              ],
            ),
          ),
          if (signed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s8, vertical: SpacingScale.s4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: AppRadius.brSm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_rounded, size: 12, color: AppColors.success),
                  SizedBox(width: SpacingScale.s4),
                  Text('Signed', style: AppTextStyles.labelSm.copyWith(color: AppColors.success, fontSize: 10)),
                ],
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildFinanceRow(String label, double amount, {bool isDeduction = false, bool isSavings = false, bool isTotal = false, required bool isDark}) {
    final color = isTotal
        ? AppColors.primary
        : (isSavings ? AppColors.success : (isDeduction ? AppColors.danger : (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary)));
    final sign = isTotal ? '₹' : (isSavings || isDeduction ? '-₹' : '₹');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SpacingScale.s4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
              color: isTotal ? (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary) : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
            ),
          ),
          Text(
            '$sign${amount.toStringAsFixed(0)}',
            style: AppTextStyles.body.copyWith(
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEscrowCard(double progress, ContractModel contract, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(SpacingScale.s16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl3,
        border: Border.all(
          color: contract.isEscrowActive ? AppColors.success.withValues(alpha: 0.3) : (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (contract.isEscrowActive ? AppColors.success : (isDark ? AppColors.textTertiary : AppColors.lightTextTertiary)).withValues(alpha: 0.1),
                  borderRadius: AppRadius.brMd,
                ),
                child: Icon(Icons.security_rounded, color: contract.isEscrowActive ? AppColors.success : (isDark ? AppColors.textTertiary : AppColors.lightTextTertiary), size: 20),
              ),
              SizedBox(width: SpacingScale.s10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contract.isEscrowActive ? 'Escrow Active' : 'Escrow Inactive',
                      style: AppTextStyles.title2.copyWith(
                        fontWeight: FontWeight.w600,
                        color: contract.isEscrowActive ? AppColors.success : (isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
                      ),
                    ),
                    Text(
                      '₹${(contract.totalAmount * 0.3).toStringAsFixed(0)} held',
                      style: AppTextStyles.caption.copyWith(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
                    ),
                  ],
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w700,
                  color: contract.isEscrowActive ? AppColors.success : (isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
                ),
              ),
            ],
          ),
          if (contract.isEscrowActive) ...[
            SizedBox(height: SpacingScale.s12),
            ClipRRect(
              borderRadius: AppRadius.brSm,
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: isDark ? AppColors.border : AppColors.lightBorder,
                valueColor: const AlwaysStoppedAnimation(AppColors.success),
              ),
            ),
            SizedBox(height: SpacingScale.s8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${((1 - progress) * 100).toInt()}% remaining',
                  style: AppTextStyles.caption.copyWith(color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
                ),
                Text(
                  contract.escrowReleaseDate != null
                      ? 'Release: ${contract.escrowReleaseDate!.day}/${contract.escrowReleaseDate!.month}/${contract.escrowReleaseDate!.year}'
                      : 'No release date set',
                  style: AppTextStyles.caption.copyWith(color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
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
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(SpacingScale.s12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl2,
        border: Border.all(
          color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: AppRadius.brMd,
            ),
            child: const Icon(Icons.fingerprint_rounded, size: 18, color: AppColors.primary),
          ),
          SizedBox(width: SpacingScale.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.title2.copyWith(fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary)),
                Text(
                  signed
                      ? (signedAt != null ? 'Signed ${signedAt.day}/${signedAt.month}/${signedAt.year}' : 'Signed')
                      : 'Not signed yet',
                  style: AppTextStyles.caption.copyWith(
                    color: signed ? AppColors.success : (isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
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
