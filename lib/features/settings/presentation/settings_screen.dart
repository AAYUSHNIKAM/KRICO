import '../../../services/providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/sports_registry.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/widgets/page_headers/page_hero.dart';
import '../../../design_system/radius/radius.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../design_system/tokens/duration_tokens.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/profile_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  final UserModel userModel;

  const SettingsScreen({super.key, required this.userModel});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.background : AppColors.lightBackground;
    final cardColor = isDark ? AppColors.card : AppColors.lightCard;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final textTertiary = isDark ? AppColors.textTertiary : AppColors.lightTextTertiary;

    final liveUser =
        ref.watch(publicUserProfileProvider(widget.userModel.uid)).value ?? widget.userModel;

    final authUser = ref.watch(authStateProvider).value;
    final emailVerified = authUser?.emailVerified ?? false;

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: CustomScrollView(
            slivers: [
          PageHero(
            title: 'Settings',
            subtitle: '@${liveUser.username}',
            showPhoneHeader: true,
          ),
          SliverPadding(
            padding: EdgeInsets.all(SpacingScale.s16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildIdentityCard(liveUser, isDark, textPrimary, textSecondary)
                    .animate()
                    .fadeIn(duration: DurationTokens.medium)
                    .slideY(begin: 0.04, end: 0),
                const SizedBox(height: SpacingScale.s20),
                _buildMenuSection(context, 'Account', [
                  _MenuItem(Icons.edit_rounded, 'Edit Profile', () => _showEditProfile(context, liveUser)),
                  _MenuItem(
                    emailVerified ? Icons.verified_user_rounded : Icons.mark_email_read_rounded,
                    emailVerified ? 'Email Verified' : 'Verify Email',
                    emailVerified ? () => _showEmailVerified(context) : () => _showVerifyEmail(context),
                    trailing: emailVerified
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20)
                        : null,
                  ),
                  _MenuItem(Icons.lock_rounded, 'Change Password', () => _showChangePassword(context)),
                  _MenuItem(Icons.notifications_rounded, 'Notifications', () => _showNotificationPreferences(context, liveUser)),
                ], cardColor, borderColor, textPrimary, textSecondary, textTertiary),
                const SizedBox(height: SpacingScale.s12),
                _buildMenuSection(context, 'Preferences', [
                  _MenuItem(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    isDark ? 'Light Mode' : 'Dark Mode',
                    () => ref.read(themeModeProvider.notifier).toggle(),
                    trailing: _ThemeToggle(isDark: isDark, onToggle: () => ref.read(themeModeProvider.notifier).toggle()),
                  ),
                ], cardColor, borderColor, textPrimary, textSecondary, textTertiary),
                const SizedBox(height: SpacingScale.s12),
                _buildMenuSection(context, 'Support', [
                  _MenuItem(Icons.help_outline_rounded, 'Help Center', () => _showHelp(context)),
                  _MenuItem(Icons.headset_mic_rounded, 'Contact Us', () => _showContact(context)),
                  _MenuItem(Icons.info_outline_rounded, 'About', () => _showAbout(context)),
                ], cardColor, borderColor, textPrimary, textSecondary, textTertiary),
                const SizedBox(height: SpacingScale.s12),
                _buildMenuSection(context, 'Other', [
                  _MenuItem(Icons.description_rounded, 'Terms of Service', () => _showTermsOfService(context)),
                  _MenuItem(Icons.privacy_tip_outlined, 'Privacy Policy', () => _showPrivacyPolicy(context)),
                  _MenuItem(Icons.delete_outline_rounded, 'Delete Account', () => _confirmDeleteAccount(context),
                      color: AppColors.danger),
                ], cardColor, borderColor, textPrimary, textSecondary, textTertiary),
                const SizedBox(height: SpacingScale.s24),
                _SignOutButton(onPressed: () async {
                  await ref.read(authServiceProvider).signOut();
                  if (context.mounted) context.go('/login');
                }),
                const SizedBox(height: SpacingScale.s40),
              ]),
            ),
          ),
          ],
        ),
      ),
    ),
  );
}



  Future<void> _pickAndUploadPhoto(BuildContext context, String uid) async {
    try {
      final bytes = await ref.read(mediaUploadServiceProvider).pickCompressedImage();
      if (bytes == null) return;
      // uploading
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Optimizing & uploading profile picture...'), duration: Duration(seconds: 2)),
        );
      }
      await ref.read(mediaUploadServiceProvider).updateUserProfilePicture(
        userId: uid,
        bytes: bytes,
      );
      ref.invalidate(authStateProvider);
      ref.invalidate(publicUserProfileProvider(uid));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully! 🎉'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload picture: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      // done
    }
  }

  Widget _buildIdentityCard(
      UserModel userModel, bool isDark, Color textPrimary, Color textSecondary) {
    return Container(
      padding: const EdgeInsets.all(SpacingScale.s16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl3,
        border: Border.all(
            color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.3),
            width: 0.5),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _pickAndUploadPhoto(context, userModel.uid),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                UserAvatar(
                  userId: userModel.uid,
                  name: userModel.name,
                  photoUrl: userModel.photoUrl,
                  size: 56,
                  readOnly: true,
                  backgroundColor: AppColors.primary,
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: isDark ? AppColors.card : AppColors.lightCard, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, size: 11, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: SpacingScale.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userModel.name,
                  style: AppTextStyles.heading3.copyWith(color: textPrimary, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: SpacingScale.s2),
                Text(
                  '@${userModel.username}',
                  style: AppTextStyles.body.copyWith(color: textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: SpacingScale.s8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: AppRadius.brFull,
                  ),
                  child: Text(
                    userModel.role.name.toUpperCase(),
                    style: AppTextStyles.labelSm.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: SpacingScale.s8),
          Icon(Icons.settings_rounded, color: textSecondary, size: 24),
        ],
      ),
    );
  }

  Widget _buildMenuSection(
      BuildContext context, String title, List<_MenuItem> items,
      Color cardColor, Color borderColor, Color textPrimary, Color textSecondary, Color textTertiary) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: AppRadius.brXl2,
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(SpacingScale.s16, SpacingScale.s16, SpacingScale.s16, SpacingScale.s8),
            child: Text(title.toUpperCase(),
                style: AppTextStyles.captionXs.copyWith(
                    color: textTertiary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0)),
          ),
          ...items.map((item) => _buildMenuItem(context, item, textPrimary, textSecondary, textTertiary)),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.04, end: 0);
  }

  Widget _buildMenuItem(BuildContext context, _MenuItem item, Color textPrimary, Color textSecondary, Color textTertiary) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s16, vertical: SpacingScale.s12),
          child: Row(
            children: [
              Icon(item.icon, size: 20,
                  color: item.color ?? textSecondary),
              const SizedBox(width: SpacingScale.s12),
              Expanded(
                child: Text(item.label,
                    style: AppTextStyles.body.copyWith(
                      color: item.color ?? textPrimary,
                    )),
              ),
              if (item.trailing != null)
                item.trailing!
              else
                Icon(Icons.chevron_right_rounded,
                    size: 20, color: textTertiary),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfile(BuildContext context, UserModel userModel) {
    final nameCtrl = TextEditingController(text: userModel.name);
    final phoneCtrl = TextEditingController(text: userModel.phone);
    final cityCtrl = TextEditingController(text: userModel.city ?? '');
    final bioCtrl = TextEditingController(text: userModel.bio ?? '');
    final List<String> coachSports = List<String>.from(userModel.sports ?? []);
    final specCtrl = TextEditingController(text: userModel.specialization ?? '');
    final expCtrl = TextEditingController(text: userModel.experience != null && userModel.experience! > 0 ? userModel.experience.toString() : '');
    final rateCtrl = TextEditingController(text: userModel.hourlyRate != null && userModel.hourlyRate! > 0 ? userModel.hourlyRate!.toInt().toString() : '');
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final cardColor = isDark ? AppColors.surfaceSecondary : AppColors.lightSurface;
        final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
        final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
        final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
        final fieldBg = isDark ? AppColors.surface : AppColors.lightSurfaceSecondary;

        return StatefulBuilder(
          builder: (ctx, setSheetState) => Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: AppRadius.top(SpacingScale.s20),
                  border: Border(top: BorderSide(color: borderColor, width: 0.5)),
                ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: SpacingScale.s20,
              right: SpacingScale.s20,
              top: SpacingScale.s20,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: borderColor,
                      borderRadius: AppRadius.brFull,
                    ),
                  ),
                  const SizedBox(height: SpacingScale.s20),
                  Text('Edit Profile',
                      style: AppTextStyles.title1.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: SpacingScale.s16),
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        await _pickAndUploadPhoto(context, userModel.uid);
                        setSheetState(() {});
                      },
                      child: Stack(
                        children: [
                          UserAvatar(
                            userId: userModel.uid,
                            name: userModel.name,
                            photoUrl: userModel.photoUrl,
                            size: 64,
                            readOnly: true,
                            backgroundColor: AppColors.primary,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextButton.icon(
                    onPressed: () async {
                      await _pickAndUploadPhoto(context, userModel.uid);
                      setSheetState(() {});
                    },
                    icon: const Icon(Icons.photo_camera_rounded, size: 14, color: AppColors.primary),
                    label: const Text('Change Profile Picture', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: SpacingScale.s16),
                  _EditField(controller: nameCtrl, label: 'Name', fieldBg: fieldBg, borderColor: borderColor, textPrimary: textPrimary, textSecondary: textSecondary, validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null),
                  const SizedBox(height: SpacingScale.s12),
                  _EditField(controller: phoneCtrl, label: 'Phone', fieldBg: fieldBg, borderColor: borderColor, textPrimary: textPrimary, textSecondary: textSecondary, keyboardType: TextInputType.phone),
                  const SizedBox(height: SpacingScale.s12),
                  _EditField(controller: cityCtrl, label: 'City', fieldBg: fieldBg, borderColor: borderColor, textPrimary: textPrimary, textSecondary: textSecondary),
                  const SizedBox(height: SpacingScale.s12),
                  _EditField(controller: bioCtrl, label: 'Bio', fieldBg: fieldBg, borderColor: borderColor, textPrimary: textPrimary, textSecondary: textSecondary, maxLines: 3),
                  if (userModel.role == UserRole.coach) ...[
                    const SizedBox(height: SpacingScale.s12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Coaching Sports (Select All That Apply)',
                          style: AppTextStyles.labelSm.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: SpacingScale.s8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: SportsRegistry.sports.take(15).map((s) {
                        final isSel = coachSports.contains(s.name);
                        return FilterChip(
                          label: Text(' '),
                          selected: isSel,
                          onSelected: (val) {
                            setSheetState(() {
                              if (val) {
                                if (!coachSports.contains(s.name)) coachSports.add(s.name);
                              } else {
                                coachSports.remove(s.name);
                              }
                            });
                          },
                          selectedColor: AppColors.primary.withValues(alpha: 0.2),
                          checkmarkColor: AppColors.primary,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: SpacingScale.s12),
                    _EditField(controller: specCtrl, label: 'Specialization (e.g. Fast Bowling / Power Hitter)', fieldBg: fieldBg, borderColor: borderColor, textPrimary: textPrimary, textSecondary: textSecondary),
                    const SizedBox(height: SpacingScale.s12),
                    Row(
                      children: [
                        Expanded(
                          child: _EditField(controller: expCtrl, label: 'Experience (Years)', fieldBg: fieldBg, borderColor: borderColor, textPrimary: textPrimary, textSecondary: textSecondary, keyboardType: TextInputType.number),
                        ),
                        const SizedBox(width: SpacingScale.s12),
                        Expanded(
                          child: _EditField(controller: rateCtrl, label: 'Rate (₹ / hr)', fieldBg: fieldBg, borderColor: borderColor, textPrimary: textPrimary, textSecondary: textSecondary, keyboardType: TextInputType.number),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: SpacingScale.s24),
                  SizedBox(
                    width: double.infinity,
                    child: _SaveButton(
                      isSaving: isSaving,
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        setSheetState(() => isSaving = true);
                        try {
                          final updates = <String, dynamic>{
                            'name': nameCtrl.text.trim(),
                            'phone': phoneCtrl.text.trim(),
                            'city': cityCtrl.text.trim(),
                            'bio': bioCtrl.text.trim(),
                          };
                          if (userModel.role == UserRole.coach) {
                            updates['sports'] = coachSports;
                            if (specCtrl.text.trim().isNotEmpty) {
                              updates['specialization'] = specCtrl.text.trim();
                            } else if (coachSports.isNotEmpty) {
                              updates['specialization'] = coachSports.join(', ');
                            }
                            final expVal = int.tryParse(expCtrl.text.trim());
                            if (expVal != null) updates['experience'] = expVal;
                            final rateVal = double.tryParse(rateCtrl.text.trim());
                            if (rateVal != null) updates['hourlyRate'] = rateVal;
                          }
                          await ref.read(authServiceProvider).updateProfile(userModel.uid, updates);
                          if (userModel.role == UserRole.coach) {
                            final coachDocData = <String, dynamic>{
                              'name': nameCtrl.text.trim(),
                              'phone': phoneCtrl.text.trim(),
                              'city': cityCtrl.text.trim(),
                              'bio': bioCtrl.text.trim(),
                              'sports': coachSports,
                              if (specCtrl.text.trim().isNotEmpty)
                                'specialization': specCtrl.text.trim()
                              else if (coachSports.isNotEmpty)
                                'specialization': coachSports.join(', '),
                              'updatedAt': FieldValue.serverTimestamp(),
                            };
                            final expVal = int.tryParse(expCtrl.text.trim());
                            if (expVal != null) coachDocData['experience'] = expVal;
                            final rateVal = double.tryParse(rateCtrl.text.trim());
                            if (rateVal != null) coachDocData['hourlyRate'] = rateVal;
                            await FirebaseFirestore.instance.collection('coaches').doc(userModel.uid).set(coachDocData, SetOptions(merge: true));
                          }
                          ref.invalidate(authStateProvider);
                          ref.invalidate(publicUserProfileProvider(userModel.uid));
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Profile updated successfully'),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                              ),
                            );
                          }
                        } catch (e) {
                          setSheetState(() => isSaving = false);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to update: $e'),
                                backgroundColor: AppColors.danger,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: SpacingScale.s20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  },
);
}

  void _showVerifyEmail(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.card : AppColors.lightCard;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.brXl2,
          side: BorderSide(color: borderColor, width: 0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(SpacingScale.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: AppRadius.brLg,
                ),
                child: const Icon(Icons.mark_email_read_rounded, color: AppColors.primary, size: 24),
              ),
              const SizedBox(height: SpacingScale.s16),
              Text('Verify Email', style: AppTextStyles.title1.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
              const SizedBox(height: SpacingScale.s8),
              Text(
                'We will send a verification link to ${widget.userModel.email}. Open the link in the email to verify your account.',
                style: AppTextStyles.body.copyWith(color: textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SpacingScale.s24),
              Row(
                children: [
                  Expanded(
                    child: _DialogButton(label: 'Cancel', onPressed: () => Navigator.pop(ctx)),
                  ),
                  const SizedBox(width: SpacingScale.s12),
                  Expanded(
                    child: _PrimaryDialogButton(
                      label: 'Send Link',
                      onPressed: () async {
                        Navigator.pop(ctx);
                        try {
                          await ref.read(authServiceProvider).sendEmailVerification();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Verification link sent to your email'),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to send link: $e'),
                                backgroundColor: AppColors.danger,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                              ),
                            );
                          }
                        }
                      },
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

  void _showEmailVerified(BuildContext context) {
    _showInfoDialog(context, 'Email Verified',
      'Your email address has been verified. Thank you!');
  }

  void _showChangePassword(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final cardColor = isDark ? AppColors.surfaceSecondary : AppColors.lightSurface;
        final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
        final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
        final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
        final fieldBg = isDark ? AppColors.surface : AppColors.lightSurfaceSecondary;

        return StatefulBuilder(
          builder: (ctx, setSheetState) => Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: AppRadius.top(SpacingScale.s20),
                  border: Border(top: BorderSide(color: borderColor, width: 0.5)),
                ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: SpacingScale.s20,
              right: SpacingScale.s20,
              top: SpacingScale.s20,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: borderColor,
                      borderRadius: AppRadius.brFull,
                    ),
                  ),
                  const SizedBox(height: SpacingScale.s20),
                  Text('Change Password',
                      style: AppTextStyles.title1.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: SpacingScale.s24),
                  _EditField(
                    controller: currentCtrl,
                    label: 'Current Password',
                    fieldBg: fieldBg,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    validator: (v) => (v == null || v.isEmpty) ? 'Current password is required' : null,
                  ),
                  const SizedBox(height: SpacingScale.s12),
                  _EditField(
                    controller: newCtrl,
                    label: 'New Password',
                    fieldBg: fieldBg,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    validator: (v) {
                      if (v == null || v.length < 6) return 'At least 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: SpacingScale.s12),
                  _EditField(
                    controller: confirmCtrl,
                    label: 'Confirm New Password',
                    fieldBg: fieldBg,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    validator: (v) => (v != newCtrl.text) ? 'Passwords do not match' : null,
                  ),
                  const SizedBox(height: SpacingScale.s24),
                  SizedBox(
                    width: double.infinity,
                    child: _SaveButton(
                      isSaving: isSaving,
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        setSheetState(() => isSaving = true);
                        try {
                          await ref
                              .read(authServiceProvider)
                              .updatePassword(currentCtrl.text, newCtrl.text);
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Password updated successfully'),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                              ),
                            );
                          }
                        } catch (e) {
                          setSheetState(() => isSaving = false);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to update password: $e'),
                                backgroundColor: AppColors.danger,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: SpacingScale.s20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  },
);
}

  void _showHelp(BuildContext context) {
    _showInfoDialog(context, 'Help Center',
      'Welcome to KRICO Help Center!\n\n'
      'Common Topics:\n'
      '• How to book a session?\n'
      '• How to message a coach?\n'
      '• How to track performance?\n'
      '• How to earn XP points?\n\n'
      'Contact our support team for further assistance.');
  }

  void _showContact(BuildContext context) {
    _showInfoDialog(context, 'Contact Us', null, children: [
      const _InfoRow(label: 'Phone:', value: '+91-9322660010'),
      const SizedBox(height: SpacingScale.s12),
      const _InfoRow(label: 'Email:', value: 'aayushmnikam@gmail.com'),
      const SizedBox(height: SpacingScale.s12),
      const _InfoRow(label: 'Address:', value: 'Pune, Maharashtra'),
      const SizedBox(height: SpacingScale.s8),
      const _InfoRow(label: 'HQ:', value: 'Pune, Maharashtra, India'),
    ]);
  }

  void _showAbout(BuildContext context) {
    _showInfoDialog(context, 'About', null, children: [
      Text('KRICO (Krida + Coach)', style: AppTextStyles.title1.copyWith(fontWeight: FontWeight.w700)),
      const SizedBox(height: SpacingScale.s4),
      Text('Version 1.0.0', style: AppTextStyles.caption.copyWith(color: _textSecondaryColor(context))),
      const SizedBox(height: SpacingScale.s12),
      Text(
        'A complete sports ecosystem connecting players, coaches, parents, and academies across India. Track performance, book sessions, earn XP, and connect with the athletic community.',
        style: AppTextStyles.body.copyWith(color: _textSecondaryColor(context)),
      ),
    ]);
  }

  Color _textSecondaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.textSecondary
        : AppColors.lightTextSecondary;
  }

  void _showInfoDialog(BuildContext context, String title, String? body, {List<Widget>? children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.card : AppColors.lightCard;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.brXl2,
          side: BorderSide(color: borderColor, width: 0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(SpacingScale.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.title1.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
              const SizedBox(height: SpacingScale.s16),
              if (body != null)
                Text(body, style: AppTextStyles.body.copyWith(color: textSecondary)),
              if (children != null) ...children,
              const SizedBox(height: SpacingScale.s20),
              Align(
                alignment: Alignment.centerRight,
                child: _DialogButton(label: 'Close', onPressed: () => Navigator.pop(ctx)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationPreferences(BuildContext context, UserModel userModel) {
    bool bookingAlerts = true;
    bool chatAlerts = true;
    bool trainingMilestones = true;
    bool academyAnnouncements = true;
    bool soundHaptics = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final cardColor = isDark ? AppColors.surfaceSecondary : AppColors.lightSurface;
        final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
        final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
        final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

        return StatefulBuilder(
          builder: (ctx, setSheetState) => Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Container(
                padding: const EdgeInsets.all(SpacingScale.s20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: AppRadius.top(SpacingScale.s20),
                  border: Border(top: BorderSide(color: borderColor, width: 0.5)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(color: borderColor, borderRadius: AppRadius.brFull),
                      ),
                    ),
                    const SizedBox(height: SpacingScale.s16),
                    Row(
                      children: [
                        const Icon(Icons.notifications_active_rounded, color: AppColors.primary, size: 24),
                        const SizedBox(width: SpacingScale.s12),
                        Text('Notification Preferences',
                            style: AppTextStyles.title1.copyWith(color: textPrimary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: SpacingScale.s8),
                    Text('Choose the alerts and updates you want to receive on your device.',
                        style: AppTextStyles.caption.copyWith(color: textSecondary)),
                    const SizedBox(height: SpacingScale.s16),
                    _buildSwitchTile(
                      title: 'Session & Booking Alerts',
                      subtitle: 'Upcoming slots, booking confirmations, coach reschedules',
                      value: bookingAlerts,
                      onChanged: (v) => setSheetState(() => bookingAlerts = v),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    _buildSwitchTile(
                      title: 'Chat & Direct Messages',
                      subtitle: 'Real-time messages from coaches, parents, and athletes',
                      value: chatAlerts,
                      onChanged: (v) => setSheetState(() => chatAlerts = v),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    _buildSwitchTile(
                      title: 'Training & XP Milestones',
                      subtitle: 'Daily streak updates, XP awards, and level-ups',
                      value: trainingMilestones,
                      onChanged: (v) => setSheetState(() => trainingMilestones = v),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    _buildSwitchTile(
                      title: 'Academy & Batch Announcements',
                      subtitle: 'Tournament updates, batch schedule modifications',
                      value: academyAnnouncements,
                      onChanged: (v) => setSheetState(() => academyAnnouncements = v),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    _buildSwitchTile(
                      title: 'Sound & Vibration Alerts',
                      subtitle: 'Play alert sounds for urgent session notifications',
                      value: soundHaptics,
                      onChanged: (v) => setSheetState(() => soundHaptics = v),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: SpacingScale.s20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Notification preferences saved successfully!'),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                            ),
                          );
                        },
                        child: const Text('Save Preferences', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.body.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.captionXs.copyWith(color: textSecondary)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeTrackColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    _showLegalModal(
      context: context,
      title: 'Terms of Service',
      lastUpdated: 'Updated October 2026',
      content: '''
1. Platform Acceptance
By creating an account or accessing the KRICO platform, you agree to comply with and be bound by these Terms of Service. KRICO operates across India connecting athletes, certified coaches, parents, and sports academies.

2. User Roles & Responsibilities
• Players & Parents: Responsible for providing accurate sports metrics, respecting venue rules, and honoring scheduled training bookings.
• Coaches: Must maintain certified coaching credentials, adhere to high athletic standards, and conduct sessions safely.
• Academies: Responsible for accurate batch timetables, qualified staff, and proper safety amenities at training grounds.

3. Session Bookings & Escrow Payments
• All session and clinic bookings are held in secure escrow protection until completion or verified resolution.
• Cancellation and rescheduling policies apply according to the individual coach's policy and platform fair play guidelines.

4. Child Safety & Zero Tolerance
KRICO maintains a zero-tolerance policy against any form of harassment, abuse, or discrimination. Parental supervision features are built into youth athlete accounts.

5. Platform Neutrality & Disputes
In case of disputes concerning session non-attendance, facility availability, or contract milestones, users may file an in-app dispute for objective mediation.
''',
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    _showLegalModal(
      context: context,
      title: 'Privacy Policy',
      lastUpdated: 'Updated October 2026',
      content: '''
1. Information We Collect
We collect account information (name, phone, role, city), athletic performance data (training logs, XP, sprint/endurance benchmarks), and booking history to deliver a personalized athletic experience.

2. Location Data & Pan-India Discovery
KRICO uses your selected city or GPS coordinates to discover nearby certified coaches, floodlit turfs, academy batches, and local sports events. We never sell your location data to third parties.

3. Athlete & Minor Safety
For youth athletes under parental accounts, profile visibility and training data are strictly governed by parent permission controls.

4. Data Security & Cloud Storage
Your personal data, messages, and performance analytics are encrypted in transit and securely hosted with industry-standard cloud database protections.

5. Your Rights & Account Control
You have the right to edit your profile, export your training history, manage notification preferences, or permanently delete your account and associated records at any time.
''',
    );
  }

  void _showLegalModal({
    required BuildContext context,
    required String title,
    required String lastUpdated,
    required String content,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceSecondary : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 650),
          child: Container(
            padding: const EdgeInsets.all(SpacingScale.s20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: AppRadius.top(SpacingScale.s20),
              border: Border(top: BorderSide(color: borderColor, width: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: borderColor, borderRadius: AppRadius.brFull),
                  ),
                ),
                const SizedBox(height: SpacingScale.s16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: AppTextStyles.title1.copyWith(color: textPrimary, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: AppRadius.brFull,
                      ),
                      child: Text(lastUpdated, style: AppTextStyles.captionXs.copyWith(color: AppColors.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: SpacingScale.s12),
                Divider(color: borderColor, height: 1),
                const SizedBox(height: SpacingScale.s12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      content.trim(),
                      style: AppTextStyles.body.copyWith(
                        color: textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: SpacingScale.s16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Understood & Close', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.card : AppColors.lightCard;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final passwordCtrl = TextEditingController();
    bool isDeleting = false;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.brXl2,
          side: BorderSide(color: borderColor, width: 0.5),
        ),
        child: StatefulBuilder(
          builder: (ctx, setDialogState) => Padding(
            padding: const EdgeInsets.all(SpacingScale.s24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.12),
                    borderRadius: AppRadius.brLg,
                  ),
                  child: const Icon(Icons.warning_rounded, color: AppColors.danger, size: 24),
                ),
                const SizedBox(height: SpacingScale.s16),
                Text('Delete Account', style: AppTextStyles.title1.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                const SizedBox(height: SpacingScale.s8),
                Text(
                  'Are you sure you want to delete your account? This permanently removes your profile, sessions, and data. Enter your password to confirm.',
                  style: AppTextStyles.body.copyWith(color: textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: SpacingScale.s16),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surface : AppColors.lightSurfaceSecondary,
                    borderRadius: AppRadius.brLg,
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  child: TextFormField(
                    controller: passwordCtrl,
                    obscureText: true,
                    style: AppTextStyles.body.copyWith(color: textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: AppTextStyles.body.copyWith(color: textSecondary),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: SpacingScale.s16,
                        vertical: SpacingScale.s12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: SpacingScale.s24),
                Row(
                  children: [
                    Expanded(
                      child: _DialogButton(label: 'Cancel', onPressed: () => Navigator.pop(ctx)),
                    ),
                    const SizedBox(width: SpacingScale.s12),
                    Expanded(
                      child: _DangerButton(
                        label: isDeleting ? 'Deleting...' : 'Delete',
                        onPressed: isDeleting
                            ? null
                            : () async {
                                if (passwordCtrl.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Enter your password to confirm'),
                                      backgroundColor: AppColors.danger,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                                    ),
                                  );
                                  return;
                                }
                                setDialogState(() => isDeleting = true);
                                try {
                                  await ref
                                      .read(authServiceProvider)
                                      .deleteAccount(passwordCtrl.text);
                                  if (ctx.mounted) Navigator.pop(ctx);
                                  await ref.read(authServiceProvider).signOut();
                                  if (context.mounted) context.go('/login');
                                } catch (e) {
                                  setDialogState(() => isDeleting = false);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to delete account: $e'),
                                        backgroundColor: AppColors.danger,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                                      ),
                                    );
                                  }
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? color;

  const _MenuItem(this.icon, this.label, this.onTap,
      {this.trailing, this.color});
}

class _ThemeToggle extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggle;

  const _ThemeToggle({required this.isDark, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: DurationTokens.fast,
        width: 44,
        height: 24,
        decoration: BoxDecoration(
          color: isDark ? AppColors.primary : AppColors.border,
          borderRadius: AppRadius.brFull,
        ),
        child: Align(
          alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
          child: AnimatedContainer(
            duration: DurationTokens.fast,
            margin: const EdgeInsets.all(SpacingScale.s2),
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _EditField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final Color fieldBg;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool obscureText;

  const _EditField({
    required this.controller,
    required this.label,
    required this.fieldBg,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.obscureText = false,
  });

  @override
  State<_EditField> createState() => _EditFieldState();
}

class _EditFieldState extends State<_EditField> {
  late FocusNode _focusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (mounted) setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: DurationTokens.fast,
      decoration: BoxDecoration(
        color: widget.fieldBg,
        borderRadius: AppRadius.brLg,
        border: Border.all(
          color: _focused ? AppColors.primary : widget.borderColor,
          width: _focused ? 1.5 : 1,
        ),
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        style: AppTextStyles.body.copyWith(color: widget.textPrimary),
        keyboardType: widget.keyboardType,
        maxLines: widget.maxLines,
        obscureText: widget.obscureText,
        validator: widget.validator,
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: AppTextStyles.body.copyWith(color: widget.textSecondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: SpacingScale.s16,
            vertical: SpacingScale.s12,
          ),
        ),
      ),
    );
  }
}

class _SaveButton extends StatefulWidget {
  final bool isSaving;
  final VoidCallback onPressed;

  const _SaveButton({required this.isSaving, required this.onPressed});

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = !widget.isSaving;

    return MouseRegion(
      onEnter: isEnabled ? (_) => setState(() => _hovered = true) : null,
      onExit: isEnabled ? (_) => setState(() => _hovered = false) : null,
      child: GestureDetector(
        onTap: isEnabled ? widget.onPressed : null,
        child: AnimatedContainer(
          duration: DurationTokens.fast,
          height: 48,
          decoration: BoxDecoration(
            gradient: isEnabled
                ? LinearGradient(
                    colors: _hovered
                        ? [AppColors.primaryHover, AppColors.primary]
                        : [AppColors.primary, AppColors.primaryLight],
                  )
                : null,
            color: !isEnabled ? AppColors.textDisabled : null,
            borderRadius: AppRadius.brXl2,
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: _hovered ? 0.4 : 0.25),
                      blurRadius: _hovered ? 20 : 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: widget.isSaving
                ? SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text('Save Changes', style: AppTextStyles.buttonLg.copyWith(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

class _SignOutButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _SignOutButton({required this.onPressed});

  @override
  State<_SignOutButton> createState() => _SignOutButtonState();
}

class _SignOutButtonState extends State<_SignOutButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: DurationTokens.fast,
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            color: _hovered
                ? AppColors.danger.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: AppRadius.brXl2,
            border: Border.all(
              color: _hovered ? AppColors.danger : AppColors.border,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout_rounded, size: 18, color: AppColors.danger),
              const SizedBox(width: SpacingScale.s8),
              Text('Sign Out', style: AppTextStyles.buttonLg.copyWith(color: AppColors.danger)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryDialogButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;

  const _PrimaryDialogButton({required this.label, this.onPressed});

  @override
  State<_PrimaryDialogButton> createState() => _PrimaryDialogButtonState();
}

class _PrimaryDialogButtonState extends State<_PrimaryDialogButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;
    return MouseRegion(
      onEnter: isEnabled ? (_) => setState(() => _hovered = true) : null,
      onExit: isEnabled ? (_) => setState(() => _hovered = false) : null,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: DurationTokens.fast,
          height: 44,
          decoration: BoxDecoration(
            gradient: isEnabled
                ? LinearGradient(
                    colors: _hovered
                        ? [AppColors.primaryHover, AppColors.primary]
                        : [AppColors.primary, AppColors.primaryLight],
                  )
                : null,
            color: !isEnabled ? AppColors.textDisabled : null,
            borderRadius: AppRadius.brXl2,
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: _hovered ? 0.4 : 0.2),
                      blurRadius: _hovered ? 16 : 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(widget.label, style: AppTextStyles.button.copyWith(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

class _DangerButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;

  const _DangerButton({required this.label, this.onPressed});

  @override
  State<_DangerButton> createState() => _DangerButtonState();
}

class _DangerButtonState extends State<_DangerButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;
    return MouseRegion(
      onEnter: isEnabled ? (_) => setState(() => _hovered = true) : null,
      onExit: isEnabled ? (_) => setState(() => _hovered = false) : null,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: DurationTokens.fast,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isEnabled
                  ? (_hovered
                      ? [AppColors.dangerLight, AppColors.danger]
                      : [AppColors.danger, const Color(0xFFB91C1C)])
                  : [AppColors.textDisabled, AppColors.textDisabled],
            ),
            borderRadius: AppRadius.brXl2,
            boxShadow: [
              BoxShadow(
                color: AppColors.danger.withValues(alpha: _hovered ? 0.4 : 0.2),
                blurRadius: _hovered ? 16 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(widget.label, style: AppTextStyles.button.copyWith(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _DialogButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.brLg,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s16, vertical: SpacingScale.s10),
          child: Text(label, style: AppTextStyles.button.copyWith(color: AppColors.primary)),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(color: textSecondary)),
        const SizedBox(height: SpacingScale.s2),
        Text(value, style: AppTextStyles.body.copyWith(color: AppColors.primary)),
      ],
    );
  }
}
