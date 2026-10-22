import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/sports_registry.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/radius/radius.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../models/batch_model.dart';
import '../../../models/coach_model.dart';
import '../../../services/providers.dart';

class BatchFormationScreen extends ConsumerStatefulWidget {
  final String academyId;
  final BatchModel? existingBatch;

  const BatchFormationScreen({
    super.key,
    required this.academyId,
    this.existingBatch,
  });

  @override
  ConsumerState<BatchFormationScreen> createState() => _BatchFormationScreenState();
}

class _BatchFormationScreenState extends ConsumerState<BatchFormationScreen> {
  final _nameCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  final _feeCtrl = TextEditingController();
  final _searchPlayerCtrl = TextEditingController();
  final _sportSearchCtrl = TextEditingController();

  late String _selectedSport;
  String _sportSearchQuery = '';
  static const List<String> _top5Sports = ['Cricket', 'Football', 'Tennis', 'Basketball', 'Badminton'];

  int _capacity = 15;
  String? _selectedCoachId;
  String? _selectedCoachName;
  final List<Map<String, dynamic>> _selectedPlayers = [];
  int _selectedPlayersPage = 0;
  static const int _playersPerPage = 5;

  final Set<String> _selectedDays = {'Mon', 'Wed', 'Fri'};
  TimeOfDay _startTime = const TimeOfDay(hour: 6, minute: 30);
  TimeOfDay _endTime = const TimeOfDay(hour: 8, minute: 0);

  bool _isSaving = false;
  String _playerSearchQuery = '';

