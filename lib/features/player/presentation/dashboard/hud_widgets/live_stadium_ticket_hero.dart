import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sports_app/design_system/colors/app_colors.dart';
import 'package:sports_app/design_system/radius/radius.dart';
import 'package:sports_app/design_system/spacing/spacing_scale.dart';
import 'package:sports_app/design_system/typography/text_styles.dart';

class LiveStadiumTicketHero extends StatelessWidget {
  const LiveStadiumTicketHero({
    super.key,
    this.sessionDoc,
    required this.userName,
  });

  final Map<String, dynamic>? sessionDoc;
  final String userName;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final subColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    final hasSession = sessionDoc != null;
    final sport = sessionDoc?['sport'] as String? ?? 'Elite Badminton';
    final venue = sessionDoc?['venue'] as String? ?? 'Krico Grand Arena • Court 3';
    final coach = sessionDoc?['coachName'] as String? ?? 'Coach Viktor';
    final _ = coach;
    final dateTime = sessionDoc?['dateTime'] != null
        ? (sessionDoc!['dateTime'] as dynamic).toDate() as DateTime
        : DateTime.now().add(const Duration(hours: 2, minutes: 15));

    final diff = dateTime.difference(DateTime.now());
    final countdownStr = diff.inHours > 0
        ? 'STARTS IN ${diff.inHours}H ${diff.inMinutes % 60}M'
        : 'STARTS IN ${diff.inMinutes.clamp(1, 60)}M';

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.brXl3,
        border: Border.all(color: borderColor, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppColors.volt : Colors.black).withValues(alpha: isDark ? 0.08 : 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.volt.withValues(alpha: isDark ? 0.22 : 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ticket Header Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF131D31) : const Color(0xFFF1F5F9),
                  border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.volt,
                        borderRadius: AppRadius.brSm,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.stadium_rounded, size: 12, color: AppColors.midnightObsidian),
                          SizedBox(width: 4),
                          Text(
                            'LIVE PASS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppColors.midnightObsidian,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withValues(alpha: 0.15),
                        borderRadius: AppRadius.brFull,
                      ),
                      child: Text(
                        countdownStr,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.emerald,
                        ),
                      ),
                    ),
                    Text(
                      DateFormat('EEE, MMM d • hh:mm a').format(dateTime),
                      style: AppTextStyles.caption.copyWith(color: subColor),
                    ),
                  ],
                ),
              ),
              // Main Ticket Body
              Padding(
                padding: const EdgeInsets.all(SpacingScale.s20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sport.toUpperCase(),
                                style: AppTextStyles.captionXs.copyWith(
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? AppColors.volt : AppColors.voltDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                hasSession
                                    ? 'Training Session with $coach'
                                    : 'Next Match: Arena Court 3',
                                style: AppTextStyles.heading2.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: textColor,
                                  height: 1.15,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.location_on_outlined, size: 14, color: subColor),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      venue,
                                      style: AppTextStyles.bodySm.copyWith(color: subColor),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.volt.withValues(alpha: 0.4), width: 1.5),
                            borderRadius: AppRadius.brLg,
                            color: AppColors.volt.withValues(alpha: 0.08),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.qr_code_2_rounded, size: 32, color: AppColors.volt),
                              SizedBox(height: 2),
                              Text(
                                'GATE PASS',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.volt,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: SpacingScale.s16),
                    Divider(color: borderColor, thickness: 1, height: 1),
                    const SizedBox(height: SpacingScale.s16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showGatePassModal(context, sport, venue, dateTime),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.volt,
                            foregroundColor: AppColors.midnightObsidian,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                          label: const Text(
                            'ACCESS GATE PASS',
                            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => context.push('/venues'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: borderColor),
                            foregroundColor: textColor,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                          ),
                          icon: const Icon(Icons.stadium_outlined, size: 18),
                          label: const Text('Venue Specs'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showGatePassModal(BuildContext context, String sport, String venue, DateTime time) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: AppColors.volt.withValues(alpha: 0.4)),
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.verified_rounded, color: AppColors.volt, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'OFFICIAL GATE PASS',
                    style: AppTextStyles.title2.copyWith(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Hold QR scanner 10cm from stadium gate sensor',
                style: AppTextStyles.caption.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.volt.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: 'KRICO-PASS-$userName-${time.millisecondsSinceEpoch}',
                  version: QrVersions.auto,
                  size: 180,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('MANUAL ENTRY PIN: ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      '829 - 410',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppColors.volt,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('DONE'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
