import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../design_system/colors/app_colors.dart';
import '../../../../../design_system/typography/text_styles.dart';
import '../../../../../design_system/spacing/spacing_scale.dart';
import '../../../../../design_system/radius/radius.dart';
import '../../../../../design_system/responsive/responsive_helpers.dart';
import '../../../../../services/providers.dart';
import '../../../../../models/academy_model.dart';

class AcademyAdvertisingSection extends ConsumerWidget {
  final AcademyModel academy;

  const AcademyAdvertisingSection({super.key, required this.academy});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            title: 'Advertising Suite',
            icon: Icons.campaign_rounded,
            color: AppColors.purple,
            isDark: isDark,
          ),
          const SizedBox(height: SpacingScale.s12),
          _AdCard(academy: academy),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
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
    ]);
  }
}

class _AdCard extends ConsumerWidget {
  final AcademyModel academy;

  const _AdCard({required this.academy});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(SpacingScale.s16),
      decoration: BoxDecoration(
        color: AppColors.purple.withValues(alpha: isDark ? 0.08 : 0.05),
        borderRadius: AppRadius.brXl3,
        border: Border.all(color: AppColors.purple.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.campaign_rounded, color: AppColors.purple),
              const SizedBox(width: SpacingScale.s8),
              Text('Promote Your Academy',
                  style: AppTextStyles.title3.copyWith(fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary)),
            ],
          ),
          const SizedBox(height: SpacingScale.s12),
          Row(
            children: [
              Expanded(child: _AdOption(
                label: 'Product Ads',
                icon: Icons.shopping_bag_rounded,
                color: AppColors.purple,
                isDark: isDark,
              )),
              const SizedBox(width: SpacingScale.s8),
              Expanded(child: _AdOption(
                label: 'Social Boost',
                icon: Icons.share_rounded,
                color: AppColors.primary,
                isDark: isDark,
              )),
              const SizedBox(width: SpacingScale.s8),
              Expanded(child: _AdOption(
                label: 'Community',
                icon: Icons.groups_rounded,
                color: AppColors.emerald,
                isDark: isDark,
              )),
            ],
          ),
          const SizedBox(height: SpacingScale.s12),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _showCreateCampaignDialog(context, ref),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: SpacingScale.s12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
                  borderRadius: AppRadius.brXl2,
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.campaign_rounded, size: 16, color: Colors.white),
                  const SizedBox(width: SpacingScale.s8),
                  Text('Create Campaign', style: AppTextStyles.buttonLg.copyWith(color: Colors.white)),
                ]),
              ),
            ),
          ),
        ],
      ),
    ).animate(delay: 300.ms).fadeIn(duration: 350.ms).slideY(begin: 0.06, end: 0);
  }

  void _showCreateCampaignDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final budgetCtrl = TextEditingController();
    String selectedType = 'Product Ads';
    final service = ref.read(academyServiceProvider);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          final dialogTextColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
          final dialogSecondaryColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
          return AlertDialog(
            backgroundColor: isDark ? AppColors.surface : AppColors.lightSurface,
            title: Text('Create Campaign', style: TextStyle(color: dialogTextColor)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    dropdownColor: isDark ? AppColors.surface : AppColors.lightSurface,
                    style: TextStyle(color: dialogTextColor),
                    decoration: InputDecoration(
                      labelText: 'Campaign Type',
                      labelStyle: TextStyle(color: dialogSecondaryColor),
                      border: const OutlineInputBorder(),
                    ),
                    items: ['Product Ads', 'Social Boost', 'Community']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setDialogState(() => selectedType = v ?? 'Product Ads'),
                  ),
                  const SizedBox(height: SpacingScale.s12),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Campaign Name',
                      hintText: 'e.g. Summer Cricket Camp',
                      labelStyle: TextStyle(color: dialogSecondaryColor),
                      hintStyle: TextStyle(color: dialogSecondaryColor.withValues(alpha: 0.5)),
                      border: const OutlineInputBorder(),
                    ),
                    style: TextStyle(color: dialogTextColor),
                  ),
                  const SizedBox(height: SpacingScale.s12),
                  TextField(
                    controller: budgetCtrl,
                    decoration: InputDecoration(
                      labelText: 'Budget (\u20B9)',
                      hintText: 'e.g. 5000',
                      labelStyle: TextStyle(color: dialogSecondaryColor),
                      hintStyle: TextStyle(color: dialogSecondaryColor.withValues(alpha: 0.5)),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: dialogTextColor),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Cancel', style: TextStyle(color: dialogSecondaryColor)),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    if (nameCtrl.text.isNotEmpty && budgetCtrl.text.isNotEmpty) {
                      service.createCampaign(
                        academyId: academy.academyId,
                        name: nameCtrl.text.trim(),
                        budget: double.tryParse(budgetCtrl.text) ?? 0,
                        type: selectedType,
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Campaign "${nameCtrl.text}" created!')),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: SpacingScale.s12, horizontal: SpacingScale.s16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
                      borderRadius: AppRadius.brXl2,
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                      const SizedBox(width: SpacingScale.s8),
                      Text('Create', style: AppTextStyles.buttonLg.copyWith(color: Colors.white)),
                    ]),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AdOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _AdOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: SpacingScale.s12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppRadius.brLg,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: SpacingScale.s4),
          Text(label, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500, color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary)),
        ],
      ),
    );
  }
}
