import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/providers.dart';

class ProfilePage extends ConsumerWidget {
  final UserModel userModel;
  final String role;

  const ProfilePage({
    super.key,
    required this.userModel,
    required this.role,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(context, ref),
            const SizedBox(height: 24),
            _buildMenuSection(context, ref, 'Account', [
              _MenuItem(Icons.edit_rounded, 'Edit Profile', () => _showEditProfile(context, ref)),
              _MenuItem(Icons.notifications_rounded, 'Notifications', () {}),
              _MenuItem(Icons.lock_rounded, 'Privacy & Security', () {}),
            ]),
            const SizedBox(height: 16),
            _buildMenuSection(context, ref, 'Preferences', [
              _MenuItem(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                isDark ? 'Light Mode' : 'Dark Mode',
                () => ref.read(themeModeProvider.notifier).toggle(),
                trailing: Switch(
                  value: isDark,
                  onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
                  activeColor: AppColors.primary,
                ),
              ),
            ]),
            const SizedBox(height: 16),
            _buildMenuSection(context, ref, 'Support', [
              _MenuItem(Icons.help_outline_rounded, 'Help Center', () => _showHelp(context)),
              _MenuItem(Icons.headset_mic_rounded, 'Contact Us', () => _showContact(context)),
              _MenuItem(Icons.info_outline_rounded, 'About', () => _showAbout(context)),
            ]),
            const SizedBox(height: 16),
            _buildMenuSection(context, ref, 'Other', [
              _MenuItem(Icons.description_rounded, 'Terms of Service', () {}),
              _MenuItem(Icons.privacy_tip_outlined, 'Privacy Policy', () {}),
              _MenuItem(Icons.delete_outline_rounded, 'Delete Account', () {},
                  color: AppColors.error),
            ]),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(authServiceProvider).signOut();
                  if (context.mounted) context.go('/login');
                },
                icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                label: const Text('Sign Out',
                    style: TextStyle(color: AppColors.error)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.gradientPrimary,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                backgroundImage: userModel.photoUrl != null
                    ? NetworkImage(userModel.photoUrl!)
                    : null,
                child: userModel.photoUrl == null
                    ? Icon(Icons.person_rounded, size: 48,
                        color: Colors.white.withValues(alpha: 0.8))
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(userModel.name,
              style: AppTextStyles.titleLarge.copyWith(color: Colors.white)),
          const SizedBox(height: 4),
          Text(userModel.email,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: Colors.white.withValues(alpha: 0.8))),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(role,
                style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
          if (userModel.city != null) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on_rounded,
                    size: 14, color: Colors.white.withValues(alpha: 0.7)),
                const SizedBox(width: 4),
                Text(userModel.city!,
                    style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.7))),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuSection(
      BuildContext context, WidgetRef ref, String title, List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(title,
                style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600)),
          ),
          ...items.map((item) => _buildMenuItem(context, item)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, _MenuItem item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(item.icon, size: 20,
                color: item.color ?? AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(item.label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: item.color ?? AppColors.textPrimary,
                  )),
            ),
            if (item.trailing != null)
              item.trailing!
            else
              Icon(Icons.chevron_right_rounded,
                  size: 20, color: AppColors.textDim),
          ],
        ),
      ),
    );
  }

  void _showEditProfile(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController(text: userModel.name);
    final phoneCtrl = TextEditingController(text: userModel.phone);
    final cityCtrl = TextEditingController(text: userModel.city ?? '');
    final bioCtrl = TextEditingController(text: userModel.bio ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceMid,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20, right: 20, top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text('Edit Profile', style: AppTextStyles.titleLarge),
            const SizedBox(height: 20),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: cityCtrl,
              decoration: const InputDecoration(
                labelText: 'City',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bioCtrl,
              decoration: const InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(authServiceProvider).updateProfile(userModel.uid, {
                    'name': nameCtrl.text,
                    'phone': phoneCtrl.text,
                    'city': cityCtrl.text,
                    'bio': bioCtrl.text,
                  });
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Changes'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceMid,
        title: const Text('Help Center'),
        content: const Text(
          'Welcome to SportsEco Help Center!\n\n'
          'Common Topics:\n'
          '• How to book a session?\n'
          '• How to message a coach?\n'
          '• How to track performance?\n'
          '• How to earn XP points?\n\n'
          'Contact our support team for further assistance.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showContact(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceMid,
        title: const Text('Contact Us'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email:', style: TextStyle(color: AppColors.textSecondary)),
            Text('support@sportseco.com',
                style: TextStyle(color: AppColors.primary)),
            SizedBox(height: 12),
            Text('Phone:', style: TextStyle(color: AppColors.textSecondary)),
            Text('+91 98765 43210',
                style: TextStyle(color: AppColors.primary)),
            SizedBox(height: 12),
            Text('Address:', style: TextStyle(color: AppColors.textSecondary)),
            Text('Pune, Maharashtra, India',
                style: TextStyle(color: AppColors.primary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceMid,
        title: const Text('About'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SportsEco',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            SizedBox(height: 8),
            Text('Version 1.0.0',
                style: TextStyle(color: AppColors.textSecondary)),
            SizedBox(height: 12),
            Text(
              'A complete sports ecosystem connecting players, coaches, parents, and academies. Track performance, earn XP, connect with the sports community.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
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
