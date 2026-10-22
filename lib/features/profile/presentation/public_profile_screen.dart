import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/radius/radius.dart';
import '../../../design_system/responsive/responsive_helpers.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../design_system/tokens/duration_tokens.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../design_system/widgets/surfaces/shimmer_widget.dart';
import '../../player/presentation/dashboard/widgets/dashboard_empty_state.dart';
import '../../../models/coach_model.dart';
import '../../../models/gamification_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/profile_providers.dart';
import '../../../services/providers.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../challenges/presentation/challenge_create_sheet.dart';
import '../../../services/progress_and_gamification_service.dart';
import 'widgets/certificate_viewer_dialog.dart';

/// Public profile of any user (player / coach / academy / parent).
/// LinkedIn/Instagram style: anyone can view, follow and message.
///
/// When embedded as a shell tab, pass [showAppBar] = false so the screen does
/// not render its own AppBar on phones (the shell's slim AppBar already shows
/// the page title). Pushed routes keep the AppBar for the back button.
class PublicProfileScreen extends ConsumerWidget {
  const PublicProfileScreen({super.key, required this.userId, this.showAppBar = true});

  final String userId;
  final bool showAppBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authStateProvider);
    final currentUserId = authState.value?.uid;
    final userAsync = ref.watch(publicUserProfileProvider(userId));

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
      appBar: (context.isPhone && !showAppBar)
          ? null
          : AppBar(
              backgroundColor: isDark ? AppColors.surface : AppColors.lightSurface,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              title: Text(
                userAsync.asData?.value != null
                    ? '@${userAsync.asData!.value!.username}'
                    : 'Profile',
                style: AppTextStyles.title2.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return _buildNotFound(isDark);
          return _ProfileBody(user: user, isDark: isDark, currentUserId: currentUserId);
        },
        loading: () => SingleChildScrollView(
          padding: const EdgeInsets.all(SpacingScale.s16),
          child: Column(
            children: [
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.card : AppColors.lightCard,
                  borderRadius: AppRadius.brXl3,
                  border: Border.all(
                      color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.3),
                      width: 0.5),
                ),
                child: const CardShimmer(count: 2),
              ),
              const SizedBox(height: SpacingScale.s16),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.card : AppColors.lightCard,
                  borderRadius: AppRadius.brXl3,
                  border: Border.all(
                      color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.3),
                      width: 0.5),
                ),
                child: const CardShimmer(count: 3),
              ),
            ],
          ),
        ),
        error: (e, _) => Center(
          child: Container(
            margin: const EdgeInsets.all(SpacingScale.s16),
            padding: const EdgeInsets.all(SpacingScale.s24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.card : AppColors.lightCard,
              borderRadius: AppRadius.brXl3,
              border: Border.all(color: AppColors.danger.withValues(alpha: 0.3), width: 0.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded, size: 40, color: AppColors.danger),
                SizedBox(height: SpacingScale.s8),
                Text('Failed to load profile: $e',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(color: AppColors.danger)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotFound(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpacingScale.s24),
        child: DashboardEmptyState(
          icon: Icons.person_off_rounded,
          title: 'User not found',
          subtitle: 'This profile may have been removed or the link is invalid.',
        ),
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({
    required this.user,
    required this.isDark,
    required this.currentUserId,
  });

  final UserModel user;
  final bool isDark;
  final String? currentUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelf = currentUserId == user.uid;
    final roleDocAsync = ref.watch(publicRoleProfileProvider((uid: user.uid, role: user.role.name)));
    final streakAsync = ref.watch(userStreakProvider(user.uid));
    final followersAsync = ref.watch(userFollowersProvider(user.uid));
    final roleDoc = roleDocAsync.asData?.value;

    final points = _extractPoints(roleDoc);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 840),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _ProfileHeader(
                user: user,
                isDark: isDark,
                points: points,
                streak: streakAsync.asData?.value ?? 0,
                isVerified: _isVerified(roleDoc),
                isSelf: isSelf,
                currentUserId: currentUserId,
                roleDoc: roleDoc,
              ),
            ),
            if (roleDoc != null)
              SliverToBoxAdapter(
                child: _RoleDetailsSection(
                  user: user,
                  roleDoc: roleDoc,
                  isDark: isDark,
                ),
              ),
            SliverToBoxAdapter(child: _sectionTitle('Posts', isDark)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s16),
              sliver: SliverToBoxAdapter(
                child: _PostsSection(userId: user.uid, isDark: isDark),
              ),
            ),
            if (followersAsync.asData?.value.isNotEmpty == true)
              SliverToBoxAdapter(child: _sectionTitle('Followers', isDark)),
            if (followersAsync.asData?.value.isNotEmpty == true)
              SliverToBoxAdapter(
                child: _FollowersStrip(
                  followers: followersAsync.asData!.value,
                  isDark: isDark,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: SpacingScale.s32)),
          ],
        ),
      ),
    );
  }

  int _extractPoints(Map<String, dynamic>? roleDoc) {
    if (roleDoc == null) return 0;
    final points = roleDoc['points'];
    if (points is num) return points.toInt();
    final reputation = roleDoc['reputationPoints'];
    if (reputation is num) return reputation.toInt();
    return 0;
  }

  bool _isVerified(Map<String, dynamic>? roleDoc) {
    if (roleDoc == null) return false;
    return roleDoc['isVerified'] == true;
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          SpacingScale.s16, SpacingScale.s24, SpacingScale.s16, SpacingScale.s12),
      child: Text(
        title,
        style: AppTextStyles.title2.copyWith(
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
        ),
      ),
    );
  }
}

