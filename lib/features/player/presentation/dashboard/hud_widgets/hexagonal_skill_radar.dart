import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sports_app/design_system/colors/app_colors.dart';
import 'package:sports_app/design_system/radius/radius.dart';
import 'package:sports_app/design_system/spacing/spacing_scale.dart';
import 'package:sports_app/design_system/typography/text_styles.dart';

class SkillMetric {
  final String name;
  final double athleteValue;
  final double benchmarkValue;
  final String description;

  const SkillMetric({
    required this.name,
    required this.athleteValue,
    required this.benchmarkValue,
    required this.description,
  });
}

class HexagonalSkillRadar extends StatefulWidget {
  const HexagonalSkillRadar({super.key});

  @override
  State<HexagonalSkillRadar> createState() => _HexagonalSkillRadarState();
}

class _HexagonalSkillRadarState extends State<HexagonalSkillRadar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  int _selectedSkillIndex = 0;

  final List<SkillMetric> _skills = const [
    SkillMetric(name: 'Speed', athleteValue: 0.88, benchmarkValue: 0.75, description: 'Footwork & shuttle chase velocity'),
    SkillMetric(name: 'Power', athleteValue: 0.92, benchmarkValue: 0.80, description: 'Smash impact & kinetic wrist whip'),
    SkillMetric(name: 'Stamina', athleteValue: 0.85, benchmarkValue: 0.82, description: 'Cardio engine through 3 full sets'),
    SkillMetric(name: 'Tactical IQ', athleteValue: 0.90, benchmarkValue: 0.70, description: 'Shot selection & court geometry deception'),
    SkillMetric(name: 'Agility', athleteValue: 0.86, benchmarkValue: 0.78, description: 'Split-step reaction & recovery angle'),
    SkillMetric(name: 'Focus', athleteValue: 0.94, benchmarkValue: 0.75, description: 'Clutch match pressure composure'),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
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

    final selected = _skills[_selectedSkillIndex];

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
                  color: AppColors.cyan.withValues(alpha: 0.15),
                  borderRadius: AppRadius.brMd,
                ),
                child: const Icon(Icons.radar_rounded, color: AppColors.cyan, size: 20),
              ),
              const SizedBox(width: SpacingScale.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COMPETITIVE MATRIX',
                      style: AppTextStyles.captionXs.copyWith(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w800,
                        color: AppColors.cyan,
                      ),
                    ),
                    Text(
                      'Hexagonal Skill Radar',
                      style: AppTextStyles.title3.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.volt.withValues(alpha: 0.12),
                  borderRadius: AppRadius.brFull,
                  border: Border.all(color: AppColors.volt.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'TOP 5% IN STATE',
                  style: AppTextStyles.captionXs.copyWith(
                    color: isDark ? AppColors.volt : AppColors.voltDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingScale.s16),
          Center(
            child: SizedBox(
              width: 250,
              height: 200,
              child: AnimatedBuilder(
                animation: _scaleAnim,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _HexagonRadarPainter(
                      skills: _skills,
                      animValue: _scaleAnim.value,
                      selectedIndex: _selectedSkillIndex,
                      isDark: isDark,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: SpacingScale.s12),
          // Interactive skill pill bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < _skills.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: InkWell(
                      onTap: () => setState(() => _selectedSkillIndex = i),
                      borderRadius: AppRadius.brFull,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _selectedSkillIndex == i
                              ? (isDark ? AppColors.volt : const Color(0xFF0F172A))
                              : (isDark ? AppColors.surfaceElevated : AppColors.lightSurface),
                          borderRadius: AppRadius.brFull,
                          border: Border.all(
                            color: _selectedSkillIndex == i
                                ? (isDark ? AppColors.volt : const Color(0xFF0F172A))
                                : borderColor,
                          ),
                        ),
                        child: Text(
                          '${_skills[i].name} (${(_skills[i].athleteValue * 100).toInt()})',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _selectedSkillIndex == i
                                ? (isDark ? AppColors.midnightObsidian : Colors.white)
                                : textColor,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: SpacingScale.s12),
          // Selected skill drill hint
          Container(
            padding: const EdgeInsets.all(SpacingScale.s12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceElevated : AppColors.lightSurface,
              borderRadius: AppRadius.brLg,
              border: Border.all(color: borderColor, width: 0.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline_rounded, size: 16, color: AppColors.volt),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${selected.name}: ${selected.description}',
                    style: AppTextStyles.caption.copyWith(color: subColor),
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

class _HexagonRadarPainter extends CustomPainter {
  final List<SkillMetric> skills;
  final double animValue;
  final int selectedIndex;
  final bool isDark;

  _HexagonRadarPainter({
    required this.skills,
    required this.animValue,
    required this.selectedIndex,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = (size.width / 2) - 34;
    final count = skills.length;

    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.10);

    // Draw 3 concentric hexagonal grids (33%, 66%, 100%)
    for (final level in [0.33, 0.66, 1.0]) {
      final r = maxRadius * level;
      final path = Path();
      for (var i = 0; i < count; i++) {
        final angle = (i * 2 * math.pi / count) - (math.pi / 2);
        final x = center.dx + r * math.cos(angle);
        final y = center.dy + r * math.sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // Draw radial spokes from center
    for (var i = 0; i < count; i++) {
      final angle = (i * 2 * math.pi / count) - (math.pi / 2);
      final x = center.dx + maxRadius * math.cos(angle);
      final y = center.dy + maxRadius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), gridPaint);
    }

    // Benchmark polygon (Dashed outline in grey)
    final benchPath = Path();
    for (var i = 0; i < count; i++) {
      final val = skills[i].benchmarkValue * animValue;
      final r = maxRadius * val;
      final angle = (i * 2 * math.pi / count) - (math.pi / 2);
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        benchPath.moveTo(x, y);
      } else {
        benchPath.lineTo(x, y);
      }
    }
    benchPath.close();
    final benchPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.grey.withValues(alpha: 0.4);
    canvas.drawPath(benchPath, benchPaint);

    // Athlete polygon (Volt fill & border)
    final athletePath = Path();
    final vertexPoints = <Offset>[];
    for (var i = 0; i < count; i++) {
      final val = skills[i].athleteValue * animValue;
      final r = maxRadius * val;
      final angle = (i * 2 * math.pi / count) - (math.pi / 2);
      final pt = Offset(center.dx + r * math.cos(angle), center.dy + r * math.sin(angle));
      vertexPoints.add(pt);
      if (i == 0) {
        athletePath.moveTo(pt.dx, pt.dy);
      } else {
        athletePath.lineTo(pt.dx, pt.dy);
      }
    }
    athletePath.close();

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.volt.withValues(alpha: isDark ? 0.28 : 0.20);
    canvas.drawPath(athletePath, fillPaint);

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..color = AppColors.volt;
    canvas.drawPath(athletePath, strokePaint);

    // Draw vertex nodes
    for (var i = 0; i < vertexPoints.length; i++) {
      final pt = vertexPoints[i];
      final isSel = i == selectedIndex;
      final nodePaint = Paint()
        ..style = PaintingStyle.fill
        ..color = isSel ? Colors.white : AppColors.volt;
      canvas.drawCircle(pt, isSel ? 5.5 : 3.5, nodePaint);
      if (isSel) {
        canvas.drawCircle(
          pt,
          8.0,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = AppColors.volt,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HexagonRadarPainter oldDelegate) {
    return oldDelegate.animValue != animValue ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.isDark != isDark;
  }
}
