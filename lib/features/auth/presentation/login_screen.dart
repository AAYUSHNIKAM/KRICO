import '../../../core/utils/auth_error_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../design_system/radius/radius.dart';
import '../../../design_system/tokens/duration_tokens.dart';
import '../../../providers/auth_provider.dart';

const _crestGradient = [Color(0xFFCCFF00), Color(0xFF00E5FF)];

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _emailFocused = false;
  bool _passwordFocused = false;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      if (mounted) setState(() => _emailFocused = _emailFocusNode.hasFocus);
    });
    _passwordFocusNode.addListener(() {
      if (mounted) setState(() => _passwordFocused = _passwordFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) context.go('/home');
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

  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
      if (mounted) context.go('/home');
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AuthErrorHelper.getFriendlyErrorMessage(e)),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Google Sign-In is not available on this platform'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLoading = _isLoading || _isGoogleLoading;
    final bgColor = isDark ? AppColors.background : AppColors.lightBackground;
    final cardColor = isDark ? AppColors.card : AppColors.lightCard;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final fieldBg = isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.22 : 0.08,
              child: Image.asset(
                'assets/backgrounds/auth_bg.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    bgColor.withValues(alpha: 0.82),
                    bgColor.withValues(alpha: 0.96),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(SpacingScale.s24),
                  child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: SpacingScale.s40),
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: _crestGradient),
                    borderRadius: AppRadius.br(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFCCFF00).withValues(alpha: isDark ? 0.4 : 0.2),
                        blurRadius: 24,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.sports_rounded, color: Color(0xFF090A0F), size: 36),
                ).animate().fadeIn().slideX(begin: -0.2, end: 0).scale(duration: DurationTokens.slower, curve: Curves.elasticOut),
                SizedBox(height: SpacingScale.s32),
                Row(
                  children: [
                    Text(
                      'Welcome Back',
                      style: AppTextStyles.heading2.copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCCFF00),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'PILOT',
                        style: TextStyle(
                          color: Color(0xFF090A0F),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0),
                SizedBox(height: SpacingScale.s8),
                Text(
                  'Sign in to continue your sports journey',
                  style: AppTextStyles.body.copyWith(color: textSecondary),
                ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2, end: 0),
                SizedBox(height: SpacingScale.s48),
                Container(
                  padding: EdgeInsets.all(SpacingScale.s24),
                  decoration: BoxDecoration(
                    color: cardColor,
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
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Email is required';
                            if (!v.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                        ),
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                      SizedBox(height: SpacingScale.s16),
                      AnimatedContainer(
                        duration: DurationTokens.fast,
                        decoration: BoxDecoration(
                          color: fieldBg,
                          borderRadius: AppRadius.brLg,
                          border: Border.all(
                            color: _passwordFocused ? AppColors.primary : borderColor,
                            width: _passwordFocused ? 1.5 : 1,
                          ),
                        ),
                        child: TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          obscureText: _obscurePassword,
                          style: AppTextStyles.body.copyWith(color: textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: AppTextStyles.body.copyWith(color: textSecondary),
                            prefixIcon: Icon(Icons.lock_outlined, color: textSecondary),
                            suffixIcon: GestureDetector(
                              onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                              child: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: textSecondary,
                              ),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: SpacingScale.s16,
                              vertical: SpacingScale.s12,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Password is required';
                            if (v.length < 6) return 'Minimum 6 characters';
                            return null;
                          },
                        ),
                      ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
                      SizedBox(height: SpacingScale.s8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => context.go('/forgot-password'),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: SpacingScale.s4),
                            child: Text(
                              'Forgot Password?',
                              style: AppTextStyles.label.copyWith(color: AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: SpacingScale.s8),
                      _GradientButton(
                        onPressed: isLoading ? null : _onLogin,
                        isLoading: isLoading,
                        child: Text(
                          'SIGN IN',
                          style: AppTextStyles.buttonLg.copyWith(
                            color: isDark ? const Color(0xFF090A0F) : Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
                      SizedBox(height: SpacingScale.s20),
                      Row(
                        children: [
                          Expanded(child: Divider(color: borderColor)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: SpacingScale.s16),
                            child: Text('OR', style: AppTextStyles.caption.copyWith(color: textSecondary)),
                          ),
                          Expanded(child: Divider(color: borderColor)),
                        ],
                      ),
                      SizedBox(height: SpacingScale.s20),
                      _GoogleSignInButton(
                        onPressed: isLoading ? null : _signInWithGoogle,
                      ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2, end: 0),
                      SizedBox(height: SpacingScale.s20),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: AppTextStyles.body.copyWith(color: textSecondary),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/signup'),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: SpacingScale.s4),
                              child: Text(
                                'Sign Up',
                                style: AppTextStyles.buttonLg.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.volt : AppColors.voltDark,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: SpacingScale.s20),
                      Container(
                        padding: const EdgeInsets.all(SpacingScale.s12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF090A0F) : AppColors.lightSurfaceSecondary,
                          borderRadius: AppRadius.brLg,
                          border: Border.all(
                            color: isDark ? const Color(0xFFCCFF00).withValues(alpha: 0.25) : AppColors.lightBorder,
                            width: 0.8,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.flash_on_rounded, size: 14, color: Color(0xFFCCFF00)),
                                const SizedBox(width: 4),
                                Text(
                                  'PILOT TESTER QUICK ROLES',
                                  style: AppTextStyles.captionXs.copyWith(
                                    color: isDark ? const Color(0xFFCCFF00) : const Color(0xFF4D7C0F),
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: SpacingScale.s8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                _buildQuickRolePill('Player', 'player@krico.app', 'player123', isDark),
                                _buildQuickRolePill('Coach', 'coach@krico.app', 'coach123', isDark),
                                _buildQuickRolePill('Parent', 'parent@krico.app', 'parent123', isDark),
                                _buildQuickRolePill('Academy', 'academy@krico.app', 'academy123', isDark),
                                _buildQuickRolePill('Admin', 'admin@krico.app', 'admin123', isDark),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
              ),
            ),
          ),
        ),
      ),
    ],
  ),
);
}


  Widget _buildQuickRolePill(String roleLabel, String email, String password, bool isDark) {
    return InkWell(
      onTap: () {
        setState(() {
          _emailController.text = email;
          _passwordController.text = password;
        });
        _onLogin();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131722) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? const Color(0xFF222736) : AppColors.lightBorder,
            width: 0.8,
          ),
        ),
        child: Text(
          roleLabel,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
          ),
        ),
      ),
    );
  }
}

