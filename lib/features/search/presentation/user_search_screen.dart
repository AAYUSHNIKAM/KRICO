import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/radius/radius.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../design_system/widgets/page_headers/page_hero.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/providers.dart';

class UserSearchScreen extends ConsumerStatefulWidget {
  const UserSearchScreen({super.key});

  @override
  ConsumerState<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends ConsumerState<UserSearchScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textTertiary = isDark ? AppColors.textTertiary : AppColors.lightTextTertiary;
    final currentUserId = ref.watch(authStateProvider).value?.uid;

    return Scaffold(
      body: Container(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        child: CustomScrollView(
          slivers: [
            const PageHero(
              title: 'Search',
              subtitle: 'Find people by name or username',
              backgroundColor: AppColors.primary,
              showPhoneHeader: true,
              phoneTitle: 'Search',
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    SpacingScale.s16, SpacingScale.s16, SpacingScale.s16, 0),
                child: TextField(
                  controller: _searchCtrl,
                  autofocus: true,
                  onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                  style: AppTextStyles.body.copyWith(color: textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search by name or username...',
                    hintStyle: AppTextStyles.body.copyWith(color: textTertiary),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: textTertiary, size: 20),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear_rounded, color: textTertiary, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary,
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.brXl2,
                      borderSide: BorderSide(
                          color: isDark ? AppColors.border : AppColors.lightBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.brXl2,
                      borderSide: BorderSide(
                          color: isDark ? AppColors.border : AppColors.lightBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppRadius.brXl2,
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
            ),
            if (_query.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _SearchHint(),
              )
            else
              ref.watch(allUsersProvider).when(
                data: (snap) {
                  final users = snap.docs
                      .map((d) => UserModel.fromDoc(d))
                      .where((u) => u.uid != currentUserId)
                      .where((u) =>
                          u.name.toLowerCase().contains(_query) ||
                          u.username.toLowerCase().contains(_query))
                      .toList()
                    ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
                  if (users.isEmpty) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _NoResults(),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                        SpacingScale.s16, SpacingScale.s12, SpacingScale.s16, SpacingScale.s32),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final user = users[index];
                          return _UserResultTile(
                            user: user,
                            isDark: isDark,
                          ).animate().fadeIn(delay: (index * 40).ms);
                        },
                        childCount: users.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
                error: (e, _) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text('Failed to load users: $e',
                        style: AppTextStyles.body.copyWith(color: AppColors.danger)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchHint extends StatelessWidget {
  const _SearchHint();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.person_search_rounded,
            size: 64,
            color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
        const SizedBox(height: SpacingScale.s16),
        Text('Search people',
            style: AppTextStyles.title2.copyWith(
              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
            )),
        const SizedBox(height: SpacingScale.s8),
        Text('Find players, coaches and academies by name or username',
            style: AppTextStyles.bodySm.copyWith(
              color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
            )),
      ],
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.search_off_rounded,
            size: 64,
            color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
        const SizedBox(height: SpacingScale.s16),
        Text('No users found',
            style: AppTextStyles.title2.copyWith(
              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
            )),
        const SizedBox(height: SpacingScale.s8),
        Text('Try a different name or username',
            style: AppTextStyles.bodySm.copyWith(
              color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
            )),
      ],
    );
  }
}

class _UserResultTile extends StatelessWidget {
  const _UserResultTile({required this.user, required this.isDark});

  final UserModel user;
  final bool isDark;

  Color get _roleColor {
    switch (user.role) {
      case UserRole.coach:
        return AppColors.primary;
      case UserRole.academy:
        return AppColors.purple;
      case UserRole.admin:
        return AppColors.danger;
      default:
        return AppColors.success;
    }
  }

  String get _roleLabel {
    switch (user.role) {
      case UserRole.parent:
        return 'Parent';
      case UserRole.player:
        return 'Player';
      case UserRole.coach:
        return 'Coach';
      case UserRole.academy:
        return 'Academy';
      case UserRole.admin:
        return 'Admin';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final textTertiary = isDark ? AppColors.textTertiary : AppColors.lightTextTertiary;

    return Container(
      margin: const EdgeInsets.only(bottom: SpacingScale.s6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl3,
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: InkWell(
        borderRadius: AppRadius.brXl3,
        onTap: () => context.push('/profile/${user.uid}'),
        child: Padding(
          padding: const EdgeInsets.all(SpacingScale.s12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _roleColor.withValues(alpha: 0.15),
                  borderRadius: AppRadius.brLg,
                ),
                clipBehavior: Clip.antiAlias,
                child: user.photoUrl != null
                    ? Image.network(user.photoUrl!, fit: BoxFit.cover)
                    : Center(
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                          style: TextStyle(
                              color: _roleColor, fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                      ),
              ),
              const SizedBox(width: SpacingScale.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name,
                        style: AppTextStyles.title3.copyWith(
                            fontWeight: FontWeight.w600, color: textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: SpacingScale.s2),
                    Text('@${user.username}',
                        style: AppTextStyles.bodySm.copyWith(color: textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: SpacingScale.s8, vertical: SpacingScale.s2),
                decoration: BoxDecoration(
                  color: _roleColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.brLg,
                ),
                child: Text(_roleLabel,
                    style: AppTextStyles.labelSm.copyWith(
                        color: _roleColor, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: SpacingScale.s4),
              Icon(Icons.chevron_right_rounded,
                  size: 20, color: textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
