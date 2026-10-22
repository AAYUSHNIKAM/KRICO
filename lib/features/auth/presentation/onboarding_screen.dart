import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/sports_registry.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/radius/radius.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../design_system/typography/text_styles.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _saving = false;

  String _selectedSport = 'Cricket';
  String _selectedLevel = 'Intermediate';
  String _selectedLocation = 'Mumbai';
  final _customLocationCtrl = TextEditingController();
  bool _isCustomLocation = false;
  final Set<String> _selectedGoals = {'Tournament Prep', 'Fitness & Conditioning'};

  late final List<Map<String, dynamic>> _sports = SportsRegistry.sports.map((s) => {
    'name': s.name,
    'icon': s.icon,
    'subtitle': s.description,
  }).toList();

  final List<Map<String, dynamic>> _levels = [
    {'title': 'Beginner', 'desc': 'New to competitive sports, learning fundamentals', 'icon': Icons.eco_rounded},
    {'title': 'Intermediate', 'desc': 'Playing regularly at club/school level', 'icon': Icons.trending_up_rounded},
    {'title': 'Advanced', 'desc': 'State or district competitor seeking refinement', 'icon': Icons.workspace_premium_rounded},
    {'title': 'Professional', 'desc': 'National or elite academy player', 'icon': Icons.military_tech_rounded},
  ];

  final List<String> _locations = [
    'Mumbai',
    'Delhi NCR',
    'Bengaluru',
    'Hyderabad',
    'Chennai',
    'Kolkata',
    'Pune',
    'Ahmedabad',
    'Jaipur',
    'Chandigarh',
    'Lucknow',
    'Kochi',
    'Indore',
    'Goa',
    'Other / Custom City',
  ];

  final List<String> _goals = [
    'Tournament Prep',
    'Fitness & Conditioning',
    'Professional Academy Trials',
    'Tactical IQ & Strategy',
    'Injury Rehabilitation',
    'College Sports Quota',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _customLocationCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _prevPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      context.go('/login');
      return;
    }

    setState(() => _saving = true);
    try {
      final finalLocation = (_isCustomLocation && _customLocationCtrl.text.trim().isNotEmpty)
          ? _customLocationCtrl.text.trim()
          : _selectedLocation;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'sport': _selectedSport,
        'sports': [_selectedSport],
        'skillLevel': _selectedLevel,
        'location': finalLocation,
        'city': finalLocation,
        'trainingGoals': _selectedGoals.toList(),
        'isProfileComplete': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // If a coach document exists for this user, keep it in sync
      final coachDoc = await FirebaseFirestore.instance.collection('coaches').doc(user.uid).get();
      if (coachDoc.exists) {
        await FirebaseFirestore.instance.collection('coaches').doc(user.uid).set({
          'specialization': _selectedSport,
          'sports': [_selectedSport],
          'city': finalLocation,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.background : AppColors.lightBackground;
    final cardColor = isDark ? AppColors.card : AppColors.lightCard;
    final surfaceColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final textTertiary = isDark ? AppColors.textTertiary : AppColors.lightTextTertiary;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s20, vertical: SpacingScale.s16),
                  child: Row(
                    children: [
                      if (_currentStep > 0)
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
                          onPressed: _prevPage,
                        )
                      else
                        const SizedBox(width: 40),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Step ${_currentStep + 1} of 3',
                              style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: SpacingScale.s8),
                            Row(
                              children: List.generate(3, (index) {
                                return Expanded(
                                  child: Container(
                                    height: 4,
                                    margin: const EdgeInsets.symmetric(horizontal: 2),
                                    decoration: BoxDecoration(
                                      color: index <= _currentStep ? AppColors.primary : borderColor,
                                      borderRadius: AppRadius.brFull,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: _finishOnboarding,
                        child: Text('Skip', style: AppTextStyles.bodySm.copyWith(color: textTertiary)),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (page) => setState(() => _currentStep = page),
                    children: [
                      _buildSportStep(isDark, textPrimary, textSecondary, cardColor, surfaceColor, borderColor),
                      _buildLevelStep(isDark, textPrimary, textSecondary, cardColor, surfaceColor, borderColor),
                      _buildLocationStep(isDark, textPrimary, textSecondary, surfaceColor, borderColor),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(SpacingScale.s20),
                  child: ElevatedButton(
                    onPressed: _saving ? null : _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.brXl),
                      elevation: 0,
                    ),
                    child: _saving
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentStep == 2 ? 'Complete Profile & Start' : 'Continue',
                                style: AppTextStyles.button.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: SpacingScale.s8),
                              const Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSportStep(
    bool isDark,
    Color textPrimary,
    Color textSecondary,
    Color cardColor,
    Color surfaceColor,
    Color borderColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Your Primary Sport', style: AppTextStyles.heading2.copyWith(color: textPrimary)),
          const SizedBox(height: SpacingScale.s8),
          Text(
            'We tailor your drills, coaches, and local training venues based on your sport.',
            style: AppTextStyles.body.copyWith(color: textSecondary),
          ),
          const SizedBox(height: SpacingScale.s20),
          Expanded(
            child: ListView.separated(
              itemCount: _sports.length,
              separatorBuilder: (_, _) => const SizedBox(height: SpacingScale.s12),
              itemBuilder: (context, index) {
                final sport = _sports[index];
                final isSelected = _selectedSport == sport['name'];

                return GestureDetector(
                  onTap: () => setState(() => _selectedSport = sport['name'] as String),
                  child: Container(
                    padding: const EdgeInsets.all(SpacingScale.s16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08) : surfaceColor,
                      borderRadius: AppRadius.brXl,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : borderColor,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(SpacingScale.s12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : cardColor,
                            borderRadius: AppRadius.brLg,
                          ),
                          child: Icon(
                            sport['icon'] as IconData,
                            color: isSelected ? Colors.white : AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: SpacingScale.s16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sport['name'] as String,
                                style: AppTextStyles.title2.copyWith(
                                  color: textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                sport['subtitle'] as String,
                                style: AppTextStyles.caption.copyWith(color: textSecondary),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 24),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildLevelStep(
    bool isDark,
    Color textPrimary,
    Color textSecondary,
    Color cardColor,
    Color surfaceColor,
    Color borderColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What is your skill level?', style: AppTextStyles.heading2.copyWith(color: textPrimary)),
          const SizedBox(height: SpacingScale.s8),
          Text(
            'This helps coaches design appropriate training batches and challenges for you.',
            style: AppTextStyles.body.copyWith(color: textSecondary),
          ),
          const SizedBox(height: SpacingScale.s20),
          Expanded(
            child: ListView.separated(
              itemCount: _levels.length,
              separatorBuilder: (_, _) => const SizedBox(height: SpacingScale.s12),
              itemBuilder: (context, index) {
                final level = _levels[index];
                final isSelected = _selectedLevel == level['title'];

                return GestureDetector(
                  onTap: () => setState(() => _selectedLevel = level['title'] as String),
                  child: Container(
                    padding: const EdgeInsets.all(SpacingScale.s16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08) : surfaceColor,
                      borderRadius: AppRadius.brXl,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : borderColor,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(SpacingScale.s12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : cardColor,
                            borderRadius: AppRadius.brLg,
                          ),
                          child: Icon(
                            level['icon'] as IconData,
                            color: isSelected ? Colors.white : AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: SpacingScale.s16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                level['title'] as String,
                                style: AppTextStyles.title2.copyWith(
                                  color: textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                level['desc'] as String,
                                style: AppTextStyles.caption.copyWith(color: textSecondary),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 24),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildLocationStep(
    bool isDark,
    Color textPrimary,
    Color textSecondary,
    Color surfaceColor,
    Color borderColor,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Location & Goals', style: AppTextStyles.heading2.copyWith(color: textPrimary)),
          const SizedBox(height: SpacingScale.s8),
          Text(
            'Select your primary training city or home base and your athletic aspirations.',
            style: AppTextStyles.body.copyWith(color: textSecondary),
          ),
          const SizedBox(height: SpacingScale.s20),

          Text('Training Base Hub', style: AppTextStyles.title2.copyWith(color: textPrimary)),
          const SizedBox(height: SpacingScale.s10),
          DropdownButtonFormField<String>(
            initialValue: _selectedLocation,
            dropdownColor: surfaceColor,
            style: AppTextStyles.body.copyWith(color: textPrimary),
            decoration: InputDecoration(
              filled: true,
              fillColor: surfaceColor,
              border: OutlineInputBorder(borderRadius: AppRadius.brLg, borderSide: BorderSide(color: borderColor)),
              enabledBorder: OutlineInputBorder(borderRadius: AppRadius.brLg, borderSide: BorderSide(color: borderColor)),
              prefixIcon: const Icon(Icons.location_on_rounded, color: AppColors.primary),
            ),
            items: _locations.map((loc) => DropdownMenuItem(value: loc, child: Text(loc))).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedLocation = val;
                  _isCustomLocation = (val == 'Other / Custom City');
                });
              }
            },
          ),
          if (_isCustomLocation) ...[
            const SizedBox(height: SpacingScale.s12),
            TextFormField(
              controller: _customLocationCtrl,
              style: AppTextStyles.body.copyWith(color: textPrimary),
              decoration: InputDecoration(
                filled: true,
                fillColor: surfaceColor,
                hintText: 'Enter your city or area (e.g. Pune, Bandra, Indiranagar)...',
                hintStyle: AppTextStyles.bodySm.copyWith(color: textSecondary),
                border: OutlineInputBorder(borderRadius: AppRadius.brLg, borderSide: BorderSide(color: borderColor)),
                enabledBorder: OutlineInputBorder(borderRadius: AppRadius.brLg, borderSide: BorderSide(color: borderColor)),
                prefixIcon: const Icon(Icons.edit_location_alt_rounded, color: AppColors.primary),
              ),
            ),
          ],

          const SizedBox(height: SpacingScale.s24),
          Text('Your Training Goals', style: AppTextStyles.title2.copyWith(color: textPrimary)),
          const SizedBox(height: SpacingScale.s10),
          Wrap(
            spacing: SpacingScale.s8,
            runSpacing: SpacingScale.s8,
            children: _goals.map((goal) {
              final isSelected = _selectedGoals.contains(goal);
              return FilterChip(
                label: Text(goal),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedGoals.add(goal);
                    } else {
                      _selectedGoals.remove(goal);
                    }
                  });
                },
                selectedColor: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.12),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primary : textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: surfaceColor,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.brFull,
                  side: BorderSide(color: isSelected ? AppColors.primary : borderColor),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: SpacingScale.s32),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}
