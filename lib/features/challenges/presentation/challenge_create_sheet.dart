import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/radius/radius.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../design_system/tokens/duration_tokens.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../models/user_model.dart';
import '../../../providers/profile_providers.dart';
import '../providers/challenges_providers.dart';

const List<String> _sports = [
  'Cricket',
  'Football',
  'Tennis',
  'Badminton',
  'Swimming',
  'Basketball',
];

const Map<String, String> _metrics = {
  'Cricket': 'Runs',
  'Football': 'Goals',
  'Tennis': 'Points',
  'Badminton': 'Points',
  'Swimming': 'Laps',
  'Basketball': 'Points',
};

/// Opens the create-challenge bottom sheet. The challenger is identified by
/// [challengerId]/[challengerName]; when [initialOpponent] is supplied the
/// sheet defaults to a 1v1 player challenge with that opponent pre-selected.
void showCreateChallengeSheet(
  BuildContext context,
  WidgetRef ref, {
  required String challengerId,
  required String challengerName,
  UserModel? initialOpponent,
}) {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final targetCtrl = TextEditingController();
  final rewardCtrl = TextEditingController();
  final opponentCtrl = TextEditingController();
  final membersCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final selectedNames = <String, String>{};

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      String challengeType = 'player';
      String selectedSport = _sports.first;
      String selectedMetric = _metrics[_sports.first]!;
      String? pickedOpponentId = initialOpponent?.uid;
      String? pickedOpponentName = initialOpponent?.name;
      if (initialOpponent != null) {
        opponentCtrl.text = initialOpponent.uid;
      }
      DateTime deadline = DateTime.now().add(const Duration(days: 30));

      Future<void> pickFromFollowers() async {
        final follower = await _showFollowersPicker(ctx, ref, challengerId);
        if (follower == null) return;
        if (challengeType == 'player') {
          opponentCtrl.text = follower.uid;
          pickedOpponentId = follower.uid;
          pickedOpponentName = follower.name;
        } else {
          membersCtrl.text = membersCtrl.text.trim().isEmpty
              ? follower.uid
              : '${membersCtrl.text.trim()}, ${follower.uid}';
          selectedNames[follower.uid] = follower.name;
        }
      }

      return StatefulBuilder(
        builder: (ctx, setSheetState) {
          final sheetDark = Theme.of(ctx).brightness == Brightness.dark;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 580),
              child: Container(
                height: MediaQuery.of(ctx).size.height * 0.88,
                decoration: BoxDecoration(
                  color: sheetDark ? AppColors.surface : AppColors.lightSurface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
            child: Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: sheetDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Create Challenge',
                        style: AppTextStyles.title1.copyWith(
                          fontWeight: FontWeight.w700,
                          color: sheetDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Challenge a player or your whole squad',
                        style: AppTextStyles.body.copyWith(
                          color: sheetDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _TypeChip(
                              label: '1v1 Player',
                              icon: Icons.sports_rounded,
                              selected: challengeType == 'player',
                              onTap: () => setSheetState(() {
                                challengeType = 'player';
                                pickedOpponentId = null;
                                pickedOpponentName = null;
                              }),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _TypeChip(
                              label: 'Squad Team',
                              icon: Icons.groups_rounded,
                              selected: challengeType == 'squad',
                              onTap: () => setSheetState(() {
                                challengeType = 'squad';
                                if (pickedOpponentId != null && membersCtrl.text.trim().isEmpty) {
                                  membersCtrl.text = pickedOpponentId!;
                                  selectedNames[pickedOpponentId!] =
                                      pickedOpponentName ?? pickedOpponentId!;
                                }
                              }),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(labelText: 'Challenge Title', hintText: '1000 Runs Sprint'),
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: 'Description', hintText: 'First to reach the target wins'),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedSport,
                        decoration: const InputDecoration(labelText: 'Sport', prefixIcon: Icon(Icons.sports_rounded)),
                        items: _sports
                            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setSheetState(() {
                              selectedSport = v;
                              selectedMetric = _metrics[v] ?? 'Points';
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: targetCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(labelText: 'Target $selectedMetric'),
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: rewardCtrl,
                              decoration: const InputDecoration(labelText: 'Reward', hintText: 'Free session'),
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (challengeType == 'player') ...[
                        Text(
                          'Opponent',
                          style: AppTextStyles.labelSm.copyWith(
                            color: sheetDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: opponentCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Opponent user ID',
                                  hintText: 'user_id',
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty) ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: pickFromFollowers,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: AppRadius.brLg,
                                ),
                                child: const Icon(Icons.person_search_rounded,
                                    color: AppColors.primary, size: 20),
                              ),
                            ),
                          ],
                        ),
                        if (pickedOpponentName != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                  size: 16, color: AppColors.success),
                              const SizedBox(width: 6),
                              Text(
                                'Opponent: $pickedOpponentName',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ] else ...[
                        TextFormField(
                          controller: membersCtrl,
                          decoration: InputDecoration(
                            labelText: 'Squad member IDs (comma-separated)',
                            hintText: 'user_id1, user_id2',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.person_add_alt_1_rounded),
                              color: AppColors.primary,
                              onPressed: pickFromFollowers,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Deadline',
                          style: AppTextStyles.body.copyWith(
                            color: sheetDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        subtitle: Text(
                          DateFormat('MMM d, yyyy').format(deadline),
                          style: AppTextStyles.bodySm.copyWith(
                            color: sheetDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        trailing: Icon(
                          Icons.calendar_today_rounded,
                          color: sheetDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: deadline,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) setSheetState(() => deadline = picked);
                        },
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () async {
                          if (!formKey.currentState!.validate()) return;
                          final participants = <String, String>{
                            challengerId: challengerName,
                          };
                          if (challengeType == 'player') {
                            final opponentId = opponentCtrl.text.trim();
                            final opponentName =
                                pickedOpponentId == opponentId && pickedOpponentName != null
                                    ? pickedOpponentName!
                                    : opponentId;
                            participants[opponentId] = opponentName;
                          } else {
                            final ids = membersCtrl.text
                                .split(',')
                                .map((e) => e.trim())
                                .where((e) => e.isNotEmpty)
                                .toList();
                            for (final id in ids) {
                              participants[id] = selectedNames[id] ?? id;
                            }
                          }
                          final service = ref.read(challengesServiceProvider);
                          try {
                            await service.createChallenge(
                              type: challengeType,
                              title: titleCtrl.text.trim(),
                              description: descCtrl.text.trim(),
                              sport: selectedSport,
                              metric: selectedMetric,
                              metricUnit: selectedMetric,
                              targetValue: int.tryParse(targetCtrl.text) ?? 0,
                              creatorId: challengerId,
                              reward: rewardCtrl.text.trim(),
                              participants: participants,
                              deadline: deadline,
                            );
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    challengeType == 'player'
                                        ? 'Challenge sent!'
                                        : 'Squad challenge created!',
                                  ),
                                  backgroundColor: AppColors.success,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                                ),
                              );
                            }
                          } catch (e) {
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to create challenge: $e'),
                                  backgroundColor: AppColors.danger,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                                ),
                              );
                            }
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: SpacingScale.s24, vertical: SpacingScale.s12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
                            borderRadius: AppRadius.brXl2,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Create Challenge',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
      );
    },
  );
}

Future<UserModel?> _showFollowersPicker(
    BuildContext context, WidgetRef ref, String userId) async {
  return showModalBottomSheet<UserModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final isDark = Theme.of(ctx).brightness == Brightness.dark;
      final followersStream =
          ref.read(profileServiceProvider).getFollowers(userId);
      return Container(
        height: MediaQuery.of(ctx).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : AppColors.lightSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(SpacingScale.s20),
              child: Row(
                children: [
                  Text('Pick from your followers',
                      style: AppTextStyles.heading3.copyWith(
                        color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                      )),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close_rounded,
                        color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: followersStream,
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final followers = snapshot.data ?? <UserModel>[];
                  if (followers.isEmpty) {
                    return Center(
                      child: Text('No followers yet',
                          style: AppTextStyles.body.copyWith(
                              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                        SpacingScale.s16, 0, SpacingScale.s16, SpacingScale.s24),
                    itemCount: followers.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, index) {
                      final person = followers[index];
                      return UserHeaderTile(
                        userId: person.uid,
                        name: person.name,
                        subtitle: '@${person.username}',
                        photoUrl: person.photoUrl,
                        onTap: () => Navigator.pop(ctx, person),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: DurationTokens.fast,
        padding: const EdgeInsets.symmetric(vertical: SpacingScale.s12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: AppRadius.brLg,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 18,
              color: selected ? AppColors.primary : AppColors.textSecondary),
          const SizedBox(width: SpacingScale.s8),
          Text(label,
              style: AppTextStyles.label.copyWith(
                color: selected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              )),
        ]),
      ),
    );
  }
}
