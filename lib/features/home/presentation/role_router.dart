import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import 'parent_shell.dart';
import 'player_shell.dart';
import 'coach_shell.dart';
import 'academy_shell.dart';
import 'admin_shell.dart';

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
    switch (userModel.role) {
      case UserRole.parent:
        return ParentShell(userModel: userModel);
      case UserRole.player:
        return PlayerShell(userModel: userModel);
      case UserRole.coach:
        return CoachShell(userModel: userModel);
      case UserRole.academy:
        return AcademyShell(userModel: userModel);
      case UserRole.admin:
        return AdminShell(userModel: userModel);
    }
  }
}

class _SplashLoading extends StatelessWidget {
  const _SplashLoading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final String e;
  const _ErrorScreen({required this.e});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Something went wrong', style: AppTextStyles.titleLarge),
            const SizedBox(height: 8),
            Text(e, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
