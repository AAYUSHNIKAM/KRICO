import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../services/providers.dart';

class StudentsTab extends ConsumerWidget {
  final String coachId;
  const StudentsTab({super.key, required this.coachId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(coachPlayersProvider(coachId));

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
                      colors: AppColors.gradientPrimary,
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
                          Text('My Students',
                              style: AppTextStyles.displaySmall.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text('Manage your athletes',
                              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            studentsAsync.when(
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
                          Text('No students yet', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                          SizedBox(height: 8),
                          Text('Students will appear when they book sessions',
                              style: TextStyle(color: AppColors.textDim, fontSize: 13)),
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
                      final level = data['level'] as String? ?? 'Beginner';
                      final points = (data['points'] as num?)?.toInt() ?? 0;
                      final sport = (data['sports'] as List<dynamic>?)?.cast<String>() ?? ['General'];
                      final rank = (data['rank'] as num?)?.toInt() ?? 0;

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardDark,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.1)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [AppColors.secondary, AppColors.secondary.withValues(alpha: 0.7)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name,
                                        style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600),
                                        maxLines: 1, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 2),
                                    Text('${sport.join(", ")} \u2022 $level',
                                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                                        maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.secondary.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text('#$rank',
                                            style: TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text('$points XP',
                                          style: AppTextStyles.caption.copyWith(color: AppColors.textDim)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: (index * 60).ms).slideY(begin: 0.1, end: 0);
                    },
                    childCount: docs.length,
                  ),
                );
              },
              loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
              error: (e, _) {
                debugPrint('Students error: $e');
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.error),
                        const SizedBox(height: 12),
                        Text('Unable to load students right now.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('Please try again.',
                            style: TextStyle(color: AppColors.textDim, fontSize: 13)),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}
