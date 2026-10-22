import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../design_system/radius/radius.dart';
import '../../../services/providers.dart';

class AdvertisingTab extends ConsumerWidget {
  final String academyId;
  const AdvertisingTab({super.key, required this.academyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignsAsync = ref.watch(academyCampaignsProvider(academyId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final count = campaignsAsync.asData?.value.docs.length ?? 0;

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          _AdvertisingHeroHeader(
            activeCampaignsCount: count,
            onLaunchCampaign: () => _showCreateCampaignDialog(context, ref),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Growth Channels Section Header
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.cyan.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.cyan,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'PROMOTIONAL CHANNELS',
                                style: AppTextStyles.captionXs.copyWith(
                                  color: AppColors.cyan,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => _showCreateCampaignDialog(context, ref),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.volt, Color(0xFF99E600)],
                            ),
                            borderRadius: AppRadius.brFull,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.volt.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add_rounded, size: 16, color: Color(0xFF0F172A)),
                              const SizedBox(width: 6),
                              Text(
                                'New Campaign',
                                style: AppTextStyles.labelSm.copyWith(
                                  color: const Color(0xFF0F172A),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Channel Cards
                _buildAdOptionCard(
                  context,
                  title: 'Product & Program Ads',
                  subtitle: 'Showcase seasonal coaching camps & programs directly to aspiring players and parents',
                  icon: Icons.campaign_rounded,
                  badgeText: 'HIGH CONVERSION',
                  accentColor: const Color(0xFF8B5CF6),
                  onTap: () => _showCreateCampaignDialog(context, ref, defaultType: 'Product Ads'),
                ).animate(delay: 50.ms).fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),
                const SizedBox(height: 10),

                _buildAdOptionCard(
                  context,
                  title: 'Social Broadcast Boost',
                  subtitle: 'Amplify viral training clips, drills, and academy achievements across member feeds',
                  icon: Icons.bolt_rounded,
                  badgeText: 'VIRAL REACH',
                  accentColor: AppColors.cyan,
                  onTap: () => _showCreateCampaignDialog(context, ref, defaultType: 'Social Boost'),
                ).animate(delay: 100.ms).fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),
                const SizedBox(height: 10),

                _buildAdOptionCard(
                  context,
                  title: 'Community Sponsorship',
                  subtitle: 'Sponsor tournament brackets, 1v1 challenges, and local athletic leagues',
                  icon: Icons.emoji_events_rounded,
                  badgeText: 'GRASSROOTS',
                  accentColor: AppColors.volt,
                  onTap: () => _showCreateCampaignDialog(context, ref, defaultType: 'Community'),
                ).animate(delay: 150.ms).fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),

                const SizedBox(height: 28),

                // Active Campaigns Header
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.volt.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.flag_rounded, size: 18, color: AppColors.volt),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Active Campaigns',
                            style: AppTextStyles.title2.copyWith(
                              color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Real-time delivery status and spending allocation',
                            style: AppTextStyles.caption.copyWith(
                              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                campaignsAsync.when(
                  data: (snap) {
                    final campaigns = snap.docs;
                    if (campaigns.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.card : AppColors.lightCard,
                          borderRadius: AppRadius.brXl3,
                          border: Border.all(
                            color: isDark ? AppColors.border : AppColors.lightBorder,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.volt.withValues(alpha: 0.1),
                                ),
                                child: const Icon(Icons.campaign_outlined, size: 30, color: AppColors.volt),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'No Active Campaigns',
                                style: AppTextStyles.title3.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Launch your first advertising campaign to accelerate enrollments.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodySm.copyWith(
                                  color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () => _showCreateCampaignDialog(context, ref),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [AppColors.volt, Color(0xFF99E600)],
                                      ),
                                      borderRadius: AppRadius.brFull,
                                    ),
                                    child: Text(
                                      'Launch Campaign Now',
                                      style: AppTextStyles.labelSm.copyWith(
                                        color: const Color(0xFF0F172A),
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: campaigns.asMap().entries.map((entry) {
                        final i = entry.key;
                        final doc = entry.value;
                        final d = doc.data();
                        final name = d['name'] as String? ?? 'Promotional Campaign';
                        final type = d['type'] as String? ?? 'Product Ads';
                        final budget = (d['budget'] as num?)?.toInt() ?? 0;
                        final status = d['status'] as String? ?? 'active';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.card : AppColors.lightCard,
                            borderRadius: AppRadius.brXl3,
                            border: Border.all(
                              color: isDark ? AppColors.border : AppColors.lightBorder,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.cyan.withValues(alpha: 0.6),
                                    ],
                                  ),
                                  borderRadius: AppRadius.brLg,
                                ),
                                child: const Icon(Icons.campaign_rounded, color: Colors.white, size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.title3.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.cyan.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            type,
                                            style: AppTextStyles.captionXs.copyWith(
                                              color: AppColors.cyan,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'Budget: ₹$budget',
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.volt,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.emerald.withValues(alpha: 0.12),
                                  borderRadius: AppRadius.brFull,
                                  border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.emerald,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      status.toUpperCase(),
                                      style: AppTextStyles.captionXs.copyWith(
                                        color: AppColors.emerald,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ).animate(delay: Duration(milliseconds: i * 40)).fadeIn(duration: 250.ms);
                      }).toList(),
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: AppColors.volt),
                    ),
                  ),
                  error: (_, _) => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.08),
                      borderRadius: AppRadius.brXl2,
                      border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'Failed to load campaigns',
                      style: AppTextStyles.body.copyWith(color: AppColors.danger),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdOptionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String badgeText,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.card : AppColors.lightCard,
            borderRadius: AppRadius.brXl3,
            border: Border.all(
              color: isDark ? AppColors.border : AppColors.lightBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.brLg,
                  border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.title3.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badgeText,
                            style: AppTextStyles.captionXs.copyWith(
                              color: accentColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateCampaignDialog(
    BuildContext context,
    WidgetRef ref, {
    String defaultType = 'Product Ads',
  }) {
    final nameController = TextEditingController();
    final budgetController = TextEditingController();
    String selectedType = defaultType;
    final service = ref.read(academyServiceProvider);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: isDark ? AppColors.card : AppColors.lightCard,
                borderRadius: AppRadius.brXl3,
                border: Border.all(
                  color: isDark ? AppColors.border : AppColors.lightBorder,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.volt.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.campaign_rounded, color: AppColors.volt, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Launch Ad Campaign',
                                style: AppTextStyles.title2.copyWith(fontWeight: FontWeight.w700),
                              ),
                              Text(
                                'Configure budget and promotional target',
                                style: AppTextStyles.caption.copyWith(
                                  color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () => Navigator.pop(ctx),
                          color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Campaign Category',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: selectedType,
                      dropdownColor: isDark ? AppColors.surface : AppColors.lightSurface,
                      style: TextStyle(
                        color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark ? AppColors.surface : AppColors.lightSurface,
                        border: OutlineInputBorder(borderRadius: AppRadius.brLg),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppRadius.brLg,
                          borderSide: BorderSide(
                            color: isDark ? AppColors.border : AppColors.lightBorder,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppRadius.brLg,
                          borderSide: const BorderSide(color: AppColors.cyan, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      items: ['Product Ads', 'Social Boost', 'Community']
                          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (v) => setDialogState(
                        () => selectedType = v ?? 'Product Ads',
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Campaign Name',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      style: TextStyle(
                        color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g. Summer Cricket Masterclass Camp',
                        hintStyle: TextStyle(
                          color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: isDark ? AppColors.surface : AppColors.lightSurface,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppRadius.brLg,
                          borderSide: BorderSide(
                            color: isDark ? AppColors.border : AppColors.lightBorder,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppRadius.brLg,
                          borderSide: const BorderSide(color: AppColors.cyan, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Allocated Budget (₹)',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: budgetController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g. 5000',
                        prefixText: '₹ ',
                        prefixStyle: const TextStyle(color: AppColors.volt, fontWeight: FontWeight.bold),
                        hintStyle: TextStyle(
                          color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: isDark ? AppColors.surface : AppColors.lightSurface,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppRadius.brLg,
                          borderSide: BorderSide(
                            color: isDark ? AppColors.border : AppColors.lightBorder,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppRadius.brLg,
                          borderSide: const BorderSide(color: AppColors.cyan, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(ctx),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary,
                                  borderRadius: AppRadius.brXl,
                                ),
                                child: Center(
                                  child: Text(
                                    'Cancel',
                                    style: AppTextStyles.label.copyWith(
                                      color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                if (nameController.text.isNotEmpty && budgetController.text.isNotEmpty) {
                                  service.createCampaign(
                                    academyId: academyId,
                                    name: nameController.text.trim(),
                                    budget: double.tryParse(budgetController.text) ?? 0,
                                    type: selectedType,
                                  );
                                  // Notify followers of this academy
                                  FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(academyId)
                                      .collection('followers')
                                      .limit(50)
                                      .get()
                                      .then((snap) {
                                    for (final doc in snap.docs) {
                                      ref.read(notificationServiceProvider).createNotification(
                                        userId: doc.id,
                                        title: 'Academy Announcement',
                                        body: 'New campaign: "${nameController.text.trim()}" ($selectedType)',
                                        type: 'campaign',
                                        refId: academyId,
                                      );
                                    }
                                  }).catchError((_) {});
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Campaign "${nameController.text}" initialized!'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppColors.volt, Color(0xFF99E600)],
                                  ),
                                  borderRadius: AppRadius.brXl,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.volt.withValues(alpha: 0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.rocket_launch_rounded, size: 16, color: Color(0xFF0F172A)),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Launch Campaign',
                                      style: AppTextStyles.buttonLg.copyWith(
                                        color: const Color(0xFF0F172A),
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AdvertisingHeroHeader extends StatelessWidget {
  final int activeCampaignsCount;
  final VoidCallback onLaunchCampaign;

  const _AdvertisingHeroHeader({
    required this.activeCampaignsCount,
    required this.onLaunchCampaign,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/backgrounds/stadium_floodlights.jpg'),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 44, 16, 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.background.withValues(alpha: 0.94),
                AppColors.background.withValues(alpha: 0.80),
                AppColors.background.withValues(alpha: 0.98),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.volt.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.volt.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.volt,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'ACADEMY SPONSORSHIP & GROWTH',
                        style: AppTextStyles.captionXs.copyWith(
                          color: AppColors.volt,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Advertising & Reach',
                style: AppTextStyles.title1.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Promote your academy programs, fill squad rosters, and sponsor athlete development',
                style: AppTextStyles.bodySm.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.rocket_launch_rounded, size: 14, color: AppColors.cyan),
                        const SizedBox(width: 6),
                        Text(
                          '$activeCampaignsCount Active Campaign${activeCampaignsCount == 1 ? '' : 's'}',
                          style: AppTextStyles.captionXs.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.volt.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.volt.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.trending_up_rounded, size: 14, color: AppColors.volt),
                        const SizedBox(width: 6),
                        Text(
                          'Multi-Channel Targeting',
                          style: AppTextStyles.captionXs.copyWith(
                            color: AppColors.volt,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
