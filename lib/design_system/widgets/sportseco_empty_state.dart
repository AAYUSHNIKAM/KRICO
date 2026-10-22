import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../colors/app_colors.dart';
import '../radius/radius.dart';
import '../spacing/spacing_scale.dart';
import '../typography/text_styles.dart';
import 'sports_vector_badge.dart';

enum EmptyStateType {
  noBookings,
  noMessages,
  noVideos,
  noNotifications,
  noVenues,
  noCertificates,
  noChallenges,
}

class SportsEcoEmptyState extends StatelessWidget {
  final EmptyStateType type;
  final String? customTitle;
  final String? customSubtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SportsEcoEmptyState({
    super.key,
    required this.type,
    this.customTitle,
    this.customSubtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    SportType badgeSport;
    IconData iconData;
    String title;
    String subtitle;
    String defaultAction;
    String? illustrationAsset;

    switch (type) {
      case EmptyStateType.noBookings:
        badgeSport = SportType.cricket;
        iconData = Icons.calendar_today_rounded;
        title = 'No Upcoming Sessions';
        subtitle = 'You have no booked training sessions. Discover verified coaches to start.';
        defaultAction = 'Find a Coach';
        illustrationAsset = 'assets/empty/no_bookings.png';
      case EmptyStateType.noMessages:
        badgeSport = SportType.football;
        iconData = Icons.chat_bubble_outline_rounded;
        title = 'Your Locker Room is Quiet';
        subtitle = 'No active conversations. Reach out to your coach or academy team.';
        defaultAction = 'Start a Chat';
        illustrationAsset = 'assets/empty/no_messages.png';
      case EmptyStateType.noVideos:
        badgeSport = SportType.athletics;
        iconData = Icons.videocam_outlined;
        title = 'No Form Analysis Footage';
        subtitle = 'Upload your bowling runup, batting stance, or tennis serve for instant AI biomechanical feedback.';
        defaultAction = 'Upload Practice Video';
        illustrationAsset = 'assets/empty/no_challenges.png';
      case EmptyStateType.noNotifications:
        badgeSport = SportType.badminton;
        iconData = Icons.notifications_none_rounded;
        title = 'All Caught Up!';
        subtitle = 'You have no pending alerts, booking confirmations, or schedule changes.';
        defaultAction = 'Explore Drills';
        illustrationAsset = 'assets/empty/no_notifications.png';
      case EmptyStateType.noCertificates:
        badgeSport = SportType.athletics;
        iconData = Icons.workspace_premium_rounded;
        title = 'No Certificates Earned Yet';
        subtitle = 'Attend verified training sessions and reach career XP milestones to unlock official KRICO accreditations.';
        defaultAction = 'View Requirements';
        illustrationAsset = 'assets/empty/no_certificates.png';
      case EmptyStateType.noChallenges:
        badgeSport = SportType.basketball;
        iconData = Icons.emoji_events_outlined;
        title = 'No Active Challenges';
        subtitle = 'Join weekly fitness drills, community leaderboard contests, and academy skill challenges.';
        defaultAction = 'Browse Challenges';
        illustrationAsset = 'assets/empty/no_challenges.png';
      case EmptyStateType.noVenues:
        badgeSport = SportType.tennis;
        iconData = Icons.stadium_rounded;
        title = 'No Venues in Radius';
        subtitle = 'Try expanding your location search filter to find floodlit turfs and indoor courts.';
        defaultAction = 'Reset Filters';
        illustrationAsset = null;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s32, vertical: SpacingScale.s40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (illustrationAsset != null)
              Container(
                constraints: const BoxConstraints(maxHeight: 150, maxWidth: 220),
                decoration: BoxDecoration(
                  borderRadius: AppRadius.brXl,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: AppRadius.brXl,
                  child: Image.asset(
                    illustrationAsset,
                    height: 140,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => _buildFallbackBadge(badgeSport, iconData),
                  ),
                ),
              ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack)
            else
              _buildFallbackBadge(badgeSport, iconData).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),

            const SizedBox(height: SpacingScale.s24),

            Text(
              customTitle ?? title,
              textAlign: TextAlign.center,
              style: AppTextStyles.heading2.copyWith(color: AppColors.textPrimary),
            ).animate().fadeIn(delay: 150.ms),

            const SizedBox(height: SpacingScale.s8),

            Text(
              customSubtitle ?? subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary, height: 1.5),
            ).animate().fadeIn(delay: 250.ms),

            if (onAction != null) ...[
              const SizedBox(height: SpacingScale.s28),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: Text(actionLabel ?? defaultAction, style: const TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s28, vertical: SpacingScale.s12),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.brXl),
                  elevation: 6,
                ),
              ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.1, end: 0),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackBadge(SportType badgeSport, IconData iconData) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SportsVectorBadge(sport: badgeSport, size: 88, showGlow: true),
        Container(
          padding: const EdgeInsets.all(SpacingScale.s8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            shape: BoxShape.circle,
          ),
          child: Icon(iconData, size: 28, color: Colors.white),
        ),
      ],
    );
  }
}

/// KRICO Design System Alias for seamless rebranding
typedef KricoEmptyState = SportsEcoEmptyState;
