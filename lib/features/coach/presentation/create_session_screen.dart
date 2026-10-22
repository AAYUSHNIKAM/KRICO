import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../design_system/widgets/page_headers/page_hero.dart';
import '../../../design_system/radius/radius.dart';
import '../../../design_system/tokens/duration_tokens.dart';
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
  bool _hovered = false;
  bool _titleFocused = false;
  bool _sportFocused = false;
  bool _descFocused = false;
  bool _capacityFocused = false;
  bool _venueFocused = false;
  bool _priceFocused = false;

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          PageHero(
            title: 'Create Session',
            subtitle: 'Set up a new training session',
            gradientColors: [AppColors.primary, AppColors.primaryLight],
            expandedHeight: 120,
            showPhoneHeader: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildField('Session Title', _titleCtrl, Icons.title_rounded, 'e.g., Cricket Bowling Practice', isDark, _titleFocused, (v) => setState(() => _titleFocused = v)),
                          const SizedBox(height: 14),
                          _buildField('Sport', _sportCtrl, Icons.sports_rounded, 'e.g., Cricket', isDark, _sportFocused, (v) => setState(() => _sportFocused = v)),
                          const SizedBox(height: 14),
                          _buildField('Description', _descCtrl, Icons.description_rounded, 'Session details...', isDark, _descFocused, (v) => setState(() => _descFocused = v), maxLines: 3),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDateField(context, isDark),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTimeField(context, isDark),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _buildField('Capacity', _capacityCtrl, Icons.people_rounded, 'e.g., 10', isDark, _capacityFocused, (v) => setState(() => _capacityFocused = v), keyboardType: TextInputType.number),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildField('Price (₹)', _priceCtrl, Icons.currency_rupee_rounded, 'e.g., 500', isDark, _priceFocused, (v) => setState(() => _priceFocused = v), keyboardType: TextInputType.number),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _buildField('Venue', _venueCtrl, Icons.location_on_rounded, 'e.g., Sports Complex', isDark, _venueFocused, (v) => setState(() => _venueFocused = v)),
                          const SizedBox(height: 14),
                          _buildOnlineToggle(isDark),
                          const SizedBox(height: 24),
                          _buildCreateButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineToggle(bool isDark) {
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    return GestureDetector(
      onTap: () => setState(() => _isOnline = !_isOnline),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Online Session', style: AppTextStyles.body.copyWith(color: textPrimary)),
                Text('Conduct session virtually', style: AppTextStyles.bodySm.copyWith(color: textSecondary)),
              ],
            ),
          ),
          AnimatedContainer(
            duration: DurationTokens.fast,
            width: 48,
            height: 26,
            decoration: BoxDecoration(
              color: _isOnline ? AppColors.primary : (isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary),
              borderRadius: AppRadius.brFull,
            ),
            child: AnimatedAlign(
              duration: DurationTokens.fast,
              alignment: _isOnline ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 22,
                height: 22,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.brFull,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
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

  Widget _buildCreateButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: _isCreating ? null : () => _createSession(ref.read(authStateProvider).value?.uid ?? ''),
        child: AnimatedContainer(
          duration: DurationTokens.fast,
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: _hovered ? [AppColors.primaryHover, AppColors.primary] : [AppColors.primary, AppColors.primaryLight]),
            borderRadius: AppRadius.brXl2,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: _hovered ? 0.4 : 0.2),
                blurRadius: _hovered ? 20 : 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: _isCreating
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('Create Session', style: AppTextStyles.buttonLg.copyWith(color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon, String hint, bool isDark, bool focused, ValueChanged<bool> onFocusChanged, {int maxLines = 1, TextInputType? keyboardType}) {
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    return AnimatedContainer(
      duration: DurationTokens.fast,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary,
        borderRadius: AppRadius.brLg,
        border: Border.all(color: focused ? AppColors.primary : borderColor, width: focused ? 1.5 : 1),
      ),
      child: Focus(
        onFocusChange: onFocusChanged,
        child: TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: AppTextStyles.body.copyWith(color: textPrimary),
          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            labelStyle: AppTextStyles.body.copyWith(color: textSecondary),
            hintStyle: AppTextStyles.bodySm.copyWith(color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
            prefixIcon: Icon(icon, size: 20, color: textSecondary),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context, bool isDark) {
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    return AnimatedContainer(
      duration: DurationTokens.fast,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary,
        borderRadius: AppRadius.brLg,
        border: Border.all(color: borderColor, width: 1),
      ),
      child: TextFormField(
        readOnly: true,
        style: AppTextStyles.body.copyWith(color: textPrimary),
        decoration: InputDecoration(
          labelText: 'Date',
          hintText: 'Select date',
          labelStyle: AppTextStyles.body.copyWith(color: textSecondary),
          hintStyle: AppTextStyles.bodySm.copyWith(color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
          prefixIcon: const Icon(Icons.calendar_today_rounded, size: 20),
          prefixIconColor: textSecondary,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                colorScheme: ColorScheme.dark(primary: AppColors.primary, surface: isDark ? AppColors.surface : AppColors.lightSurface),
              ),
              child: child!,
            ),
          );
          if (date != null) setState(() => _selectedDate = date);
        },
      ),
    );
  }

  Widget _buildTimeField(BuildContext context, bool isDark) {
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    return AnimatedContainer(
      duration: DurationTokens.fast,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary,
        borderRadius: AppRadius.brLg,
        border: Border.all(color: borderColor, width: 1),
      ),
      child: TextFormField(
        readOnly: true,
        style: AppTextStyles.body.copyWith(color: textPrimary),
        decoration: InputDecoration(
          labelText: 'Time',
          hintText: 'Select time',
          labelStyle: AppTextStyles.body.copyWith(color: textSecondary),
          hintStyle: AppTextStyles.bodySm.copyWith(color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
          prefixIcon: const Icon(Icons.access_time_rounded, size: 20),
          prefixIconColor: textSecondary,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        controller: TextEditingController(text: _selectedTime != null ? _selectedTime!.format(context) : ''),
        validator: (v) => _selectedTime == null ? 'Select a time' : null,
        onTap: () async {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
            builder: (context, child) => Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.dark(primary: AppColors.primary, surface: isDark ? AppColors.surface : AppColors.lightSurface),
              ),
              child: child!,
            ),
          );
          if (time != null) setState(() => _selectedTime = time);
        },
      ),
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
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }
}
