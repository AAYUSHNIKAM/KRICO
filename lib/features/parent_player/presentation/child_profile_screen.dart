import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/radius/radius.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../design_system/widgets/inputs/text_field_widget.dart';
import '../../../design_system/widgets/page_headers/page_hero.dart';
import '../../../models/player_model.dart';
import '../../../models/gamification_model.dart';
import '../../../services/progress_and_gamification_service.dart';
import '../../profile/presentation/widgets/certificate_viewer_dialog.dart';
import '../../../services/providers.dart';

class ChildProfileScreen extends ConsumerStatefulWidget {
  const ChildProfileScreen({super.key, required this.playerId});

  final String playerId;

  @override
  ConsumerState<ChildProfileScreen> createState() => _ChildProfileScreenState();
}

class _ChildProfileScreenState extends ConsumerState<ChildProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _emergencyCtrl = TextEditingController();
  final _medicalNotesCtrl = TextEditingController();
  final _schoolCtrl = TextEditingController();
  String? _bloodGroup;
  final Set<String> _selectedSports = {};
  bool _isSaving = false;
  bool _isUnlinking = false;

  static const List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _emergencyCtrl.dispose();
    _medicalNotesCtrl.dispose();
    _schoolCtrl.dispose();
    super.dispose();
  }

  void _syncForm(PlayerModel player) {
    if (_nameCtrl.text == player.name &&
        _ageCtrl.text == (player.age?.toString() ?? '') &&
        _emergencyCtrl.text == (player.emergencyContact ?? '') &&
        _medicalNotesCtrl.text == (player.medicalNotes ?? '') &&
        _schoolCtrl.text == (player.schoolOrClub ?? '') &&
        _bloodGroup == player.bloodGroup) {
      return;
    }

    _nameCtrl.text = player.name;
    _ageCtrl.text = player.age?.toString() ?? '';
    _emergencyCtrl.text = player.emergencyContact ?? '';
    _medicalNotesCtrl.text = player.medicalNotes ?? '';
    _schoolCtrl.text = player.schoolOrClub ?? '';
    _bloodGroup = player.bloodGroup;
    _selectedSports
      ..clear()
      ..addAll(player.sports ?? const []);
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      await ref.read(parentServiceProvider).updateChild(widget.playerId, {
        'name': name,
        'age': int.tryParse(_ageCtrl.text.trim()),
        'sports': _selectedSports.toList(),
        'emergencyContact': _emergencyCtrl.text.trim(),
        'medicalNotes': _medicalNotesCtrl.text.trim(),
        'schoolOrClub': _schoolCtrl.text.trim(),
        if (_bloodGroup != null) 'bloodGroup': _bloodGroup,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Child profile & medical records updated'), backgroundColor: AppColors.success),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _unlink() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.surface : AppColors.lightSurface,
        title: Text(
          'Unlink child?',
          style: TextStyle(color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary),
        ),
        content: Text(
          'The child will be unlinked from your account and can be linked to another parent.',
          style: TextStyle(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Unlink', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isUnlinking = true);
    try {
      await ref.read(parentServiceProvider).unlinkChild(widget.playerId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Child unlinked'), backgroundColor: AppColors.success),
      );
      context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to unlink: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isUnlinking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.card : AppColors.lightCard;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final playerAsync = ref.watch(playerProvider(widget.playerId));

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: CustomScrollView(
            slivers: [
          playerAsync.when(
            data: (player) => PageHero(
              title: player.name,
              subtitle: player.level ?? 'Beginner',
              backgroundColor: AppColors.primary,
              showPhoneHeader: true,
              phoneTitle: player.name,
              heroExtra: [
                const SizedBox(height: SpacingScale.s8),
                Text(
                  '${player.points} XP',
                  style: AppTextStyles.title2.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            loading: () => const PageHero(
              title: 'Child',
              backgroundColor: AppColors.primary,
              showPhoneHeader: true,
              phoneTitle: 'Child',
            ),
            error: (_, _) => const PageHero(
              title: 'Child',
              backgroundColor: AppColors.primary,
              showPhoneHeader: true,
              phoneTitle: 'Child',
            ),
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
                playerAsync.when(
                  data: (player) {
                    _syncForm(player);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsRow(player),
                        const SizedBox(height: SpacingScale.s16),
                        _buildMilestonesAndCertificates(player),
                        const SizedBox(height: SpacingScale.s20),
                        _buildEditableCard(
                          isDark,
                          cardColor,
                          borderColor,
                          textSecondary,
                        ),
                        const SizedBox(height: SpacingScale.s20),
                        GestureDetector(
                          onTap: _isUnlinking ? null : _unlink,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: SpacingScale.s12),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withValues(alpha: 0.1),
                              borderRadius: AppRadius.brXl2,
                              border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isUnlinking)
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.danger),
                                  )
                                else
                                  const Icon(Icons.link_off_rounded, size: 18, color: AppColors.danger),
                                const SizedBox(width: SpacingScale.s8),
                                Text(
                                  _isUnlinking ? 'Unlinking...' : 'Unlink Child',
                                  style: AppTextStyles.label.copyWith(
                                    color: AppColors.danger,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(SpacingScale.s40),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.all(SpacingScale.s24),
                    child: Text('Failed to load child: $e', style: const TextStyle(color: AppColors.danger)),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    ),
  ),
);
}

  Widget _buildStatsRow(PlayerModel player) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(child: _buildStat('Rank', '${player.rank}', Icons.emoji_events_rounded, AppColors.gold, isDark)),
        const SizedBox(width: SpacingScale.s12),
        Expanded(child: _buildStat('Wins', '${player.championshipWins}', Icons.stars_rounded, AppColors.purple, isDark)),
        const SizedBox(width: SpacingScale.s12),
        Expanded(child: _buildStat('Tournament Pts', '${player.tournamentPoints}', Icons.workspace_premium_rounded, AppColors.primary, isDark)),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildMilestonesAndCertificates(PlayerModel player) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final level = LevelModel.getLevel(player.points);
    final certsAsync = ref.watch(playerCertificatesProvider(player.playerId));
    final readiness = player.readinessStatus;

    final readinessColor = readiness == 'Elite Roster'
        ? AppColors.gold
        : readiness == 'Tournament Ready'
            ? AppColors.emerald
            : readiness == 'Sparring Ready'
                ? AppColors.primary
                : const Color(0xFF94A3B8);

    return Container(
      padding: const EdgeInsets.all(SpacingScale.s16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl3,
        border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: SpacingScale.s8),
                  Text(
                    'Level ${level.level} \u2022 ${level.title}',
                    style: AppTextStyles.title3.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: readinessColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.brFull,
                  border: Border.all(color: readinessColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  readiness,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: readinessColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingScale.s10),
          Row(
            children: [
              Icon(Icons.local_fire_department_rounded, size: 14, color: AppColors.orange),
              const SizedBox(width: 4),
              Text(
                'Streak: ${player.consistencyStreak} Session${player.consistencyStreak > 1 ? "s" : ""} (76h consistency window)',
                style: AppTextStyles.captionXs.copyWith(color: AppColors.orange, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: SpacingScale.s12),

          certsAsync.when(
            data: (certs) {
              if (certs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'No prestige certificates unlocked yet (${100 - player.points} XP to first certificate)',
                    style: AppTextStyles.captionXs.copyWith(
                      color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                    ),
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prestige Certificates (${certs.length} Earned)',
                    style: AppTextStyles.captionXs.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: SpacingScale.s8),
                  Wrap(
                    spacing: SpacingScale.s8,
                    runSpacing: SpacingScale.s8,
                    children: certs.map((cert) {
                      final tier = cert.tierDefinition;
                      return InkWell(
                        onTap: () => CertificateViewerDialog.show(context, cert),
                        borderRadius: AppRadius.brFull,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: tier.primaryColor.withValues(alpha: 0.12),
                            borderRadius: AppRadius.brFull,
                            border: Border.all(color: tier.borderColor.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(tier.crestBadge, style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              Text(
                                tier.title,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: tier.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_outward_rounded, size: 10, color: Colors.grey),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(SpacingScale.s16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl3,
        border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: AppRadius.brLg),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: SpacingScale.s10),
          Text(value, style: AppTextStyles.numericSm.copyWith(fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary)),
          const SizedBox(height: SpacingScale.s2),
          Text(label, style: AppTextStyles.labelSm.copyWith(color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary)),
        ],
      ),
    );
  }

  Widget _buildEditableCard(
    bool isDark,
    Color cardColor,
    Color borderColor,
    Color textSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(SpacingScale.s16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: AppRadius.brXl3,
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Edit Details', style: AppTextStyles.title2.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: SpacingScale.s16),
          AppTextField(
            label: 'Child Name',
            controller: _nameCtrl,
            prefixIcon: const Icon(Icons.child_care_rounded, size: 18),
          ),
          const SizedBox(height: SpacingScale.s16),
          AppTextField(
            label: 'Age',
            controller: _ageCtrl,
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.cake_outlined, size: 18),
          ),
          const SizedBox(height: SpacingScale.s16),
          AppTextField(
            label: 'School / Academy Club',
            controller: _schoolCtrl,
            prefixIcon: const Icon(Icons.school_outlined, size: 18),
          ),
          const SizedBox(height: SpacingScale.s16),
          AppTextField(
            label: 'Emergency / Guardian Phone *',
            controller: _emergencyCtrl,
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(Icons.emergency_outlined, size: 18),
          ),
          const SizedBox(height: SpacingScale.s16),
          Text('Blood Group', style: AppTextStyles.label.copyWith(color: textSecondary)),
          const SizedBox(height: SpacingScale.s8),
          Wrap(
            spacing: SpacingScale.s8,
            runSpacing: SpacingScale.s8,
            children: _bloodGroups.map((bg) {
              final isSelected = _bloodGroup == bg;
              return GestureDetector(
                onTap: () => setState(() => _bloodGroup = isSelected ? null : bg),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.danger.withValues(alpha: 0.15)
                        : (isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary),
                    borderRadius: AppRadius.brFull,
                    border: Border.all(
                      color: isSelected ? AppColors.danger : borderColor,
                      width: isSelected ? 1.5 : 0.5,
                    ),
                  ),
                  child: Text(
                    bg,
                    style: AppTextStyles.labelSm.copyWith(
                      color: isSelected ? AppColors.danger : textSecondary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: SpacingScale.s16),
          AppTextField(
            label: 'Medical Conditions / Allergies / Notes',
            controller: _medicalNotesCtrl,
            prefixIcon: const Icon(Icons.medical_information_outlined, size: 18),
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
          GestureDetector(
            onTap: _isSaving ? null : _save,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: SpacingScale.s12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
                borderRadius: AppRadius.brXl2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isSaving)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  else
                    const Icon(Icons.save_rounded, size: 18, color: Colors.white),
                  const SizedBox(width: SpacingScale.s8),
                  Text(
                    _isSaving ? 'Saving...' : 'Save Changes',
                    style: AppTextStyles.label.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms);
  }
}
