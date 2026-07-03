import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../models/venue_model.dart';
import '../../../services/providers.dart';

class VenueDetailScreen extends ConsumerWidget {
  const VenueDetailScreen({super.key, required this.venueId});
  final String venueId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final venueAsync = ref.watch(venueProvider(venueId));

    return Scaffold(
      body: venueAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Failed to load venue', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.invalidate(venueProvider(venueId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (venue) => _VenueDetailContent(venue: venue),
      ),
    );
  }
}

class _VenueDetailContent extends StatelessWidget {
  const _VenueDetailContent({required this.venue});
  final VenueModel venue;

  @override
  Widget build(BuildContext context) {
    final location = [venue.city, venue.address].where((s) => s != null && s.isNotEmpty).join(', ');
    final sportLabel = venue.sports?.join(', ') ?? 'Multi-sport';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.gradientPrimary,
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.15,
                        child: CustomPaint(
                          painter: _GridPainter(),
                        ),
                      ),
                    ),
                    Center(
                      child: Icon(Icons.stadium_rounded, size: 100, color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(venue.name, style: AppTextStyles.headlineSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.location_on_rounded, size: 16, color: Colors.white.withValues(alpha: 0.8)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  location.isNotEmpty ? location : 'Location unavailable',
                                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.sports_rounded, size: 14, color: Colors.white.withValues(alpha: 0.7)),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(sportLabel, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.caption.copyWith(color: Colors.white.withValues(alpha: 0.7))),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildInfoChipsRow(context),
                const SizedBox(height: 24),
                const SectionTitle(title: 'About'),
                const SizedBox(height: 8),
                Text(
                  venue.description ?? 'No description available for this venue.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.6),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 24),
                const SectionTitle(title: 'Amenities'),
                const SizedBox(height: 12),
                _buildAmenitiesGrid(context),
                const SizedBox(height: 24),
                const SectionTitle(title: 'Available Time Slots'),
                const SizedBox(height: 12),
                ...List.generate(6, (i) => _buildSlotCard(context, i)),
                const SizedBox(height: 24),
                _buildBookButton(context),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChipsRow(BuildContext context) {
    final chips = <Widget>[
      _InfoChip(icon: Icons.star_rounded, label: venue.rating.toStringAsFixed(1), color: AppColors.gold),
      const SizedBox(width: 8),
      _InfoChip(icon: Icons.location_on_rounded, label: venue.city ?? 'N/A', color: AppColors.primary),
      const SizedBox(width: 8),
      _InfoChip(
        icon: Icons.people_rounded,
        label: venue.capacity != null ? '${venue.capacity} cap' : 'N/A',
        color: AppColors.accent,
      ),
    ];
    if (venue.pricePerHour != null) {
      chips.add(const SizedBox(width: 8));
      chips.add(_InfoChip(
        icon: Icons.currency_rupee_rounded,
        label: '₹${venue.pricePerHour!.toStringAsFixed(0)}/hr',
        color: AppColors.success,
      ));
    }
    return Row(children: chips).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildAmenitiesGrid(BuildContext context) {
    final amenities = venue.amenities ?? [];
    if (amenities.isEmpty) {
      return Text('No amenities listed', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDim));
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: amenities.map((a) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, size: 14, color: AppColors.success),
            const SizedBox(width: 6),
            Text(a, style: AppTextStyles.labelSmall.copyWith(color: AppColors.success, fontWeight: FontWeight.w500)),
          ],
        ),
      )).toList(),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildSlotCard(BuildContext context, int index) {
    final times = ['6:00 - 7:00 AM', '7:00 - 8:00 AM', '4:00 - 5:00 PM', '5:00 - 6:00 PM', '6:00 - 7:00 PM', '7:00 - 8:00 PM'];
    final prices = [500, 500, 600, 600, 700, 700];
    final available = [true, true, false, true, true, false];
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: available[index] ? AppColors.success.withValues(alpha: 0.25) : AppColors.borderLight.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (available[index] ? AppColors.success : AppColors.textDim).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              available[index] ? Icons.access_time_rounded : Icons.block_rounded,
              size: 18,
              color: available[index] ? AppColors.success : AppColors.textDim,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(times[index], style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text('₹${prices[index]}/hr', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (available[index] ? AppColors.success : AppColors.error).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              available[index] ? 'Available' : 'Booked',
              style: AppTextStyles.labelSmall.copyWith(
                color: available[index] ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (400 + index * 80).ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildBookButton(BuildContext context) {
    final price = venue.pricePerHour != null ? '₹${venue.pricePerHour!.toStringAsFixed(0)}/hr' : 'Book Now';
    return GradientButton(
      onPressed: () {},
      height: 56,
      child: Text(
        'Book Now${venue.pricePerHour != null ? ' - $price' : ''}',
        style: AppTextStyles.buttonLarge.copyWith(color: Colors.white),
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0);
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 3, height: 18, decoration: BoxDecoration(
          gradient: const LinearGradient(colors: AppColors.gradientPrimary),
          borderRadius: BorderRadius.circular(2),
        )),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 0.5;
    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
