import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../design_system/widgets/page_headers/page_hero.dart';
import '../../../design_system/radius/radius.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/providers.dart';

class UsersTab extends ConsumerWidget {
  const UsersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.background, AppColors.surface],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            PageHero(
              title: 'User Management',
              subtitle: 'Manage platform users',
              gradientColors: [AppColors.gold, AppColors.warningLight],
              expandedHeight: 160,
            ),
            usersAsync.when(
              data: (snap) {
                final docs = snap.docs;
                if (docs.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline_rounded, size: 64, color: AppColors.textTertiary),
                          SizedBox(height: 16),
                          Text('No users found', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                        ],
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final data = docs[index].data();
                      final name = data['name'] as String? ?? 'Unknown';
                      final email = data['email'] as String? ?? '';
                      final role = data['role'] as String? ?? 'unknown';
                      final phone = data['phone'] as String? ?? '';
                      final isActive = data['isActive'] as bool? ?? true;
                      final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

                      final roleColors = {
                        'parent': AppColors.primary,
                        'player': AppColors.success,
                        'coach': AppColors.purple,
                        'academy': AppColors.orange,
                        'admin': AppColors.gold,
                      };
                      final roleLabel = role[0].toUpperCase() + role.substring(1);
                      final color = roleColors[role] ?? AppColors.textSecondary;

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border.withValues(alpha: 0.1)),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => context.push('/profile/${docs[index].id}'),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () => context.push('/profile/${docs[index].id}'),
                                      child: Text(name, style: AppTextStyles.title3.copyWith(fontWeight: FontWeight.w600)),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(email, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                                    if (phone.isNotEmpty)
                                      Text(phone, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 11)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(roleLabel,
                                            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
                                      ),
                                      if (!isActive) ...[
                                        const SizedBox(width: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.danger.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text('BANNED',
                                              style: TextStyle(color: AppColors.danger, fontSize: 10, fontWeight: FontWeight.w600)),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (createdAt != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      '${createdAt.day}/${createdAt.month}/${createdAt.year}',
                                      style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 9),
                                    ),
                                  ],
                                ],
                              ),
                              PopupMenuButton<String>(
                                color: AppColors.surface,
                                shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                                icon: const Icon(Icons.more_vert_rounded, size: 20, color: AppColors.textSecondary),
                                onSelected: (value) => _handleAction(context, ref, docs[index].id, data, value),
                                itemBuilder: (menuContext) => [
                                  if (isActive)
                                    const PopupMenuItem(
                                      value: 'ban',
                                      child: Row(
                                        children: [
                                          Icon(Icons.block_rounded, size: 18, color: AppColors.danger),
                                          SizedBox(width: SpacingScale.s10),
                                          Text('Ban user', style: TextStyle(color: AppColors.danger)),
                                        ],
                                      ),
                                    )
                                  else
                                    const PopupMenuItem(
                                      value: 'unban',
                                      child: Row(
                                        children: [
                                          Icon(Icons.check_circle_rounded, size: 18, color: AppColors.success),
                                          SizedBox(width: SpacingScale.s10),
                                          Text('Unban user', style: TextStyle(color: AppColors.success)),
                                        ],
                                      ),
                                    ),
                                  const PopupMenuItem(
                                    value: 'role',
                                    child: Row(
                                      children: [
                                        Icon(Icons.swap_horiz_rounded, size: 18, color: AppColors.primary),
                                        SizedBox(width: SpacingScale.s10),
                                        Text('Change role'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: (index * 40).ms).slideY(begin: 0.1, end: 0);
                    },
                    childCount: docs.length,
                  ),
                );
              },
              loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('Failed to load users', style: TextStyle(color: AppColors.danger))),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, String uid, Map<String, dynamic> data, String action) {
    switch (action) {
      case 'ban':
        _confirmBan(context, ref, uid, data['name'] as String? ?? 'this user', true);
      case 'unban':
        _confirmBan(context, ref, uid, data['name'] as String? ?? 'this user', false);
      case 'role':
        _showRolePicker(context, ref, uid, data['role'] as String? ?? 'parent');
    }
  }

  Future<void> _confirmBan(BuildContext context, WidgetRef ref, String uid, String name, bool ban) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(ban ? 'Ban user?' : 'Unban user?'),
        content: Text(ban
            ? '$name will no longer be able to access the app.'
            : '$name will be able to access the app again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              ban ? 'Ban' : 'Unban',
              style: TextStyle(color: ban ? AppColors.danger : AppColors.success, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(authServiceProvider).toggleUserActive(uid, !ban);
      if (!context.mounted) return;
      _showSnack(context, ban ? '$name banned' : '$name unbanned', AppColors.success);
    } catch (e) {
      if (!context.mounted) return;
      _showSnack(context, 'Failed: $e', AppColors.danger);
    }
  }

  Future<void> _showRolePicker(BuildContext context, WidgetRef ref, String uid, String currentRole) async {
    final current = UserRole.values.firstWhere(
      (r) => r.name == currentRole,
      orElse: () => UserRole.parent,
    );

    final selected = await showDialog<UserRole>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
        title: const Text('Change user role'),
        children: UserRole.values.map((role) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, role),
            child: Row(
              children: [
                Icon(
                  _roleIcon(role),
                  size: 20,
                  color: _roleColor(role),
                ),
                const SizedBox(width: SpacingScale.s12),
                Text(
                  role.name[0].toUpperCase() + role.name.substring(1),
                  style: TextStyle(
                    color: role == current ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: role == current ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                if (role == current)
                  const Padding(
                    padding: EdgeInsets.only(left: SpacingScale.s8),
                    child: Icon(Icons.check_rounded, size: 16, color: AppColors.primary),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );

    if (selected == null || selected == current || !context.mounted) return;

    try {
      await ref.read(authServiceProvider).setUserRole(uid, selected);
      if (!context.mounted) return;
      _showSnack(context, 'Role updated to ${selected.name}', AppColors.success);
    } catch (e) {
      if (!context.mounted) return;
      _showSnack(context, 'Failed: $e', AppColors.danger);
    }
  }

  IconData _roleIcon(UserRole role) {
    switch (role) {
      case UserRole.parent:
        return Icons.family_restroom_rounded;
      case UserRole.player:
        return Icons.sports_rounded;
      case UserRole.coach:
        return Icons.school_rounded;
      case UserRole.academy:
        return Icons.account_balance_rounded;
      case UserRole.admin:
        return Icons.admin_panel_settings_rounded;
    }
  }

  Color _roleColor(UserRole role) {
    switch (role) {
      case UserRole.parent:
        return AppColors.primary;
      case UserRole.player:
        return AppColors.success;
      case UserRole.coach:
        return AppColors.purple;
      case UserRole.academy:
        return AppColors.orange;
      case UserRole.admin:
        return AppColors.gold;
    }
  }

  void _showSnack(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
    ));
  }
}
