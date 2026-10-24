import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/radius/radius.dart';
import '../../../../design_system/spacing/spacing_scale.dart';
import '../../../../design_system/typography/text_styles.dart';
import '../../../../design_system/layouts/premium_shell.dart';
import '../../../../models/coach_model.dart';
import '../../../../models/user_model.dart';
import '../../../../services/providers.dart';
import '../../../../features/home/presentation/workspace_destinations.dart';

class CoachHomeView extends ConsumerStatefulWidget {
  const CoachHomeView({
    super.key,
    required this.user,
    required this.destinations,
  });

  final UserModel user;
  final List<WorkspaceDestination> destinations;

  @override
  ConsumerState<CoachHomeView> createState() => _CoachHomeViewState();
}

class _CoachHomeViewState extends ConsumerState<CoachHomeView> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final coachAsync = ref.watch(coachProvider(widget.user.uid));
    final sessionsAsync = ref.watch(coachSessionsProvider(widget.user.uid));
    final pendingAsync = ref.watch(pendingBookingsProvider(widget.user.uid));

    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final subColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Welcome & Status Header
                _buildHeader(isDark, textColor, subColor, coachAsync),
                const SizedBox(height: SpacingScale.s20),

                // 2. Urgent Pending Requests Alert (if any)
                _buildPendingRequestsBanner(isDark, textColor, subColor, pendingAsync),
                _buildRoutineConfigurationBanner(isDark, textColor, subColor, coachAsync),

                // 3. Operational Domain KPIs Row
                _buildKpiMetrics(isDark, textColor, subColor, sessionsAsync, pendingAsync),
                const SizedBox(height: SpacingScale.s28),

                // 4. Interactive Timetable Header & Day Selector Strip
                _buildTimetableHeader(isDark, textColor, subColor),
                const SizedBox(height: SpacingScale.s12),
                _buildDateStrip(isDark),
                const SizedBox(height: SpacingScale.s16),

                // 5. Real-Time Interactive Timetable
                _buildInteractiveTimetable(isDark, textColor, subColor, sessionsAsync),
                const SizedBox(height: SpacingScale.s32),

                // 6. Quick Coaching Actions Grid
                _buildQuickActions(isDark, textColor, subColor),
                const SizedBox(height: SpacingScale.s40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(
    bool isDark,
    Color textColor,
    Color subColor,
    AsyncValue<CoachModel> coachAsync,
  ) {
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'GOOD MORNING'
        : now.hour < 17
            ? 'GOOD AFTERNOON'
            : 'GOOD EVENING';

    final rating = coachAsync.value?.rating ?? 4.9;
    final specialization = coachAsync.value?.specialization ?? 'Sports Coach';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF131D31),
                  const Color(0xFF0F172A),
                  AppColors.surfaceSecondary,
                ]
              : [
                  const Color(0xFFF0F7FF),
                  Colors.white,
                  AppColors.lightSurfaceSecondary,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.primary.withValues(alpha: 0.28) : AppColors.primary.withValues(alpha: 0.15),
          width: 1.2,
        ),
        boxShadow: [
          if (isDark)
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            )
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: isDark ? 0.28 : 0.12,
                child: Image.asset(
                  'assets/backgrounds/coach_hero_bg.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
            ),
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(SpacingScale.s20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF06B6D4)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/avatars/coach_default.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Text(
                                widget.user.name.isNotEmpty ? widget.user.name[0].toUpperCase() : 'C',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              greeting,
                              style: const TextStyle(
                                color: AppColors.emeraldLight,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Coach ${widget.user.name}',
                              style: AppTextStyles.title1.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B).withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                                      const SizedBox(width: 3),
                                      Text(
                                        rating.toStringAsFixed(1),
                                        style: const TextStyle(
                                          color: Color(0xFFF59E0B),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.surfaceElevated : AppColors.lightSurfaceSecondary,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isDark ? AppColors.border : AppColors.lightBorder,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Text(
                                    specialization,
                                    style: TextStyle(
                                      color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SpacingScale.s16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF090D16) : Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.emerald,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.emerald,
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'PRO COMMAND CENTER',
                            style: TextStyle(
                              color: isDark ? AppColors.emeraldLight : AppColors.emerald,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('MMM d').format(DateTime.now()),
                          style: TextStyle(
                            color: subColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => WorkspaceNavigation.go(context, 1),
                          icon: const Icon(Icons.inbox_rounded, size: 16),
                          label: Text(
                            widget.destinations.length > 1 ? widget.destinations[1].label : 'Requests',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(width: SpacingScale.s10),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: textColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(
                              color: isDark ? AppColors.border : AppColors.lightBorder,
                              width: 1,
                            ),
                            backgroundColor: isDark ? AppColors.surfaceElevated : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => WorkspaceNavigation.go(context, 2),
                          icon: const Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.primary),
                          label: Text(
                            widget.destinations.length > 2 ? widget.destinations[2].label : 'Schedule',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  

  Widget _buildRoutineConfigurationBanner(
    bool isDark,
    Color textColor,
    Color subColor,
    AsyncValue<CoachModel> coachAsync,
  ) {
    final coach = coachAsync.value;
    if (coach == null || coach.hasConfiguredRoutines) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: SpacingScale.s20),
      padding: const EdgeInsets.all(SpacingScale.s16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0x2D1515) : const Color(0xFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.danger.withValues(alpha: 0.5),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Action Required: Training Routines Setup',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0x991B1B),
                      ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'MANDATORY',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Your profile is currently incomplete and player bookings are disabled until you configure your training routines and 100% kRICO XP allocations.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: isDark ? const Color(0xFCA5A5) : const Color(0x7F1D1D),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () => context.push('/coach-training-routines/' + coach.coachId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  icon: const Icon(Icons.fitness_center_rounded, size: 14),
                  label: const Text(
                    'Setup Training Routines & XP',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingRequestsBanner(
    bool isDark,
    Color textColor,
    Color subColor,
    AsyncValue<QuerySnapshot<Map<String, dynamic>>> pendingAsync,
  ) {
    return pendingAsync.when(
      data: (snap) {
        if (snap.docs.isEmpty) return const SizedBox.shrink();
        final count = snap.docs.length;
        final firstDoc = snap.docs.first.data();
        final firstId = snap.docs.first.id;
        final sport = firstDoc['sport'] as String? ?? 'Training Session';
        final dateTime = (firstDoc['dateTime'] as Timestamp?)?.toDate();

        return Container(
          margin: const EdgeInsets.only(bottom: SpacingScale.s20),
          padding: const EdgeInsets.all(SpacingScale.s16),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: isDark ? 0.14 : 0.1),
            borderRadius: AppRadius.brXl2,
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications_active_rounded,
                        color: AppColors.warning, size: 20),
                  ),
                  const SizedBox(width: SpacingScale.s10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$count Pending Booking Request${count > 1 ? 's' : ''}',
                          style: AppTextStyles.title3.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (dateTime != null)
                          Text(
                            '$sport • ${DateFormat('MMM d, hh:mm a').format(dateTime)}',
                            style: AppTextStyles.caption.copyWith(color: subColor),
                          ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/booking-requests', extra: widget.user.uid),
                    child: Text(
                      'View All ($count)',
                      style: AppTextStyles.buttonSm.copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpacingScale.s12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
                      ),
                      onPressed: () async {
                        await ref
                            .read(coachServiceProvider)
                            .respondToBooking(firstId, 'confirmed');
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Booking accepted and session confirmed!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text('Accept Latest'),
                    ),
                  ),
                  const SizedBox(width: SpacingScale.s8),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
                      side: BorderSide(color: isDark ? AppColors.border : AppColors.lightBorder),
                    ),
                    onPressed: () => context.push('/booking-requests', extra: widget.user.uid),
                    child: Text('Review Details', style: AppTextStyles.buttonSm),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.05, end: 0);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildKpiMetrics(
    bool isDark,
    Color textColor,
    Color subColor,
    AsyncValue<QuerySnapshot<Map<String, dynamic>>> sessionsAsync,
    AsyncValue<QuerySnapshot<Map<String, dynamic>>> pendingAsync,
  ) {
    return sessionsAsync.when(
      data: (snap) {
        final now = DateTime.now();
        final todaySessions = snap.docs.where((d) {
          final time = (d.data()['dateTime'] as Timestamp?)?.toDate();
          return time != null && DateUtils.isSameDay(time, now);
        }).toList();

        final pendingCount = pendingAsync.value?.docs.length ?? 0;

        final uniqueStudents = snap.docs
            .map((d) => d.data()['playerId'] as String?)
            .where((id) => id != null && id.isNotEmpty)
            .toSet()
            .length;

        double todayEarnings = 0;
        for (final doc in todaySessions) {
          final data = doc.data();
          todayEarnings += (data['price'] as num?)?.toDouble() ?? 0;
        }

        return LayoutBuilder(builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 600;
          return GridView.count(
            crossAxisCount: isNarrow ? 2 : 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: isNarrow ? 1.45 : 1.35,
            children: [
              _kpiCard(
                isDark: isDark,
                icon: Icons.calendar_today_rounded,
                color: AppColors.primary,
                title: "TODAY'S SESSIONS",
                value: '${todaySessions.length}',
                subtitle: todaySessions.isEmpty ? 'Free day' : 'Active today',
                onTap: () {
                  setState(() => _selectedDate = DateTime.now());
                },
              ),
              _kpiCard(
                isDark: isDark,
                icon: Icons.pending_actions_rounded,
                color: pendingCount > 0 ? const Color(0xFFF59E0B) : AppColors.emerald,
                title: 'PENDING REQUESTS',
                value: '$pendingCount',
                subtitle: pendingCount > 0 ? 'Needs response' : 'All clear',
                onTap: () => context.push('/booking-requests', extra: widget.user.uid),
              ),
              _kpiCard(
                isDark: isDark,
                icon: Icons.groups_rounded,
                color: const Color(0xFF8B5CF6),
                title: 'ACTIVE ATHLETES',
                value: '$uniqueStudents',
                subtitle: 'Total roster',
                onTap: () => WorkspaceNavigation.go(context, 3),
              ),
              _kpiCard(
                isDark: isDark,
                icon: Icons.currency_rupee_rounded,
                color: AppColors.emerald,
                title: "TODAY'S VALUE",
                value: '₹${todayEarnings.toInt()}',
                subtitle: 'Session billing',
                onTap: () => WorkspaceNavigation.go(context, 5),
              ),
            ],
          );
        });
      },
      loading: () => LayoutBuilder(builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        return GridView.count(
          crossAxisCount: isNarrow ? 2 : 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: isNarrow ? 1.45 : 1.35,
          children: List.generate(4, (_) => Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131722) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF222A3B) : AppColors.lightBorder,
                width: 0.8,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 50,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          )),
        );
      }),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _kpiCard({
    required bool isDark,
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final cardBg = isDark ? const Color(0xFF131722) : Colors.white;
    final borderColor = isDark ? const Color(0xFF222A3B) : AppColors.lightBorder;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 0.8),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 14, color: color),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: AppTextStyles.heading2.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimetableHeader(bool isDark, Color textColor, Color subColor) {
    final isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());
    final label = isToday ? "Today's Schedule" : DateFormat('EEE, MMM d').format(_selectedDate);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: SpacingScale.s10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.title2.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Court timetable & player bookings',
                style: AppTextStyles.captionXs.copyWith(color: subColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => context.push('/manage-availability', extra: widget.user.uid),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? AppColors.border : AppColors.lightBorder,
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.tune_rounded, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  'Slots',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateStrip(bool isDark) {
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.add(Duration(days: i)));

    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final d = days[i];
          final isSelected = DateUtils.isSameDay(d, _selectedDate);
          final isToday = i == 0;

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = d),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected
                    ? null
                    : (isDark ? const Color(0xFF131722) : Colors.white),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF3B82F6)
                      : (isDark ? const Color(0xFF222A3B) : AppColors.lightBorder),
                  width: isSelected ? 1.5 : 0.8,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isToday ? 'TODAY' : DateFormat('EEE').format(d).toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('d').format(d),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInteractiveTimetable(
    bool isDark,
    Color textColor,
    Color subColor,
    AsyncValue<QuerySnapshot<Map<String, dynamic>>> sessionsAsync,
  ) {
    return sessionsAsync.when(
      data: (snap) {
        final selectedDaySessions = snap.docs.where((d) {
          final time = (d.data()['dateTime'] as Timestamp?)?.toDate();
          return time != null && DateUtils.isSameDay(time, _selectedDate);
        }).toList()
          ..sort((a, b) {
            final aTime = (a.data()['dateTime'] as Timestamp).toDate();
            final bTime = (b.data()['dateTime'] as Timestamp).toDate();
            return aTime.compareTo(bTime);
          });

        if (selectedDaySessions.isEmpty) {
          return _buildEmptyTimetable(isDark, textColor, subColor);
        }

        return Column(
          children: selectedDaySessions.asMap().entries.map((entry) {
            final idx = entry.key;
            final doc = entry.value;
            return _buildTimetableSlotCard(
              isDark: isDark,
              textColor: textColor,
              subColor: subColor,
              sessionId: doc.id,
              data: doc.data(),
              index: idx,
            );
          }).toList(),
        );
      },
      loading: () => _buildTimetableSkeleton(isDark),
      error: (e, _) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.1),
          borderRadius: AppRadius.brLg,
        ),
        child: Text('Error loading schedule: $e'),
      ),
    );
  }

  Widget _buildTimetableSkeleton(bool isDark) {
    final baseColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    return Column(
      children: List.generate(2, (i) => Container(
        height: 110,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131722) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF222A3B) : const Color(0xFFE2E8F0),
            width: 0.8,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 60,
              decoration: BoxDecoration(
                color: baseColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 16,
                    decoration: BoxDecoration(
                      color: baseColor.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 90,
                    height: 12,
                    decoration: BoxDecoration(
                      color: baseColor.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate(onPlay: (controller) => controller.repeat(reverse: true)).fade(begin: 0.4, end: 0.85, duration: 800.ms)),
    );
  }

  Widget _buildEmptyTimetable(bool isDark, Color textColor, Color subColor) {
    final isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131722) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF222A3B) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/animations/calendar_empty.gif',
              width: 68,
              height: 68,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      AppColors.primary.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.sports_tennis_rounded,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isToday ? 'CALENDAR OPEN' : 'AVAILABLE DAY',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isToday ? 'No sessions booked for today' : 'No bookings on this day',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Text(
              isToday
                  ? 'Your court calendar is free. Log a private walk-in training or open additional time slots.'
                  : 'Share your profile with student athletes or customize slots for this day.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: subColor,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              InkWell(
                onTap: () => context.push('/create-session'),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, size: 16, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'Add Walk-in Session',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () => context.push('/manage-availability', extra: widget.user.uid),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit_calendar_rounded,
                        size: 16,
                        color: textColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Manage Availability',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimetableSlotCard({
    required bool isDark,
    required Color textColor,
    required Color subColor,
    required String sessionId,
    required Map<String, dynamic> data,
    required int index,
  }) {
    final dateTime = (data['dateTime'] as Timestamp).toDate();
    final sport = data['sport'] as String? ?? 'General Training';
    final status = data['status'] as String? ?? 'booked';
    final venue = data['venue'] as String? ?? 'Home Turf / Field';
    final price = (data['price'] as num?)?.toDouble() ?? 0;

    final now = DateTime.now();
    final endEstimate = dateTime.add(const Duration(minutes: 60));
    final isLiveNow = now.isAfter(dateTime) && now.isBefore(endEstimate);
    final isPast = now.isAfter(endEstimate);

    Color statusColor;
    String statusText;
    if (status == 'completed') {
      statusColor = AppColors.success;
      statusText = 'Completed';
    } else if (status == 'checked_in' || isLiveNow) {
      statusColor = const Color(0xFF10B981);
      statusText = 'LIVE ON COURT';
    } else if (status == 'cancelled') {
      statusColor = AppColors.danger;
      statusText = 'Cancelled';
    } else if (isPast) {
      statusColor = AppColors.warning;
      statusText = 'Needs Attendance';
    } else {
      statusColor = AppColors.primary;
      statusText = 'Upcoming';
    }

    final timeString = DateFormat('hh:mm a').format(dateTime);
    final endTimeString = DateFormat('hh:mm a').format(endEstimate);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131722) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isLiveNow
              ? const Color(0xFF10B981)
              : (isDark ? const Color(0xFF222A3B) : const Color(0xFFE2E8F0)),
          width: isLiveNow ? 1.5 : 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            if (isLiveNow)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF059669), Color(0xFF10B981)],
                  ),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        'assets/animations/live_pulse.gif',
                        width: 14,
                        height: 14,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.bolt_rounded, size: 16, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'SESSION IN PROGRESS RIGHT NOW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Ends $endTimeString',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time block
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                            width: 0.8,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              timeString,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              endTimeString,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: subColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: statusColor.withValues(alpha: 0.3),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    statusText.toUpperCase(),
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                if (price > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '₹${price.toInt()}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF10B981),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    _getSportAsset(sport),
                                    width: 36,
                                    height: 36,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.sports, size: 18, color: AppColors.primary),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        sport,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: textColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on_outlined, size: 13, color: subColor),
                                          const SizedBox(width: 3),
                                          Expanded(
                                            child: Text(
                                              venue,
                                              style: TextStyle(fontSize: 12, color: subColor),
                                              overflow: TextOverflow.ellipsis,
                                            ),
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
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Divider(
                    height: 1,
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (status != 'completed') ...[
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              await ref.read(coachServiceProvider).checkOutSession(sessionId);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.asset(
                                            'assets/animations/success_check.gif',
                                            width: 22,
                                            height: 22,
                                            fit: BoxFit.contain,
                                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        const Expanded(
                                          child: Text('Attendance marked and session completed!'),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle_outline_rounded, size: 15, color: Color(0xFF10B981)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Mark Complete',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: InkWell(
                          onTap: () => context.push('/session/$sessionId'),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.25),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.launch_rounded, size: 15, color: Colors.white),
                                SizedBox(width: 6),
                                Text(
                                  'View Session',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => context.push('/chat'),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                              width: 0.8,
                            ),
                          ),
                          child: Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 16,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms, duration: 250.ms);
  }

  Widget _buildQuickActions(bool isDark, Color textColor, Color subColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'COACH ACTIONS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: subColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Quick Operations',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: textColor,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(builder: (context, constraints) {
          final columns = constraints.maxWidth >= 720 ? 4 : 2;
          final width = (constraints.maxWidth - (columns - 1) * 12) / columns;

          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              
              _actionCard(
                width: width,
                isDark: isDark,
                icon: Icons.fitness_center_rounded,
                accentColor: AppColors.primary,
                title: 'Training Routines & XP',
                subtitle: 'Manage 100% routines',
                onTap: () => context.push('/coach-training-routines/' + widget.user.uid),
              ),
_actionCard(
                width: width,
                isDark: isDark,
                icon: Icons.add_circle_outline_rounded,
                accentColor: const Color(0xFF3B82F6),
                title: 'Add Walk-in',
                subtitle: 'Record private training',
                onTap: () => context.push('/create-session'),
              ),
              _actionCard(
                width: width,
                isDark: isDark,
                icon: Icons.edit_calendar_rounded,
                accentColor: const Color(0xFF10B981),
                title: 'Availability',
                subtitle: 'Adjust daily booking slots',
                onTap: () => context.push('/manage-availability', extra: widget.user.uid),
              ),
              _actionCard(
                width: width,
                isDark: isDark,
                icon: Icons.groups_rounded,
                accentColor: const Color(0xFF8B5CF6),
                title: 'Player Roster',
                subtitle: 'Track athlete progress notes',
                onTap: () => WorkspaceNavigation.go(context, 3), // Students tab
              ),
              _actionCard(
                width: width,
                isDark: isDark,
                icon: Icons.account_balance_wallet_outlined,
                accentColor: const Color(0xFFF59E0B),
                title: 'Earnings & Escrow',
                subtitle: 'Check revenue & payouts',
                onTap: () => WorkspaceNavigation.go(context, 5), // Earnings tab
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _actionCard({
    required double width,
    required bool isDark,
    required IconData icon,
    required Color accentColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final cardBg = isDark ? const Color(0xFF131722) : Colors.white;
    final borderColor = isDark ? const Color(0xFF222A3B) : const Color(0xFFE2E8F0);
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final subColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor, width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accentColor.withValues(alpha: 0.22),
                            accentColor.withValues(alpha: 0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      child: Icon(icon, color: accentColor, size: 20),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: subColor.withValues(alpha: 0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: subColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getSportAsset(String sport) {
    final s = sport.toLowerCase();
    if (s.contains('badminton')) return 'assets/images/sports/badminton.jpg';
    if (s.contains('football') || s.contains('soccer')) return 'assets/images/sports/football.jpg';
    if (s.contains('basketball')) return 'assets/images/sports/basketball.webp';
    if (s.contains('tennis')) return 'assets/images/sports/tennis.jpg';
    return 'assets/images/sports/badminton.jpg';
  }
}

