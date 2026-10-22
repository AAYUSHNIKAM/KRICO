import 'package:flutter/material.dart';
import '../../typography/text_styles.dart';
import '../../spacing/spacing_scale.dart';
import '../../radius/radius.dart';

class PremiumPill extends StatelessWidget {
  final String text;
  final Color color;

  const PremiumPill({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingScale.s10,
        vertical: SpacingScale.s4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.brFull,
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 0.75,
        ),
      ),
      child: Text(
        text,
        style: AppTextStyles.captionXs.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
