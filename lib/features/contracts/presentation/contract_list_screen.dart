import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/contract_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/providers.dart';

class ContractListScreen extends ConsumerStatefulWidget {
  const ContractListScreen({super.key});

  @override
  ConsumerState<ContractListScreen> createState() => _ContractListScreenState();
}

class _ContractListScreenState extends ConsumerState<ContractListScreen> {
  String _selectedFilter = 'All';

  final _filters = ['All', 'Active', 'Pending', 'Completed', 'Disputed'];

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authStateProvider);
    final user = authAsync.asData?.value;

    if (user == null) {
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            _buildAppBar(),
      SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_rounded, size: 48, color: AppColors.textDim),
              const SizedBox(height: 16),
              Text('Sign in to view contracts', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
          ],
        ),
      );
    }

    final contractsAsync = ref.watch(userContractsProvider(user.uid));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final selected = _selectedFilter == filter;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: selected ? const LinearGradient(colors: AppColors.gradientPrimary) : null,
                        color: selected ? null : AppColors.cardDark,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? Colors.transparent : AppColors.borderLight.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          filter,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: selected ? Colors.white : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
                },
              ),
            ),
          ),
          contractsAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text('Failed to load contracts', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => ref.invalidate(userContractsProvider(user.uid)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
            data: (contracts) {
              final filtered = _selectedFilter == 'All'
                  ? contracts
                  : contracts.where((c) => c.status.name.toLowerCase() == _selectedFilter.toLowerCase()).toList();

              if (filtered.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.description_rounded, size: 64, color: AppColors.textDim.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text(
                          _selectedFilter == 'All' ? 'No contracts yet' : 'No ${_selectedFilter.toLowerCase()} contracts',
                          style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your contracts will appear here',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDim),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildContractCard(filtered[index]),
                    childCount: filtered.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.gradientDark,
            ),
          ),
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Contracts', style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContractCard(ContractModel contract) {
    final statusColors = {
      ContractStatus.draft: AppColors.textDim,
      ContractStatus.pending: AppColors.warning,
      ContractStatus.active: AppColors.success,
      ContractStatus.completed: AppColors.info,
      ContractStatus.cancelled: AppColors.error,
      ContractStatus.disputed: AppColors.error,
    };
    final typeLabels = {
      ContractType.coaching: 'Coaching',
      ContractType.academy: 'Academy',
      ContractType.subscription: 'Subscription',
    };
    final typeIcons = {
      ContractType.coaching: Icons.sports_rounded,
      ContractType.academy: Icons.business_rounded,
      ContractType.subscription: Icons.workspace_premium_rounded,
    };

    final statusColor = statusColors[contract.status] ?? AppColors.primary;
    final typeLabel = typeLabels[contract.type] ?? 'Contract';
    final typeIcon = typeIcons[contract.type] ?? Icons.description_rounded;
    final dateStr = contract.createdAt != null
        ? '${contract.createdAt!.day} ${_monthAbbr(contract.createdAt!.month)} ${contract.createdAt!.year}'
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(typeIcon, color: statusColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$typeLabel Contract', style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(
                      '${contract.partyARole} → ${contract.partyBRole} · $dateStr',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹${contract.totalAmount.toStringAsFixed(0)}', style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      contract.status.name.toUpperCase(),
                      style: AppTextStyles.labelSmall.copyWith(color: statusColor, fontWeight: FontWeight.w700, fontSize: 9, letterSpacing: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.security_rounded, size: 13, color: contract.isEscrowActive ? AppColors.success : AppColors.textDim),
              const SizedBox(width: 4),
              Text(
                contract.isEscrowActive ? 'Escrow Protected' : 'No Escrow',
                style: AppTextStyles.caption.copyWith(color: contract.isEscrowActive ? AppColors.success : AppColors.textDim, fontSize: 10),
              ),
              const SizedBox(width: 16),
              Icon(Icons.fingerprint_rounded, size: 13, color: (contract.digitalSignatureA != null && contract.digitalSignatureB != null) ? AppColors.primary : AppColors.textDim),
              const SizedBox(width: 4),
              Text(
                (contract.digitalSignatureA != null && contract.digitalSignatureB != null) ? 'Digitally Signed' : 'Pending Signatures',
                style: AppTextStyles.caption.copyWith(
                  color: (contract.digitalSignatureA != null && contract.digitalSignatureB != null) ? AppColors.primary : AppColors.textDim,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08, end: 0);
  }

  String _monthAbbr(int month) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month];
  }
}
