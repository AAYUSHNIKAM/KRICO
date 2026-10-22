import '../../../../services/pilot_feedback_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/radius/radius.dart';
import '../../../../design_system/spacing/spacing_scale.dart';
import '../../../../design_system/typography/text_styles.dart';
import '../../../../providers/auth_provider.dart';


void showPilotFeedbackModal(BuildContext context, WidgetRef ref) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final currentUser = ref.read(authStateProvider).value;
  final userProfile = currentUser != null
      ? ref.read(userProfileProvider(currentUser.uid)).value
      : null;

  int rating = 5;
  String category = 'Bug / Crash';
  final messageCtrl = TextEditingController();
  bool isSubmitting = false;

  final categories = [
    'Bug / Crash',
    'Feature Suggestion',
    'Booking & Pilot UX',
    'Speed & Performance',
    'General Feedback',
  ];

  final ratingLabels = {
    1: 'Needs Work',
    2: 'Fair',
    3: 'Good',
    4: 'Great',
    5: 'Awesome!',
  };

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setModalState) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(SpacingScale.s20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surface : AppColors.lightSurface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: SpacingScale.s16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary,
                        borderRadius: AppRadius.brFull,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(SpacingScale.s10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCCFF00).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.rate_review_rounded, color: Color(0xFFCCFF00), size: 24),
                      ),
                      const SizedBox(width: SpacingScale.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pilot Feedback & Bug Report',
                              style: AppTextStyles.heading3.copyWith(
                                color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            Text(
                              'Help shape KRICO Pune before public rollout',
                              style: AppTextStyles.caption.copyWith(
                                color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SpacingScale.s20),
                  Text(
                    'Overall Experience Rating',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: SpacingScale.s8),
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        final star = index + 1;
                        final filled = star <= rating;
                        return IconButton(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            filled ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: filled ? const Color(0xFFEAB308) : (isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
                            size: 32,
                          ),
                          onPressed: () => setModalState(() => rating = star),
                        );
                      }),
                      const SizedBox(width: SpacingScale.s8),
                      Text(
                        ratingLabels[rating] ?? '',
                        style: AppTextStyles.body.copyWith(
                          color: const Color(0xFFEAB308),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SpacingScale.s16),
                  Text(
                    'Category',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: SpacingScale.s8),
                  Wrap(
                    spacing: SpacingScale.s8,
                    runSpacing: SpacingScale.s8,
                    children: categories.map((cat) {
                      final isSelected = category == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: isSelected ? const Color(0xFFCCFF00) : null,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black : (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary),
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        onSelected: (_) => setModalState(() => category = cat),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: SpacingScale.s16),
                  Text(
                    'Your Feedback / Description',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: SpacingScale.s8),
                  TextField(
                    controller: messageCtrl,
                    maxLines: 4,
                    style: TextStyle(
                      color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary,
                      hintText: 'Describe what worked well, what was confusing, or what bug you ran into...',
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.brLg,
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: SpacingScale.s20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCCFF00),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.brXl2),
                        elevation: 0,
                      ),
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              final text = messageCtrl.text.trim();
                              if (text.isEmpty) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter a brief description before submitting.'),
                                    backgroundColor: AppColors.warning,
                                  ),
                                );
                                return;
                              }

                              setModalState(() => isSubmitting = true);
                              try {
                                final userId = currentUser?.uid ?? 'guest_tester';
                                final userEmail = currentUser?.email;
                                final userName = currentUser?.displayName ?? userProfile?.name;
                                final userRole = userProfile?.role;

                                await ref.read(pilotFeedbackServiceProvider).submitFeedback(
                                  userId: userId,
                                  userEmail: userEmail,
                                  userName: userName,
                                  userRole: userRole,
                                  category: category,
                                  rating: rating,
                                  message: text,
                                );

                                if (ctx.mounted) Navigator.pop(ctx);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(Icons.check_circle_rounded, color: Colors.white),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text('Thank you! Your feedback has been sent to the KRICO engineering team.'),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                }
                              } catch (e) {
                                setModalState(() => isSubmitting = false);
                                if (ctx.mounted) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    SnackBar(content: Text('Submission failed: $e'), backgroundColor: AppColors.danger),
                                  );
                                }
                              }
                            },
                      child: Text(
                        isSubmitting ? 'Submitting Feedback...' : 'Submit to KRICO Pune Team',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
