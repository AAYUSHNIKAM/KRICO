import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../models/user_model.dart';
import '../../../services/providers.dart';
import '../../../providers/auth_provider.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  final _postCtrl = TextEditingController();
  bool _isPosting = false;

  @override
  void dispose() {
    _postCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final currentUserId = authState.value?.uid;
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.surfaceDark, AppColors.surfaceMid],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 140,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Community', style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('Discover, share & connect', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.1)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: AppColors.gradientPrimary),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _postCtrl,
                            maxLines: 2,
                            style: AppTextStyles.bodyMedium,
                            decoration: InputDecoration(
                              hintText: 'Share something with the community...',
                              hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDim),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _iconBtn(Icons.image_rounded, AppColors.success),
                            const SizedBox(width: 8),
                            _iconBtn(Icons.videocam_rounded, AppColors.primary),
                            const SizedBox(width: 8),
                            _iconBtn(Icons.emoji_emotions_rounded, AppColors.warning),
                          ],
                        ),
                        GradientButton(
                          onPressed: _isPosting ? null : _createPost,
                          height: 34,
                          width: 90,
                          borderRadius: 8,
                          child: _isPosting
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Post', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.1, end: 0),
            ),
            usersAsync.when(
              data: (snap) {
                final docs = snap.docs;
                final users = docs
                    .map((d) => UserModel.fromDoc(d))
                    .where((u) => u.uid != currentUserId)
                    .toList();
                if (users.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people_outline_rounded, size: 64, color: AppColors.textDim),
                          const SizedBox(height: 16),
                          Text('No community posts yet', style: AppTextStyles.titleSmall.copyWith(color: AppColors.textSecondary)),
                          const SizedBox(height: 8),
                          Text('Be the first to share something!', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textDim)),
                        ],
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final user = users[index % users.length];
                        final postIndex = index ~/ users.length;
                        final mockPosts = [
                          _MockPost(
                            'Just finished an amazing training session! Ready for the upcoming tournament. Hard work pays off! 💪🏆',
                            '🏋️ Training',
                            DateTime.now().subtract(Duration(hours: postIndex * 3 + index % 3)),
                            likes: 24 - postIndex,
                            comments: 8 - postIndex,
                          ),
                          _MockPost(
                            'Great game today! Our team showed incredible spirit and teamwork. Proud of every player! ⚽🔥',
                            '🏟️ Match Day',
                            DateTime.now().subtract(Duration(hours: postIndex * 5 + 2)),
                            likes: 42 - postIndex * 2,
                            comments: 15 - postIndex,
                          ),
                          _MockPost(
                            'New personal best in 100m sprint! Coaching sessions are really paying off. 🏃‍♂️⚡',
                            '🎯 Achievement',
                            DateTime.now().subtract(Duration(hours: postIndex * 4 + 1)),
                            likes: 31 - postIndex,
                            comments: 12 - postIndex,
                          ),
                        ];
                        final post = mockPosts[index % mockPosts.length];
                        final color = Colors.primaries[index % Colors.primaries.length];

                        return _buildPostCard(user, post, color).animate().fadeIn(delay: (index * 60).ms).slideY(begin: 0.1, end: 0);
                      },
                      childCount: users.length * 3,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('Failed to load community', style: TextStyle(color: AppColors.error))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }

  void _createPost() {
    if (_postCtrl.text.trim().isEmpty) return;
    setState(() => _isPosting = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isPosting = false;
          _postCtrl.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post shared!'), backgroundColor: AppColors.success),
        );
      }
    });
  }

  Widget _buildPostCard(UserModel user, _MockPost post, Color avatarColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: avatarColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: TextStyle(color: avatarColor, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name,
                          style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(post.tag, style: AppTextStyles.caption.copyWith(color: AppColors.textDim, fontSize: 10)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: avatarColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(user.role.name[0].toUpperCase() + user.role.name.substring(1),
                      style: TextStyle(color: avatarColor, fontSize: 9, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Text(post.content, style: AppTextStyles.bodyMedium.copyWith(height: 1.4)),
          ),
          const SizedBox(height: 10),
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: avatarColor.withValues(alpha: 0.05),
            ),
            child: Center(
              child: Icon(Icons.image_rounded, size: 48, color: avatarColor.withValues(alpha: 0.3)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Row(
              children: [
                _postAction(Icons.favorite_rounded, '${post.likes}', AppColors.error),
                const SizedBox(width: 16),
                _postAction(Icons.chat_bubble_outline_rounded, '${post.comments}', AppColors.textSecondary),
                const Spacer(),
                _postAction(Icons.share_rounded, 'Share', AppColors.textSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _postAction(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {},
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}

class _MockPost {
  final String content;
  final String tag;
  final DateTime timestamp;
  final int likes;
  final int comments;

  const _MockPost(this.content, this.tag, this.timestamp, {required this.likes, required this.comments});
}