class _GoogleSignInButton extends StatefulWidget {
  final VoidCallback? onPressed;
  const _GoogleSignInButton({required this.onPressed});

  @override
  State<_GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<_GoogleSignInButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final hoverBg = isDark ? AppColors.hover : AppColors.lightHover;
    final isEnabled = widget.onPressed != null;

    return MouseRegion(
      onEnter: isEnabled ? (_) => setState(() => _isHovered = true) : null,
      onExit: isEnabled ? (_) => setState(() => _isHovered = false) : null,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: DurationTokens.fast,
          height: 52,
          decoration: BoxDecoration(
            color: _isHovered ? hoverBg : Colors.transparent,
            borderRadius: AppRadius.brXl2,
            border: Border.all(
              color: _isHovered ? AppColors.borderHover : borderColor,
              width: 1,
            ),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.g_mobiledata_rounded, size: 24, color: Colors.grey),
                SizedBox(width: SpacingScale.s8),
                Text(
                  'Continue with Google',
                  style: AppTextStyles.button.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    final bgColors = isDark
        ? (_isHovered
            ? [const Color(0xFFD4FF33), const Color(0xFFCCFF00)]
            : [const Color(0xFFCCFF00), const Color(0xFFB8E600)])
        : (_isHovered
            ? [const Color(0xFF1E293B), const Color(0xFF334155)]
            : [const Color(0xFF0F172A), const Color(0xFF1E293B)]);

    return MouseRegion(
      onEnter: isEnabled ? (_) => setState(() => _isHovered = true) : null,
      onExit: isEnabled ? (_) => setState(() => _isHovered = false) : null,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: DurationTokens.fast,
          height: 52,
          decoration: BoxDecoration(
            gradient: isEnabled ? LinearGradient(colors: bgColors) : null,
            color: !isEnabled ? AppColors.textDisabled : null,
            borderRadius: AppRadius.brXl2,
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: (isDark ? const Color(0xFFCCFF00) : Colors.black).withValues(
                        alpha: _isHovered ? 0.35 : 0.2,
                      ),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: widget.isLoading
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/animations/runner_loader.gif',
                      width: 28,
                      height: 28,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: isDark ? const Color(0xFF090A0F) : Colors.white,
                        ),
                      ),
                    ),
                  )
                : widget.child,
          ),
        ),
      ),
    );
  }
}
