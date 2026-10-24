import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/radius/radius.dart';
import '../../../../design_system/spacing/spacing_scale.dart';
import '../../../../design_system/typography/text_styles.dart';
import '../../../../models/training_routine_model.dart';
import '../../../../core/gamification/krico_xp_system.dart';

class SessionRoutineProgressFormModal extends ConsumerStatefulWidget {
  final String sessionId;
  final String coachId;
  final String playerId;
  final String playerName;
  final int playerLevel;
  final bool isFinalCompletion;
  final Map<String, dynamic>? initialSavedProgress;

  const SessionRoutineProgressFormModal({
    super.key,
    required this.sessionId,
    required this.coachId,
    required this.playerId,
    required this.playerName,
    required this.playerLevel,
    this.isFinalCompletion = false,
    this.initialSavedProgress,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String sessionId,
    required String coachId,
    required String playerId,
    required String playerName,
    required int playerLevel,
    bool isFinalCompletion = false,
    Map<String, dynamic>? initialSavedProgress,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: !isFinalCompletion,
      isDismissible: !isFinalCompletion,
      builder: (context) => SessionRoutineProgressFormModal(
        sessionId: sessionId,
        coachId: coachId,
        playerId: playerId,
        playerName: playerName,
        playerLevel: playerLevel,
        isFinalCompletion: isFinalCompletion,
        initialSavedProgress: initialSavedProgress,
      ),
    );
  }

  @override
  ConsumerState<SessionRoutineProgressFormModal> createState() =>
      _SessionRoutineProgressFormModalState();
}

