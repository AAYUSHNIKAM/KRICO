import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../design_system/radius/radius.dart';
import '../../../design_system/tokens/duration_tokens.dart';
import '../../../providers/auth_provider.dart';

const _logoGradient = [Color(0xFFCCFF00), Color(0xFF00E5FF)];

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _minimumTimeElapsed = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), _onMinimumTimeElapsed);
  }

  void _onMinimumTimeElapsed() {
    if (!mounted) return;
    setState(() => _minimumTimeElapsed = true);
    final authState = ref.read(authStateProvider);
    authState.whenOrNull(data: (user) {
      if (user != null) {
        context.go('/home');
      } else {
        context.go('/login');
      }
    });
    if (authState.asData == null) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        context.go('/home');
      } else {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, (_, next) {
      if (!_minimumTimeElapsed) return;
      next.whenOrNull(data: (user) {
        if (user != null) {
          context.go('/home');
        } else {
          context.go('/login');
        }
      });
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0A0F),
              Color(0xFF12121A),
              Color(0xFF1A1A25),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.04),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -80,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.purple.withValues(alpha: 0.03),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: _logoGradient),
                      borderRadius: AppRadius.brXl3,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFCCFF00).withValues(alpha: 0.4),
                          blurRadius: 36,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.sports_rounded, size: 60, color: Color(0xFF090A0F)),
                  ).animate().scale(duration: DurationTokens.xl, curve: Curves.elasticOut),
                  SizedBox(height: SpacingScale.s24),
                  Text(
                    'KRICO',
                    style: AppTextStyles.display.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ).animate().fadeIn(duration: DurationTokens.slower, delay: 400.ms).slideY(begin: 0.3, end: 0),
                  SizedBox(height: SpacingScale.s8),
                  Text(
                    'Krida • Coach • Community',
                    style: AppTextStyles.bodyLg.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ).animate().fadeIn(duration: DurationTokens.slower, delay: 800.ms).slideY(begin: 0.3, end: 0),
                  SizedBox(height: SpacingScale.s64),
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary.withValues(alpha: 0.8)),
                    ),
                  ).animate().fadeIn(delay: 1200.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
