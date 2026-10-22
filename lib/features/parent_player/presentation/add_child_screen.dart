import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/radius/radius.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../design_system/widgets/inputs/segment_control.dart';
import '../../../design_system/widgets/inputs/text_field_widget.dart';
import '../../../design_system/widgets/page_headers/page_hero.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/providers.dart';

class AddChildScreen extends ConsumerStatefulWidget {
  const AddChildScreen({super.key});

  @override
  ConsumerState<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends ConsumerState<AddChildScreen> {
  final _newChildFormKey = GlobalKey<FormState>();
  final _linkFormKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  int _mode = 0;
  final Set<String> _selectedSports = {};
  bool _isSubmitting = false;
  String? _generatedPin;
  double _monthlyLimit = 5000.0;
  bool _requireApproval = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _addNewChild() async {
    final parentId = ref.read(authStateProvider).value?.uid;
    if (parentId == null) return;
    if (!(_newChildFormKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    try {
      final playerId = await ref.read(parentServiceProvider).addChild(
            parentId: parentId,
            name: _nameCtrl.text.trim(),
            age: int.tryParse(_ageCtrl.text.trim()),
            sports: _selectedSports.toList(),
            monthlyLimit: _monthlyLimit,
            requireApproval: _requireApproval,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${_nameCtrl.text.trim()} to your family'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop(playerId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add child: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _linkExisting() async {
    final parentId = ref.read(authStateProvider).value?.uid;
    if (parentId == null) return;
    if (!(_linkFormKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    try {
      final player = await ref.read(parentServiceProvider).linkChildByEmail(
            parentId: parentId,
            email: _emailCtrl.text.trim(),
          );
      if (!mounted) return;
      if (player == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No player account found with that email'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${player.name} is now linked to your family'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop(player.playerId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.card : AppColors.lightCard;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const PageHero(
            title: 'Add a Child',
            subtitle: 'Add a new child or link an existing player account',
            backgroundColor: AppColors.primary,
            showPhoneHeader: true,
            phoneTitle: 'Add a Child',
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              SpacingScale.s16,
              SpacingScale.s16,
              SpacingScale.s16,
              SpacingScale.s32,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SegmentControl(
                  segments: const ['New Child', 'Link by Email', 'Family PIN'],
                  selectedIndex: _mode,
                  onChanged: (i) => setState(() => _mode = i),
                ),
                const SizedBox(height: SpacingScale.s16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _mode == 0
                      ? _buildNewChildForm(isDark, cardColor, borderColor, textPrimary, textSecondary)
                      : (_mode == 1
                          ? _buildLinkForm(isDark, cardColor, borderColor, textPrimary, textSecondary)
                          : _buildPinInviteCard(isDark, cardColor, borderColor, textPrimary, textSecondary)),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewChildForm(
      bool isDark, Color cardColor, Color borderColor, Color textPrimary, Color textSecondary) {
    return Form(
      key: _newChildFormKey,
      child: Container(
        key: const ValueKey('new-child'),
        padding: const EdgeInsets.all(SpacingScale.s16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: AppRadius.brXl3,
          border: Border.all(color: borderColor, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              label: 'Child Name',
              hint: 'e.g. Aarav Sharma',
              controller: _nameCtrl,
              prefixIcon: const Icon(Icons.child_care_rounded, size: 18),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: SpacingScale.s16),
            AppTextField(
              label: 'Age (optional)',
              hint: 'e.g. 12',
              controller: _ageCtrl,
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.cake_outlined, size: 18),
            ),
            const SizedBox(height: SpacingScale.s20),
            Text('Sports', style: AppTextStyles.label.copyWith(color: textSecondary)),
            const SizedBox(height: SpacingScale.s10),
            Wrap(
              spacing: SpacingScale.s8,
              runSpacing: SpacingScale.s8,
              children: AppConstants.sportCategories.map((sport) {
                final isSelected = _selectedSports.contains(sport);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (isSelected) {
                      _selectedSports.remove(sport);
                    } else {
                      _selectedSports.add(sport);
                    }
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingScale.s12,
                      vertical: SpacingScale.s8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.14)
                          : (isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary),
                      borderRadius: AppRadius.brFull,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : borderColor,
                        width: isSelected ? 1.2 : 0.5,
                      ),
                    ),
                    child: Text(
                      sport,
                      style: AppTextStyles.labelSm.copyWith(
                        color: isSelected ? AppColors.primary : textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: SpacingScale.s24),
            _buildSubmitButton(
              label: 'Add Child',
              loading: _isSubmitting,
              onTap: _isSubmitting ? null : _addNewChild,
              icon: Icons.person_add_alt_1_rounded,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 250.ms);
  }

  Widget _buildLinkForm(
      bool isDark, Color cardColor, Color borderColor, Color textPrimary, Color textSecondary) {
    return Form(
      key: _linkFormKey,
      child: Container(
        key: const ValueKey('link-existing'),
        padding: const EdgeInsets.all(SpacingScale.s16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: AppRadius.brXl3,
          border: Border.all(color: borderColor, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              label: 'Child Email',
              hint: 'e.g. child@example.com',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email_outlined, size: 18),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                if (!v.contains('@')) return 'Invalid email format';
                return null;
              },
            ),
            const SizedBox(height: SpacingScale.s24),
            _buildSubmitButton(
              label: 'Link Child',
              loading: _isSubmitting,
              onTap: _isSubmitting ? null : _linkExisting,
              icon: Icons.link_rounded,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 250.ms);
  }

  Widget _buildSubmitButton({
    required String label,
    required bool loading,
    required VoidCallback? onTap,
    required IconData icon,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }

  Widget _buildPinInviteCard(
      bool isDark, Color cardColor, Color borderColor, Color textPrimary, Color textSecondary) {
    final parentId = ref.read(authStateProvider).value?.uid;

    return Container(
      padding: const EdgeInsets.all(SpacingScale.s20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: AppRadius.brXl2,
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(SpacingScale.s10),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.15),
                  borderRadius: AppRadius.brLg,
                ),
                child: const Icon(Icons.pin_rounded, color: AppColors.emerald, size: 24),
              ),
              const SizedBox(width: SpacingScale.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Family Invite PIN', style: AppTextStyles.heading3.copyWith(color: textPrimary)),
                    Text('Generate a secure 6-digit code for your child',
                        style: AppTextStyles.bodySm.copyWith(color: textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingScale.s20),

          if (_generatedPin != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(SpacingScale.s20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surface : Colors.white,
                borderRadius: AppRadius.brXl,
                border: Border.all(color: AppColors.emerald, width: 2),
              ),
              child: Column(
                children: [
                  Text('ACTIVE INVITE CODE',
                      style: AppTextStyles.caption.copyWith(color: AppColors.emerald, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: SpacingScale.s8),
                  Text(
                    _generatedPin!,
                    style: AppTextStyles.heading1.copyWith(
                      color: textPrimary,
                      letterSpacing: 6,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: SpacingScale.s8),
                  Text('Valid for 48 hours • Single Use',
                      style: AppTextStyles.caption.copyWith(color: textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: SpacingScale.s20),
          ],

          Text('Parental Controls & Limits', style: AppTextStyles.title2.copyWith(color: textPrimary)),
          const SizedBox(height: SpacingScale.s12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Monthly Budget Limit', style: AppTextStyles.body.copyWith(color: textPrimary)),
              Text('₹${_monthlyLimit.toInt()}',
                  style: AppTextStyles.title2.copyWith(color: AppColors.emerald, fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: _monthlyLimit,
            min: 1000,
            max: 20000,
            divisions: 19,
            activeColor: AppColors.emerald,
            label: '₹${_monthlyLimit.toInt()}',
            onChanged: (val) => setState(() => _monthlyLimit = val),
          ),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Require Booking Consent', style: AppTextStyles.body.copyWith(color: textPrimary)),
            subtitle: Text('Child must request your approval for paid sessions',
                style: AppTextStyles.caption.copyWith(color: textSecondary)),
            value: _requireApproval,
            activeThumbColor: AppColors.emerald,
            onChanged: (val) => setState(() => _requireApproval = val),
          ),

          const SizedBox(height: SpacingScale.s20),

          ElevatedButton.icon(
            onPressed: _isSubmitting || parentId == null
                ? null
                : () async {
                    setState(() => _isSubmitting = true);
                    try {
                      final pin = await ref.read(parentServiceProvider).createFamilyInvitePin(
                            parentId: parentId,
                            monthlySpendingLimit: _monthlyLimit,
                            requireBookingApproval: _requireApproval,
                          );
                      if (mounted) {
                        setState(() => _generatedPin = pin);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Family invite code $pin generated!'),
                            backgroundColor: AppColors.emerald,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.danger),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _isSubmitting = false);
                    }
                  },
            icon: const Icon(Icons.key_rounded, size: 18),
            label: Text(_generatedPin == null ? 'Generate Family Invite PIN' : 'Regenerate New PIN'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emerald,
              foregroundColor: Colors.black,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms);
  }
}
