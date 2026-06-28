import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/auth_provider.dart';

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
    // Fallback if stream hasn't emitted yet
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
                  color: AppColors.accent.withValues(alpha: 0.03),
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
                      gradient: const LinearGradient(colors: AppColors.gradientPrimary),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.sports_rounded, size: 60, color: Colors.white),
                  ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 24),
                  Text(
                    'SportsEco',
                    style: AppTextStyles.displayLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    'Your Complete Sports Ecosystem',
                    style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                  ).animate().fadeIn(duration: 600.ms, delay: 800.ms).slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 60),
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
