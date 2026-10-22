import 'dart:math' as math;
import 'package:flutter/material.dart';

enum SportType { cricket, football, badminton, tennis, athletics, basketball }

class SportsVectorBadge extends StatelessWidget {
  final SportType sport;
  final double size;
  final bool showGlow;

  const SportsVectorBadge({
    super.key,
    required this.sport,
    this.size = 56,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    Color primaryColor;
    Color secondaryColor;

    switch (sport) {
      case SportType.cricket:
        primaryColor = const Color(0xFFEF4444); // Crimson red
        secondaryColor = const Color(0xFFF59E0B); // Amber leather
      case SportType.football:
        primaryColor = const Color(0xFF10B981); // Emerald pitch
        secondaryColor = Colors.white;
      case SportType.badminton:
        primaryColor = const Color(0xFF06B6D4); // Cyan speed
        secondaryColor = Colors.white;
      case SportType.tennis:
        primaryColor = const Color(0xFF84CC16); // Tennis yellow-green
        secondaryColor = Colors.white;
      case SportType.athletics:
        primaryColor = const Color(0xFFF97316); // Track orange
        secondaryColor = const Color(0xFFFACC15); // Gold flame
      case SportType.basketball:
        primaryColor = const Color(0xFFEA580C); // Deep orange
        secondaryColor = const Color(0xFF1E293B);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withValues(alpha: 0.25),
            primaryColor.withValues(alpha: 0.05),
          ],
        ),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.35),
                  blurRadius: size * 0.3,
                  spreadRadius: 2,
                ),
              ]
            : null,
        border: Border.all(color: primaryColor.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.6, size * 0.6),
          painter: _SportBadgePainter(
            sport: sport,
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
          ),
        ),
      ),
    );
  }
}

class _SportBadgePainter extends CustomPainter {
  final SportType sport;
  final Color primaryColor;
  final Color secondaryColor;

  _SportBadgePainter({
    required this.sport,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final fillPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    switch (sport) {
      case SportType.cricket:
        // Cricket ball with white seam
        canvas.drawCircle(center, radius * 0.85, fillPaint);
        final seamPath = Path();
        seamPath.moveTo(center.dx - radius * 0.7, center.dy);
        seamPath.quadraticBezierTo(
          center.dx,
          center.dy - radius * 0.5,
          center.dx + radius * 0.7,
          center.dy,
        );
        seamPath.quadraticBezierTo(
          center.dx,
          center.dy + radius * 0.5,
          center.dx - radius * 0.7,
          center.dy,
        );
        canvas.drawPath(seamPath, strokePaint..strokeWidth = 1.8);

      case SportType.football:
        // Football hexagon core
        canvas.drawCircle(center, radius * 0.85, strokePaint..strokeWidth = 1.5);
        final hexPath = Path();
        for (int i = 0; i < 6; i++) {
          final angle = (i * 60) * math.pi / 180;
          final x = center.dx + (radius * 0.4) * math.cos(angle);
          final y = center.dy + (radius * 0.4) * math.sin(angle);
          if (i == 0) {
            hexPath.moveTo(x, y);
          } else {
            hexPath.lineTo(x, y);
          }
        }
        hexPath.close();
        canvas.drawPath(hexPath, fillPaint);

      case SportType.badminton:
        // Shuttlecock cone & cork
        final cone = Path();
        cone.moveTo(center.dx, center.dy + radius * 0.7);
        cone.lineTo(center.dx - radius * 0.7, center.dy - radius * 0.5);
        cone.lineTo(center.dx + radius * 0.7, center.dy - radius * 0.5);
        cone.close();
        canvas.drawPath(cone, strokePaint..strokeWidth = 1.5);
        canvas.drawCircle(Offset(center.dx, center.dy + radius * 0.65), radius * 0.25, fillPaint);

      case SportType.tennis:
        // Tennis ball with curve seams
        canvas.drawCircle(center, radius * 0.85, fillPaint);
        final tSeam1 = Path()
          ..addArc(Rect.fromCircle(center: Offset(center.dx - radius * 0.6, center.dy), radius: radius * 0.6), -math.pi / 2, math.pi);
        final tSeam2 = Path()
          ..addArc(Rect.fromCircle(center: Offset(center.dx + radius * 0.6, center.dy), radius: radius * 0.6), math.pi / 2, math.pi);
        canvas.drawPath(tSeam1, strokePaint..strokeWidth = 1.5);
        canvas.drawPath(tSeam2, strokePaint..strokeWidth = 1.5);

      case SportType.athletics:
        // Running track curve lines
        for (double r = radius * 0.35; r <= radius * 0.85; r += radius * 0.25) {
          canvas.drawArc(
            Rect.fromCircle(center: center, radius: r),
            math.pi * 0.2,
            math.pi * 1.6,
            false,
            strokePaint..strokeWidth = 2.0,
          );
        }
        canvas.drawCircle(center, radius * 0.2, fillPaint);

      case SportType.basketball:
        // Basketball lines
        canvas.drawCircle(center, radius * 0.85, fillPaint);
        canvas.drawLine(Offset(center.dx - radius * 0.85, center.dy), Offset(center.dx + radius * 0.85, center.dy), strokePaint);
        canvas.drawLine(Offset(center.dx, center.dy - radius * 0.85), Offset(center.dx, center.dy + radius * 0.85), strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SportBadgePainter oldDelegate) => false;
}
