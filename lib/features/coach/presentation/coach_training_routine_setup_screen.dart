import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/radius/radius.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../models/training_routine_model.dart';
import '../../../core/gamification/krico_xp_system.dart';

class CoachTrainingRoutineSetupScreen extends ConsumerStatefulWidget {
  final String coachId;

  const CoachTrainingRoutineSetupScreen({
    super.key,
    required this.coachId,
  });

  @override
  ConsumerState<CoachTrainingRoutineSetupScreen> createState() =>
      _CoachTrainingRoutineSetupScreenState();
}

class _CoachTrainingRoutineSetupScreenState
    extends ConsumerState<CoachTrainingRoutineSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  String _selectedSport = 'Athletics';

  final List<_SubRoutineDraft> _subRoutines = [];
  bool _saving = false;
  bool _hasShownExplainer = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: 'Standard Athletic Performance Routine');
    _descController = TextEditingController(
      text: 'Accredited multi-phase training curriculum focusing on progressive skill acquisition, kinetic execution, and functional recovery.',
    );

    // Initial default 4-phase standard curriculum equaling 100%
    _subRoutines.addAll([
      _SubRoutineDraft(
        id: 'sub_warmup',
        name: 'Dynamic Kinetic Warm-Up & Mobility',
        description: 'Joint activation, dynamic stretching, and neuromuscular prep',
        completionCriteria: 'Perform 100% of warmup movement sequences',
        progressTrackingField: 'Completed (Yes/No)',
        percentage: 20.0,
      ),
      _SubRoutineDraft(
        id: 'sub_technical',
        name: 'Technical Drill & Mechanics Acquisition',
        description: 'Sport-specific drill repetitions emphasizing optimal biomechanics',
        completionCriteria: 'Execute prescribed drill volume with coach verified form',
        progressTrackingField: 'Repetitions / Sets',
        percentage: 35.0,
      ),
      _SubRoutineDraft(
        id: 'sub_tactical',
        name: 'Tactical Game Simulation & Pressure Execution',
        description: 'Competitive scenario play, decision making, and tempo training',
        completionCriteria: 'Achieve targeted tactical objectives under match conditions',
        progressTrackingField: 'Points / Score / Accuracy %',
        percentage: 30.0,
      ),
      _SubRoutineDraft(
        id: 'sub_recovery',
        name: 'Biomechanics Review & Active Cool-Down',
        description: 'Post-session recovery stretching, mobility check, and technical debrief',
        completionCriteria: 'Complete cooldown sequence and review session milestones',
        progressTrackingField: 'Coach Performance Grade (1-5)',
        percentage: 15.0,
      ),
    ]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showKricoXpExplainerModal();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    for (final s in _subRoutines) {
      s.dispose();
    }
    super.dispose();
  }

  void _showKricoXpExplainerModal() {
    if (_hasShownExplainer) return;
    _hasShownExplainer = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF10141E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: isDark ? AppColors.border : AppColors.lightBorder,
            ),
          ),
          padding: const EdgeInsets.all(SpacingScale.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
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
                    child: const Icon(Icons.bolt_rounded, color: AppColors.volt, size: 26),
                  ),
                  const SizedBox(width: SpacingScale.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'KRICO XP & Progression System',
                          style: AppTextStyles.title2.copyWith(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          'Standardized Athlete Progression Rules',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpacingScale.s20),
              _buildExplainerRule(
                icon: Icons.shield_rounded,
                title: 'Standardized Session XP Capping',
                description:
                    'Each session awards max 25 XP for Level 1 athletes, scaling +2 XP per level (L2=27, L3=29... up to max 45 XP). Arbitrary manual XP numbers are strictly disabled.',
                isDark: isDark,
              ),
              const SizedBox(height: SpacingScale.s12),
              _buildExplainerRule(
                icon: Icons.pie_chart_rounded,
                title: 'Percentage-Based XP Allocation (100%)',
                description:
                    'As coach, you define sub-routines and assign percentage weights totaling exactly 100%. KRICO computes the exact XP automatically based on each player\'s level.',
                isDark: isDark,
              ),
              const SizedBox(height: SpacingScale.s12),
              _buildExplainerRule(
                icon: Icons.checklist_rtl_rounded,
                title: 'Verification & Milestone Integrity',
                description:
                    'XP is awarded strictly for verified sub-routines during checkout. Saving your routine activates your profile so players can discover and book sessions.',
                isDark: isDark,
              ),
              const SizedBox(height: SpacingScale.s24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.volt,
                  foregroundColor: AppColors.midnightObsidian,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                ),
                child: const Text('I Understand • Start Routine Setup',
                    style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExplainerRule({
    required IconData icon,
    required String title,
    required String description,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(SpacingScale.s12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141A29) : const Color(0xFFF8FAFC),
        borderRadius: AppRadius.brLg,
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.volt),
          const SizedBox(width: SpacingScale.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 3),
                Text(description, style: const TextStyle(fontSize: 11, color: Colors.grey, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double get _currentTotalPercentage =>
      _subRoutines.fold<double>(0.0, (acc, item) => acc + item.percentage);

  bool get _is100Percent => (_currentTotalPercentage - 100.0).abs() <= 0.01;

  void _addSubRoutine() {
    setState(() {
      final id = 'sub_';
      _subRoutines.add(
        _SubRoutineDraft(
          id: id,
          name: '',
          description: '',
          completionCriteria: 'Complete prescribed sets and form',
          progressTrackingField: 'Repetitions',
          percentage: 0.0,
        ),
      );
    });
  }

  void _removeSubRoutine(int index) {
    if (_subRoutines.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one sub-routine is required in a session routine.')),
      );
      return;
    }
    setState(() {
      _subRoutines[index].dispose();
      _subRoutines.removeAt(index);
    });
  }

  Future<void> _saveRoutines() async {
    if (!_formKey.currentState!.validate()) return;

    final validationErr = KricoXpSystem.validateRoutinePercentages(
      _subRoutines.map((s) => s.percentage).toList(),
    );
    if (validationErr != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationErr),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final subRoutineModels = _subRoutines.map((s) {
        return TrainingSubRoutineModel(
          id: s.id,
          name: s.nameCtrl.text.trim(),
          description: s.descCtrl.text.trim(),
          completionCriteria: s.critCtrl.text.trim(),
          progressTrackingField: s.fieldCtrl.text.trim(),
          percentageAllocation: s.percentage,
        );
      }).toList();

      final routineModel = TrainingRoutineModel(
        id: 'routine__default',
        coachId: widget.coachId,
        sport: _selectedSport,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        subRoutines: subRoutineModels,
        isStandard: true,
      );

      final coachRef =
          FirebaseFirestore.instance.collection('coaches').doc(widget.coachId);
      await coachRef.set({
        'hasConfiguredRoutines': true,
        'routines': [routineModel.toMap()],
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Training routines configured successfully! Your profile is now available for bookings.'),
            backgroundColor: AppColors.emerald,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save routines: '),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.background : AppColors.lightBackground;
    final cardBg = isDark ? AppColors.surface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final subColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    final total = _currentTotalPercentage;
    final formattedTotal = total.toStringAsFixed(total.truncateToDouble() == total ? 0 : 1);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Mandatory Training Routine Setup'),
        backgroundColor: cardBg,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: AppColors.volt),
            onPressed: () {
              _hasShownExplainer = false;
              _showKricoXpExplainerModal();
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sticky percentage telemetry banner
                    Container(
                      padding: const EdgeInsets.all(SpacingScale.s16),
                      decoration: BoxDecoration(
                        color: _is100Percent
                            ? AppColors.emerald.withValues(alpha: 0.15)
                            : AppColors.warning.withValues(alpha: 0.15),
                        borderRadius: AppRadius.brXl,
                        border: Border.all(
                          color: _is100Percent ? AppColors.emerald : AppColors.warning,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _is100Percent ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                            color: _is100Percent ? AppColors.emerald : AppColors.warning,
                            size: 26,
                          ),
                          const SizedBox(width: SpacingScale.s12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _is100Percent
                                      ? 'Total Allocation: 100% (Ready to Save)'
                                      : 'Total Allocation: % / 100%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: _is100Percent ? AppColors.emerald : AppColors.warning,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _is100Percent
                                      ? 'XP weights are distributed evenly. Beginners earn 25 XP; higher levels scale to 45 XP.'
                                      : (total < 100
                                          ? 'Please allocate the remaining % across sub-routines.'
                                          : 'Total exceeds 100% by %. Please balance weights.'),
                                  style: TextStyle(fontSize: 11, color: textColor, height: 1.2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: SpacingScale.s24),

                    // Routine Overview Fields
                    Text('Session Curriculum Overview',
                        style: AppTextStyles.title3.copyWith(fontWeight: FontWeight.w800, color: textColor)),
                    const SizedBox(height: SpacingScale.s12),

                    TextFormField(
                      controller: _titleController,
                      style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        labelText: 'Routine Title',
                        filled: true,
                        fillColor: cardBg,
                        border: OutlineInputBorder(borderRadius: AppRadius.brLg),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Routine title is required' : null,
                    ),
                    const SizedBox(height: SpacingScale.s12),

                    TextFormField(
                      controller: _descController,
                      maxLines: 2,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: 'Curriculum Description',
                        filled: true,
                        fillColor: cardBg,
                        border: OutlineInputBorder(borderRadius: AppRadius.brLg),
                      ),
                    ),
                    const SizedBox(height: SpacingScale.s28),

                    // Sub-Routines Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Sub-Routines & XP Share',
                            style: AppTextStyles.title3.copyWith(fontWeight: FontWeight.w800, color: textColor)),
                        FilledButton.icon(
                          onPressed: _addSubRoutine,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.volt,
                            foregroundColor: AppColors.midnightObsidian,
                            shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                          ),
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: const Text('Add Phase', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: SpacingScale.s16),

                    // List of sub-routine cards
                    for (int i = 0; i < _subRoutines.length; i++) ...[
                      _buildSubRoutineCard(
                        index: i,
                        item: _subRoutines[i],
                        isDark: isDark,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        textColor: textColor,
                        subColor: subColor,
                      ),
                      const SizedBox(height: SpacingScale.s16),
                    ],

                    const SizedBox(height: SpacingScale.s24),
                    ElevatedButton.icon(
                      onPressed: _saving ? null : _saveRoutines,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.brXl),
                      ),
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.check_circle_rounded),
                      label: Text(
                        _saving ? 'Saving Routines...' : 'Save Routine & Activate Profile',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubRoutineCard({
    required int index,
    required _SubRoutineDraft item,
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
    required Color textColor,
    required Color subColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(SpacingScale.s16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.brXl,
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: AppRadius.brSm,
                ),
                child: Text('Phase #',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 11)),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20),
                onPressed: () => _removeSubRoutine(index),
              ),
            ],
          ),
          const SizedBox(height: SpacingScale.s12),
          TextFormField(
            controller: item.nameCtrl,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
            decoration: const InputDecoration(
              labelText: 'Sub-Routine Name (e.g. Kinetic Warmup)',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Name required' : null,
          ),
          const SizedBox(height: SpacingScale.s12),
          TextFormField(
            controller: item.critCtrl,
            style: TextStyle(color: textColor, fontSize: 12),
            decoration: const InputDecoration(
              labelText: 'Completion Criteria (e.g. 5x 40m Sprints)',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Criteria required' : null,
          ),
          const SizedBox(height: SpacingScale.s12),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: item.fieldCtrl,
                  style: TextStyle(color: textColor, fontSize: 12),
                  decoration: const InputDecoration(
                    labelText: 'Tracking Metric (e.g. Reps, Time)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: SpacingScale.s12),
              Expanded(
                flex: 2,
                child: TextFormField(
                  initialValue: item.percentage.toStringAsFixed(0),
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: textColor, fontWeight: FontWeight.w800),
                  decoration: const InputDecoration(
                    labelText: 'XP %',
                    suffixText: '%',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  onChanged: (val) {
                    final p = double.tryParse(val) ?? 0.0;
                    setState(() => item.percentage = p);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SubRoutineDraft {
  final String id;
  final TextEditingController nameCtrl;
  final TextEditingController descCtrl;
  final TextEditingController critCtrl;
  final TextEditingController fieldCtrl;
  double percentage;

  _SubRoutineDraft({
    required this.id,
    required String name,
    required String description,
    required String completionCriteria,
    required String progressTrackingField,
    required this.percentage,
  })  : nameCtrl = TextEditingController(text: name),
        descCtrl = TextEditingController(text: description),
        critCtrl = TextEditingController(text: completionCriteria),
        fieldCtrl = TextEditingController(text: progressTrackingField);

  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    critCtrl.dispose();
    fieldCtrl.dispose();
  }
}
