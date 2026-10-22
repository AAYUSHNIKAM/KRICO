import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../design_system/utils/extensions.dart';
import '../../../services/providers.dart';
import '../../../models/coach_model.dart';

class EarningsTab extends ConsumerWidget {
  final String coachId;
  const EarningsTab({super.key, required this.coachId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sessionsAsync = ref.watch(coachSessionsProvider(coachId));
    final coachAsync = ref.watch(coachProvider(coachId));

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090B10) : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _EarningsHeroHeader(
              coachAsync: coachAsync,
              sessionsAsync: sessionsAsync,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                sessionsAsync.when(
                  data: (snapshot) {
                    return coachAsync.when(
                      data: (coach) => _buildEarningsContent(context, snapshot, coach),
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(color: Color(0xFFCCFF00)),
                        ),
                      ),
                      error: (_, _) => _buildEarningsContent(context, snapshot, null),
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: Color(0xFFCCFF00)),
                    ),
                  ),
                  error: (e, _) {
                    debugPrint('Earnings error: $e');
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.danger),
                          const SizedBox(height: 12),
                          Text('Unable to load earnings data right now.',
                              style: AppTextStyles.body.copyWith(color: AppColors.danger)),
                        ],
                      ),
                    );
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsContent(
      BuildContext context, QuerySnapshot<Map<String, dynamic>> snapshot, CoachModel? coach) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sessions = snapshot.docs;
    final totalSessions = sessions.length;
    final completedSessions =
        sessions.where((d) => d.data()['status'] == 'completed').length;
    final rate = coach?.hourlyRate ?? 0;
    final estimatedEarnings = completedSessions * rate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Animate(
          effects: [
            const FadeEffect(duration: Duration(milliseconds: 350)),
            const SlideEffect(
                begin: Offset(0, 0.05),
                end: Offset.zero,
                duration: Duration(milliseconds: 350)),
          ],
          child: context.width > 900
              ? _buildWideStatsRow(
                  totalSessions, completedSessions, estimatedEarnings, rate, isDark)
              : _buildMobileStats(
                  totalSessions, completedSessions, estimatedEarnings, rate, isDark),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFCCFF00).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFCCFF00).withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.receipt_long_rounded,
                  size: 18, color: Color(0xFFCCFF00)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Session Revenue Log',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    )),
                Text('Recorded coaching payouts & pending reconciliations',
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontSize: 11,
                    )),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        Animate(
          effects: [
            const FadeEffect(
                duration: Duration(milliseconds: 350),
                delay: Duration(milliseconds: 80)),
            const SlideEffect(
                begin: Offset(0, 0.04),
                end: Offset.zero,
                duration: Duration(milliseconds: 350),
                delay: Duration(milliseconds: 80)),
          ],
          child: sessions.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(SpacingScale.s32),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF121622) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long_rounded,
                            size: 40,
                            color: isDark
                                ? AppColors.textSecondary
                                : AppColors.lightTextSecondary),
                        const SizedBox(height: SpacingScale.s8),
                        Text('No session payouts recorded yet',
                            style: AppTextStyles.body.copyWith(
                                color: isDark
                                    ? AppColors.textSecondary
                                    : AppColors.lightTextSecondary)),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: sessions.take(15).map((doc) {
                    final d = doc.data();
                    final sport = d['sport'] as String? ?? 'Training';
                    final ts = d['dateTime'] as Timestamp?;
                    final status = d['status'] as String? ?? 'booked';
                    final timeStr = ts != null ? _formatDate(ts.toDate()) : 'TBD';
                    return _buildSessionRow(sport, timeStr, status, rate, isDark);
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color iconColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121622) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: iconColor.withValues(alpha: 0.3)),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const Spacer(),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: iconColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(value,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              )),
          const SizedBox(height: 3),
          Text(label,
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }

  Widget _buildWideStatsRow(
      int total, int completed, double earnings, double rate, bool isDark) {
    return Row(
      children: [
        Expanded(
            child: _buildStatCard('Total Booked', '$total', Icons.schedule_rounded,
                const Color(0xFF00E5FF), isDark)),
        const SizedBox(width: 12),
        Expanded(
            child: _buildStatCard('Completed Fixtures', '$completed',
                Icons.check_circle_rounded, const Color(0xFFCCFF00), isDark)),
        const SizedBox(width: 12),
        Expanded(
            child: _buildStatCard('Estimated Earnings', '₹${earnings.toInt()}',
                Icons.account_balance_wallet_rounded, const Color(0xFFFFB300), isDark)),
        const SizedBox(width: 12),
        Expanded(
            child: _buildStatCard('Hourly Rate', '₹${rate.toInt()}/hr',
                Icons.bolt_rounded, const Color(0xFF9D4EDD), isDark)),
      ],
    );
  }

  Widget _buildMobileStats(
      int total, int completed, double earnings, double rate, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _buildStatCard('Total Booked', '$total',
                    Icons.schedule_rounded, const Color(0xFF00E5FF), isDark)),
            const SizedBox(width: 12),
            Expanded(
                child: _buildStatCard('Completed', '$completed',
                    Icons.check_circle_rounded, const Color(0xFFCCFF00), isDark)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _buildStatCard('Est. Earnings', '₹${earnings.toInt()}',
                    Icons.account_balance_wallet_rounded, const Color(0xFFFFB300), isDark)),
            const SizedBox(width: 12),
            Expanded(
                child: _buildStatCard('Rate / Hour', '₹${rate.toInt()}',
                    Icons.bolt_rounded, const Color(0xFF9D4EDD), isDark)),
          ],
        ),
      ],
    );
  }

  Widget _buildSessionRow(
      String name, String time, String status, double rate, bool isDark) {
    final isCompleted = status == 'completed';
    final statusColor = isCompleted ? const Color(0xFFCCFF00) : const Color(0xFFFFB300);
    final statusLabel = isCompleted ? 'SETTLED' : (status == 'cancelled' ? 'CANCELLED' : 'PENDING');
    final amountText = isCompleted ? '+₹${rate.toInt()}' : '₹${rate.toInt()}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121622) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.25)),
            ),
            child: const Icon(Icons.sports_rounded, color: Color(0xFF00E5FF), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 2),
                Text(time,
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontSize: 12,
                    )),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amountText,
                style: TextStyle(
                  color: isCompleted ? const Color(0xFFCCFF00) : (isDark ? Colors.white70 : Colors.black87),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _EarningsHeroHeader extends StatelessWidget {
  final AsyncValue<CoachModel> coachAsync;
  final AsyncValue<QuerySnapshot<Map<String, dynamic>>> sessionsAsync;

  const _EarningsHeroHeader({
    required this.coachAsync,
    required this.sessionsAsync,
  });

  @override
  Widget build(BuildContext context) {
    final coach = coachAsync.asData?.value;
    final rate = coach?.hourlyRate ?? 0;
    final sessionsSnap = sessionsAsync.asData?.value;
    final completedCount = sessionsSnap?.docs
            .where((d) => d.data()['status'] == 'completed')
            .length ??
        0;
    final totalEarnings = completedCount * rate;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 190),
      decoration: BoxDecoration(
        color: const Color(0xFF090B10),
        image: const DecorationImage(
          image: AssetImage('assets/backgrounds/stadium_floodlights.jpg'),
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFCCFF00).withValues(alpha: 0.25),
            width: 1,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.5),
              const Color(0xFF090B10).withValues(alpha: 0.88),
              const Color(0xFF090B10),
            ],
            stops: const [0.0, 0.65, 1.0],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCCFF00).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFCCFF00).withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFFCCFF00),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'FINANCIAL TELEMETRY',
                        style: TextStyle(
                          color: Color(0xFFCCFF00),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: const Text(
                    'DIRECT RECONCILIATION',
                    style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '₹${totalEarnings.toInt()}',
              style: const TextStyle(
                color: Color(0xFFCCFF00),
                fontSize: 34,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Gross Coaching Income (Settled)',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$completedCount sessions completed at ₹${rate.toInt()}/hr',
                    style: const TextStyle(color: Colors.white60, fontSize: 11),
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
