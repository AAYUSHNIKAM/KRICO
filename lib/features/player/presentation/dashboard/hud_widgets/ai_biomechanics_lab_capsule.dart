import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/design_system/colors/app_colors.dart';
import 'package:sports_app/design_system/radius/radius.dart';
import 'package:sports_app/design_system/spacing/spacing_scale.dart';
import 'package:sports_app/design_system/typography/text_styles.dart';

class AiBiomechanicsLabCapsule extends StatelessWidget {
  const AiBiomechanicsLabCapsule({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.card : AppColors.lightCard;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;

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
                  color: AppColors.purple.withValues(alpha: 0.15),
                  borderRadius: AppRadius.brMd,
                ),
                child: const Icon(Icons.slow_motion_video_rounded, color: AppColors.purple, size: 20),
              ),
              const SizedBox(width: SpacingScale.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COMPUTER VISION & POSE AI',
                      style: AppTextStyles.captionXs.copyWith(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w800,
                        color: AppColors.purple,
                      ),
                    ),
                    Text(
                      'AI Biomechanics Lab',
                      style: AppTextStyles.title3.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.15),
                  borderRadius: AppRadius.brSm,
                ),
                child: const Text(
                  'GRADE S',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppColors.emerald,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingScale.s16),
          // Hawk-Eye Pose Simulation Preview Box
          Container(
            height: 126,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF090A0F) : const Color(0xFF1E293B),
              borderRadius: AppRadius.brLg,
              border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3)),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _VisionGridPainter(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'KINETIC WHIP',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '44.2°',
                              style: AppTextStyles.heading2.copyWith(
                                color: AppColors.volt,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const Text(
                              'Optimal: 45°',
                              style: TextStyle(fontSize: 10, color: AppColors.emerald),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'RACKET SPEED',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '138 km/h',
                              style: AppTextStyles.heading2.copyWith(
                                color: AppColors.cyan,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const Text(
                              'Top 3% State',
                              style: TextStyle(fontSize: 10, color: AppColors.cyan),
                              overflow: TextOverflow.ellipsis,
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
          const SizedBox(height: SpacingScale.s16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/video-analysis'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.purple.withValues(alpha: 0.5)),
                foregroundColor: textColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
              ),
              icon: const Icon(Icons.videocam_outlined, size: 16, color: AppColors.purple),
              label: const Text('Record & Analyze Technique', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _VisionGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.cyan.withValues(alpha: 0.08)
      ..strokeWidth = 0.5;

    for (var x = 0.0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final skeletonPaint = Paint()
      ..color = AppColors.volt.withValues(alpha: 0.7)
      ..strokeWidth = 1.5;
    final jointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final p1 = Offset(size.width * 0.48, size.height * 0.3);
    final p2 = Offset(size.width * 0.52, size.height * 0.45);
    final p3 = Offset(size.width * 0.58, size.height * 0.25);

    canvas.drawLine(p1, p2, skeletonPaint);
    canvas.drawLine(p2, p3, skeletonPaint);

    canvas.drawCircle(p1, 3, jointPaint);
    canvas.drawCircle(p2, 4, jointPaint);
    canvas.drawCircle(p3, 3, jointPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
