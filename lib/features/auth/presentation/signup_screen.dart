import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  UserRole _selectedRole = UserRole.parent;
  bool _obscurePassword = true;
  bool _isLoading = false;
  int _currentStep = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
      );
      if (mounted) context.go('/home');
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
    final isLoading = _isLoading;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_rounded),
                      onPressed: () {
                        if (_currentStep > 0) {
                          setState(() => _currentStep--);
                        } else {
                          context.go('/login');
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Create Account',
                  style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
                ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                const SizedBox(height: 8),
                Text(
                  'Choose your role and join the ecosystem',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0),
                const SizedBox(height: 24),
                _buildStepIndicator(),
                const SizedBox(height: 24),
                if (_currentStep == 0) _buildRoleSelector(),
                if (_currentStep == 1) _buildPersonalInfo(),
                if (_currentStep == 2) _buildCredentials(isLoading),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index <= _currentStep;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isActive ? const LinearGradient(colors: AppColors.gradientPrimary) : null,
                color: isActive ? null : theme.colorScheme.surfaceContainerHighest,
                border: !isActive ? Border.all(color: theme.colorScheme.outline) : null,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isActive ? Colors.white : theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            if (index < 2)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 40,
                height: 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: index < _currentStep ? const LinearGradient(colors: AppColors.gradientPrimary) : null,
                  color: index < _currentStep ? null : theme.colorScheme.outline,
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildRoleSelector() {
    final theme = Theme.of(context);
    final roles = [
      _RoleOption(
        role: UserRole.parent,
        icon: Icons.family_restroom_rounded,
        title: 'Parent',
        desc: "Track your child's sports progress",
        gradient: AppColors.gradientPrimary,
      ),
      _RoleOption(
        role: UserRole.player,
        icon: Icons.person_rounded,
        title: 'Player',
        desc: 'Find coaches & grow your career',
        gradient: AppColors.gradientSecondary,
      ),
      _RoleOption(
        role: UserRole.coach,
        icon: Icons.sports_rounded,
        title: 'Coach',
        desc: 'Manage sessions & grow your brand',
        gradient: AppColors.gradientAccent,
      ),
      _RoleOption(
        role: UserRole.academy,
        icon: Icons.business_rounded,
        title: 'Academy',
        desc: 'Manage batches & hire coaches',
        gradient: AppColors.gradientPremium,
      ),
    ];

    return Column(
      children: [
        ...List.generate(roles.length, (index) {
          final role = roles[index];
          final isSelected = _selectedRole == role.role;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedRole = role.role),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: isSelected ? LinearGradient(colors: role.gradient) : null,
                  color: isSelected ? null : theme.colorScheme.surfaceContainerHighest,
                  border: Border.all(
                    color: isSelected ? Colors.transparent : theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: role.gradient.first.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white.withValues(alpha: 0.2) : theme.colorScheme.outline.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(role.icon, color: isSelected ? Colors.white : role.gradient.first, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(role.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                              )),
                          const SizedBox(height: 2),
                          Text(role.desc,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isSelected ? Colors.white.withValues(alpha: 0.8) : theme.colorScheme.onSurfaceVariant,
                              )),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 16),
                      ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: (300 + index * 100).ms).slideY(begin: 0.3, end: 0),
          );
        }),
        const SizedBox(height: 24),
        GradientButton(
          onPressed: () => setState(() => _currentStep = 1),
          height: 54,
          child: Text('Continue', style: AppTextStyles.buttonLarge.copyWith(color: Colors.white)),
        ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildPersonalInfo() {
    final theme = Theme.of(context);
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            prefixIcon: Icon(Icons.person_outlined),
          ),
          validator: (v) => (v == null || v.isEmpty) ? 'Name is required' : null,
        ).animate().fadeIn().slideY(begin: 0.2, end: 0),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Email is required';
            final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
            if (!emailRegex.hasMatch(v)) return 'Enter a valid email address';
            return null;
          },
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Phone is required';
            final digitsOnly = v.replaceAll(RegExp(r'\D'), '');
            if (digitsOnly.length != 10) return 'Phone must be exactly 10 digits';
            return null;
          },
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 0),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('Back', style: theme.textTheme.labelLarge),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: GradientButton(
                onPressed: () => setState(() => _currentStep = 2),
                child: Text('Next', style: AppTextStyles.buttonLarge.copyWith(color: Colors.white)),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }

  Widget _buildCredentials(bool isLoading) {
    final theme = Theme.of(context);
    return Column(
      children: [
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Password is required';
            if (v.length < 6) return 'Minimum 6 characters';
            return null;
          },
        ).animate().fadeIn().slideY(begin: 0.2, end: 0),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'By creating an account, you agree to our Terms of Service and Privacy Policy.',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 32),
        GradientButton(
          onPressed: isLoading ? null : _onSignUp,
          isLoading: isLoading,
          height: 54,
          child: Text('Create Account', style: AppTextStyles.buttonLarge.copyWith(color: Colors.white)),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => setState(() => _currentStep = 1),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            minimumSize: const Size(double.infinity, 52),
          ),
          child: Text('Back', style: theme.textTheme.labelLarge),
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }
}

class _RoleOption {
  const _RoleOption({
    required this.role,
    required this.icon,
    required this.title,
    required this.desc,
    required this.gradient,
  });

  final UserRole role;
  final IconData icon;
  final String title;
  final String desc;
  final List<Color> gradient;
}
