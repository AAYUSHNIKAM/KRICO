import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/section_header.dart';
import '../../../services/providers.dart';

class AdvertisingTab extends ConsumerWidget {
  final String academyId;
  const AdvertisingTab({super.key, required this.academyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignsAsync = ref.watch(academyCampaignsProvider(academyId));
    final theme = Theme.of(context);

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
                    colors: AppColors.gradientSecondary,
                  ),
                ),
                padding: EdgeInsets.fromLTRB(
                    20, MediaQuery.of(context).padding.top + 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Advertising',
                        style: AppTextStyles.headlineMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                    Text('Promote your academy',
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
                Animate(
                  effects: const [
                    FadeEffect(duration: Duration(milliseconds: 400)),
                    SlideEffect(
                        begin: Offset(0, 0.05),
                        end: Offset.zero,
                        duration: Duration(milliseconds: 400)),
                  ],
                  child: _buildAdOptionCard(context, 'Product Ads',
                      Icons.shopping_bag_rounded, AppColors.secondary,
                      'Showcase your academy programs to parents'),
                ),
                const SizedBox(height: 8),
                Animate(
                  effects: const [
                    FadeEffect(
                        duration: Duration(milliseconds: 400),
                        delay: Duration(milliseconds: 100)),
                    SlideEffect(
                        begin: Offset(0, 0.05),
                        end: Offset.zero,
                        duration: Duration(milliseconds: 400),
                        delay: Duration(milliseconds: 100)),
                  ],
                  child: _buildAdOptionCard(context, 'Social Boost',
                      Icons.share_rounded, AppColors.info,
                      'Amplify reach on social media platforms'),
                ),
                const SizedBox(height: 8),
                Animate(
                  effects: const [
                    FadeEffect(
                        duration: Duration(milliseconds: 400),
                        delay: Duration(milliseconds: 200)),
                    SlideEffect(
                        begin: Offset(0, 0.05),
                        end: Offset.zero,
                        duration: Duration(milliseconds: 400),
                        delay: Duration(milliseconds: 200)),
                  ],
                  child: _buildAdOptionCard(context, 'Community',
                      Icons.groups_rounded, AppColors.success,
                      'Engage with local sports communities'),
                ),
                const SizedBox(height: 16),
                GradientButton(
                  onPressed: () => _showCreateCampaignDialog(context, ref),
                  gradient: AppColors.gradientSecondary,
                  child: const Text('Create Campaign',
                      style: TextStyle(color: Colors.white, fontSize: 13)),
                ),
                const SizedBox(height: 24),
                SectionHeader(title: 'Your Campaigns'),
                const SizedBox(height: 12),
                campaignsAsync.when(
                  data: (snap) {
                    final campaigns = snap.docs;
                    if (campaigns.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.campaign_rounded, size: 40, color: AppColors.textDim),
                              const SizedBox(height: 8),
                              Text('No campaigns yet',
                                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: campaigns.map((doc) {
                        final d = doc.data();
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.cardDark,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44, height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.campaign_rounded, color: AppColors.secondary, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(d['name'] as String? ?? '',
                                        style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600)),
                                    Text('${d['type'] ?? ''} \u2022 ₹${(d['budget'] as num?)?.toInt() ?? 0}',
                                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(d['status'] as String? ?? 'active',
                                    style: AppTextStyles.caption.copyWith(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => Text('Failed to load campaigns',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdOptionCard(
      BuildContext context, String title, IconData icon, Color color, String desc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.titleSmall
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(desc,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  void _showCreateCampaignDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final budgetController = TextEditingController();
    String selectedType = 'Product Ads';
    final service = ref.read(academyServiceProvider);
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceMid,
          title: const Text('Create Campaign'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedType,
                  dropdownColor: AppColors.surfaceMid,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Campaign Type',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Product Ads', 'Social Boost', 'Community']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedType = v ?? 'Product Ads'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Campaign Name',
                    hintText: 'e.g. Summer Cricket Camp',
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: budgetController,
                  decoration: const InputDecoration(
                    labelText: 'Budget (₹)',
                    hintText: 'e.g. 5000',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
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
                if (nameController.text.isNotEmpty && budgetController.text.isNotEmpty) {
                  service.createCampaign(
                    academyId: academyId,
                    name: nameController.text.trim(),
                    budget: double.tryParse(budgetController.text) ?? 0,
                    type: selectedType,
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Campaign "${nameController.text}" created!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              height: 38,
              child: const Text('Create', style: TextStyle(color: Colors.white, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}