class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader({
    required this.user,
    required this.isDark,
    required this.points,
    required this.streak,
    required this.isVerified,
    required this.isSelf,
    required this.currentUserId,
    this.roleDoc,
  });

  final UserModel user;
  final bool isDark;
  final int points;
  final int streak;
  final bool isVerified;
  final bool isSelf;
  final String? currentUserId;
  final Map<String, dynamic>? roleDoc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardColor = isDark ? AppColors.card : AppColors.lightCard;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    final isFollowingAsync = currentUserId != null
        ? ref.watch(isFollowingProvider((followerId: currentUserId!, followedId: user.uid)))
        : null;

    final canChallenge =
        currentUserId != null && !isSelf && user.role == UserRole.player;
    final canBook =
        currentUserId != null && !isSelf && user.role == UserRole.coach;
    final viewerAsync = currentUserId != null
        ? ref.watch(publicUserProfileProvider(currentUserId!))
        : null;
    final viewerName = viewerAsync?.asData?.value?.name ?? '';

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CoverGradient(),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    SpacingScale.s16, 0, SpacingScale.s16, SpacingScale.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 48),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      user.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.heading3.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (isVerified) ...[
                                    const SizedBox(width: SpacingScale.s6),
                                    const Icon(Icons.verified_rounded,
                                        size: 18, color: AppColors.primary),
                                  ],
                                ],
                              ),
                              const SizedBox(height: SpacingScale.s2),
                              Text(
                                '@${user.username}',
                                style: AppTextStyles.body.copyWith(color: textSecondary),
                              ),
                              const SizedBox(height: SpacingScale.s10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: SpacingScale.s10, vertical: SpacingScale.s4),
                                decoration: BoxDecoration(
                                  color: _roleColor().withValues(alpha: 0.12),
                                  borderRadius: AppRadius.brFull,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(_roleIcon(), size: 12, color: _roleColor()),
                                    const SizedBox(width: 4),
                                    Text(
                                      _roleLabel(),
                                      style: AppTextStyles.labelSm.copyWith(
                                        color: _roleColor(),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -52),
                          child: GestureDetector(
                            onTap: isSelf ? () => _uploadProfilePic(context, ref) : null,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: AppRadius.brXl3,
                                border: Border.all(color: borderColor),
                              ),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  UserAvatar(
                                    userId: user.uid,
                                    name: user.name,
                                    photoUrl: user.photoUrl,
                                    size: 72,
                                    readOnly: true,
                                    backgroundColor: _roleColor(),
                                  ),
                                  if (isSelf)
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
                        ),
                      ],
                    ),
                    if ((user.bio ?? '').isNotEmpty) ...[
                      const SizedBox(height: SpacingScale.s12),
                      Text(user.bio!, style: AppTextStyles.body.copyWith(
                        color: textPrimary,
                        height: 1.4,
                      )),
                    ],
                    const SizedBox(height: SpacingScale.s12),
                    Wrap(
                      spacing: SpacingScale.s16,
                      runSpacing: SpacingScale.s8,
                      children: [
                        if (user.city != null && user.city!.isNotEmpty)
                          _infoPill(Icons.location_on_rounded, user.city!, textSecondary),
                        if (user.createdAt != null)
                          _infoPill(Icons.calendar_today_rounded,
                              'Joined ${_formatMonthYear(user.createdAt!)}', textSecondary),
                      ],
                    ),
                    const SizedBox(height: SpacingScale.s16),
                    Row(
                      children: [
                        Expanded(
                          child: _StatTile(
                            label: 'Followers',
                            value: formatCount(user.followersCount),
                            onTap: () => _showPeopleSheet(context, 'Followers'),
                          ),
                        ),
                        Expanded(
                          child: _StatTile(
                            label: 'Following',
                            value: formatCount(user.followingCount),
                            onTap: () => _showPeopleSheet(context, 'Following'),
                          ),
                        ),
                        Expanded(
                          child: _StatTile(
                            label: 'XP',
                            value: formatCount(points),
                          ),
                        ),
                        Expanded(
                          child: _StatTile(
                            label: 'Streak',
                            value: '${streak}d',
                            icon: Icons.local_fire_department_rounded,
                            iconColor: AppColors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: SpacingScale.s16),
                    if (isSelf)
                      _actionButton(
                        icon: Icons.edit_rounded,
                        label: 'Edit Profile',
                        isPrimary: false,
                        onTap: () => context.push(AppRoutes.settings, extra: user),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: isFollowingAsync?.asData?.value == true
                                    ? _actionButton(
                                        icon: Icons.check_rounded,
                                        label: 'Following',
                                        isPrimary: false,
                                        onTap: () => _toggleFollow(context, ref),
                                      )
                                    : _actionButton(
                                        icon: Icons.person_add_alt_1_rounded,
                                        label: 'Follow',
                                        isPrimary: true,
                                        onTap: () => _toggleFollow(context, ref),
                                      ),
                              ),
                              const SizedBox(width: SpacingScale.s12),
                              Expanded(
                                child: _actionButton(
                                  icon: Icons.chat_bubble_outline_rounded,
                                  label: 'Message',
                                  isPrimary: false,
                                  onTap: () => _startChat(context, ref),
                                ),
                              ),
                            ],
                          ),
                          if (canBook) ...[
                            const SizedBox(height: SpacingScale.s12),
                            _actionButton(
                              icon: Icons.event_available_rounded,
                              label: 'Book Session',
                              isPrimary: true,
                              onTap: () => _startBooking(context, ref),
                            ),
                          ],
                          if (canChallenge) ...[
                            const SizedBox(height: SpacingScale.s12),
                            _actionButton(
                              icon: Icons.bolt_rounded,
                              label: 'Challenge',
                              isPrimary: false,
                              onTap: () => _startChallenge(context, ref, viewerName),
                            ),
                          ],
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: DurationTokens.fast);
  }


  Future<void> _uploadProfilePic(BuildContext context, WidgetRef ref) async {
    try {
      final bytes = await ref.read(mediaUploadServiceProvider).pickCompressedImage();
      if (bytes == null) return;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Optimizing & uploading profile picture...'), duration: Duration(seconds: 2)),
        );
      }
      await ref.read(mediaUploadServiceProvider).updateUserProfilePicture(
        userId: user.uid,
        bytes: bytes,
      );
      ref.invalidate(authStateProvider);
      ref.invalidate(publicUserProfileProvider(user.uid));
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
            content: Text('Failed to update picture: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Color _roleColor() {
    switch (user.role) {
      case UserRole.player:
        return AppColors.success;
      case UserRole.coach:
        return AppColors.purple;
      case UserRole.academy:
        return AppColors.orange;
      case UserRole.admin:
        return AppColors.gold;
      case UserRole.parent:
        return AppColors.primary;
    }
  }

  IconData _roleIcon() {
    switch (user.role) {
      case UserRole.player:
        return Icons.sports_tennis_rounded;
      case UserRole.coach:
        return Icons.sports_rounded;
      case UserRole.academy:
        return Icons.school_rounded;
      case UserRole.admin:
        return Icons.admin_panel_settings_rounded;
      case UserRole.parent:
        return Icons.family_restroom_rounded;
    }
  }

  String _roleLabel() {
    switch (user.role) {
      case UserRole.player:
        return 'Player';
      case UserRole.coach:
        return 'Coach';
      case UserRole.academy:
        return 'Academy';
      case UserRole.admin:
        return 'Admin';
      case UserRole.parent:
        return 'Parent';
    }
  }

  Widget _infoPill(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: SpacingScale.s4),
        Text(label, style: AppTextStyles.caption.copyWith(color: color)),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          gradient: isPrimary
              ? const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight])
              : null,
          color: isPrimary ? null : (isDark ? AppColors.surfaceElevated : AppColors.lightSurfaceSecondary),
          borderRadius: AppRadius.brXl2,
          border: isPrimary ? null : Border.all(
              color: isDark ? AppColors.border : AppColors.lightBorder, width: 1),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18,
                color: isPrimary ? Colors.white : (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary)),
            const SizedBox(width: SpacingScale.s6),
            Text(
              label,
              style: AppTextStyles.button.copyWith(
                color: isPrimary ? Colors.white : (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFollow(BuildContext context, WidgetRef ref) async {
    final followerId = currentUserId;
    if (followerId == null || followerId == user.uid) return;
    final service = ref.read(profileServiceProvider);
    final currentlyFollowing = await service.isFollowing(followerId, user.uid);
    try {
      if (currentlyFollowing) {
        await service.unfollow(followerId, user.uid);
      } else {
        await service.follow(followerId, user.uid);
      }
      ref.invalidate(isFollowingProvider((followerId: followerId, followedId: user.uid)));
      ref.invalidate(publicUserProfileProvider(user.uid));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(currentlyFollowing ? 'Unfollowed' : 'Following'),
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
            content: Text('Failed: $e'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
          ),
        );
      }
    }
  }

  Future<void> _startChat(BuildContext context, WidgetRef ref) async {
    final senderId = currentUserId;
    if (senderId == null) return;
    final chatService = ref.read(chatServiceProvider);
    try {
      final chatId = await chatService.createChat([senderId, user.uid]);
      if (context.mounted) {
        context.push('/chat/$chatId', extra: user.uid);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start chat: $e'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
          ),
        );
      }
    }
  }

  void _startChallenge(BuildContext context, WidgetRef ref, String challengerName) {
    final challengerId = currentUserId;
    if (challengerId == null || challengerId == user.uid) return;
    showCreateChallengeSheet(
      context,
      ref,
      challengerId: challengerId,
      challengerName: challengerName.isNotEmpty ? challengerName : challengerId,
      initialOpponent: user,
    );
  }

  void _startBooking(BuildContext context, WidgetRef ref) {
    final coach = CoachModel(
      coachId: user.uid,
      name: user.name,
      email: user.email,
      phone: user.phone,
      photoUrl: user.photoUrl,
      city: user.city,
      specialization: (roleDoc?['specialization'] as String?) ?? user.bio,
      experience: (roleDoc?['experience'] as num?)?.toInt() ?? 0,
      hourlyRate: (roleDoc?['hourlyRate'] as num?)?.toDouble() ?? 0,
      bio: (roleDoc?['bio'] as String?) ?? user.bio,
      rating: (roleDoc?['rating'] as num?)?.toDouble() ?? 0,
      totalReviews: (roleDoc?['totalReviews'] as num?)?.toInt() ?? 0,
      isVerified: isVerified,
    );
    context.push(AppRoutes.bookingFlow, extra: coach);
  }

  void _showPeopleSheet(BuildContext context, String title) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _PeopleSheet(
        title: title,
        userId: user.uid,
        isDark: isDark,
      ),
    );
  }
}

