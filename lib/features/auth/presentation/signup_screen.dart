import '../../../core/constants/sports_registry.dart';
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
import '../../../models/user_model.dart';

const _gradientNormal = [Color(0xFFCCFF00), Color(0xFFB8E600)];
const _gradientHover = [Color(0xFFD4FF33), Color(0xFFCCFF00)];
const _gradientPrimary = [Color(0xFF38BDF8), Color(0xFF0284C7)];
const _gradientSecondary = [Color(0xFFCCFF00), Color(0xFF00E5FF)];
const _gradientAccent = [Color(0xFFFF9100), Color(0xFFFF3D00)];
const _gradientPremium = [Color(0xFF8B5CF6), Color(0xFF6D28D9)];

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
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _coachSpecController = TextEditingController();
  final _coachExpController = TextEditingController();
  final _coachRateController = TextEditingController();
  final _coachBioController = TextEditingController();
  final List<String> _selectedCoachSports = ['Cricket'];
  String _coachSportSearch = '';

  UserRole _selectedRole = UserRole.parent;
  bool _obscurePassword = true;
  bool _isLoading = false;
  int _currentStep = 0;
  bool _nameFocused = false;
  bool _emailFocused = false;
  bool _phoneFocused = false;
  bool _passwordFocused = false;

  @override
  void initState() {
    super.initState();
    _nameFocusNode.addListener(() {
      if (mounted) setState(() => _nameFocused = _nameFocusNode.hasFocus);
    });
    _emailFocusNode.addListener(() {
      if (mounted) setState(() => _emailFocused = _emailFocusNode.hasFocus);
    });
    _phoneFocusNode.addListener(() {
      if (mounted) setState(() => _phoneFocused = _phoneFocusNode.hasFocus);
    });
    _passwordFocusNode.addListener(() {
      if (mounted) setState(() => _passwordFocused = _passwordFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _coachSpecController.dispose();
    _coachExpController.dispose();
    _coachRateController.dispose();
    _coachBioController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _onSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      if (_selectedRole == UserRole.coach && _selectedCoachSports.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select at least one sport you coach'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }
      await ref.read(authServiceProvider).signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
        sports: _selectedRole == UserRole.coach ? _selectedCoachSports : null,
        specialization: _selectedRole == UserRole.coach ? _coachSpecController.text.trim() : null,
        experience: _selectedRole == UserRole.coach ? int.tryParse(_coachExpController.text.trim()) : null,
        hourlyRate: _selectedRole == UserRole.coach ? double.tryParse(_coachRateController.text.trim()) : null,
        bio: _selectedRole == UserRole.coach ? _coachBioController.text.trim() : null,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.background : AppColors.lightBackground;
    final cardColor = isDark ? AppColors.card : AppColors.lightCard;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final fieldBg = isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(SpacingScale.s24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: SpacingScale.s16),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (_currentStep > 0) {
                              setState(() => _currentStep--);
                            } else {
                              context.go('/login');
                            }
                          },
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
                      ],
                    ),
                    SizedBox(height: SpacingScale.s8),
                    Text(
                      'Create Account',
                      style: AppTextStyles.heading2.copyWith(color: textPrimary),
                    ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                    SizedBox(height: SpacingScale.s8),
                    Text(
                      'Choose your role and join the ecosystem',
                      style: AppTextStyles.body.copyWith(color: textSecondary),
                    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0),
                    SizedBox(height: SpacingScale.s24),
                    _buildStepIndicator(isDark, borderColor),
                    SizedBox(height: SpacingScale.s24),
                    if (_currentStep == 0) _buildRoleSelector(isDark, cardColor, borderColor, textPrimary, textSecondary, fieldBg),
                    if (_currentStep == 1) _buildPersonalInfo(isDark, cardColor, borderColor, textPrimary, textSecondary, fieldBg),
                    if (_currentStep == 2) _buildCredentials(isDark, cardColor, borderColor, textPrimary, textSecondary, fieldBg),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(bool isDark, Color borderColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index <= _currentStep;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: DurationTokens.slower,
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isActive ? const LinearGradient(colors: _gradientNormal) : null,
                color: isActive ? null : (isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary),
                border: !isActive ? Border.all(color: borderColor) : null,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: AppTextStyles.label.copyWith(
                    color: isActive ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            if (index < 2)
              AnimatedContainer(
                duration: DurationTokens.slower,
                width: 40,
                height: 3,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.brSm,
                  gradient: index < _currentStep ? const LinearGradient(colors: _gradientNormal) : null,
                  color: index < _currentStep ? null : borderColor,
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildRoleSelector(bool isDark, Color cardColor, Color borderColor, Color textPrimary, Color textSecondary, Color fieldBg) {
    final roles = [
      _RoleOption(
        role: UserRole.parent,
        icon: Icons.family_restroom_rounded,
        title: 'Parent',
        desc: "Track your child's sports progress",
        gradient: _gradientPrimary,
      ),
      _RoleOption(
        role: UserRole.player,
        icon: Icons.person_rounded,
        title: 'Player',
        desc: 'Find coaches & grow your career',
        gradient: _gradientSecondary,
      ),
      _RoleOption(
        role: UserRole.coach,
        icon: Icons.sports_rounded,
        title: 'Coach',
        desc: 'Manage sessions & grow your brand',
        gradient: _gradientAccent,
      ),
      _RoleOption(
        role: UserRole.academy,
        icon: Icons.business_rounded,
        title: 'Academy',
        desc: 'Manage batches & hire coaches',
        gradient: _gradientPremium,
      ),
    ];

    return Column(
      children: [
        ...List.generate(roles.length, (index) {
          final role = roles[index];
          final isSelected = _selectedRole == role.role;
          return Padding(
            padding: EdgeInsets.only(bottom: SpacingScale.s12),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => setState(() => _selectedRole = role.role),
                child: AnimatedContainer(
                  duration: DurationTokens.medium,
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.all(SpacingScale.s16),
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.brXl2,
                    gradient: isSelected ? LinearGradient(colors: role.gradient) : null,
                    color: isSelected ? null : cardColor,
                    border: Border.all(
                      color: isSelected ? Colors.transparent : borderColor.withValues(alpha: 0.3),
                      width: isSelected ? 0 : 0.5,
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
                          color: isSelected ? Colors.white.withValues(alpha: 0.2) : borderColor.withValues(alpha: 0.3),
                          borderRadius: AppRadius.br(14),
                        ),
                        child: Icon(role.icon, color: isSelected ? Colors.white : role.gradient.first, size: 24),
                      ),
                      SizedBox(width: SpacingScale.s16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              role.title,
                              style: AppTextStyles.title2.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : textPrimary,
                              ),
                            ),
                            SizedBox(height: SpacingScale.s2),
                            Text(
                              role.desc,
                              style: AppTextStyles.bodySm.copyWith(
                                color: isSelected ? Colors.white.withValues(alpha: 0.8) : textSecondary,
                              ),
                            ),
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
              ),
            ).animate().fadeIn(delay: (300 + index * 100).ms).slideY(begin: 0.3, end: 0),
          );
        }),
        SizedBox(height: SpacingScale.s24),
        _GradientButton(
          onPressed: () => setState(() => _currentStep = 1),
          child: Text('Continue', style: AppTextStyles.buttonLg.copyWith(color: Colors.white)),
        ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildPersonalInfo(bool isDark, Color cardColor, Color borderColor, Color textPrimary, Color textSecondary, Color fieldBg) {
    return Column(
      children: [
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
                    color: _nameFocused ? AppColors.primary : borderColor,
                    width: _nameFocused ? 1.5 : 1,
                  ),
                ),
                child: TextFormField(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  style: AppTextStyles.body.copyWith(color: textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    labelStyle: AppTextStyles.body.copyWith(color: textSecondary),
                    prefixIcon: Icon(Icons.person_outlined, color: textSecondary),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: SpacingScale.s16,
                      vertical: SpacingScale.s12,
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Name is required' : null,
                ),
              ).animate().fadeIn().slideY(begin: 0.2, end: 0),
              SizedBox(height: SpacingScale.s16),
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
                    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                    if (!emailRegex.hasMatch(v)) return 'Enter a valid email address';
                    return null;
                  },
                ),
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
              SizedBox(height: SpacingScale.s16),
              AnimatedContainer(
                duration: DurationTokens.fast,
                decoration: BoxDecoration(
                  color: fieldBg,
                  borderRadius: AppRadius.brLg,
                  border: Border.all(
                    color: _phoneFocused ? AppColors.primary : borderColor,
                    width: _phoneFocused ? 1.5 : 1,
                  ),
                ),
                child: TextFormField(
                  controller: _phoneController,
                  focusNode: _phoneFocusNode,
                  keyboardType: TextInputType.phone,
                  style: AppTextStyles.body.copyWith(color: textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: AppTextStyles.body.copyWith(color: textSecondary),
                    prefixIcon: Icon(Icons.phone_outlined, color: textSecondary),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: SpacingScale.s16,
                      vertical: SpacingScale.s12,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Phone is required';
                    final digitsOnly = v.replaceAll(RegExp(r'\D'), '');
                    if (digitsOnly.length != 10) return 'Phone must be exactly 10 digits';
                    return null;
                  },
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
              if (_selectedRole == UserRole.coach) ...[
                SizedBox(height: SpacingScale.s20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Coaching Sports',
                        style: AppTextStyles.title2.copyWith(color: textPrimary, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Select the sports you coach (multi-select)',
                        style: AppTextStyles.bodySm.copyWith(color: textSecondary),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: SpacingScale.s12),
                // Top 5 Sports chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['Cricket', 'Football', 'Tennis', 'Basketball', 'Badminton'].map((sport) {
                    final isSel = _selectedCoachSports.contains(sport);
                    return FilterChip(
                      label: Text(sport),
                      selected: isSel,
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            if (!_selectedCoachSports.contains(sport)) _selectedCoachSports.add(sport);
                          } else {
                            _selectedCoachSports.remove(sport);
                          }
                        });
                      },
                      selectedColor: AppColors.primary.withValues(alpha: 0.25),
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSel ? AppColors.primary : textPrimary,
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 12,
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: SpacingScale.s8),
                // Search or add other sports
                TextFormField(
                  onChanged: (val) => setState(() => _coachSportSearch = val.trim().toLowerCase()),
                  style: AppTextStyles.bodySm.copyWith(color: textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search or add other sports...',
                    hintStyle: AppTextStyles.bodySm.copyWith(color: textSecondary),
                    prefixIcon: Icon(Icons.search, size: 18, color: textSecondary),
                    filled: true,
                    fillColor: fieldBg,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.brMd,
                      borderSide: BorderSide(color: borderColor),
                    ),
                  ),
                ),
                if (_coachSportSearch.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: SportsRegistry.sports
                        .where((s) => s.name.toLowerCase().contains(_coachSportSearch) && !['Cricket', 'Football', 'Tennis', 'Basketball', 'Badminton'].contains(s.name))
                        .map((s) {
                      final isSel = _selectedCoachSports.contains(s.name);
                      return FilterChip(
                        label: Text('${s.emoji} ${s.name}'),
                        selected: isSel,
                        onSelected: (val) {
                          setState(() {
                            if (val) {
                              if (!_selectedCoachSports.contains(s.name)) _selectedCoachSports.add(s.name);
                            } else {
                              _selectedCoachSports.remove(s.name);
                            }
                          });
                        },
                        selectedColor: AppColors.primary.withValues(alpha: 0.25),
                        checkmarkColor: AppColors.primary,
                      );
                    }).toList(),
                  ),
                ],
                if (_selectedCoachSports.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Selected: ${_selectedCoachSports.join(", ")}',
                      style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
                SizedBox(height: SpacingScale.s16),
                // Specialization
                Container(
                  decoration: BoxDecoration(
                    color: fieldBg,
                    borderRadius: AppRadius.brLg,
                    border: Border.all(color: borderColor),
                  ),
                  child: TextFormField(
                    controller: _coachSpecController,
                    style: AppTextStyles.body.copyWith(color: textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Specialization (e.g. Fast Bowling, Attacking Midfield)',
                      labelStyle: AppTextStyles.body.copyWith(color: textSecondary),
                      prefixIcon: Icon(Icons.military_tech_outlined, color: textSecondary),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: SpacingScale.s16, vertical: SpacingScale.s12),
                    ),
                  ),
                ),
                SizedBox(height: SpacingScale.s12),
                // Experience and Hourly Rate
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: fieldBg,
                          borderRadius: AppRadius.brLg,
                          border: Border.all(color: borderColor),
                        ),
                        child: TextFormField(
                          controller: _coachExpController,
                          keyboardType: TextInputType.number,
                          style: AppTextStyles.body.copyWith(color: textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Experience (Yrs)',
                            labelStyle: AppTextStyles.body.copyWith(color: textSecondary),
                            prefixIcon: Icon(Icons.history_edu_outlined, color: textSecondary),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: SpacingScale.s16, vertical: SpacingScale.s12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: SpacingScale.s12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: fieldBg,
                          borderRadius: AppRadius.brLg,
                          border: Border.all(color: borderColor),
                        ),
                        child: TextFormField(
                          controller: _coachRateController,
                          keyboardType: TextInputType.number,
                          style: AppTextStyles.body.copyWith(color: textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Rate (₹ / hr)',
                            labelStyle: AppTextStyles.body.copyWith(color: textSecondary),
                            prefixIcon: Icon(Icons.currency_rupee_rounded, color: textSecondary),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: SpacingScale.s16, vertical: SpacingScale.s12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: SpacingScale.s12),
                // Coaching Philosophy / Bio
                Container(
                  decoration: BoxDecoration(
                    color: fieldBg,
                    borderRadius: AppRadius.brLg,
                    border: Border.all(color: borderColor),
                  ),
                  child: TextFormField(
                    controller: _coachBioController,
                    maxLines: 3,
                    style: AppTextStyles.body.copyWith(color: textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Coaching Bio / Philosophy',
                      labelStyle: AppTextStyles.body.copyWith(color: textSecondary),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Icon(Icons.info_outline, color: textSecondary),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: SpacingScale.s16, vertical: SpacingScale.s12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: SpacingScale.s32),
        Row(
          children: [
            Expanded(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => setState(() => _currentStep = 0),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: AppRadius.brXl2,
                      border: Border.all(color: borderColor),
                    ),
                    child: Center(
                      child: Text('Back', style: AppTextStyles.button.copyWith(color: textPrimary)),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: SpacingScale.s16),
            Expanded(
              flex: 2,
              child: _GradientButton(
                onPressed: () => setState(() => _currentStep = 2),
                child: Text('Next', style: AppTextStyles.buttonLg.copyWith(color: isDark ? const Color(0xFF090A0F) : Colors.white, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }

  Widget _buildCredentials(bool isDark, Color cardColor, Color borderColor, Color textPrimary, Color textSecondary, Color fieldBg) {
    return Column(
      children: [
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
              ).animate().fadeIn().slideY(begin: 0.2, end: 0),
            ],
          ),
        ),
        SizedBox(height: SpacingScale.s24),
        Container(
          padding: EdgeInsets.all(SpacingScale.s16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: AppRadius.brXl2,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              SizedBox(width: SpacingScale.s12),
              Expanded(
                child: Text(
                  'By creating an account, you agree to our Terms of Service and Privacy Policy.',
                  style: AppTextStyles.bodySm.copyWith(color: textSecondary),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms),
        SizedBox(height: SpacingScale.s32),
        _GradientButton(
          onPressed: _isLoading ? null : _onSignUp,
          isLoading: _isLoading,
          child: Text('CREATE ACCOUNT', style: AppTextStyles.buttonLg.copyWith(color: isDark ? const Color(0xFF090A0F) : Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
        SizedBox(height: SpacingScale.s16),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => setState(() => _currentStep = 1),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: AppRadius.brXl2,
                border: Border.all(color: borderColor),
              ),
              child: Center(
                child: Text('Back', style: AppTextStyles.button.copyWith(color: textPrimary)),
              ),
            ),
          ),
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
