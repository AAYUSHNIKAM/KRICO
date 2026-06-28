import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
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
            colors: [AppColors.surfaceDark, AppColors.surfaceMid],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 160,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.gradientGold,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('User Management',
                              style: AppTextStyles.displaySmall.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text('Manage platform users',
                              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
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
                          Icon(Icons.people_outline_rounded, size: 64, color: AppColors.textDim),
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
                      final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

                      final roleColors = {
                        'parent': AppColors.primary,
                        'player': AppColors.success,
                        'coach': AppColors.secondary,
                        'academy': AppColors.accent,
                        'admin': AppColors.gold,
                      };
                      final roleLabel = role[0].toUpperCase() + role.substring(1);
                      final color = roleColors[role] ?? AppColors.textSecondary;

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.cardDark,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.1)),
                          ),
                          child: Row(
                            children: [
                              Container(
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
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 1),
                                    Text(email, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                                    if (phone.isNotEmpty)
                                      Text(phone, style: AppTextStyles.caption.copyWith(color: AppColors.textDim, fontSize: 11)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
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
                                  if (createdAt != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      '${createdAt.day}/${createdAt.month}/${createdAt.year}',
                                      style: AppTextStyles.caption.copyWith(color: AppColors.textDim, fontSize: 9),
                                    ),
                                  ],
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
                child: Center(child: Text('Failed to load users', style: TextStyle(color: AppColors.error))),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}
