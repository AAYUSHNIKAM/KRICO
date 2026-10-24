import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/radius/radius.dart';
import '../../../../design_system/spacing/spacing_scale.dart';
import '../../../../design_system/typography/text_styles.dart';
import '../../../../services/providers.dart';

class ReviewCoachModal extends ConsumerStatefulWidget {
  final String sessionId;
  final String coachId;
  final String coachName;
  final String playerId;
  final String playerName;

  const ReviewCoachModal({
    super.key,
    required this.sessionId,
    required this.coachId,
    required this.coachName,
    required this.playerId,
    required this.playerName,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String sessionId,
    required String coachId,
    required String coachName,
    required String playerId,
    required String playerName,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReviewCoachModal(
        sessionId: sessionId,
        coachId: coachId,
        coachName: coachName,
        playerId: playerId,
        playerName: playerName,
      ),
    );
  }

  @override
  ConsumerState<ReviewCoachModal> createState() => _ReviewCoachModalState();
}

class _ReviewCoachModalState extends ConsumerState<ReviewCoachModal> {
  final TextEditingController _commentCtrl = TextEditingController();
  double _rating = 5.0;
  bool _submitting = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    setState(() => _submitting = true);
    try {
      await ref.read(reviewServiceProvider).addReview(
            coachId: widget.coachId,
            playerId: widget.playerId,
            playerName: widget.playerName,
            rating: _rating,
            comment: _commentCtrl.text.trim(),
          );

      // Mark session as reviewed by player
      await FirebaseFirestore.instance
          .collection('sessions')
          .doc(widget.sessionId)
          .set({'playerReviewed': true, 'playerRating': _rating}, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Thank you! Your review has been submitted.'),
            backgroundColor: AppColors.emerald,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit review: '), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF10141E) : Colors.white;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: borderColor),
        ),
        padding: const EdgeInsets.all(SpacingScale.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: AppRadius.brFull,
                ),
              ),
            ),
            const SizedBox(height: SpacingScale.s16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.volt.withValues(alpha: 0.15),
                    borderRadius: AppRadius.brLg,
                  ),
                  child: const Icon(Icons.star_rounded, color: AppColors.volt, size: 26),
                ),
                const SizedBox(width: SpacingScale.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Review Coach ',
                        style: AppTextStyles.title2.copyWith(
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                      Text(
                        'How was your training session today?',
                        style: AppTextStyles.caption.copyWith(color: textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpacingScale.s20),

            // Star rating selector
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  final starVal = index + 1.0;
                  final isFilled = _rating >= starVal;
                  return IconButton(
                    iconSize: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    icon: Icon(
                      isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: isFilled ? const Color(0xFFF59E0B) : Colors.grey,
                    ),
                    onPressed: () => setState(() => _rating = starVal),
                  );
                }),
              ),
            ),
            Center(
              child: Text(
                ' / 5.0 Rating',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: textPrimary),
              ),
            ),
            const SizedBox(height: SpacingScale.s20),

            TextField(
              controller: _commentCtrl,
              maxLines: 3,
              style: TextStyle(color: textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Share your feedback, coaching drill experience, or improvements...',
                labelText: 'Written Review (Optional)',
                filled: true,
                fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: AppRadius.brLg),
              ),
            ),
            const SizedBox(height: SpacingScale.s24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                    ),
                    child: Text('Review Later', style: TextStyle(color: textSecondary, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: SpacingScale.s12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submitReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Submit Review', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
