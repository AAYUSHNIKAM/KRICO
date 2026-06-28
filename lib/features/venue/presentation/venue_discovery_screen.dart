import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/venue_model.dart';
import '../../../services/providers.dart';

class VenueDiscoveryScreen extends ConsumerStatefulWidget {
  const VenueDiscoveryScreen({super.key});

  @override
  ConsumerState<VenueDiscoveryScreen> createState() => _VenueDiscoveryScreenState();
}

class _VenueDiscoveryScreenState extends ConsumerState<VenueDiscoveryScreen> {
  final _searchController = TextEditingController();
  String? _selectedSport;
  Timer? _debounce;

  final _sports = ['All', 'Cricket', 'Football', 'Badminton', 'Tennis', 'Swimming', 'Basketball'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1200;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withValues(alpha: 0.8)],
                  ),
                ),
                padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Venue Discovery', style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search venues, sports, locations...',
                          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withValues(alpha: 0.7)),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear_rounded, color: Colors.white.withValues(alpha: 0.7)),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _sports.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final sport = _sports[index];
                  final selected = (_selectedSport == null && sport == 'All') || _selectedSport == sport;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedSport = sport == 'All' ? null : sport;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: selected ? const LinearGradient(colors: AppColors.gradientPrimary) : null,
                        color: selected ? null : AppColors.cardDark,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? Colors.transparent : AppColors.borderLight.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          sport,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: selected ? Colors.white : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
                },
              ),
            ),
          ),
          ref.watch(venuesStreamProvider).when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text('Failed to load venues', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => ref.invalidate(venuesStreamProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
            data: (venues) {
              final query = _searchController.text.trim().toLowerCase();
              final displayVenues = venues.where((v) {
                final matchesSearch = query.isEmpty ||
                    v.name.toLowerCase().contains(query) ||
                    (v.sports?.any((s) => s.toLowerCase().contains(query)) ?? false) ||
                    (v.city?.toLowerCase().contains(query) ?? false);
                final matchesSport = _selectedSport == null ||
                    (v.sports?.any((s) => s.toLowerCase() == _selectedSport!.toLowerCase()) ?? false);
                return matchesSearch && matchesSport;
              }).toList();

              if (displayVenues.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.stadium_rounded, size: 64, color: AppColors.textDim.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text('No venues found', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        Text('Try adjusting your search or filters', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDim)),
                      ],
                    ),
                  ),
                );
              }

              if (isMobile) {
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildVenueCard(displayVenues[index]),
                      childCount: displayVenues.length,
                    ),
                  ),
                );
              }

              final itemsPerRow = isTablet ? 2 : 3;
              final rows = (displayVenues.length / itemsPerRow).ceil();
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, rowIndex) {
                      final start = rowIndex * itemsPerRow;
                      final end = (start + itemsPerRow).clamp(0, displayVenues.length);
                      final rowVenues = displayVenues.sublist(start, end);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: rowVenues.map((v) => Expanded(child: _buildVenueCard(v, compact: true))).toList(),
                        ),
                      );
                    },
                    childCount: rows,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVenueCard(VenueModel venue, {bool compact = false}) {
    final iconMap = <String, IconData>{
      'cricket': Icons.sports_cricket_rounded,
      'football': Icons.sports_soccer_rounded,
      'badminton': Icons.sports_kabaddi_rounded,
      'tennis': Icons.sports_tennis_rounded,
      'swimming': Icons.pool_rounded,
      'basketball': Icons.sports_basketball_rounded,
    };
    final primarySport = venue.sports?.firstOrNull?.toLowerCase() ?? 'sports';
    final icon = iconMap[primarySport] ?? Icons.stadium_rounded;
    final sportLabel = venue.sports?.join(', ') ?? 'Multi-sport';
    final location = venue.city ?? venue.address ?? 'Unknown location';
    final isGoogle = venue.isGoogleSourced;

    return Container(
      margin: compact ? EdgeInsets.only(right: 12) : EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      AppColors.accent.withValues(alpha: 0.15),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(venue.name, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(sportLabel, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, size: 12, color: AppColors.textDim),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(location, style: AppTextStyles.caption.copyWith(color: AppColors.textDim, fontSize: 10), overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.star_rounded, size: 12, color: AppColors.gold),
                        const SizedBox(width: 2),
                        Text(venue.rating.toStringAsFixed(1), style: AppTextStyles.caption.copyWith(color: AppColors.gold, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (venue.pricePerHour != null)
                    Text('₹${venue.pricePerHour!.toStringAsFixed(0)}/hr', style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: isGoogle
                          ? const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)])
                          : const LinearGradient(colors: AppColors.gradientPrimary),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isGoogle ? 'Google Listed' : 'New Discovery',
                      style: AppTextStyles.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 9),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (compact && venue.amenities != null && venue.amenities!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: venue.amenities!.take(3).map((a) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(a, style: AppTextStyles.overline.copyWith(color: AppColors.success, fontSize: 8)),
              )).toList(),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}
