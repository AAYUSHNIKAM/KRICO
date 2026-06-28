import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/providers.dart';

class CreateSessionScreen extends ConsumerStatefulWidget {
  const CreateSessionScreen({super.key});

  @override
  ConsumerState<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends ConsumerState<CreateSessionScreen> {
  final _titleCtrl = TextEditingController();
  final _sportCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  final _venueCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isOnline = false;
  bool _isCreating = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _sportCtrl.dispose();
    _descCtrl.dispose();
    _capacityCtrl.dispose();
    _venueCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final coachId = authState.value?.uid ?? '';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.gradientPrimary,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Create Session', style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                    Text('Set up a new training session', style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildField('Session Title', _titleCtrl, Icons.title_rounded, 'e.g., Cricket Bowling Practice'),
                      const SizedBox(height: 14),
                      _buildField('Sport', _sportCtrl, Icons.sports_rounded, 'e.g., Cricket'),
                      const SizedBox(height: 14),
                      _buildField('Description', _descCtrl, Icons.description_rounded, 'Session details...', maxLines: 3),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateField(context),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTimeField(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _buildField('Capacity', _capacityCtrl, Icons.people_rounded, 'e.g., 10', keyboardType: TextInputType.number),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildField('Price (₹)', _priceCtrl, Icons.currency_rupee_rounded, 'e.g., 500', keyboardType: TextInputType.number),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildField('Venue', _venueCtrl, Icons.location_on_rounded, 'e.g., Sports Complex'),
                      const SizedBox(height: 14),
                      SwitchListTile(
                        title: const Text('Online Session', style: TextStyle(color: AppColors.textPrimary)),
                        subtitle: const Text('Conduct session virtually', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        value: _isOnline,
                        onChanged: (v) => setState(() => _isOnline = v),
                        activeColor: AppColors.primary,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                      const SizedBox(height: 24),
                      GradientButton(
                        onPressed: _isCreating ? null : () => _createSession(coachId),
                        isLoading: _isCreating,
                        child: const Text('Create Session', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon, String hint, {int maxLines = 1, TextInputType? keyboardType}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: AppTextStyles.bodyMedium,
      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
        hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textDim),
        prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surfaceMid,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.borderLight)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.borderLight.withValues(alpha: 0.5))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return TextFormField(
      readOnly: true,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: 'Date',
        hintText: 'Select date',
        labelStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
        hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textDim),
        prefixIcon: const Icon(Icons.calendar_today_rounded, size: 20, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surfaceMid,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.borderLight)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.borderLight.withValues(alpha: 0.5))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      controller: TextEditingController(text: _selectedDate != null ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}' : ''),
      validator: (v) => _selectedDate == null ? 'Select a date' : null,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now().add(const Duration(days: 1)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 90)),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(primary: AppColors.primary, surface: AppColors.cardDark),
            ),
            child: child!,
          ),
        );
        if (date != null) setState(() => _selectedDate = date);
      },
    );
  }

  Widget _buildTimeField(BuildContext context) {
    return TextFormField(
      readOnly: true,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: 'Time',
        hintText: 'Select time',
        labelStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
        hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textDim),
        prefixIcon: const Icon(Icons.access_time_rounded, size: 20, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surfaceMid,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.borderLight)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.borderLight.withValues(alpha: 0.5))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      controller: TextEditingController(text: _selectedTime != null ? _selectedTime!.format(context) : ''),
      validator: (v) => _selectedTime == null ? 'Select a time' : null,
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(primary: AppColors.primary, surface: AppColors.cardDark),
            ),
            child: child!,
          ),
        );
        if (time != null) setState(() => _selectedTime = time);
      },
    );
  }

  Future<void> _createSession(String coachId) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isCreating = true);
    try {
      final dateTime = DateTime(
        _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
        _selectedTime!.hour, _selectedTime!.minute,
      );
      final coachService = ref.read(coachServiceProvider);
      await coachService.createSession(
        coachId: coachId,
        title: _titleCtrl.text.trim(),
        sport: _sportCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        dateTime: dateTime,
        capacity: int.tryParse(_capacityCtrl.text) ?? 1,
        venue: _venueCtrl.text.trim(),
        price: double.tryParse(_priceCtrl.text) ?? 0,
        isOnline: _isOnline,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session created!'), backgroundColor: AppColors.success),
        );
        context.pop();
      }
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
}