  static const List<String> _allDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    final b = widget.existingBatch;
    if (b != null) {
      _nameCtrl.text = b.name;
      _selectedSport = b.sport;
      _capacity = b.maxStudents;
      _capacityCtrl.text = '$_capacity';
      _feeCtrl.text = b.feeMonthly > 0 ? b.feeMonthly.toInt().toString() : '';
      _selectedCoachId = b.coachId;
      _selectedCoachName = b.coachName;
      if (b.days.isNotEmpty) {
        _selectedDays.clear();
        _selectedDays.addAll(b.days);
      }
      _loadExistingPlayers(b.playerIds);
    } else {
      _selectedSport = _top5Sports.first;
      _capacityCtrl.text = '$_capacity';
      _feeCtrl.text = '1500';
    }
  }

  Future<void> _loadExistingPlayers(List<String> playerIds) async {
    for (final id in playerIds) {
      try {
        final doc = await FirebaseFirestore.instance.collection('players').doc(id).get();
        if (doc.exists) {
          final data = doc.data()!;
          if (mounted) {
            setState(() {
              _selectedPlayers.add({
                'id': doc.id,
                'name': data['name'] ?? 'Player',
                'avatar': data['avatarUrl'] ?? '',
                'sport': (data['sports'] is List && (data['sports'] as List).isNotEmpty)
                    ? (data['sports'] as List).first
                    : 'Athlete',
              });
            });
          }
        }
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _capacityCtrl.dispose();
    _feeCtrl.dispose();
    _searchPlayerCtrl.dispose();
    _sportSearchCtrl.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final min = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$min $period';
  }

  String get _scheduleSummary {
    final days = _selectedDays.toList()..sort((a, b) => _allDays.indexOf(a).compareTo(_allDays.indexOf(b)));
    return '${days.join(", ")} \u2022 ${_formatTime(_startTime)} - ${_formatTime(_endTime)}';
  }

  Future<void> _saveBatch() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a batch name')),
      );
      return;
    }
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one training day')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final fee = double.tryParse(_feeCtrl.text.trim()) ?? 0.0;
      final playerIds = _selectedPlayers.map((p) => p['id'] as String).toList();
      final days = _selectedDays.toList()..sort((a, b) => _allDays.indexOf(a).compareTo(_allDays.indexOf(b)));

      final batchId = widget.existingBatch?.id ?? FirebaseFirestore.instance.collection('batches').doc().id;

      final data = {
        'batchId': batchId,
        'id': batchId,
        'academyId': widget.academyId,
        'name': name,
        'sport': _selectedSport,
        'ageGroup': 'All Ages',
        'maxStudents': _capacity,
        'currentStudents': playerIds.length,
        'coachId': _selectedCoachId,
        'coachName': _selectedCoachName,
        'playerIds': playerIds,
        'schedule': _scheduleSummary,
        'days': days,
        'startTime': _formatTime(_startTime),
        'endTime': _formatTime(_endTime),
        'feeMonthly': fee,
        'isActive': true,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.existingBatch == null) {
        data['createdAt'] = FieldValue.serverTimestamp();
      }

      final batchDoc = FirebaseFirestore.instance.collection('batches').doc(batchId);
      await batchDoc.set(data, SetOptions(merge: true));

      // Synchronize student records in batches/$batchId/students subcollection
      final batchStudents = batchDoc.collection('students');
      for (final p in _selectedPlayers) {
        final pid = p['id'] as String;
        await batchStudents.doc(pid).set({
          'id': pid,
          'playerId': pid,
          'name': p['name'],
          'avatarUrl': p['avatar'] ?? '',
          'sport': _selectedSport,
          'enrolledAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // Notify assigned coach
      if (_selectedCoachId != null && _selectedCoachId!.isNotEmpty) {
        try {
          await ref.read(notificationServiceProvider).createNotification(
            userId: _selectedCoachId!,
            title: 'New Academy Batch Assigned! \u26be',
            body: 'You have been assigned to lead "$name" ($_selectedSport) at ${_scheduleSummary}.',
            type: 'batch',
            refId: batchId,
          );
        } catch (_) {}
      }

      // Notify all enrolled players
      for (final pid in playerIds) {
        try {
          await ref.read(notificationServiceProvider).createNotification(
            userId: pid,
            title: 'Enrolled in $name! \U0001f3c6',
            body: 'Your academy enrolled you into $_selectedSport batch training on ${_scheduleSummary}.',
            type: 'batch',
            refId: batchId,
          );
        } catch (_) {}
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFFCCFF00)),
                const SizedBox(width: 8),
                Text(widget.existingBatch == null ? 'Squad Batch created successfully!' : 'Batch updated successfully!'),
              ],
            ),
            backgroundColor: const Color(0xFF0F172A),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save batch: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.white60 : Colors.black54;
    final cardBg = isDark ? const Color(0xFF131D31) : Colors.white;

    final totalSelected = _selectedPlayers.length;
    final totalPages = (totalSelected / _playersPerPage).ceil();
    final pageStart = _selectedPlayersPage * _playersPerPage;
    final paginatedPlayers = _selectedPlayers.skip(pageStart).take(_playersPerPage).toList();

    // Top 5 sports list, with current selection guaranteed to be included
    final visibleChips = List<String>.from(_top5Sports);
    if (!visibleChips.contains(_selectedSport)) {
      visibleChips.add(_selectedSport);
    }

    // Filtered search list for other sports
    final filteredOtherSports = SportsRegistry.sports
        .map((s) => s.name)
        .where((name) =>
            !visibleChips.contains(name) &&
            (_sportSearchQuery.isEmpty || name.toLowerCase().contains(_sportSearchQuery.toLowerCase())))
        .toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B101D) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        elevation: 0,
        title: Text(
          widget.existingBatch == null ? 'Dedicated Batch Formation' : 'Edit Academy Batch',
          style: AppTextStyles.title2.copyWith(fontWeight: FontWeight.w800, color: textPrimary),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveBatch,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCCFF00),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                elevation: 0,
              ),
              icon: _isSaving
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : const Icon(Icons.check_rounded, size: 18),
              label: Text(
                widget.existingBatch == null ? 'Create Batch' : 'Save Changes',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(SpacingScale.s16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // STEP 1: Sport Selection at Top (Top 5 + Search Bar)
                _buildSectionHeader('1. Choose Sport for Batch', Icons.sports_tennis_rounded, const Color(0xFF00E5FF), isDark),
                const SizedBox(height: SpacingScale.s10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: visibleChips.map((sportName) {
                    final isSel = _selectedSport == sportName;
                    return ChoiceChip(
                      label: Text(sportName),
                      selected: isSel,
                      selectedColor: const Color(0xFF00E5FF),
                      labelStyle: TextStyle(
                        color: isSel ? Colors.black : textPrimary,
                        fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                      ),
                      onSelected: (_) => setState(() {
                        _selectedSport = sportName;
                        _selectedCoachId = null;
                        _selectedCoachName = null;
                      }),
                    );
                  }).toList(),
                ),
                const SizedBox(height: SpacingScale.s10),
                // Compact Sport Search Bar
                TextField(
                  controller: _sportSearchCtrl,
                  style: TextStyle(color: textPrimary, fontSize: 13),
                  onChanged: (val) => setState(() => _sportSearchQuery = val.trim()),
                  decoration: InputDecoration(
                    hintText: 'Search other sports (Athletics, Swimming, Martial Arts...)...',
                    hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.5), fontSize: 12),
                    prefixIcon: const Icon(Icons.search_rounded, size: 18),
                    suffixIcon: _sportSearchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () {
                              _sportSearchCtrl.clear();
                              setState(() => _sportSearchQuery = '');
                            },
                          )
                        : null,
                    isDense: true,
                    filled: true,
                    fillColor: cardBg,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
                if (_sportSearchQuery.isNotEmpty && filteredOtherSports.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06)),
                    ),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: filteredOtherSports.map((s) {
                        return ActionChip(
                          avatar: const Icon(Icons.add, size: 14),
                          label: Text(s, style: TextStyle(fontSize: 12, color: textPrimary)),
                          backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                          onPressed: () {
                            setState(() {
                              _selectedSport = s;
                              _selectedCoachId = null;
                              _selectedCoachName = null;
                              _sportSearchCtrl.clear();
                              _sportSearchQuery = '';
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
                const SizedBox(height: SpacingScale.s24),

                // STEP 2: Batch Name & Capacity (Responsive Layout to prevent pixel overflow)
                _buildSectionHeader('2. Batch Details & Capacity', Icons.groups_rounded, const Color(0xFFCCFF00), isDark),
                const SizedBox(height: SpacingScale.s10),
                Container(
                  padding: const EdgeInsets.all(SpacingScale.s16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: AppRadius.brXl2,
                    border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Batch Title / Name', style: AppTextStyles.label.copyWith(color: textPrimary, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _nameCtrl,
                        style: TextStyle(color: textPrimary),
                        decoration: InputDecoration(
                          hintText: 'e.g., Morning Pro U-16 Football Squad',
                          hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.5)),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: SpacingScale.s16),
                      LayoutBuilder(
                        builder: (ctx, constraints) {
                          final isNarrow = constraints.maxWidth < 450;
                          final capacityWidget = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Max Batch Capacity', style: AppTextStyles.label.copyWith(color: textPrimary, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton.filledTonal(
                                    onPressed: () {
                                      if (_capacity > 1) {
                                        setState(() {
                                          _capacity--;
                                          _capacityCtrl.text = '$_capacity';
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.remove, size: 16),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  const SizedBox(width: 8),
                                  Text('$_capacity Athletes', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: textPrimary)),
                                  const SizedBox(width: 8),
                                  IconButton.filledTonal(
                                    onPressed: () {
                                      setState(() {
                                        _capacity++;
                                        _capacityCtrl.text = '$_capacity';
                                      });
                                    },
                                    icon: const Icon(Icons.add, size: 16),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ],
                              ),
                            ],
                          );

                          final feeWidget = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Monthly Fee (\u20B9)', style: AppTextStyles.label.copyWith(color: textPrimary, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _feeCtrl,
                                keyboardType: TextInputType.number,
                                style: TextStyle(color: textPrimary),
                                decoration: InputDecoration(
                                  prefixText: '\u20B9 ',
                                  hintText: '1500',
                                  filled: true,
                                  fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                ),
                              ),
                            ],
                          );

                          if (isNarrow) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                capacityWidget,
                                const SizedBox(height: SpacingScale.s16),
                                feeWidget,
                              ],
                            );
                          }

                          return Row(
                            children: [
                              Expanded(child: capacityWidget),
                              const SizedBox(width: 16),
                              Expanded(child: feeWidget),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: SpacingScale.s24),

                // STEP 3: Assigned Coach (Filtered to coaches teaching this sport & associated with academy)
                _buildSectionHeader('3. Assign Certified Coach', Icons.sports_rounded, const Color(0xFFFF9100), isDark),
                const SizedBox(height: 4),
                Text(
                  'Only certified coaches teaching $_selectedSport and affiliated with this academy are listed.',
                  style: AppTextStyles.caption.copyWith(color: textSecondary),
                ),
                const SizedBox(height: SpacingScale.s10),
                _buildCoachSelector(isDark, cardBg, textPrimary, textSecondary),
                const SizedBox(height: SpacingScale.s24),

                // STEP 4: Select Students with Search & Pagination (>5)
                _buildSectionHeader('4. Select & Add Students', Icons.person_add_alt_1_rounded, const Color(0xFF00F59B), isDark),
                const SizedBox(height: 4),
                Text(
                  'Search athletes from registry and enroll them into this batch (${_selectedPlayers.length} of $_capacity capacity filled - not required to fill full capacity). Tap athlete to view profile.',
                  style: AppTextStyles.caption.copyWith(color: textSecondary),
                ),
                const SizedBox(height: SpacingScale.s10),
                _buildPlayerSearchAndEnroll(isDark, cardBg, textPrimary, textSecondary),
                const SizedBox(height: SpacingScale.s16),

                // Enrolled Players List with Pagination
                if (_selectedPlayers.isNotEmpty) ...[
                  Text(
                    'Enrolled Students in this Batch ($totalSelected)',
                    style: AppTextStyles.title3.copyWith(fontWeight: FontWeight.w700, color: textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: AppRadius.brXl2,
                      border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08)),
                    ),
                    child: Column(
                      children: [
                        for (final p in paginatedPlayers)
                          ListTile(
                            onTap: () => context.push('/profile/${p['id']}'),
                            leading: CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                              backgroundImage: (p['avatar'] != null && (p['avatar'] as String).isNotEmpty)
                                  ? NetworkImage(p['avatar'] as String)
                                  : null,
                              child: (p['avatar'] == null || (p['avatar'] as String).isEmpty)
                                  ? Text((p['name'] as String).isNotEmpty ? (p['name'] as String)[0].toUpperCase() : 'A',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary))
                                  : null,
                            ),
                            title: Text(p['name'] as String, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                            subtitle: Text('${p['sport']} \u2022 Tap to view profile', style: TextStyle(color: textSecondary, fontSize: 11)),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.redAccent, size: 20),
                              tooltip: 'Remove from batch',
                              onPressed: () {
                                setState(() {
                                  _selectedPlayers.removeWhere((item) => item['id'] == p['id']);
                                  if (_selectedPlayersPage > 0 && pageStart >= _selectedPlayers.length) {
                                    _selectedPlayersPage = (_selectedPlayers.length / _playersPerPage).ceil() - 1;
                                    if (_selectedPlayersPage < 0) _selectedPlayersPage = 0;
                                  }
                                });
                              },
                            ),
                          ),

                        // Pagination Bar if > 5 players
                        if (totalPages > 1) ...[
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Showing ${pageStart + 1}-${(pageStart + _playersPerPage).clamp(1, totalSelected)} of $totalSelected',
                                  style: TextStyle(fontSize: 12, color: textSecondary),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.chevron_left_rounded),
                                      onPressed: _selectedPlayersPage > 0
                                          ? () => setState(() => _selectedPlayersPage--)
                                          : null,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    Text(
                                      '${_selectedPlayersPage + 1} / $totalPages',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textPrimary),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.chevron_right_rounded),
                                      onPressed: _selectedPlayersPage < totalPages - 1
                                          ? () => setState(() => _selectedPlayersPage++)
                                          : null,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: SpacingScale.s24),

                // STEP 5: Schedule Timing & Recurrence
                _buildSectionHeader('5. Schedule & Training Timings', Icons.schedule_rounded, const Color(0xFFB388FF), isDark),
                const SizedBox(height: SpacingScale.s10),
                Container(
                  padding: const EdgeInsets.all(SpacingScale.s16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: AppRadius.brXl2,
                    border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Weekly Training Days', style: AppTextStyles.label.copyWith(color: textPrimary, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _allDays.map((d) {
                          final isSel = _selectedDays.contains(d);
                          return FilterChip(
                            label: Text(d),
                            selected: isSel,
                            selectedColor: const Color(0xFFB388FF).withValues(alpha: 0.3),
                            checkmarkColor: const Color(0xFFB388FF),
                            labelStyle: TextStyle(
                              color: isSel ? const Color(0xFFB388FF) : textPrimary,
                              fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                            ),
                            onSelected: (val) {
                              setState(() {
                                if (val) {
                                  _selectedDays.add(d);
                                } else {
                                  if (_selectedDays.length > 1) _selectedDays.remove(d);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: SpacingScale.s16),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final t = await showTimePicker(context: context, initialTime: _startTime);
                                if (t != null) setState(() => _startTime = t);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Start Time', style: TextStyle(fontSize: 11, color: textSecondary)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFFB388FF)),
                                        const SizedBox(width: 6),
                                        Text(_formatTime(_startTime), style: TextStyle(fontWeight: FontWeight.w800, color: textPrimary, fontSize: 14)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final t = await showTimePicker(context: context, initialTime: _endTime);
                                if (t != null) setState(() => _endTime = t);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('End Time', style: TextStyle(fontSize: 11, color: textSecondary)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.timelapse_rounded, size: 16, color: Color(0xFFB388FF)),
                                        const SizedBox(width: 6),
                                        Text(_formatTime(_endTime), style: TextStyle(fontWeight: FontWeight.w800, color: textPrimary, fontSize: 14)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: SpacingScale.s12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB388FF).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.event_note_rounded, size: 18, color: Color(0xFFB388FF)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _scheduleSummary,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFFB388FF)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: SpacingScale.s32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveBatch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCCFF00),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.brXl),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                        : Text(
                            widget.existingBatch == null ? 'Complete Batch Creation & Notify' : 'Save Batch Updates',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.3),
                          ),
                  ),
                ),
                const SizedBox(height: SpacingScale.s40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: AppTextStyles.title3.copyWith(fontWeight: FontWeight.w800, color: isDark ? Colors.white : Colors.black87),
        ),
      ],
    );
  }

  Widget _buildCoachSelector(bool isDark, Color cardBg, Color textPrimary, Color textSecondary) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('coaches').snapshots(),
      builder: (ctx, snap) {
        if (!snap.hasData) {
          return const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()));
        }

        // Filter: coaches with matching sport AND working at this academy
        final matchingCoaches = snap.data!.docs.map((doc) => CoachModel.fromDoc(doc)).where((c) {
          final sportMatch = (c.sports != null && c.sports!.any((s) => s.toLowerCase() == _selectedSport.toLowerCase())) ||
              (c.specialization != null && c.specialization!.toLowerCase().contains(_selectedSport.toLowerCase()));
          final academyMatch = c.academyId == widget.academyId || c.academyId == null || c.academyId!.isEmpty;
          return sportMatch && academyMatch;
        }).toList();

        if (matchingCoaches.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'No coaches currently mapped to $_selectedSport in this academy. You can still create the batch and assign a coach later.',
                    style: TextStyle(fontSize: 12, color: textSecondary),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: AppRadius.brXl2,
            border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08)),
          ),
          child: Column(
            children: [
              RadioListTile<String?>(
                value: null,
                groupValue: _selectedCoachId,
                title: Text('Assign Later (No Coach Selected)', style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                onChanged: (val) => setState(() {
                  _selectedCoachId = null;
                  _selectedCoachName = null;
                }),
              ),
              for (final coach in matchingCoaches)
                RadioListTile<String?>(
                  value: coach.coachId,
                  groupValue: _selectedCoachId,
                  secondary: CircleAvatar(
                    radius: 18,
                    backgroundImage: coach.photoUrl != null && coach.photoUrl!.isNotEmpty ? NetworkImage(coach.photoUrl!) : null,
                    child: coach.photoUrl == null ? Text(coach.name.isNotEmpty ? coach.name[0].toUpperCase() : 'C') : null,
                  ),
                  title: Row(
                    children: [
                      Text(coach.name, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                      if (coach.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, size: 14, color: AppColors.primary),
                      ],
                    ],
                  ),
                  subtitle: Text(
                    '${coach.specialization ?? _selectedSport} \u2022 ${coach.experience} yrs exp',
                    style: TextStyle(color: textSecondary, fontSize: 12),
                  ),
                  onChanged: (val) => setState(() {
                    _selectedCoachId = val;
                    _selectedCoachName = coach.name;
                  }),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlayerSearchAndEnroll(bool isDark, Color cardBg, Color textPrimary, Color textSecondary) {
    return Column(
      children: [
        TextField(
          controller: _searchPlayerCtrl,
          style: TextStyle(color: textPrimary),
          onChanged: (val) => setState(() => _playerSearchQuery = val.trim().toLowerCase()),
          decoration: InputDecoration(
            hintText: 'Search athletes by name to add...',
            hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.5)),
            prefixIcon: const Icon(Icons.search_rounded),
            filled: true,
            fillColor: cardBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 8),

        // Search Results List (Stream from players collection)
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('players').limit(20).snapshots(),
          builder: (ctx, snap) {
            if (!snap.hasData) return const SizedBox.shrink();

            final results = snap.data!.docs.where((doc) {
              final d = doc.data();
              final name = (d['name'] as String? ?? '').toLowerCase();
              final alreadySelected = _selectedPlayers.any((p) => p['id'] == doc.id);
              if (alreadySelected) return false;
              if (_playerSearchQuery.isEmpty) return true;
              return name.contains(_playerSearchQuery);
            }).take(4).toList();

            if (results.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  _playerSearchQuery.isEmpty ? 'No more athletes in registry' : 'No matching athletes found',
                  style: TextStyle(fontSize: 12, color: textSecondary),
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: AppRadius.brXl2,
                border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08)),
              ),
              child: Column(
                children: results.map((doc) {
                  final data = doc.data();
                  final name = data['name'] as String? ?? 'Athlete';
                  final avatar = data['avatarUrl'] as String? ?? '';
                  final sport = (data['sports'] is List && (data['sports'] as List).isNotEmpty)
                      ? (data['sports'] as List).first
                      : 'Athlete';

                  return ListTile(
                    onTap: () => context.push('/profile/${doc.id}'),
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFF00F59B).withValues(alpha: 0.15),
                      backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
                      child: avatar.isEmpty
                          ? Text(name.isNotEmpty ? name[0].toUpperCase() : 'A',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF00F59B)))
                          : null,
                    ),
                    title: Text(name, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                    subtitle: Text('$sport \u2022 Tap to view profile', style: TextStyle(color: textSecondary, fontSize: 11)),
                    trailing: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedPlayers.add({
                            'id': doc.id,
                            'name': name,
                            'avatar': avatar,
                            'sport': sport,
                          });
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00F59B),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add in Batch', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}
