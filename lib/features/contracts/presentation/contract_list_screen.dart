import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../design_system/radius/radius.dart';
import '../../../design_system/tokens/duration_tokens.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authAsync = ref.watch(authStateProvider);
    final user = authAsync.asData?.value;

    if (user == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
        body: CustomScrollView(
          slivers: [
            _buildAppBar(isDark),
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_rounded, size: 48, color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
                    SizedBox(height: SpacingScale.s16),
                    Text('Sign in to view contracts', style: AppTextStyles.bodyLg.copyWith(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
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
      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(isDark),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s16),
                itemCount: _filters.length,
                separatorBuilder: (_, _) => SizedBox(width: SpacingScale.s8),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final selected = _selectedFilter == filter;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: AnimatedContainer(
                      duration: DurationTokens.fast,
                      padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s16, vertical: SpacingScale.s8),
                      decoration: BoxDecoration(
                        gradient: selected ? LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]) : null,
                        color: selected ? null : (isDark ? AppColors.card : AppColors.lightCard),
                        borderRadius: AppRadius.brFull,
                        border: Border.all(
                          color: selected ? Colors.transparent : (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          filter,
                          style: AppTextStyles.label.copyWith(
                            color: selected ? Colors.white : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
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
                    Icon(Icons.error_outline_rounded, size: 48, color: AppColors.danger),
                    SizedBox(height: SpacingScale.s16),
                    Text('Failed to load contracts', style: AppTextStyles.bodyLg.copyWith(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
                    SizedBox(height: SpacingScale.s12),
                    GestureDetector(
                      onTap: () => ref.invalidate(userContractsProvider(user.uid)),
                      child: Text('Retry', style: AppTextStyles.button.copyWith(color: AppColors.primary)),
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
                        Icon(Icons.description_rounded, size: 64, color: (isDark ? AppColors.textTertiary : AppColors.lightTextTertiary).withValues(alpha: 0.5)),
                        SizedBox(height: SpacingScale.s16),
                        Text(
                          _selectedFilter == 'All' ? 'No contracts yet' : 'No ${_selectedFilter.toLowerCase()} contracts',
                          style: AppTextStyles.title2.copyWith(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
                        ),
                        SizedBox(height: SpacingScale.s8),
                        Text(
                          'Your contracts will appear here',
                          style: AppTextStyles.body.copyWith(color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(SpacingScale.s16, SpacingScale.s12, SpacingScale.s16, SpacingScale.s32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildContractCard(filtered[index], isDark),
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

  Widget _buildAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 150,
      floating: false,
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 2,
      backgroundColor: isDark ? const Color(0xFF0F1219) : AppColors.lightSurface,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00E5FF), Color(0xFF0072FF)],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'ESCROW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Pro Contracts',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ],
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/backgrounds/stadium_tunnel.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF0F1219)),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.35),
                    Colors.black.withValues(alpha: 0.88),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContractCard(ContractModel contract, bool isDark) {
    final statusColors = {
      ContractStatus.draft: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
      ContractStatus.pending: AppColors.warning,
      ContractStatus.active: AppColors.success,
      ContractStatus.completed: AppColors.primary,
      ContractStatus.cancelled: AppColors.danger,
      ContractStatus.disputed: AppColors.danger,
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
      margin: const EdgeInsets.only(bottom: SpacingScale.s12),
      padding: const EdgeInsets.all(SpacingScale.s16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl3,
        border: Border.all(
          color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5),
          width: 0.5,
        ),
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
                  borderRadius: AppRadius.brLg,
                ),
                child: Icon(typeIcon, color: statusColor, size: 22),
              ),
              SizedBox(width: SpacingScale.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$typeLabel Contract', style: AppTextStyles.title2.copyWith(fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary)),
                    SizedBox(height: SpacingScale.s2),
                    Text(
                      '${contract.partyARole} → ${contract.partyBRole} · $dateStr',
                      style: AppTextStyles.caption.copyWith(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('₹${contract.totalAmount.toStringAsFixed(0)}', style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary)),
                    ),
                    SizedBox(height: SpacingScale.s4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: AppRadius.brSm,
                      ),
                      child: Text(
                        contract.status.name.toUpperCase(),
                        style: AppTextStyles.labelSm.copyWith(color: statusColor, fontWeight: FontWeight.w700, fontSize: 9, letterSpacing: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: SpacingScale.s12),
          Row(
            children: [
              Icon(Icons.security_rounded, size: 13, color: contract.isEscrowActive ? AppColors.success : (isDark ? AppColors.textTertiary : AppColors.lightTextTertiary)),
              SizedBox(width: SpacingScale.s4),
              Text(
                contract.isEscrowActive ? 'Escrow Protected' : 'No Escrow',
                style: AppTextStyles.caption.copyWith(color: contract.isEscrowActive ? AppColors.success : (isDark ? AppColors.textTertiary : AppColors.lightTextTertiary), fontSize: 10),
              ),
              SizedBox(width: SpacingScale.s16),
              Icon(Icons.fingerprint_rounded, size: 13, color: (contract.digitalSignatureA != null && contract.digitalSignatureB != null) ? AppColors.primary : (isDark ? AppColors.textTertiary : AppColors.lightTextTertiary)),
              SizedBox(width: SpacingScale.s4),
              Text(
                (contract.digitalSignatureA != null && contract.digitalSignatureB != null) ? 'Digitally Signed' : 'Pending Signatures',
                style: AppTextStyles.caption.copyWith(
                  color: (contract.digitalSignatureA != null && contract.digitalSignatureB != null) ? AppColors.primary : (isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
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
