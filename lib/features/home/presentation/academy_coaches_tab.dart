import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
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
    final coachesAsync = ref.watch(academyCoachesProvider(widget.academyId));
    final allCoachesAsync = ref.watch(coachesStreamProvider);
    final invitationsAsync = ref.watch(academyInvitationsProvider(widget.academyId));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Coaches'),
          bottom: const TabBar(
            indicatorColor: AppColors.accent,
            labelColor: AppColors.accent,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: 'My Coaches'),
              Tab(text: 'Find & Invite'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMyCoachesTab(coachesAsync),
            _buildFindCoachesTab(allCoachesAsync, invitationsAsync),
          ],
        ),
      ),
    );
  }

  Widget _buildMyCoachesTab(AsyncValue<QuerySnapshot<Map<String, dynamic>>> coachesAsync) {
    return coachesAsync.when(
      data: (snapshot) {
        final docs = snapshot.docs;
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sports_rounded, size: 64, color: AppColors.textDim),
                const SizedBox(height: 16),
                Text('No coaches yet', style: AppTextStyles.titleLarge.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Text('Invite coaches to your academy', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDim)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final d = docs[index].data();
            return _buildCoachCard(d).animate().fadeIn(
                duration: const Duration(milliseconds: 300),
                delay: Duration(milliseconds: index * 50));
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text('Failed to load coaches', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
          ],
        ),
      ),
    );
  }

  Widget _buildFindCoachesTab(AsyncValue<List<CoachModel>> allCoachesAsync, AsyncValue<QuerySnapshot<Map<String, dynamic>>> invitationsAsync) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Search by name, sport, location...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDim),
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textDim, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: AppColors.textDim, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surfaceMid,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.borderLight)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                      Icon(Icons.person_search_rounded, size: 48, color: AppColors.textDim),
                      const SizedBox(height: 12),
                      Text(_searchQuery.isNotEmpty ? 'No coaches match your search' : 'No coaches registered yet',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final coach = filtered[index];
                  return _buildDiscoverCoachCard(coach, invitationsAsync).animate().fadeIn(
                      duration: const Duration(milliseconds: 300),
                      delay: Duration(milliseconds: index * 50));
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Failed to load coaches', style: TextStyle(color: AppColors.error))),
          ),
        ),
      ],
    );
  }

  Widget _buildCoachCard(Map<String, dynamic> d) {
    final name = d['name'] as String? ?? 'Unknown Coach';
    final specialization = d['specialization'] as String?;
    final rating = (d['rating'] as num?)?.toDouble() ?? 0;
    final isVerified = d['isVerified'] as bool? ?? false;
    final hourlyRate = (d['hourlyRate'] as num?)?.toDouble() ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.person_rounded, color: AppColors.accent, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600)),
                    if (isVerified) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.verified_rounded, size: 14, color: AppColors.primary),
                    ],
                  ],
                ),
                if (specialization != null && specialization.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(specialization, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                  ),
              ],
            ),
          ),
          if (rating > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_rounded, size: 12, color: AppColors.gold),
                  const SizedBox(width: 2),
                  Text(rating.toStringAsFixed(1), style: AppTextStyles.labelSmall.copyWith(color: AppColors.gold, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          if (hourlyRate > 0) ...[
            const SizedBox(width: 8),
            Text('₹${hourlyRate.toInt()}/hr', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          ],
        ],
      ),
    );
  }

  Widget _buildDiscoverCoachCard(CoachModel coach, AsyncValue<QuerySnapshot<Map<String, dynamic>>> invitationsAsync) {
    final initials = coach.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();

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

    final colorSeed = coach.coachId.hashCode.abs() % Colors.primaries.length;
    final color = Colors.primaries[colorSeed];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(initials, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(coach.name, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (coach.specialization != null) ...[
                      Text(coach.specialization!, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 10)),
                      const SizedBox(width: 6),
                    ],
                    if (coach.city != null) ...[
                      Icon(Icons.location_on_rounded, size: 10, color: AppColors.textDim),
                      const SizedBox(width: 2),
                      Text(coach.city!, style: AppTextStyles.caption.copyWith(color: AppColors.textDim, fontSize: 10)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          alreadyInvited
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _inviteStatusColor(inviteStatus).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    inviteStatus != null ? _capitalize(inviteStatus) : 'Invited',
                    style: TextStyle(color: _inviteStatusColor(inviteStatus), fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                )
              : SizedBox(
                  height: 32,
                  child: GradientButton(
                    onPressed: () => _sendInvite(coach),
                    height: 32,
                    borderRadius: 8,
                    child: const Text('Invite', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ),
        ],
      ),
    );
  }

  Color _inviteStatusColor(String? status) {
    switch (status) {
      case 'pending': return AppColors.warning;
      case 'accepted': return AppColors.success;
      case 'declined': return AppColors.error;
      default: return AppColors.textSecondary;
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return '${s[0].toUpperCase()}${s.substring(1)}';
  }

  void _sendInvite(CoachModel coach) {
    final service = ref.read(academyServiceProvider);
    service.sendCoachInvitation(
      academyId: widget.academyId,
      academyName: 'Academy',
      coachId: coach.coachId,
      coachEmail: coach.email,
      coachName: coach.name,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Invitation sent to ${coach.name}'), backgroundColor: AppColors.success),
    );
  }
}
