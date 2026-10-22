import '../../../core/utils/auth_error_helper.dart';
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

const _gradientNormal = [Color(0xFFCCFF00), Color(0xFFB8E600)];
const _gradientHover = [Color(0xFFD4FF33), Color(0xFFCCFF00)];

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();
  bool _isLoading = false;
  bool _isSent = false;
  bool _emailFocused = false;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      if (mounted) setState(() => _emailFocused = _emailFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your email'),
          backgroundColor: AppColors.warning,
        ),
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
          SnackBar(
            content: Text(AuthErrorHelper.getFriendlyErrorMessage(e)),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.background : AppColors.lightBackground;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: EdgeInsets.all(SpacingScale.s24),
              child: _isSent ? _buildSuccess(textPrimary, textSecondary, borderColor) : _buildForm(isDark, textPrimary, textSecondary, borderColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(bool isDark, Color textPrimary, Color textSecondary, Color borderColor) {
    final fieldBg = isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => context.go('/login'),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary,
                borderRadius: AppRadius.brLg,
              ),
              child: const Icon(Icons.arrow_back_rounded, size: 20),
            ),
          ),
          SizedBox(height: SpacingScale.s24),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: _gradientNormal),
              borderRadius: AppRadius.br(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(child: Icon(Icons.lock_reset_rounded, color: Color(0xFF090A0F), size: 28)),
          ).animate().fadeIn().scale(duration: DurationTokens.long, curve: Curves.elasticOut),
          SizedBox(height: SpacingScale.s24),
          Text(
            'Reset Password',
            style: AppTextStyles.heading2.copyWith(color: textPrimary),
          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0),
          SizedBox(height: SpacingScale.s8),
          Text(
            "Enter your email and we'll send you a reset link",
            style: AppTextStyles.body.copyWith(color: textSecondary),
          ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2, end: 0),
          SizedBox(height: SpacingScale.s32),
          Container(
            padding: EdgeInsets.all(SpacingScale.s24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.card : AppColors.lightCard,
              borderRadius: AppRadius.brXl2,
              border: Border.all(color: borderColor, width: 0.5),
            ),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: DurationTokens.fast,
                  decoration: BoxDecoration(
                    color: fieldBg,
                    borderRadius: AppRadius.brLg,
                    border: Border.all(
                      color: _emailFocused ? AppColors.primary : borderColor,
                      width: _emailFocused ? 1.5 : 1,
                    ),
                  ),
                  child: TextFormField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    keyboardType: TextInputType.emailAddress,
                    style: AppTextStyles.body.copyWith(color: textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: AppTextStyles.body.copyWith(color: textSecondary),
                      prefixIcon: Icon(Icons.email_outlined, color: textSecondary),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: SpacingScale.s16,
                        vertical: SpacingScale.s12,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
              ],
            ),
          ),
          SizedBox(height: SpacingScale.s24),
          _GradientButton(
            onPressed: _isLoading ? null : _sendResetLink,
            isLoading: _isLoading,
            child: Text('SEND RESET LINK', style: AppTextStyles.buttonLg.copyWith(color: isDark ? const Color(0xFF090A0F) : Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildSuccess(Color textPrimary, Color textSecondary, Color borderColor) {
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
          ).animate().scale(duration: DurationTokens.long, curve: Curves.elasticOut),
          SizedBox(height: SpacingScale.s24),
          Text(
            'Email Sent!',
            style: AppTextStyles.heading2.copyWith(color: textPrimary),
          ).animate().fadeIn(delay: 300.ms),
          SizedBox(height: SpacingScale.s8),
          Text(
            'Check your inbox for the reset link',
            style: AppTextStyles.body.copyWith(color: textSecondary),
          ).animate().fadeIn(delay: 400.ms),
          SizedBox(height: SpacingScale.s32),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => context.go('/login'),
              child: Container(
                height: 48,
                padding: EdgeInsets.symmetric(horizontal: SpacingScale.s48),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: AppRadius.brXl2,
                  border: Border.all(color: borderColor),
                ),
                child: Center(
                  child: Text(
                    'Back to Login',
                    style: AppTextStyles.button.copyWith(color: textPrimary),
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }
}

class _GradientButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;

  const _GradientButton({
    required this.onPressed,
    required this.child,
    this.isLoading = false,
  });

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return MouseRegion(
      onEnter: isEnabled ? (_) => setState(() => _isHovered = true) : null,
      onExit: isEnabled ? (_) => setState(() => _isHovered = false) : null,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: DurationTokens.fast,
          height: 52,
          decoration: BoxDecoration(
            gradient: isEnabled
                ? LinearGradient(
                    colors: _isHovered ? _gradientHover : _gradientNormal,
                  )
                : null,
            color: !isEnabled ? AppColors.textDisabled : null,
            borderRadius: AppRadius.brXl2,
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: _isHovered ? 0.4 : 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : widget.child,
          ),
        ),
      ),
    );
  }
}
