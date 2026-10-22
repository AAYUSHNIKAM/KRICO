import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../design_system/radius/radius.dart';

class VideoAnalysisScreen extends ConsumerStatefulWidget {
  final String playerId;
  final String playerName;

  const VideoAnalysisScreen({
    super.key,
    required this.playerId,
    required this.playerName,
  });

  @override
  ConsumerState<VideoAnalysisScreen> createState() => _VideoAnalysisScreenState();
}

class _VideoAnalysisScreenState extends ConsumerState<VideoAnalysisScreen> {
  bool _joinedWaitlist = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.background : AppColors.lightBackground;
    final cardBg = isDark ? AppColors.surface : AppColors.lightSurface;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(SpacingScale.s16, SpacingScale.s12, SpacingScale.s16, SpacingScale.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button & header
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: textPrimary),
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: SpacingScale.s8),
                        Expanded(
                          child: Text(
                            'Video Analysis Lab',
                            style: AppTextStyles.title1.copyWith(
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFCCFF00), Color(0xFF00E5FF)],
                            ),
                            borderRadius: AppRadius.brFull,
                          ),
                          child: const Text(
                            'COMING SOON',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: SpacingScale.s16),

                    // Page Hero Showcase Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(SpacingScale.s24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [
                                  const Color(0xFF131D31),
                                  const Color(0xFF0F172A),
                                  const Color(0xFF0B1120),
                                ]
                              : [
                                  Colors.white,
                                  const Color(0xFFF1F5F9),
                                  const Color(0xFFE2E8F0),
                                ],
                        ),
                        borderRadius: AppRadius.brXl3,
                        border: Border.all(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(SpacingScale.s12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                              borderRadius: AppRadius.brXl,
                            ),
                            child: const Icon(
                              Icons.sports_rounded,
                              size: 32,
                              color: Color(0xFF00E5FF),
                            ),
                          ),
                          const SizedBox(height: SpacingScale.s16),
                          Text(
                            'AI-Powered Biomechanical Video Breakdown',
                            style: AppTextStyles.heading2.copyWith(
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: SpacingScale.s8),
                          Text(
                            'We are fine-tuning proprietary computer-vision models to calculate precise joint angular velocities, release angles, and stance stability straight from your smartphone camera.',
                            style: AppTextStyles.body.copyWith(
                              color: textSecondary,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: SpacingScale.s20),

                          // Waitlist Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() => _joinedWaitlist = !_joinedWaitlist);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      _joinedWaitlist
                                          ? '🚀 You have been added to the VIP Beta Access list!'
                                          : 'You left the waitlist.',
                                    ),
                                    backgroundColor: AppColors.primary,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _joinedWaitlist ? AppColors.emerald : const Color(0xFFCCFF00),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 14.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.brXl,
                                ),
                                elevation: 0,
                              ),
                              icon: Icon(
                                _joinedWaitlist ? Icons.check_circle_rounded : Icons.notifications_active_rounded,
                                size: 20,
                              ),
                              label: Text(
                                _joinedWaitlist ? 'VIP Priority Access Granted' : 'Get Notified When It Launches',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0),

                    const SizedBox(height: SpacingScale.s24),

                    // Feature Preview Cards
                    Text(
                      'What to Expect in V1.1',
                      style: AppTextStyles.title2.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: SpacingScale.s12),

                    _FeatureShowcaseCard(
                      icon: Icons.slow_motion_video_rounded,
                      color: const Color(0xFF00E5FF),
                      title: 'Millisecond Pose Tracking',
                      description: 'Track 33 kinetic keypoints in real time across swings, sprints, and jump landings without external sensors.',
                      isDark: isDark,
                    ),
                    const SizedBox(height: SpacingScale.s12),

                    _FeatureShowcaseCard(
                      icon: Icons.draw_rounded,
                      color: const Color(0xFFCCFF00),
                      title: 'Coach Telestrator & Voice Memos',
                      description: 'Your certified coach can draw vector angles, slow down motion to 240 FPS, and record voice debriefs directly over your clips.',
                      isDark: isDark,
                    ),
                    const SizedBox(height: SpacingScale.s12),

                    _FeatureShowcaseCard(
                      icon: Icons.radar_rounded,
                      color: const Color(0xFFFF9100),
                      title: 'Injury Risk & Fatigue Heatmaps',
                      description: 'Detect mechanical compensations before muscle strains occur with AI kinematic asymmetry alerts.',
                      isDark: isDark,
                    ),
                    const SizedBox(height: SpacingScale.s24),

                    // Interactive Telemetry Sneak Peek
                    Container(
                      padding: const EdgeInsets.all(SpacingScale.s16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: AppRadius.brXl2,
                        border: Border.all(
                          color: isDark ? AppColors.border : AppColors.lightBorder,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.hub_rounded, size: 16, color: AppColors.primary),
                              const SizedBox(width: SpacingScale.s6),
                              Text(
                                'Telemetry Preview Benchmark',
                                style: AppTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: SpacingScale.s12),
                          Row(
                            children: [
                              _TelemetryPill(label: 'Elbow Flexion', value: '168.4°', color: const Color(0xFF00E5FF)),
                              const SizedBox(width: SpacingScale.s8),
                              _TelemetryPill(label: 'Launch Angle', value: '42.1°', color: const Color(0xFFCCFF00)),
                              const SizedBox(width: SpacingScale.s8),
                              _TelemetryPill(label: 'Form Score', value: '94/100', color: AppColors.emerald),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: SpacingScale.s32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureShowcaseCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final bool isDark;

  const _FeatureShowcaseCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SpacingScale.s16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        borderRadius: AppRadius.brXl2,
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.lightBorder,
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(SpacingScale.s10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: AppRadius.brLg,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.title3.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: SpacingScale.s4),
                Text(
                  description,
                  style: AppTextStyles.bodySm.copyWith(
                    color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TelemetryPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _TelemetryPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: SpacingScale.s10, horizontal: SpacingScale.s8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: AppRadius.brLg,
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