class _SessionRoutineProgressFormModalState
    extends ConsumerState<SessionRoutineProgressFormModal> {
  final _formKey = GlobalKey<FormState>();
  final Set<String> _completedSubRoutineIds = {};
  final Map<String, TextEditingController> _metricControllers = {};
  final TextEditingController _notesController = TextEditingController();

  List<TrainingSubRoutineModel> _subRoutines = [];
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadRoutineAndProgress();
  }

  @override
  void dispose() {
    for (final c in _metricControllers.values) {
      c.dispose();
    }
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadRoutineAndProgress() async {
    try {
      final coachDoc = await FirebaseFirestore.instance
          .collection('coaches')
          .doc(widget.coachId)
          .get();

      List<TrainingSubRoutineModel> loaded = [];
      if (coachDoc.exists) {
        final routinesData = coachDoc.data()?['routines'] as List<dynamic>?;
        if (routinesData != null && routinesData.isNotEmpty) {
          final firstRoutine = TrainingRoutineModel.fromMap(
            Map<String, dynamic>.from(routinesData.first as Map),
          );
          loaded = firstRoutine.subRoutines;
        }
      }

      // If no custom routine found, fall back to standardized 4-phase curriculum
      if (loaded.isEmpty) {
        loaded = const [
          TrainingSubRoutineModel(
            id: 'sub_warmup',
            name: 'Dynamic Kinetic Warm-Up & Mobility',
            description: 'Neuromuscular activation and joint mobility sequences',
            completionCriteria: 'Complete 100% of warmup sequences',
            progressTrackingField: 'Completed',
            percentageAllocation: 20.0,
          ),
          TrainingSubRoutineModel(
            id: 'sub_technical',
            name: 'Technical Drill & Mechanics Execution',
            description: 'Targeted sport-specific skills and movement drills',
            completionCriteria: 'Perform drill volume with optimal biomechanics',
            progressTrackingField: 'Repetitions / Sets',
            percentageAllocation: 35.0,
          ),
          TrainingSubRoutineModel(
            id: 'sub_tactical',
            name: 'Tactical Game Simulation & Pressure Play',
            description: 'Match play scenarios, situational awareness, and decision-making',
            completionCriteria: 'Execute game strategies under competitive pressure',
            progressTrackingField: 'Score / Accuracy %',
            percentageAllocation: 30.0,
          ),
          TrainingSubRoutineModel(
            id: 'sub_recovery',
            name: 'Cool-Down, Biomechanics & Review',
            description: 'Active recovery stretching, mobility check, and technical evaluation',
            completionCriteria: 'Complete cooldown sequence and review milestones',
            progressTrackingField: 'Performance Grade (1-5)',
            percentageAllocation: 15.0,
          ),
        ];
      }

      // Initialize metric controllers
      for (final s in loaded) {
        _metricControllers[s.id] = TextEditingController();
      }

      // Populate previously saved progress if any
      final saved = widget.initialSavedProgress;
      if (saved != null) {
        final savedIds = (saved['completedSubRoutineIds'] as List<dynamic>?)?.cast<String>() ?? [];
        _completedSubRoutineIds.addAll(savedIds);

        final metrics = (saved['performanceMetrics'] as Map<String, dynamic>?) ?? {};
        metrics.forEach((key, val) {
          if (_metricControllers.containsKey(key)) {
            _metricControllers[key]!.text = val.toString();
          }
        });

        _notesController.text = saved['coachNotes'] as String? ?? '';
      }

      if (mounted) {
        setState(() {
          _subRoutines = loaded;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Map<String, int> get _xpBreakdown {
    return KricoXpSystem.calculateSubRoutineXpBreakdown(
      playerLevel: widget.playerLevel,
      subRoutines: _subRoutines.map((s) => s.toMap()).toList(),
    );
  }

  int get _calculatedEarnedXp {
    return KricoXpSystem.calculateSessionAward(
      playerLevel: widget.playerLevel,
      subRoutineXpMap: _xpBreakdown,
      completedSubRoutineIds: _completedSubRoutineIds,
    );
  }

  int get _maxSessionXp => KricoXpSystem.maxSessionXpForLevel(widget.playerLevel);

  Future<void> _saveProgressOnly() async {
    setState(() => _submitting = true);
    try {
      final progressData = {
        'completedSubRoutineIds': _completedSubRoutineIds.toList(),
        'performanceMetrics': {
          for (final entry in _metricControllers.entries)
            entry.key: entry.value.text.trim(),
        },
        'coachNotes': _notesController.text.trim(),
        'estimatedEarnedXp': _calculatedEarnedXp,
        'lastSavedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('sessions')
          .doc(widget.sessionId)
          .set({'savedProgress': progressData}, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Training progress saved! You can resume or checkout anytime.'),
            backgroundColor: AppColors.emerald,
          ),
        );
        Navigator.of(context).pop(false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save progress: '), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  Future<void> _confirmAndCompleteSession() async {
    if (_completedSubRoutineIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please verify and check at least one completed training sub-routine.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    try {
      final sessionRef = FirebaseFirestore.instance.collection('sessions').doc(widget.sessionId);
      final sessionSnap = await sessionRef.get();
      final sessionData = sessionSnap.data() ?? {};

      // Idempotency: verify XP not already awarded
      final alreadyAwarded = sessionData['xpAwarded'] as bool? ?? false;
      final finalAwardXp = _calculatedEarnedXp;

      final completedProgress = {
        'completedSubRoutineIds': _completedSubRoutineIds.toList(),
        'performanceMetrics': {
          for (final entry in _metricControllers.entries)
            entry.key: entry.value.text.trim(),
        },
        'coachNotes': _notesController.text.trim(),
        'totalSessionXpAwarded': finalAwardXp,
        'completedAt': FieldValue.serverTimestamp(),
      };

      // 1. Update Session to completed and release escrow
      await sessionRef.set({
        'status': 'completed',
        'checkedOutAt': FieldValue.serverTimestamp(),
        'attendanceVerified': true,
        'escrowStatus': 'released_to_coach',
        'savedProgress': completedProgress,
        'xpAwarded': true,
        'xpAwardedAmount': finalAwardXp,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 2. Award XP to player exactly once
      if (!alreadyAwarded && finalAwardXp > 0) {
        final playerRef = FirebaseFirestore.instance.collection('players').doc(widget.playerId);
        await playerRef.set({
          'points': FieldValue.increment(finalAwardXp),
          'lastSessionCompletedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Log to studentProgress collection
        await FirebaseFirestore.instance.collection('studentProgress').add({
          'sessionId': widget.sessionId,
          'coachId': widget.coachId,
          'playerId': widget.playerId,
          'playerName': widget.playerName,
          'completedSubRoutineIds': _completedSubRoutineIds.toList(),
          'totalXpAwarded': finalAwardXp,
          'maxSessionXp': _maxSessionXp,
          'playerLevel': widget.playerLevel,
          'coachNotes': _notesController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 Session completed! Awarded  XP to . Escrow released.'),
            backgroundColor: AppColors.emerald,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error completing session: '), backgroundColor: AppColors.danger),
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

    if (_loading) {
      return Container(
        height: 350,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: const Center(child: CircularProgressIndicator(color: AppColors.volt)),
      );
    }

    final breakdown = _xpBreakdown;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: borderColor),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: borderColor)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.volt.withValues(alpha: 0.15),
                        borderRadius: AppRadius.brMd,
                      ),
                      child: const Icon(Icons.fact_check_rounded, color: AppColors.volt, size: 22),
                    ),
                    const SizedBox(width: SpacingScale.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isFinalCompletion
                                ? 'Final Routine Verification & Checkout'
                                : 'Session Routine Progress',
                            style: AppTextStyles.title3.copyWith(
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                          ),
                          Text(
                            'Athlete:  • Level ',
                            style: AppTextStyles.caption.copyWith(color: textSecondary),
                          ),
                        ],
                      ),
                    ),
                    if (!widget.isFinalCompletion)
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                  ],
                ),
              ),

              // Telemetry bar: calculated XP
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                color: isDark ? const Color(0xFF141A29) : const Color(0xFFF1F5F9),
                child: Row(
                  children: [
                    const Icon(Icons.bolt_rounded, size: 18, color: AppColors.volt),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Total XP to Award:  /  XP max',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.volt,
                        borderRadius: AppRadius.brSm,
                      ),
                      child: Text(
                        'LVL ',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppColors.midnightObsidian,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Routine checkboxes & grading list
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    for (final s in _subRoutines) ...[
                      _buildSubRoutineVerificationTile(
                        item: s,
                        xpShare: breakdown[s.id] ?? 0,
                        isDark: isDark,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                      const SizedBox(height: SpacingScale.s16),
                    ],

                    const SizedBox(height: SpacingScale.s12),
                    Text(
                      'Coach Debrief & Technical Notes',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700).copyWith(
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: SpacingScale.s8),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 2,
                      style: TextStyle(color: textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Enter session feedback, performance notes, or biomechanical focus...',
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                        border: OutlineInputBorder(borderRadius: AppRadius.brLg),
                      ),
                    ),
                  ],
                ),
              ),

              // Actions Footer
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  border: Border(top: BorderSide(color: borderColor)),
                ),
                child: Row(
                  children: [
                    if (!widget.isFinalCompletion) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _submitting ? null : _saveProgressOnly,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: borderColor),
                            shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                          ),
                          child: const Text('Save Progress & Keep Active',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _submitting ? null : _confirmAndCompleteSession,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                          ),
                          icon: _submitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.verified_rounded),
                          label: Text(
                            _submitting ? 'Completing Session...' : 'Confirm Progress & Complete Session',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubRoutineVerificationTile({
    required TrainingSubRoutineModel item,
    required int xpShare,
    required bool isDark,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final isChecked = _completedSubRoutineIds.contains(item.id);

    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: isChecked
            ? (isDark ? AppColors.volt.withValues(alpha: 0.08) : const Color(0xFFF0FDF4))
            : (isDark ? const Color(0xFF131826) : const Color(0xFFFAFAFA)),
        borderRadius: AppRadius.brXl,
        border: Border.all(
          color: isChecked ? AppColors.volt : borderColor,
          width: isChecked ? 1.4 : 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: isChecked,
                activeColor: AppColors.volt,
                checkColor: AppColors.midnightObsidian,
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _completedSubRoutineIds.add(item.id);
                    } else {
                      _completedSubRoutineIds.remove(item.id);
                    }
                  });
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                            borderRadius: AppRadius.brSm,
                          ),
                          child: Text(
                            '+ XP (%)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isChecked ? AppColors.volt : textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.completionCriteria,
                      style: TextStyle(fontSize: 12, color: textSecondary, height: 1.2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingScale.s10),
          TextFormField(
            controller: _metricControllers[item.id],
            style: TextStyle(fontSize: 12, color: textPrimary),
            decoration: InputDecoration(
              labelText: 'Performance Grade / Field ()',
              labelStyle: TextStyle(fontSize: 11, color: textSecondary),
              hintText: 'e.g. Completed, 40 reps, 9.4s, 5/5 form',
              filled: true,
              fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
              border: OutlineInputBorder(borderRadius: AppRadius.brMd),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            validator: (v) {
              if (isChecked && widget.isFinalCompletion) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please grade ';
                }
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