class _PeopleSheet extends ConsumerWidget {
  const _PeopleSheet({
    required this.title,
    required this.userId,
    required this.isDark,
  });

  final String title;
  final String userId;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final peopleAsync = title == 'Followers'
        ? ref.watch(userFollowersProvider(userId))
        : ref.watch(userFollowingProvider(userId));
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.85,
      minChildSize: 0.35,
      builder: (ctx, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : AppColors.lightSurface,
          borderRadius: AppRadius.top(SpacingScale.s24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(SpacingScale.s20),
              child: Row(
                children: [
                  Text(title,
                      style: AppTextStyles.heading3.copyWith(
                        color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                      )),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close_rounded,
                        color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            Expanded(
              child: peopleAsync.when(
                data: (people) {
                  if (people.isEmpty) {
                    return Center(
                      child: Text('No $title yet',
                          style: AppTextStyles.body.copyWith(
                              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
                    );
                  }
                  return ListView.separated(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(
                        SpacingScale.s16, 0, SpacingScale.s16, SpacingScale.s24),
                    itemCount: people.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, index) {
                      final person = people[index];
                      return UserHeaderTile(
                        userId: person.uid,
                        name: person.name,
                        subtitle: '@${person.username}',
                        photoUrl: person.photoUrl,
                        onTap: () {
                          Navigator.pop(ctx);
                          context.push('/profile/${person.uid}');
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Failed to load: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverGradient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF090B10),
        image: DecorationImage(
          image: AssetImage('assets/backgrounds/stadium_floodlights.jpg'),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.35),
              const Color(0xFF090B10).withValues(alpha: 0.65),
              const Color(0xFF090B10).withValues(alpha: 0.95),
            ],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        alignment: Alignment.topRight,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF00E5FF),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'ATHLETE PROFILE',
                style: TextStyle(
                  color: Color(0xFF00E5FF),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    this.onTap,
    this.icon,
    this.iconColor,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: iconColor),
                const SizedBox(width: 3),
              ],
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title2.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(label,
              style: AppTextStyles.captionXs.copyWith(color: textSecondary, fontSize: 10)),
        ],
      ),
    );
  }
}

class _RoleDetailsSection extends ConsumerWidget {
  const _RoleDetailsSection({
    required this.user,
    required this.roleDoc,
    required this.isDark,
  });

  final UserModel user;
  final Map<String, dynamic> roleDoc;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (user.role) {
      case UserRole.player:
        return _playerDetails(context, ref);
      case UserRole.coach:
        return _coachDetails(context);
      case UserRole.academy:
        return _academyDetails(context);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _sectionCard(BuildContext context, Widget child) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          SpacingScale.s16, SpacingScale.s16, SpacingScale.s16, 0),
      padding: const EdgeInsets.all(SpacingScale.s16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl3,
        border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder, width: 0.5),
      ),
      child: child,
    );
  }

  Widget _sectionHeader(BuildContext context, IconData icon, String title) {
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    return Row(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: AppRadius.brLg,
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: SpacingScale.s10),
        Text(title,
            style: AppTextStyles.title2.copyWith(
                fontWeight: FontWeight.w700, color: textPrimary)),
      ],
    );
  }

  Widget _detailRow(BuildContext context, String label, String value, {Color? valueColor}) {
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SpacingScale.s6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body.copyWith(color: textSecondary)),
          const SizedBox(width: SpacingScale.s12),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: AppTextStyles.body.copyWith(
                    color: valueColor ?? textPrimary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _playerDetails(BuildContext context, WidgetRef ref) {
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final points = (roleDoc['points'] as num?)?.toInt() ?? 0;
    final rank = (roleDoc['rank'] as num?)?.toInt() ?? 0;
    final wins = (roleDoc['championshipWins'] as num?)?.toInt() ?? 0;
    final tournamentPoints = (roleDoc['tournamentPoints'] as num?)?.toInt() ?? 0;
    final age = roleDoc['age'] as num?;
    final sports = (roleDoc['sports'] as List<dynamic>?)?.cast<String>() ?? <String>[];
    final readiness = roleDoc['readinessStatus'] as String? ?? 'Fundamentals';
    final highestCertTitle = roleDoc['highestCertificateTitle'] as String?;
    final totalPbs = (roleDoc['totalPbs'] as num?)?.toInt() ?? 0;
    final totalDrills = (roleDoc['totalDrills'] as num?)?.toInt() ?? 0;

    final levelModel = LevelModel.getLevel(points);
    final progress = LevelModel.getProgress(points);
    final rankModel = rank >= 1 && rank <= RankModel.ranks.length
        ? RankModel.ranks[rank - 1]
        : null;

    final achievementsAsync = ref.watch(userAchievementsProvider(user.uid));
    final certsAsync = ref.watch(playerCertificatesProvider(user.uid));

    final readinessColor = readiness == 'Elite Roster'
        ? AppColors.gold
        : readiness == 'Tournament Ready'
            ? AppColors.emerald
            : readiness == 'Sparring Ready'
                ? AppColors.primary
                : const Color(0xFF94A3B8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionCard(
          context,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionHeader(context, Icons.insights_rounded, 'Player Stats'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: readinessColor.withValues(alpha: 0.12),
                      borderRadius: AppRadius.brLg,
                      border: Border.all(color: readinessColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shield_rounded, size: 12, color: readinessColor),
                        const SizedBox(width: 4),
                        Text(
                          readiness,
                          style: AppTextStyles.captionXs.copyWith(
                            color: readinessColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpacingScale.s12),
              Row(
                children: [
                  Expanded(
                    child: _levelBox(
                      icon: levelModel.icon,
                      label: 'Level ${levelModel.level}',
                      value: levelModel.title,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: SpacingScale.s10),
                  Expanded(
                    child: _levelBox(
                      icon: rankModel?.icon ?? '🎖️',
                      label: 'Rank',
                      value: rankModel?.title ?? 'Unranked',
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpacingScale.s12),
              ClipRRect(
                borderRadius: AppRadius.brFull,
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: isDark ? AppColors.surfaceElevated : AppColors.lightSurfaceSecondary,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
              const SizedBox(height: SpacingScale.s6),
              Text(
                '$points XP \u2022 ${levelModel.maxPoints - points} XP to next level',
                style: AppTextStyles.captionXs.copyWith(color: textSecondary),
              ),
              if (highestCertTitle != null) ...[
                const SizedBox(height: SpacingScale.s12),
                Container(
                  padding: const EdgeInsets.all(SpacingScale.s10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.gold.withValues(alpha: 0.15),
                        AppColors.purple.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: AppRadius.brLg,
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Text('🏆', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: SpacingScale.s10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'HIGHEST PRESTIGE ACCREDITATION',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: AppColors.gold,
                              ),
                            ),
                            Text(
                              highestCertTitle,
                              style: AppTextStyles.bodySm.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        _sectionCard(
          context,
          Column(
            children: [
              _sectionHeader(context, Icons.emoji_events_rounded, 'Achievements & Credentials'),
              const SizedBox(height: SpacingScale.s12),
              if (age != null || sports.isNotEmpty) ...[
                _detailRow(context, 'Age', '${age!.toInt()} yrs'),
                if (sports.isNotEmpty)
                  _detailRow(context, 'Sports', sports.join(', ')),
                const Divider(height: SpacingScale.s16),
              ],
              _detailRow(context, 'Championship Wins', '$wins'),
              _detailRow(context, 'Tournament Points', '$tournamentPoints'),
              if (totalPbs > 0 || totalDrills > 0) ...[
                _detailRow(context, 'Career Personal Bests', '$totalPbs'),
                _detailRow(context, 'Verified Drills', '$totalDrills'),
              ],
              const SizedBox(height: SpacingScale.s12),

              // Prestige Certificates Showcase
              certsAsync.when(
                data: (certs) {
                  if (certs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: SpacingScale.s12),
                      child: InkWell(
                        onTap: () => context.push('/player-certificates/${user.uid}'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.04),
                            borderRadius: AppRadius.brLg,
                            border: Border.all(
                              color: isDark ? AppColors.border : AppColors.lightBorder,
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.workspace_premium_rounded, size: 16, color: AppColors.gold),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Prestige Certificates (15 Tiers)',
                                      style: AppTextStyles.caption.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      'View credential milestones & PDF export',
                                      style: AppTextStyles.captionXs.copyWith(
                                        color: isDark ? Colors.white54 : Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'Trophy Room',
                                style: AppTextStyles.captionXs.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.primary),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.workspace_premium_rounded, size: 14, color: AppColors.gold),
                              const SizedBox(width: 4),
                              Text(
                                'Prestige Certificates (${certs.length})',
                                style: AppTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () => context.push('/player-certificates/${user.uid}'),
                            child: Row(
                              children: [
                                Text(
                                  'Trophy Room & PDF',
                                  style: AppTextStyles.captionXs.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.primary),
                              ],
                            ),
                          ),
                        ],
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
                                  const Icon(Icons.arrow_outward_rounded, size: 11, color: Colors.grey),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: SpacingScale.s12),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),

              achievementsAsync.when(
                data: (achievements) => achievements.isEmpty
                    ? Text('No other achievements yet', style: AppTextStyles.caption.copyWith(color: textSecondary))
                    : Wrap(
                        spacing: SpacingScale.s8,
                        runSpacing: SpacingScale.s8,
                        children: achievements
                            .take(8)
                            .map((a) => _achievementChip(context, a))
                            .toList(),
                      ),
                loading: () => const Center(
                    child: Padding(
                  padding: EdgeInsets.all(SpacingScale.s8),
                  child: SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                )),
                error: (_, _) => Text('Failed to load achievements',
                    style: AppTextStyles.caption.copyWith(color: AppColors.danger)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _levelBox({
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    return Container(
      padding: const EdgeInsets.all(SpacingScale.s12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppRadius.brXl2,
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: SpacingScale.s4),
          Text(label, style: AppTextStyles.captionXs.copyWith(
              color: textPrimary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.captionXs.copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _achievementChip(BuildContext context, Map<String, dynamic> achievement) {
    final title = achievement['title'] as String? ?? 'Achievement';
    final icon = achievement['icon'] as String?;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s10, vertical: SpacingScale.s6),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: AppRadius.brFull,
        border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon ?? '🏅', style: const TextStyle(fontSize: 13)),
          const SizedBox(width: SpacingScale.s4),
          Text(title,
              style: AppTextStyles.captionXs.copyWith(
                  color: AppColors.success, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _coachDetails(BuildContext context) {
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final rating = (roleDoc['rating'] as num?)?.toDouble() ?? 0;
    final totalReviews = (roleDoc['totalReviews'] as num?)?.toInt() ?? 0;
    final experience = (roleDoc['experience'] as num?)?.toInt() ?? 0;
    final hourlyRate = (roleDoc['hourlyRate'] as num?)?.toDouble() ?? 0;
    final specialization = roleDoc['specialization'] as String?;
    final certificates = (roleDoc['certificates'] as List<dynamic>?)?.cast<String>() ?? <String>[];
    final bio = roleDoc['bio'] as String?;

    return Column(
      children: [
        _sectionCard(
          context,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(context, Icons.workspace_premium_rounded, 'Coach Profile'),
              const SizedBox(height: SpacingScale.s12),
              if (bio != null && bio.isNotEmpty) ...[
                Text(bio,
                    style: AppTextStyles.body.copyWith(
                      color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                      height: 1.4,
                    )),
                const Divider(height: SpacingScale.s16),
              ],
              Row(
                children: [
                  Expanded(
                    child: _levelBox(
                      icon: '⭐',
                      label: 'Rating',
                      value: rating.toStringAsFixed(1),
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(width: SpacingScale.s10),
                  Expanded(
                    child: _levelBox(
                      icon: '📈',
                      label: 'Reviews',
                      value: '$totalReviews',
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpacingScale.s8),
              _detailRow(context, 'Experience', '$experience yrs'),
              if (specialization != null && specialization.isNotEmpty)
                _detailRow(context, 'Specialization', specialization),
              if (hourlyRate > 0) ...[
                _detailRow(context, 'Hourly Rate', '\u20B9${hourlyRate.toInt()}/hr',
                    valueColor: AppColors.primary),
              ],
              if (certificates.isNotEmpty) ...[
                const Divider(height: SpacingScale.s16),
                Text('Certificates', style: AppTextStyles.label.copyWith(color: textSecondary)),
                const SizedBox(height: SpacingScale.s8),
                Wrap(
                  spacing: SpacingScale.s8,
                  runSpacing: SpacingScale.s8,
                  children: certificates
                      .take(8)
                      .map((c) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: SpacingScale.s10, vertical: SpacingScale.s6),
                            decoration: BoxDecoration(
                              color: AppColors.purple.withValues(alpha: 0.08),
                              borderRadius: AppRadius.brFull,
                              border: Border.all(color: AppColors.purple.withValues(alpha: 0.2)),
                            ),
                            child: Text(c,
                                style: AppTextStyles.captionXs.copyWith(
                                    color: AppColors.purple, fontWeight: FontWeight.w600)),
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _academyDetails(BuildContext context) {
    final reputation = (roleDoc['reputationPoints'] as num?)?.toInt() ?? 0;
    final placements = (roleDoc['coachPlacements'] as num?)?.toInt() ?? 0;
    final students = (roleDoc['totalStudents'] as num?)?.toInt() ?? 0;
    final sports = (roleDoc['sports'] as List<dynamic>?)?.cast<String>() ?? <String>[];
    final description = roleDoc['description'] as String?;

    return Column(
      children: [
        _sectionCard(
          context,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(context, Icons.school_rounded, 'Academy Profile'),
              const SizedBox(height: SpacingScale.s12),
              if (description != null && description.isNotEmpty) ...[
                Text(description,
                    style: AppTextStyles.body.copyWith(
                      color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                      height: 1.4,
                    )),
                const Divider(height: SpacingScale.s16),
              ],
              _detailRow(context, 'Reputation Points', '$reputation'),
              _detailRow(context, 'Coach Placements', '$placements'),
              _detailRow(context, 'Active Students', '$students'),
              if (sports.isNotEmpty) _detailRow(context, 'Sports', sports.join(', ')),
            ],
          ),
        ),
      ],
    );
  }
}

class _PostsSection extends ConsumerWidget {
  const _PostsSection({required this.userId, required this.isDark});

  final String userId;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(userPostsProvider(userId));
    return postsAsync.when(
      data: (posts) {
        if (posts.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(SpacingScale.s24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.card : AppColors.lightCard,
              borderRadius: AppRadius.brXl3,
              border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder, width: 0.5),
            ),
            child: Column(
              children: [
                Icon(Icons.article_outlined, size: 40,
                    color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
                const SizedBox(height: SpacingScale.s12),
                Text('No posts yet',
                    style: AppTextStyles.body.copyWith(
                        color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${posts.length} PUBLISHED POSTS • SLIDE TO EXPLORE',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.swipe_rounded, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Slide',
                    style: TextStyle(
                      color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 290,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: posts.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return _slidingPostCard(context, posts[index]);
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(
          child: Padding(
        padding: EdgeInsets.all(SpacingScale.s16),
        child: CircularProgressIndicator(color: AppColors.primary),
      )),
      error: (e, _) => Center(
        child: Text('Failed to load posts: $e',
            style: AppTextStyles.body.copyWith(color: AppColors.danger)),
      ),
    );
  }

  Widget _slidingPostCard(BuildContext context, Map<String, dynamic> post) {
    final content = post['content'] as String? ?? '';
    final mediaUrl = post['mediaUrl'] as String?;
    final likes = (post['likes'] as num?)?.toInt() ?? 0;
    final commentsCount = (post['comments'] as List?)?.length ?? 0;
    final createdAt = (post['createdAt'] as Timestamp?)?.toDate();
    final timeStr = createdAt != null ? _formatTime(createdAt) : '';

    return Container(
      width: 270,
      padding: const EdgeInsets.all(SpacingScale.s12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl2,
        border: Border.all(
          color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Media display
          if (mediaUrl != null && mediaUrl.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 135,
                width: double.infinity,
                child: _buildMediaWidget(mediaUrl),
              ),
            ),
            const SizedBox(height: SpacingScale.s10),
          ] else ...[
            Container(
              height: 70,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(Icons.format_quote_rounded, size: 28, color: AppColors.primary.withValues(alpha: 0.4)),
              ),
            ),
            const SizedBox(height: SpacingScale.s10),
          ],

          // Post Content
          Expanded(
            child: Text(
              content.isNotEmpty ? content : 'Shared athletic moments & progress',
              maxLines: mediaUrl != null ? 3 : 5,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySm.copyWith(
                color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                height: 1.35,
              ),
            ),
          ),

          const SizedBox(height: SpacingScale.s8),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: SpacingScale.s8),

          // Footer
          Row(
            children: [
              Icon(Icons.favorite_rounded, size: 14, color: AppColors.danger),
              const SizedBox(width: SpacingScale.s4),
              Text('$likes',
                  style: AppTextStyles.captionXs.copyWith(
                      color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: SpacingScale.s12),
              Icon(Icons.chat_bubble_outline_rounded, size: 14,
                  color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
              const SizedBox(width: SpacingScale.s4),
              Text('$commentsCount',
                  style: AppTextStyles.captionXs.copyWith(
                      color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary)),
              const Spacer(),
              if (timeStr.isNotEmpty)
                Text(timeStr,
                    style: AppTextStyles.captionXs.copyWith(
                        color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMediaWidget(String url) {
    if (url.startsWith('data:')) {
      try {
        final commaIdx = url.indexOf(',');
        final base64Str = commaIdx != -1 ? url.substring(commaIdx + 1) : url;
        final bytes = base64Decode(base64Str);
        return Image.memory(bytes, fit: BoxFit.cover, errorBuilder: (_, _, _) => _mediaPlaceholder());
      } catch (_) {
        return _mediaPlaceholder();
      }
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _mediaPlaceholder(),
    );
  }

  Widget _mediaPlaceholder() {
    return Container(
      color: Colors.black26,
      child: const Center(
        child: Icon(Icons.broken_image_rounded, color: Colors.white54, size: 28),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}


class _FollowersStrip extends StatelessWidget {
  const _FollowersStrip({required this.followers, required this.isDark});
  final List<UserModel> followers;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s16),
        scrollDirection: Axis.horizontal,
        itemCount: followers.length,
        separatorBuilder: (_, _) => const SizedBox(width: SpacingScale.s12),
        itemBuilder: (ctx, i) {
          final f = followers[i];
          return GestureDetector(
            onTap: () => context.push('/profile/${f.uid}'),
            child: Column(
              children: [
                UserAvatar(
                  userId: f.uid,
                  name: f.name,
                  photoUrl: f.photoUrl,
                  size: 48,
                  readOnly: true,
                ),
                const SizedBox(height: SpacingScale.s4),
                SizedBox(
                  width: 60,
                  child: Text(
                    f.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.captionXs.copyWith(
                      color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

String _formatMonthYear(DateTime dt) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${months[dt.month - 1]} ${dt.year}';
}

String formatCount(int count) {
  if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
  if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
  return count.toString();
}
