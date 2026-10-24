import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/design_system/colors/app_colors.dart';
import 'package:sports_app/design_system/radius/radius.dart';
import 'package:sports_app/design_system/spacing/spacing_scale.dart';
import 'package:sports_app/design_system/typography/text_styles.dart';

class SquadLeaderboardPodium extends StatelessWidget {
  const SquadLeaderboardPodium({super.key, required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.card : AppColors.lightCard;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    // subColor

    return Container(
      padding: const EdgeInsets.all(SpacingScale.s20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.brXl3,
        border: Border.all(color: borderColor, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: AppRadius.brMd,
                ),
                child: Icon(Icons.emoji_events_rounded, color: AppColors.warning, size: 20),
              ),
              const SizedBox(width: SpacingScale.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SQUAD COMPETITION',
                      style: AppTextStyles.captionXs.copyWith(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w800,
                        color: AppColors.warning,
                      ),
                    ),
                    Text(
                      'Live Squad XP Podium',
                      style: AppTextStyles.title3.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => context.push('/leaderboard'),
                child: Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: SpacingScale.s20),
          // 3-Athlete Podium visualization
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Rank 2 (Silver)
              _buildPodiumStep(
                rank: 2,
                name: 'Priya S.',
                xp: '2,180 XP',
                height: 70,
                color: const Color(0xFF94A3B8),
                isDark: isDark,
              ),
              // Rank 1 (Gold)
              _buildPodiumStep(
                rank: 1,
                name: 'Arjun V.',
                xp: '2,450 XP',
                height: 95,
                color: const Color(0xFFF59E0B),
                isDark: isDark,
                isCrown: true,
              ),
              // Rank 3 (Bronze - Current user)
              _buildPodiumStep(
                rank: 3,
                name: 'You ()',
                xp: '1,940 XP',
                height: 55,
                color: const Color(0xFFB45309),
                isDark: isDark,
                isUser: true,
              ),
            ],
          ),
          const SizedBox(height: SpacingScale.s16),
          // Gap telemetry pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.volt.withValues(alpha: 0.12),
              borderRadius: AppRadius.brLg,
              border: Border.all(color: AppColors.volt.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.trending_up_rounded, size: 16, color: AppColors.volt),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '+240 XP needed to overtake Priya for #2 spot in Pune Squad!',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.volt : const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumStep({
    required int rank,
    required String name,
    required String xp,
    required double height,
    required Color color,
    required bool isDark,
    bool isCrown = false,
    bool isUser = false,
  }) {
    return Column(
      children: [
        if (isCrown)
          Icon(Icons.workspace_premium_rounded, size: 22, color: Color(0xFFF59E0B)),
        const SizedBox(height: 4),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.2),
            border: Border.all(color: color, width: isUser ? 2.5 : 1.5),
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0] : 'A',
              style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isUser ? FontWeight.w900 : FontWeight.w700,
            color: isUser ? AppColors.volt : (isDark ? Colors.white : const Color(0xFF0F172A)),
          ),
        ),
        Text(xp, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        // Podium block
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.22 : 0.15),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Center(
            child: Text(
              '#',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color),
            ),
          ),
        ),
      ],
    );
  }
}
