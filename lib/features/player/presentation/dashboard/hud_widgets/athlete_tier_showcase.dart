import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/design_system/colors/app_colors.dart';
import 'package:sports_app/design_system/radius/radius.dart';
import 'package:sports_app/design_system/spacing/spacing_scale.dart';
import 'package:sports_app/design_system/typography/text_styles.dart';

class AthleteTierShowcase extends StatelessWidget {
  const AthleteTierShowcase({super.key, required this.playerId});

  final String playerId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.card : AppColors.lightCard;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final subColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

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
                  color: AppColors.volt.withValues(alpha: 0.15),
                  borderRadius: AppRadius.brMd,
                ),
                child: Icon(Icons.workspace_premium_rounded, color: AppColors.volt, size: 20),
              ),
              const SizedBox(width: SpacingScale.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '15-TIER ATHLETIC MASTERY',
                      style: AppTextStyles.captionXs.copyWith(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.volt : AppColors.voltDark,
                      ),
                    ),
                    Text(
                      'Tier 8: Elite Competitor',
                      style: AppTextStyles.title3.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Universal certification framework based on global KRICO XP',
                      style: AppTextStyles.captionXs.copyWith(
                        color: subColor,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () => context.push('/player-certificates/' + playerId),
                style: FilledButton.styleFrom(
                  backgroundColor: isDark ? AppColors.volt : const Color(0xFF0F172A),
                  foregroundColor: isDark ? AppColors.midnightObsidian : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
                ),
                icon: Icon(Icons.download_rounded, size: 14),
                label: Text('Export PDF', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: SpacingScale.s16),
          // Tier progression bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Next: Tier 9 Mastery Vanguard',
                  style: AppTextStyles.caption.copyWith(color: subColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '850/1K XP',
                style: AppTextStyles.labelSm.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.volt : AppColors.voltDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.85,
              minHeight: 8,
              backgroundColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? AppColors.volt : const Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(height: SpacingScale.s16),
          // 5-Badge sample strip
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTierBadge(number: '06', name: 'Rising Star', isUnlocked: true, isDark: isDark),
                _buildTierBadge(number: '07', name: 'Proven Contender', isUnlocked: true, isDark: isDark),
                _buildTierBadge(number: '08', name: 'Elite Competitor', isUnlocked: true, isCurrent: true, isDark: isDark),
                _buildTierBadge(number: '09', name: 'Mastery Vanguard', isUnlocked: false, isDark: isDark),
                _buildTierBadge(number: '10', name: 'Academy Champion', isUnlocked: false, isDark: isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierBadge({
    required String number,
    required String name,
    required bool isUnlocked,
    bool isCurrent = false,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrent
            ? (isDark ? AppColors.volt.withValues(alpha: 0.18) : const Color(0xFF0F172A))
            : (isDark ? AppColors.surfaceElevated : AppColors.lightSurface),
        borderRadius: AppRadius.brLg,
        border: Border.all(
          color: isCurrent ? AppColors.volt : (isUnlocked ? Colors.grey.withValues(alpha: 0.4) : Colors.transparent),
          width: isCurrent ? 1.5 : 0.8,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isUnlocked ? Icons.verified_rounded : Icons.lock_outline_rounded,
                size: 14,
                color: isCurrent
                    ? AppColors.volt
                    : (isUnlocked ? AppColors.emerald : Colors.grey),
              ),
              const SizedBox(width: 4),
              Text(
                'TIER ',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: isCurrent && !isDark ? Colors.white : (isCurrent ? AppColors.volt : Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isCurrent && !isDark ? Colors.white : (isDark ? Colors.white : const Color(0xFF0F172A)),
            ),
          ),
        ],
      ),
    );
  }
}
