import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../services/providers.dart';

class CoachOffersScreen extends ConsumerWidget {
  final String coachId;
  const CoachOffersScreen({super.key, required this.coachId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final invitationsAsync = ref.watch(coachInvitationsProvider(coachId));

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090B10) : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _CoachOffersHeroHeader(invitationsAsync: invitationsAsync),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                invitationsAsync.when(
                  data: (snapshot) {
                    final docs = snapshot.docs;
                    if (docs.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(SpacingScale.s40),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF121622) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: const Color(0xFFCCFF00).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.mail_outline_rounded,
                                  size: 32, color: Color(0xFFCCFF00)),
                            ),
                            const SizedBox(height: SpacingScale.s16),
                            Text('No Academy Offers Yet',
                                style: AppTextStyles.title3.copyWith(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.w700,
                                )),
                            const SizedBox(height: SpacingScale.s4),
                            Text('When academies scout your coaching profile, formal recruitment offers will appear here',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodySm.copyWith(
                                  color: isDark ? Colors.white60 : Colors.black54,
                                )),
                          ],
                        ),
                      );
                    }
                    return Column(
                      children: docs.asMap().entries.map((entry) {
                        final index = entry.key;
                        final doc = entry.value;
                        return _OfferCard(
                          invitationId: doc.id,
                          data: doc.data(),
                          coachId: coachId,
                          isDark: isDark,
                        )
                            .animate()
                            .fadeIn(delay: (index * 50).ms, duration: 320.ms)
                            .slideY(begin: 0.04, end: 0);
                      }).toList(),
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(SpacingScale.s40),
                      child: CircularProgressIndicator(color: Color(0xFFCCFF00)),
                    ),
                  ),
                  error: (e, _) {
                    debugPrint('Coach offers error: $e');
                    return Container(
                      padding: const EdgeInsets.all(SpacingScale.s40),
                      child: Text('Unable to load offers right now.',
                          style: AppTextStyles.body.copyWith(color: AppColors.danger)),
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
}

class _OfferCard extends ConsumerWidget {
  final String invitationId;
  final Map<String, dynamic> data;
  final String coachId;
  final bool isDark;

  const _OfferCard({
    required this.invitationId,
    required this.data,
    required this.coachId,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = data['status'] as String? ?? 'pending';
    final createdAt = data['createdAt'] as Timestamp?;
    final timeStr = createdAt != null ? _formatDate(createdAt.toDate()) : '';
    final role = data['role'] as String? ?? 'Head Coach Position';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121622) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: status == 'pending'
              ? const Color(0xFFCCFF00).withValues(alpha: 0.4)
              : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFCCFF00).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCCFF00).withValues(alpha: 0.25)),
                ),
                child: const Icon(Icons.school_rounded, color: Color(0xFFCCFF00), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _academyName,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      role,
                      style: const TextStyle(
                        color: Color(0xFF00E5FF),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (timeStr.isNotEmpty)
                      Text(
                        'Sent $timeStr',
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black45,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              _buildStatusBadge(status),
            ],
          ),
          if (status == 'pending') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => _accept(context, ref),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFCCFF00), Color(0xFF88FF00)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFCCFF00).withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_rounded, size: 16, color: Colors.black),
                            SizedBox(width: 6),
                            Text(
                              'Accept Contract',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => _decline(context, ref),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.danger.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cancel_rounded, size: 16, color: AppColors.danger),
                            const SizedBox(width: 6),
                            Text(
                              'Decline',
                              style: TextStyle(
                                color: AppColors.danger,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;
    String label;
    switch (status) {
      case 'accepted':
        color = const Color(0xFFCCFF00);
        icon = Icons.check_circle_rounded;
        label = 'ACCEPTED';
        break;
      case 'declined':
        color = AppColors.danger;
        icon = Icons.cancel_rounded;
        label = 'DECLINED';
        break;
      default:
        color = const Color(0xFFFFB300);
        icon = Icons.hourglass_empty_rounded;
        label = 'OFFER PENDING';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  String get _academyName => data['academyName'] as String? ?? 'An Academy';

  void _accept(BuildContext context, WidgetRef ref) {
    final academyId = data['academyId'] as String?;
    if (academyId == null) return;
    ref.read(academyServiceProvider).acceptInvitation(invitationId, coachId, academyId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Accepted offer from $_academyName'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _decline(BuildContext context, WidgetRef ref) {
    ref.read(academyServiceProvider).declineInvitation(invitationId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Declined offer from $_academyName'),
        backgroundColor: AppColors.danger,
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _CoachOffersHeroHeader extends StatelessWidget {
  final AsyncValue<dynamic> invitationsAsync;
  const _CoachOffersHeroHeader({required this.invitationsAsync});

  @override
  Widget build(BuildContext context) {
    final docs = invitationsAsync.asData?.value?.docs ?? [];
    final pendingCount = docs.where((d) => (d.data() as Map<String, dynamic>)['status'] == 'pending').length;
    final acceptedCount = docs.where((d) => (d.data() as Map<String, dynamic>)['status'] == 'accepted').length;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 180),
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
                        'DIRECT RECRUITMENT OFFERS',
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
                    'HEADHUNTING DISPATCH',
                    style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Academy Offers',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Direct coaching contracts and invitations extended to you by sports academies',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                _buildStatPill('PENDING OFFERS', '$pendingCount', const Color(0xFFFFB300)),
                _buildStatPill('ACCEPTED CONTRACTS', '$acceptedCount', const Color(0xFFCCFF00)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatPill(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w900),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
