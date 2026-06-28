import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email'), backgroundColor: AppColors.warning),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).sendPasswordResetEmail(email);
      setState(() => _isSent = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _isSent ? _buildSuccess(theme) : _buildForm(theme),
        ),
      ),
    );
  }

  Widget _buildForm(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.go('/login'),
          ),
          const SizedBox(height: 24),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.gradientPrimary),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: Icon(Icons.lock_reset_rounded, color: Colors.white, size: 28)),
          ).animate().fadeIn().scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 24),
          Text(
            'Reset Password',
            style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0),
          const SizedBox(height: 8),
          Text(
            "Enter your email and we'll send you a reset link",
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2, end: 0),
          const SizedBox(height: 32),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 24),
          GradientButton(
            onPressed: _isLoading ? null : _sendResetLink,
            isLoading: _isLoading,
            height: 54,
            child: Text('Send Reset Link', style: AppTextStyles.buttonLarge.copyWith(color: Colors.white)),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildSuccess(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 48),
          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 24),
          Text(
            'Email Sent!',
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 8),
          Text(
            'Check your inbox for the reset link',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 32),
          OutlinedButton(
            onPressed: () => context.go('/login'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(200, 48),
            ),
            child: Text('Back to Login', style: theme.textTheme.labelLarge),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }
}
