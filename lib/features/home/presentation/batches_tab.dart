import '../../../models/batch_model.dart';
import '../../academy/presentation/batch_formation_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/sports_registry.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../services/providers.dart';

class BatchesTab extends ConsumerStatefulWidget {
  final String academyId;
  const BatchesTab({super.key, required this.academyId});

  @override
  ConsumerState<BatchesTab> createState() => _BatchesTabState();
}

class _BatchesTabState extends ConsumerState<BatchesTab> {
  final _nameController = TextEditingController();
  final _capacityController = TextEditingController();
  final _scheduleController = TextEditingController();
  String _selectedSport = SportsRegistry.sports.first.name;
  bool _showForm = false;
  bool _isCreating = false;
  String? _editingBatchId;

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _scheduleController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _nameController.clear();
    _selectedSport = SportsRegistry.sports.first.name;
    _capacityController.clear();
    _scheduleController.clear();
    _editingBatchId = null;
    setState(() => _showForm = false);
  }

  Future<void> _createBatch() async {
    if (_nameController.text.isEmpty) return;
    setState(() => _isCreating = true);
    try {
      final service = ref.read(academyServiceProvider);
      if (_editingBatchId != null) {
        await service.updateBatch(_editingBatchId!, {
          'name': _nameController.text.trim(),
          'sport': _selectedSport,
          'capacity': int.tryParse(_capacityController.text) ?? 10,
          'schedule': _scheduleController.text.trim(),
        });
      } else {
        await service.createBatch(
          academyId: widget.academyId,
          name: _nameController.text.trim(),
          sport: _selectedSport,
          capacity: int.tryParse(_capacityController.text) ?? 10,
          schedule: _scheduleController.text.trim(),
        );
      }
      _resetForm();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  void _editBatch(Map<String, dynamic> data) {
    final batch = BatchModel(
      id: data['batchId'] as String? ?? data['id'] as String? ?? '',
      academyId: widget.academyId,
      name: data['name'] as String? ?? '',
      sport: data['sport'] as String? ?? 'General',
      ageGroup: data['ageGroup'] as String? ?? 'All Ages',
      maxStudents: (data['maxStudents'] ?? data['capacity'] as num?)?.toInt() ?? 15,
      currentStudents: (data['currentStudents'] as num?)?.toInt() ?? 0,
      coachId: data['coachId'] as String?,
      coachName: data['coachName'] as String?,
      playerIds: (data['playerIds'] as List<dynamic>?)?.cast<String>() ?? <String>[],
      schedule: data['schedule'] as String? ?? '',
      days: (data['days'] as List<dynamic>?)?.cast<String>() ?? <String>[],
      startTime: data['startTime'] as String?,
      endTime: data['endTime'] as String?,
      feeMonthly: (data['feeMonthly'] ?? data['monthlyFee'] as num?)?.toDouble() ?? 0.0,
      isActive: data['isActive'] as bool? ?? true,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BatchFormationScreen(
          academyId: widget.academyId,
          existingBatch: batch,
        ),
      ),
    );
  }

  void _showBatchRosterSheet(BuildContext context, Map<String, dynamic> data) {
    final batchId = (data['batchId'] as String?)?.isNotEmpty == true
        ? data['batchId'] as String
        : ((data['id'] as String?)?.isNotEmpty == true ? data['id'] as String : '');
    if (batchId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot open roster: Batch ID is missing')),
      );
      return;
    }
    final batchName = data['name'] as String? ?? 'Batch';
    final sport = data['sport'] as String? ?? 'General';
    final capacity = (data['capacity'] as num?)?.toInt() ?? 10;
    final monthlyFee = (data['monthlyFee'] as num?)?.toDouble() ??
        (data['fee'] as num?)?.toDouble() ??
        2500.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _BatchRosterModal(
        academyId: widget.academyId,
        batchId: batchId,
        batchName: batchName,
        sport: sport,
        capacity: capacity,
        monthlyFee: monthlyFee,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final batchesAsync = ref.watch(academyBatchesProvider(widget.academyId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090B10) : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _BatchesHeroHeader(
              batchesAsync: batchesAsync,
              showForm: false,
              onToggleForm: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BatchFormationScreen(academyId: widget.academyId),
                ),
              ),
            ),
          ),
          if (_showForm)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF141926) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.4), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _editingBatchId != null ? 'Edit Training Batch' : 'Register New Training Batch',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        if (_editingBatchId != null)
                          TextButton(
                            onPressed: _resetForm,
                            child: Text('Cancel Edit', style: TextStyle(color: textSecondary, fontSize: 12)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _nameController,
                      style: TextStyle(color: textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Batch Name (e.g. Under-17 Elite Squad)',
                        labelStyle: TextStyle(color: textSecondary),
                        prefixIcon: const Icon(Icons.group_rounded, color: Color(0xFF00E5FF)),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF090B10) : Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: SportsRegistry.sports.any((s) => s.name == _selectedSport)
                          ? _selectedSport
                          : SportsRegistry.sports.first.name,
                      dropdownColor: isDark ? const Color(0xFF141926) : Colors.white,
                      style: TextStyle(color: textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Sport / Discipline (30 Catalog Sports)',
                        labelStyle: TextStyle(color: textSecondary),
                        prefixIcon: const Icon(Icons.sports_rounded, color: Color(0xFF00E5FF)),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF090B10) : Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: SportsRegistry.sports.map((sport) {
                        return DropdownMenuItem<String>(
                          value: sport.name,
                          child: Text('${sport.name} (${sport.category})'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedSport = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _capacityController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: textPrimary),
                            decoration: InputDecoration(
                              labelText: 'Max Capacity',
                              labelStyle: TextStyle(color: textSecondary),
                              prefixIcon: const Icon(Icons.people_rounded, color: Color(0xFF00E5FF)),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF090B10) : Colors.grey.shade100,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _scheduleController,
                            style: TextStyle(color: textPrimary),
                            decoration: InputDecoration(
                              labelText: 'Schedule (e.g. Mon, Wed 4 PM)',
                              labelStyle: TextStyle(color: textSecondary),
                              prefixIcon: const Icon(Icons.schedule_rounded, color: Color(0xFF00E5FF)),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF090B10) : Colors.grey.shade100,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    GradientButton(
                      onPressed: _isCreating ? null : _createBatch,
                      isLoading: _isCreating,
                      child: Text(
                        _editingBatchId != null ? 'Update Batch' : 'Create Squad Batch',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.05, end: 0),
            ),
          batchesAsync.when(
            data: (snap) {
              final docs = snap.docs.toList()
                ..sort((a, b) {
                  final aTime = (a.data()['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
                  final bTime = (b.data()['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
                  return bTime.compareTo(aTime);
                });
              if (docs.isEmpty && !_showForm) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.group_outlined, size: 64, color: Color(0xFF00E5FF)),
                        SizedBox(height: 16),
                        Text('No Squad Batches Active', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                        SizedBox(height: 8),
                        Text('Create your first training batch to start enrolling athletes',
                            style: TextStyle(color: Colors.white60, fontSize: 13)),
                      ],
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final data = Map<String, dynamic>.from(docs[index].data());
                    data['id'] = docs[index].id;
                    data['batchId'] = (data['batchId'] as String?)?.isNotEmpty == true ? data['batchId'] : docs[index].id;
                    final name = data['name'] as String? ?? 'Unnamed Batch';
                    final sport = data['sport'] as String? ?? 'General';
                    final capacity = (data['capacity'] as num?)?.toInt() ?? 0;
                    final enrolled = (data['enrolled'] as num?)?.toInt() ?? 0;
                    final schedule = data['schedule'] as String? ?? 'Flexible';
                    final fillPercent = capacity > 0 ? enrolled / capacity : 0.0;
                    final isFull = fillPercent >= 1.0;

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.25)),
                                ),
                                child: const Icon(Icons.group_rounded, color: Color(0xFF00E5FF), size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            name,
                                            style: TextStyle(
                                              color: isDark ? Colors.white : Colors.black87,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: isFull
                                                ? AppColors.danger.withValues(alpha: 0.12)
                                                : const Color(0xFFCCFF00).withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: isFull ? AppColors.danger : const Color(0xFFCCFF00),
                                            ),
                                          ),
                                          child: Text(
                                            '$enrolled / $capacity Athletes',
                                            style: TextStyle(
                                              color: isFull ? AppColors.danger : const Color(0xFFCCFF00),
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '$sport \u2022 $schedule',
                                      style: TextStyle(
                                        color: isDark ? Colors.white60 : Colors.black54,
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: fillPercent.clamp(0.0, 1.0),
                              minHeight: 6,
                              backgroundColor: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isFull ? AppColors.danger : const Color(0xFFCCFF00),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${(fillPercent * 100).toInt()}% Occupancy',
                                  style: TextStyle(
                                    color: isDark ? Colors.white54 : Colors.black45,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isFull)
                                Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.how_to_reg_rounded, size: 14),
                                    label: const Text('Waitlist', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.amber.withValues(alpha: 0.15),
                                      foregroundColor: Colors.amber,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(color: Colors.amber.withValues(alpha: 0.4)),
                                      ),
                                    ),
                                    onPressed: () => _showWaitlistDialog(context, data),
                                  ),
                                ),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.people_alt_rounded, size: 14),
                                label: const Text('Roster & Attendance', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                                  foregroundColor: const Color(0xFF00E5FF),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(color: const Color(0xFF00E5FF).withValues(alpha: 0.4)),
                                  ),
                                ),
                                onPressed: () => _showBatchRosterSheet(context, data),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(Icons.edit_rounded, size: 18, color: Color(0xFF00E5FF)),
                                onPressed: () => _editBatch(data),
                                visualDensity: VisualDensity.compact,
                                tooltip: 'Edit Batch',
                              ),
                              IconButton(
                                icon: const Icon(Icons.archive_rounded, size: 18, color: Color(0xFFFFB300)),
                                onPressed: () => _confirmDeleteBatch(context, data['batchId'] as String? ?? ''),
                                visualDensity: VisualDensity.compact,
                                tooltip: 'Archive Batch',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: (index * 45).ms).slideY(begin: 0.05, end: 0);
                  },
                  childCount: docs.length,
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF))),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Failed to load batches: $e', style: const TextStyle(color: AppColors.danger))),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  void _confirmDeleteBatch(BuildContext context, String batchId) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF141926) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Archive Batch', style: TextStyle(fontWeight: FontWeight.w800, color: isDark ? Colors.white : Colors.black87)),
        content: Text('This will archive the batch. Students will no longer be able to join. Continue?',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            onPressed: () {
              ref.read(academyServiceProvider).deleteBatch(batchId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Batch archived'), backgroundColor: AppColors.success),
              );
            },
            child: const Text('Archive'),
          ),
        ],
      ),
    );
  }

  void _showWaitlistDialog(BuildContext context, Map<String, dynamic> data) {
    final batchId = data['batchId'] as String? ?? '';
    final batchName = data['name'] as String? ?? 'Batch';
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF141926) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Join Waitlist - $batchName',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: isDark ? Colors.white : Colors.black87),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This squad batch is currently at full capacity. Register on the waitlist to receive priority notification when a spot opens up.',
              style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black54),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: nameCtrl,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: const InputDecoration(
                labelText: 'Athlete / Parent Name *',
                prefixIcon: Icon(Icons.person_rounded),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: const InputDecoration(
                labelText: 'Contact Phone Number *',
                prefixIcon: Icon(Icons.phone_rounded),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: notesCtrl,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: const InputDecoration(
                labelText: 'Notes / Target Days (Optional)',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) return;
              try {
                await FirebaseFirestore.instance
                    .collection('academies')
                    .doc(widget.academyId)
                    .collection('batches')
                    .doc(batchId)
                    .collection('waitlist')
                    .add({
                  'name': nameCtrl.text.trim(),
                  'phone': phoneCtrl.text.trim(),
                  'notes': notesCtrl.text.trim(),
                  'createdAt': FieldValue.serverTimestamp(),
                  'status': 'waiting',
                });
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Registered on squad waitlist! You will be notified when a slot opens.'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.danger),
                  );
                }
              }
            },
            child: const Text('Join Waitlist', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

class _BatchesHeroHeader extends StatelessWidget {
  final AsyncValue<dynamic> batchesAsync;
  final bool showForm;
  final VoidCallback onToggleForm;

  const _BatchesHeroHeader({
    required this.batchesAsync,
    required this.showForm,
    required this.onToggleForm,
  });

  @override
  Widget build(BuildContext context) {
    final totalBatches = batchesAsync.asData?.value?.docs?.length ?? 0;

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
                        'ACADEMY CADRE & SQUADS',
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
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: onToggleForm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: showForm
                              ? [Colors.grey.shade700, Colors.grey.shade800]
                              : [const Color(0xFFCCFF00), const Color(0xFF88FF00)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          if (!showForm)
                            BoxShadow(
                              color: const Color(0xFFCCFF00).withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(showForm ? Icons.close_rounded : Icons.add_rounded,
                              size: 16, color: showForm ? Colors.white : Colors.black),
                          const SizedBox(width: 5),
                          Text(
                            showForm ? 'Close Form' : 'New Batch',
                            style: TextStyle(
                              color: showForm ? Colors.white : Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Training Batches',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Organize age groups, sports disciplines, schedules, and capacity limits',
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
                    '$totalBatches',
                    style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'ACTIVE SQUAD BATCHES',
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

class _BatchRosterModal extends ConsumerStatefulWidget {
  final String academyId;
  final String batchId;
  final String batchName;
  final String sport;
  final int capacity;
  final double monthlyFee;

  const _BatchRosterModal({
    required this.academyId,
    required this.batchId,
    required this.batchName,
    required this.sport,
    required this.capacity,
    this.monthlyFee = 2500.0,
  });

  @override
  ConsumerState<_BatchRosterModal> createState() => _BatchRosterModalState();
}

class _BatchRosterModalState extends ConsumerState<_BatchRosterModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DateTime _attendanceDate = DateTime.now();
  final Map<String, bool> _attendanceState = {};
  final Map<String, bool> _lateState = {};
  bool _isSavingAttendance = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _dateKey => DateFormat('yyyy-MM-dd').format(_attendanceDate);

  void _showEnrollStudentDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final remainingDays = (daysInMonth - now.day + 1).clamp(1, daysInMonth);
    final proRatedFee = ((widget.monthlyFee * remainingDays) / daysInMonth).roundToDouble();

    bool isProRated = now.day > 5;
    bool isCashAtDesk = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final effectiveFee = isProRated ? proRatedFee : widget.monthlyFee;

          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF141926) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              'Enroll Athlete in ${widget.batchName}',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: isDark ? Colors.white : Colors.black87),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameCtrl,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: const InputDecoration(
                      labelText: 'Athlete Full Name *',
                      prefixIcon: Icon(Icons.person_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: contactCtrl,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: const InputDecoration(
                      labelText: 'Parent / Emergency Contact *',
                      prefixIcon: Icon(Icons.contact_phone_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ADMISSION & FEE CALCULATION',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: Text(
                            'Full (₹${widget.monthlyFee.toInt()})',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: !isProRated ? Colors.black : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                          selected: !isProRated,
                          selectedColor: const Color(0xFF00E5FF),
                          onSelected: (val) {
                            if (val) setDialogState(() => isProRated = false);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: Text(
                            'Pro-Rated (${remainingDays}d: ₹${proRatedFee.toInt()})',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isProRated ? Colors.black : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                          selected: isProRated,
                          selectedColor: const Color(0xFF00E5FF),
                          onSelected: (val) {
                            if (val) setDialogState(() => isProRated = true);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      isProRated
                          ? '📅 Mid-month admission: Calculated for remaining $remainingDays of $daysInMonth days in current month (₹${proRatedFee.toInt()}).'
                          : '📅 Standard full calendar month admission fee (₹${widget.monthlyFee.toInt()}).',
                      style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0D111A) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isCashAtDesk
                            ? AppColors.success.withValues(alpha: 0.6)
                            : (isDark ? Colors.white12 : Colors.black12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isCashAtDesk ? Icons.check_circle_rounded : Icons.point_of_sale_rounded,
                          color: isCashAtDesk ? AppColors.success : const Color(0xFF00E5FF),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Paid Offline Cash at Front Desk',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              Text(
                                isCashAtDesk
                                    ? '✅ Reconciled & logged in academy ledger'
                                    : 'Parent will be billed via parent app notification',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isCashAtDesk ? AppColors.success : (isDark ? Colors.white54 : Colors.black54),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: isCashAtDesk,
                          activeTrackColor: AppColors.success,
                          onChanged: (val) => setDialogState(() => isCashAtDesk = val),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  if (nameCtrl.text.trim().isEmpty) return;
                  try {
                    await ref.read(academyServiceProvider).enrollStudentInBatch(
                      batchId: widget.batchId,
                      academyId: widget.academyId,
                      studentName: nameCtrl.text.trim(),
                      studentPhone: phoneCtrl.text.trim(),
                      studentEmail: emailCtrl.text.trim(),
                      emergencyContact: contactCtrl.text.trim(),
                      paymentMode: isCashAtDesk ? 'cash_at_desk' : 'online_app',
                      admissionType: isProRated ? 'pro_rated' : 'full_month',
                      feePaid: effectiveFee,
                      proRatedDays: isProRated ? remainingDays : null,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${nameCtrl.text.trim()} enrolled! ${isCashAtDesk ? "Cash ₹${effectiveFee.toInt()} reconciled at front desk." : "Billed ₹${effectiveFee.toInt()} via app."}',
                          ),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
                      );
                    }
                  }
                },
                child: Text('Enroll Athlete (₹${effectiveFee.toInt()})', style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _removeStudent(String studentId, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove $name?'),
        content: const Text('This will remove the athlete from this batch squad.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            onPressed: () async {
              await ref.read(academyServiceProvider).removeStudentFromBatch(
                batchId: widget.batchId,
                studentId: studentId,
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAttendance() async {
    setState(() => _isSavingAttendance = true);
    try {
      await ref.read(academyServiceProvider).saveBatchAttendance(
        batchId: widget.batchId,
        dateKey: _dateKey,
        attendance: _attendanceState,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attendance recorded for $_dateKey!'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingAttendance = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.white60 : Colors.black54;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F141E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.batchName, style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w800)),
                      Text('${widget.sport} \u2022 Max Capacity: ${widget.capacity}', style: TextStyle(color: textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.person_add_rounded, size: 16),
                  label: const Text('Enroll Athlete', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _showEnrollStudentDialog(context),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF00E5FF),
            unselectedLabelColor: textSecondary,
            indicatorColor: const Color(0xFF00E5FF),
            tabs: const [
              Tab(icon: Icon(Icons.people_outline_rounded), text: 'Athletes Roster'),
              Tab(icon: Icon(Icons.checklist_rounded), text: 'Daily Attendance'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRosterTab(isDark, textPrimary, textSecondary),
                _buildAttendanceTab(isDark, textPrimary, textSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRosterTab(bool isDark, Color textPrimary, Color textSecondary) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: ref.watch(academyServiceProvider).getBatchStudents(widget.batchId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)));
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_off_rounded, size: 48, color: textSecondary),
                const SizedBox(height: 12),
                Text('No Athletes Enrolled Yet', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 4),
                Text('Tap "Enroll Athlete" above to add squad members.', style: TextStyle(color: textSecondary, fontSize: 12)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final name = data['name'] as String? ?? 'Athlete';
            final phone = data['phone'] as String? ?? '';
            final email = data['email'] as String? ?? '';
            final contact = data['emergencyContact'] as String? ?? '';
            final admissionType = data['admissionType'] as String? ?? 'full_month';
            final feePaid = (data['feePaid'] as num?)?.toDouble() ?? 0.0;
            final isReconciled = data['isReconciled'] as bool? ?? false;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF141A26) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                    foregroundColor: const Color(0xFF00E5FF),
                    child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'A', style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                        if (phone.isNotEmpty || email.isNotEmpty)
                          Text([if (phone.isNotEmpty) phone, if (email.isNotEmpty) email].join(' \u2022 '),
                              style: TextStyle(color: textSecondary, fontSize: 11)),
                        if (contact.isNotEmpty)
                          Text('Contact: $contact', style: TextStyle(color: textSecondary, fontSize: 11)),
                        if (feePaid > 0 || isReconciled)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isReconciled
                                    ? AppColors.success.withValues(alpha: 0.15)
                                    : const Color(0xFF00E5FF).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isReconciled
                                      ? AppColors.success.withValues(alpha: 0.4)
                                      : const Color(0xFF00E5FF).withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                isReconciled
                                    ? 'Cash Paid: ₹${feePaid.toInt()} (Reconciled)'
                                    : (admissionType == 'pro_rated'
                                        ? 'Pro-Rated Billed: ₹${feePaid.toInt()}'
                                        : 'App Billed: ₹${feePaid.toInt()}'),
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: isReconciled ? AppColors.success : const Color(0xFF00E5FF),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.danger, size: 20),
                    onPressed: () => _removeStudent(docs[index].id, name),
                    tooltip: 'Remove Athlete',
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAttendanceTab(bool isDark, Color textPrimary, Color textSecondary) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: ref.watch(academyServiceProvider).getBatchStudents(widget.batchId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)));
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Text('Enroll athletes first to take attendance.', style: TextStyle(color: textSecondary)),
          );
        }

        for (final doc in docs) {
          _attendanceState.putIfAbsent(doc.id, () => true);
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.calendar_month_rounded, size: 16, color: textSecondary),
                  const SizedBox(width: 6),
                  Text('Date: $_dateKey', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
                  const Spacer(),
                  Text('${_attendanceState.values.where((v) => v).length} / ${docs.length} Present',
                      style: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.w700, fontSize: 12)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.done_all_rounded, size: 14),
                    label: const Text('Mark All Present', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF00E5FF),
                      side: const BorderSide(color: Color(0xFF00E5FF)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      setState(() {
                        for (final doc in docs) {
                          _attendanceState[doc.id] = true;
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.clear_rounded, size: 14),
                    label: const Text('Clear All', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.white70 : Colors.black54,
                      side: BorderSide(color: isDark ? Colors.white24 : Colors.black26),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      setState(() {
                        for (final doc in docs) {
                          _attendanceState[doc.id] = false;
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data();
                  final studentId = docs[index].id;
                  final name = data['name'] as String? ?? 'Athlete';
                  final isPresent = _attendanceState[studentId] ?? true;

                  final isLate = _lateState[studentId] ?? false;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF141A26) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: isLate ? Border.all(color: Colors.amber.withValues(alpha: 0.5)) : null,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                            value: isPresent,
                            activeColor: const Color(0xFF00E5FF),
                            checkColor: Colors.black,
                            title: Text(name, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13.5)),
                            subtitle: Text(
                              isLate ? 'Late Arrival' : (isPresent ? 'Present' : 'Absent'),
                              style: TextStyle(
                                color: isLate ? Colors.amber : (isPresent ? AppColors.success : AppColors.danger),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onChanged: (val) {
                              setState(() {
                                _attendanceState[studentId] = val ?? false;
                                if (val == false) _lateState[studentId] = false;
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                final nowLate = !isLate;
                                _lateState[studentId] = nowLate;
                                if (nowLate) _attendanceState[studentId] = true;
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                              decoration: BoxDecoration(
                                color: isLate ? Colors.amber.withValues(alpha: 0.2) : (isDark ? Colors.white10 : Colors.black12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isLate ? Colors.amber : Colors.transparent,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.schedule_rounded, size: 12, color: isLate ? Colors.amber : textSecondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Late',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isLate ? Colors.amber : textSecondary,
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
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: _isSavingAttendance
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Icon(Icons.check_circle_rounded, size: 18),
                  label: Text(_isSavingAttendance ? 'Saving...' : 'Save Attendance Record',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSavingAttendance ? null : _saveAttendance,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
