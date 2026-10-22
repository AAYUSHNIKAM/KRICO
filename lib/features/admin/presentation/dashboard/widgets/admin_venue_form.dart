import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../design_system/colors/app_colors.dart';
import '../../../../../design_system/typography/text_styles.dart';
import '../../../../../design_system/spacing/spacing_scale.dart';
import '../../../../../design_system/radius/radius.dart';
import '../../../../../models/venue_model.dart';
import '../../../../../services/providers.dart';
import 'admin_section_header.dart';

class AdminVenueForm extends ConsumerStatefulWidget {
  const AdminVenueForm({super.key});

  @override
  ConsumerState<AdminVenueForm> createState() => _AdminVenueFormState();
}

class _AdminVenueFormState extends ConsumerState<AdminVenueForm> {
  final _venueFormKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _sportCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  final _amenitiesCtrl = TextEditingController();
  bool _isAddingVenue = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _sportCtrl.dispose();
    _capacityCtrl.dispose();
    _amenitiesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitVenue() async {
    if (!_venueFormKey.currentState!.validate()) return;
    setState(() => _isAddingVenue = true);
    try {
      final venueService = ref.read(venueServiceProvider);
      final venue = VenueModel(
        venueId: '',
        name: _nameCtrl.text.trim(),
        address: _locationCtrl.text.trim(),
        sports: [_sportCtrl.text.trim()],
        capacity: int.tryParse(_capacityCtrl.text.trim()),
        amenities: _amenitiesCtrl.text.trim().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        isVerified: false,
        createdAt: DateTime.now(),
      );
      await venueService.addVenue(venue);
      _venueFormKey.currentState!.reset();
      _nameCtrl.clear();
      _locationCtrl.clear();
      _sportCtrl.clear();
      _capacityCtrl.clear();
      _amenitiesCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Venue added successfully'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add venue: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isAddingVenue = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminSectionHeader(title: 'Manual Venue Addition', subtitle: null),
        SizedBox(height: SpacingScale.s12),
        Container(
          padding: EdgeInsets.all(SpacingScale.s16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.card : AppColors.lightCard,
            borderRadius: AppRadius.brXl3,
            border: Border.all(color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5)),
          ),
          child: Form(
            key: _venueFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: AppRadius.brLg,
                      ),
                      child: const Icon(Icons.add_location_alt_rounded, color: AppColors.primary, size: 20),
                    ),
                    SizedBox(width: SpacingScale.s10),
                    Text('Add New Venue', style: AppTextStyles.title3.copyWith(fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary)),
                  ],
                ),
                SizedBox(height: SpacingScale.s16),
                _buildFormField(
                  isDark: isDark,
                  controller: _nameCtrl,
                  label: 'Venue Name',
                  hint: 'Enter venue name',
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                SizedBox(height: SpacingScale.s10),
                _buildFormField(
                  isDark: isDark,
                  controller: _locationCtrl,
                  label: 'Location',
                  hint: 'Enter address or coordinates',
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                SizedBox(height: SpacingScale.s10),
                Row(
                  children: [
                    Expanded(
                      child: _buildFormField(
                        isDark: isDark,
                        controller: _sportCtrl,
                        label: 'Sport Type',
                        hint: 'e.g., Cricket',
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                    SizedBox(width: SpacingScale.s8),
                    Expanded(
                      child: _buildFormField(
                        isDark: isDark,
                        controller: _capacityCtrl,
                        label: 'Capacity',
                        hint: 'Number',
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          if (int.tryParse(v.trim()) == null) return 'Invalid number';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: SpacingScale.s10),
                _buildFormField(
                  isDark: isDark,
                  controller: _amenitiesCtrl,
                  label: 'Amenities',
                  hint: 'Comma separated (e.g., Parking, Lights)',
                ),
                SizedBox(height: SpacingScale.s16),
                Row(
                  children: [
                    Expanded(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: SpacingScale.s12),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: AppRadius.brXl2,
                              border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder),
                            ),
                            child: Text('Add Photos', style: AppTextStyles.buttonLg.copyWith(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: SpacingScale.s12),
                    Expanded(
                      flex: 2,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: _isAddingVenue ? null : _submitVenue,
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [AppColors.primary, AppColors.orange]),
                              borderRadius: AppRadius.brXl2,
                            ),
                            child: Center(
                              child: _isAddingVenue
                                  ? const SizedBox(
                                      width: 20, height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : Text('Submit Venue', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormField({
    required bool isDark,
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTextStyles.body.copyWith(color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: AppTextStyles.label.copyWith(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
        hintStyle: AppTextStyles.bodySm.copyWith(color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: SpacingScale.s12, vertical: SpacingScale.s12),
        filled: true,
        fillColor: isDark ? AppColors.surface : AppColors.lightSurfaceSecondary,
        border: OutlineInputBorder(borderRadius: AppRadius.brXl2, borderSide: BorderSide(color: isDark ? AppColors.border : AppColors.lightBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: AppRadius.brXl2, borderSide: BorderSide(color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5))),
        focusedBorder: OutlineInputBorder(borderRadius: AppRadius.brXl2, borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: AppRadius.brXl2, borderSide: const BorderSide(color: AppColors.danger)),
      ),
    );
  }
}
