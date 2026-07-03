import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
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
  final _sportController = TextEditingController();
  final _capacityController = TextEditingController();
  final _scheduleController = TextEditingController();
  bool _showForm = false;
  bool _isCreating = false;
  String? _editingBatchId;

  @override
  void dispose() {
    _nameController.dispose();
    _sportController.dispose();
    _capacityController.dispose();
    _scheduleController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _nameController.clear();
    _sportController.clear();
    _capacityController.clear();
    _scheduleController.clear();
    _editingBatchId = null;
    setState(() => _showForm = false);
  }

  Future<void> _createBatch() async {
    if (_nameController.text.isEmpty || _sportController.text.isEmpty) return;
    setState(() => _isCreating = true);
    try {
      final service = ref.read(academyServiceProvider);
      if (_editingBatchId != null) {
        await service.updateBatch(_editingBatchId!, {
          'name': _nameController.text.trim(),
          'sport': _sportController.text.trim(),
          'capacity': int.tryParse(_capacityController.text) ?? 10,
          'schedule': _scheduleController.text.trim(),
        });
      } else {
        await service.createBatch(
          academyId: widget.academyId,
          name: _nameController.text.trim(),
          sport: _sportController.text.trim(),
          capacity: int.tryParse(_capacityController.text) ?? 10,
          schedule: _scheduleController.text.trim(),
        );
      }
      _resetForm();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  void _editBatch(Map<String, dynamic> data) {
    _nameController.text = data['name'] as String? ?? '';
    _sportController.text = data['sport'] as String? ?? '';
    _capacityController.text = '${data['capacity'] as num? ?? ''}';
    _scheduleController.text = data['schedule'] as String? ?? '';
    _editingBatchId = data['batchId'] as String?;
    setState(() => _showForm = true);
  }

  @override
  Widget build(BuildContext context) {
    final batchesAsync = ref.watch(academyBatchesProvider(widget.academyId));

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.surfaceDark, AppColors.surfaceMid],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 160,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.gradientAccent,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Batches',
                              style: AppTextStyles.displaySmall.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text('Manage training batches',
                              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(_showForm ? Icons.close_rounded : Icons.add_rounded, color: Colors.white),
                  onPressed: () => setState(() => _showForm = !_showForm),
                ),
              ],
            ),
                if (_showForm)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(_editingBatchId != null ? 'Edit Batch' : 'New Batch',
                              style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600)),
                          const Spacer(),
                          if (_editingBatchId != null)
                            TextButton(
                              onPressed: _resetForm,
                              child: const Text('Cancel Edit', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _nameController,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Batch Name',
                          prefixIcon: Icon(Icons.group_rounded, color: AppColors.textDim),
                          filled: true,
                          fillColor: Color(0xFF12121A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _sportController,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Sport',
                          prefixIcon: Icon(Icons.sports_rounded, color: AppColors.textDim),
                          filled: true,
                          fillColor: Color(0xFF12121A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _capacityController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: AppColors.textPrimary),
                              decoration: const InputDecoration(
                                labelText: 'Capacity',
                                prefixIcon: Icon(Icons.people_rounded, color: AppColors.textDim),
                                filled: true,
                                fillColor: Color(0xFF12121A),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _scheduleController,
                              style: const TextStyle(color: AppColors.textPrimary),
                              decoration: const InputDecoration(
                                labelText: 'Schedule',
                                prefixIcon: Icon(Icons.schedule_rounded, color: AppColors.textDim),
                                filled: true,
                                fillColor: Color(0xFF12121A),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GradientButton(
                        onPressed: _isCreating ? null : _createBatch,
                        isLoading: _isCreating,
                        child: Text(_editingBatchId != null ? 'Update Batch' : 'Create Batch',
                            style: AppTextStyles.buttonLarge.copyWith(color: Colors.white)),
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: -0.1, end: 0),
              ),
            batchesAsync.when(
              data: (snap) {
                final docs = snap.docs;
                if (docs.isEmpty && !_showForm) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.group_outlined, size: 64, color: AppColors.textDim),
                          SizedBox(height: 16),
                          Text('No batches yet', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                          SizedBox(height: 8),
                          Text('Create your first batch to get started',
                              style: TextStyle(color: AppColors.textDim, fontSize: 13)),
                        ],
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final data = docs[index].data();
                      final name = data['name'] as String? ?? 'Unnamed';
                      final sport = data['sport'] as String? ?? 'General';
                      final capacity = (data['capacity'] as num?)?.toInt() ?? 0;
                      final enrolled = (data['enrolled'] as num?)?.toInt() ?? 0;
                      final schedule = data['schedule'] as String? ?? 'Flexible';
                      final fillPercent = capacity > 0 ? enrolled / capacity : 0.0;

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardDark,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.1)),
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
                                      gradient: LinearGradient(
                                        colors: [AppColors.accent, AppColors.accent.withValues(alpha: 0.7)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(Icons.group_rounded, color: Colors.white, size: 24),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(name,
                                            style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600),
                                            maxLines: 1, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 2),
                                        Text('$sport \u2022 $schedule',
                                            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                                            maxLines: 1, overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: fillPercent >= 1.0
                                            ? AppColors.error.withValues(alpha: 0.12)
                                            : AppColors.success.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text('$enrolled/$capacity',
                                          style: TextStyle(
                                            color: fillPercent >= 1.0 ? AppColors.error : AppColors.success,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          )),
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
                                  backgroundColor: AppColors.borderLight.withValues(alpha: 0.3),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    fillPercent >= 1.0 ? AppColors.error : AppColors.success,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_rounded, size: 16, color: AppColors.info),
                                    onPressed: () => _editBatch(data),
                                    visualDensity: VisualDensity.compact,
                                    tooltip: 'Edit',
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    icon: const Icon(Icons.archive_rounded, size: 16, color: AppColors.warning),
                                    onPressed: () => _confirmDeleteBatch(context, data['batchId'] as String? ?? ''),
                                    visualDensity: VisualDensity.compact,
                                    tooltip: 'Archive',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: (index * 60).ms).slideY(begin: 0.1, end: 0);
                    },
                    childCount: docs.length,
                  ),
                );
              },
              loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('Failed to load batches', style: TextStyle(color: AppColors.error))),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteBatch(BuildContext context, String batchId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceMid,
        title: const Text('Archive Batch'),
        content: const Text('This will archive the batch. Students will no longer be able to join. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(academyServiceProvider).deleteBatch(batchId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Batch archived'), backgroundColor: AppColors.success),
              );
            },
            child: const Text('Archive', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
