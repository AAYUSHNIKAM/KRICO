import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sports_app/design_system/colors/app_colors.dart';
import 'package:sports_app/design_system/radius/radius.dart';
import 'package:sports_app/design_system/spacing/spacing_scale.dart';
import 'package:sports_app/design_system/typography/text_styles.dart';

class ConcentricActivityRings extends StatefulWidget {
  const ConcentricActivityRings({
    super.key,
    this.intensity = 0.84,
    this.drills = 0.68,
    this.recovery = 0.92,
  });

  final double intensity;
  final double drills;
  final double recovery;

  @override
  State<ConcentricActivityRings> createState() => _ConcentricActivityRingsState();
}

class _ConcentricActivityRingsState extends State<ConcentricActivityRings>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _progressAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

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
                child: const Icon(Icons.speed_rounded, color: AppColors.volt, size: 20),
              ),
              const SizedBox(width: SpacingScale.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ATHLETIC TELEMETRY',
                      style: AppTextStyles.captionXs.copyWith(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.volt : AppColors.voltDark,
                      ),
                    ),
                    Text(
                      'Activity & Readiness Orbit',
                      style: AppTextStyles.title3.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: 0.12),
                  borderRadius: AppRadius.brFull,
                  border: Border.all(color: AppColors.orange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department_rounded, size: 14, color: AppColors.orange),
                    const SizedBox(width: 4),
                    Text(
                      '14D STREAK',
                      style: AppTextStyles.captionXs.copyWith(
                        color: AppColors.orange,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingScale.s20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isVeryNarrow = constraints.maxWidth < 280;
              final canvasSize = isVeryNarrow ? 90.0 : 115.0;

              return Row(
                children: [
                  SizedBox(
                    width: canvasSize,
                    height: canvasSize,
                    child: AnimatedBuilder(
                      animation: _progressAnim,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: _RingsPainter(
                            intensity: widget.intensity * _progressAnim.value,
                            drills: widget.drills * _progressAnim.value,
                            recovery: widget.recovery * _progressAnim.value,
                            isDark: isDark,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${(widget.recovery * 100).toInt()}%',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: textColor,
                                    height: 1.0,
                                  ),
                                ),
                                const Text(
                                  'READY',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.emerald,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: SpacingScale.s16),
                  Expanded(
                    child: Column(
                      children: [
                        _buildMetricRow(
                          label: 'Intensity',
                          value: '${(widget.intensity * 100).toInt()}%',
                          sub: '1,480 XP (+18%)',
                          color: AppColors.volt,
                          textColor: textColor,
                          subColor: subColor,
                        ),
                        const SizedBox(height: SpacingScale.s8),
                        _buildMetricRow(
                          label: 'Drills',
                          value: '${(widget.drills * 100).toInt()}%',
                          sub: '14 of 20 Done',
                          color: AppColors.cyan,
                          textColor: textColor,
                          subColor: subColor,
                        ),
                        const SizedBox(height: SpacingScale.s8),
                        _buildMetricRow(
                          label: 'Recovery',
                          value: '${(widget.recovery * 100).toInt()}%',
                          sub: 'Match Fitness',
                          color: AppColors.orange,
                          textColor: textColor,
                          subColor: subColor,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow({
    required String label,
    required String value,
    required String sub,
    required Color color,
    required Color textColor,
    required Color subColor,
  }) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: SpacingScale.s8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: AppTextStyles.labelSm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    value,
                    style: AppTextStyles.labelSm.copyWith(
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                ],
              ),
              Text(
                sub,
                style: AppTextStyles.captionXs.copyWith(color: subColor),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RingsPainter extends CustomPainter {
  final double intensity;
  final double drills;
  final double recovery;
  final bool isDark;

  _RingsPainter({
    required this.intensity,
    required this.drills,
    required this.recovery,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 8.0;
    const spacing = 11.0;

    final outerRadius = (size.width / 2) - strokeWidth;
    final middleRadius = outerRadius - spacing;
    final innerRadius = middleRadius - spacing;

    // Background tracks
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08);

    canvas.drawCircle(center, outerRadius, bgPaint);
    canvas.drawCircle(center, middleRadius, bgPaint);
    canvas.drawCircle(center, innerRadius, bgPaint);

    // Outer: Intensity (Volt)
    _drawArc(canvas, center, outerRadius, strokeWidth, intensity, AppColors.volt);
    // Middle: Drills (Cyan)
    _drawArc(canvas, center, middleRadius, strokeWidth, drills, AppColors.cyan);
    // Inner: Recovery (Orange)
    _drawArc(canvas, center, innerRadius, strokeWidth, recovery, AppColors.orange);
  }

  void _drawArc(Canvas canvas, Offset center, double radius, double stroke, double progress, Color color) {
    if (progress <= 0) return;
    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingsPainter oldDelegate) {
    return oldDelegate.intensity != intensity ||
        oldDelegate.drills != drills ||
        oldDelegate.recovery != recovery ||
        oldDelegate.isDark != isDark;
  }
}
