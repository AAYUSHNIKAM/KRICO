import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/utils/extensions.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../models/coach_model.dart';
import '../../../services/providers.dart';

class AcademyCoachesTab extends ConsumerStatefulWidget {
  final String academyId;
  const AcademyCoachesTab({super.key, required this.academyId});

  @override
  ConsumerState<AcademyCoachesTab> createState() => _AcademyCoachesTabState();
}

class _AcademyCoachesTabState extends ConsumerState<AcademyCoachesTab> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final coachesAsync = ref.watch(academyCoachesProvider(widget.academyId));
    final allCoachesAsync = ref.watch(coachesStreamProvider);
    final invitationsAsync = ref.watch(academyInvitationsProvider(widget.academyId));
    final horizontalPadding = context.width > 1280 ? SpacingScale.s24 : SpacingScale.s16;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF090B10) : AppColors.lightBackground,
        body: Column(
          children: [
            _AcademyCoachesHeroHeader(coachesAsync: coachesAsync),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF101420) : Colors.grey.shade100,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
                  ),
                ),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00E5FF), Color(0xFF0088FF)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.black,
                unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
                labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Academy Staff Roster'),
                  Tab(text: 'Global Coach Scout & Invite'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildMyCoachesTab(coachesAsync, horizontalPadding),
                  _buildFindCoachesTab(allCoachesAsync, invitationsAsync, horizontalPadding),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyCoachesTab(
      AsyncValue<QuerySnapshot<Map<String, dynamic>>> coachesAsync, double horizontalPadding) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return coachesAsync.when(
      data: (snapshot) {
        final docs = snapshot.docs;
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.sports_rounded, size: 32, color: Color(0xFF00E5FF)),
                ),
                const SizedBox(height: SpacingScale.s16),
                Text(
                  'No Coaches on Academy Roster',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Use the Scout tab to invite certified coaches to your academy',
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.all(horizontalPadding),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final d = docs[index].data();
            return _buildCoachCard(d)
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 300), delay: Duration(milliseconds: index * 40));
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF))),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: AppColors.danger),
            const SizedBox(height: SpacingScale.s12),
            Text('Failed to load coaching roster', style: TextStyle(color: AppColors.danger)),
          ],
        ),
      ),
    );
  }

  Widget _buildFindCoachesTab(
    AsyncValue<List<CoachModel>> allCoachesAsync,
    AsyncValue<QuerySnapshot<Map<String, dynamic>>> invitationsAsync,
    double horizontalPadding,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(horizontalPadding, 14, horizontalPadding, 10),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: 'Search by coach name, sport, or city...',
              hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13),
              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF00E5FF), size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear_rounded, color: isDark ? Colors.white54 : Colors.black54, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: isDark ? const Color(0xFF141926) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF00E5FF)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
        Expanded(
          child: allCoachesAsync.when(
            data: (allCoaches) {
              final filtered = allCoaches.where((c) {
                if (_searchQuery.isEmpty) return true;
                return c.name.toLowerCase().contains(_searchQuery) ||
                    (c.specialization?.toLowerCase().contains(_searchQuery) ?? false) ||
                    (c.city?.toLowerCase().contains(_searchQuery) ?? false);
              }).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_search_rounded,
                          size: 48, color: isDark ? Colors.white24 : Colors.black26),
                      const SizedBox(height: SpacingScale.s12),
                      Text(
                        _searchQuery.isNotEmpty ? 'No coaches match your search criteria' : 'No coaches registered yet',
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, SpacingScale.s16),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final coach = filtered[index];
                  return _buildDiscoverCoachCard(coach, invitationsAsync).animate().fadeIn(
                      duration: const Duration(milliseconds: 300), delay: Duration(milliseconds: index * 40));
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF))),
            error: (e, _) => Center(
              child: Text('Failed to load coaches', style: TextStyle(color: AppColors.danger)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoachCard(Map<String, dynamic> d) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = d['name'] as String? ?? 'Unknown Coach';
    final specialization = d['specialization'] as String?;
    final rating = (d['rating'] as num?)?.toDouble() ?? 0;
    final isVerified = d['isVerified'] as bool? ?? false;
    final hourlyRate = (d['hourlyRate'] as num?)?.toDouble() ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.25)),
            ),
            child: const Icon(Icons.person_rounded, color: Color(0xFF00E5FF), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isVerified) ...[
                      const SizedBox(width: 5),
                      const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF00E5FF)),
                    ],
                  ],
                ),
                if (specialization != null && specialization.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      specialization,
                      style: const TextStyle(
                        color: Color(0xFFCCFF00),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (rating > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB300).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, size: 13, color: Color(0xFFFFB300)),
                  const SizedBox(width: 3),
                  Text(
                    rating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Color(0xFFFFB300),
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          if (hourlyRate > 0) ...[
            const SizedBox(width: 8),
            Text(
              '₹${hourlyRate.toInt()}/hr',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDiscoverCoachCard(
      CoachModel coach, AsyncValue<QuerySnapshot<Map<String, dynamic>>> invitationsAsync) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initials =
        coach.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();

    bool alreadyInvited = false;
    String? inviteStatus;
    if (invitationsAsync.hasValue) {
      final invites = invitationsAsync.value!.docs;
      for (final inv in invites) {
        final invData = inv.data();
        if (invData['coachId'] == coach.coachId) {
          alreadyInvited = true;
          inviteStatus = invData['status'] as String?;
          break;
        }
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00E5FF), Color(0xFF0088FF)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        coach.name,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (coach.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified_rounded, size: 13, color: Color(0xFF00E5FF)),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Wrap(
                  spacing: 6,
                  runSpacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (coach.specialization != null)
                      Text(
                        coach.specialization!,
                        style: const TextStyle(
                          color: Color(0xFF00E5FF),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (coach.city != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on_rounded, size: 11, color: isDark ? Colors.white54 : Colors.black45),
                          const SizedBox(width: 2),
                          Text(
                            coach.city!,
                            style: TextStyle(
                              color: isDark ? Colors.white54 : Colors.black45,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          alreadyInvited
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _inviteStatusColor(inviteStatus, isDark).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _inviteStatusColor(inviteStatus, isDark).withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    inviteStatus != null ? _capitalize(inviteStatus).toUpperCase() : 'INVITED',
                    style: TextStyle(
                      color: _inviteStatusColor(inviteStatus, isDark),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                )
              : MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => _sendInvite(coach),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFCCFF00), Color(0xFF88FF00)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFCCFF00).withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.send_rounded, size: 12, color: Colors.black),
                          SizedBox(width: 4),
                          Text(
                            'Invite',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Color _inviteStatusColor(String? status, bool isDark) {
    switch (status) {
      case 'pending':
        return const Color(0xFFFFB300);
      case 'accepted':
        return const Color(0xFFCCFF00);
      case 'declined':
        return AppColors.danger;
      default:
        return isDark ? Colors.white60 : Colors.black54;
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return '${s[0].toUpperCase()}${s.substring(1)}';
  }

  void _sendInvite(CoachModel coach) {
    final academy = ref.read(academyProvider(widget.academyId)).asData?.value;
    final academyName = academy?.name ?? 'Academy';
    final service = ref.read(academyServiceProvider);
    service.sendCoachInvitation(
      academyId: widget.academyId,
      academyName: academyName,
      coachId: coach.coachId,
      coachEmail: coach.email,
      coachName: coach.name,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Recruitment invitation dispatched to ${coach.name}'), backgroundColor: AppColors.success),
    );
  }
}

class _AcademyCoachesHeroHeader extends StatelessWidget {
  final AsyncValue<dynamic> coachesAsync;
  const _AcademyCoachesHeroHeader({required this.coachesAsync});

  @override
  Widget build(BuildContext context) {
    final totalStaff = coachesAsync.asData?.value?.docs?.length ?? 0;

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
            color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
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
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00E5FF),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'COACHING ROSTER & SCOUT',
                        style: TextStyle(
                          color: Color(0xFF00E5FF),
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
                    'FACILITY STAFFING',
                    style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Academy Coaches',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage current training faculty & scout certified freelance specialists',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$totalStaff',
                    style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'STAFF COACHES ENROLLED',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
