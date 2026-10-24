import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design_system/design_system.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import 'role_workspace.dart';

class RoleRouter extends ConsumerWidget {
  const RoleRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateProvider);

    return authAsync.when(
      data: (firebaseUser) {
        if (firebaseUser == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go('/login');
          });
          return const SizedBox.shrink();
        }
        final profileAsync = ref.watch(userProfileProvider(firebaseUser.uid));
        return profileAsync.when(
          data: (userModel) {
            if (userModel == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) context.go('/login');
              });
              return const SizedBox.shrink();
            }
            return _buildShell(userModel);
          },
          loading: () => const _SplashLoading(),
          error: (e, _) => _ErrorScreen(e: e.toString()),
        );
      },
      loading: () => const _SplashLoading(),
      error: (e, _) => _ErrorScreen(e: e.toString()),
    );
  }

  Widget _buildShell(UserModel userModel) {
    return RoleWorkspace(user: userModel);
  }
}

class _SplashLoading extends StatefulWidget {
  const _SplashLoading();

  @override
  State<_SplashLoading> createState() => _SplashLoadingState();
}

class _SplashLoadingState extends State<_SplashLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.medium,
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: AppAnimations.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryHover],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppRadius.brXl2,
                ),
                child: const Icon(
                  Icons.sports_soccer_rounded,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: SpacingScale.s20),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? AppColors.primary : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: SpacingScale.s12),
              Text(
                'Loading...',
                style: AppTextStyles.body.copyWith(
                  color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorScreen extends StatefulWidget {
  final String e;
  const _ErrorScreen({required this.e});

  @override
  State<_ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<_ErrorScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.slower,
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: AppAnimations.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: AppAnimations.decelerate));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Padding(
              padding: const EdgeInsets.all(SpacingScale.s24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.1),
                      borderRadius: AppRadius.brXl2,
                    ),
                    child: const Icon(
                      Icons.error_outline_rounded,
                      size: 28,
                      color: AppColors.danger,
                    ),
                  ),
                  const SizedBox(height: SpacingScale.s16),
                  Text(
                    'Something went wrong',
                    style: AppTextStyles.heading3.copyWith(
                      color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: SpacingScale.s8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: Text(
                      widget.e,
                      style: AppTextStyles.body.copyWith(
                        color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: SpacingScale.s24),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpacingScale.s24,
                        vertical: SpacingScale.s12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryHover],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: AppRadius.brLg,
                      ),
                      child: Text(
                        'Back to Login',
                        style: AppTextStyles.button.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
