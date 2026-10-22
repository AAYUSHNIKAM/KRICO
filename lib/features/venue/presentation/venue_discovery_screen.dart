import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/constants/sports_registry.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_router.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/radius/radius.dart';
import '../../../design_system/responsive/responsive_helpers.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../design_system/utils/extensions.dart';
import '../../../design_system/widgets/page_headers/page_hero.dart';
import '../../../design_system/widgets/shared/widgets.dart';
import '../../../core/constants/app_assets.dart';
import '../../../models/venue_model.dart';
import '../../../services/providers.dart';

enum VenueViewMode { list, map }

class VenueDiscoveryScreen extends ConsumerStatefulWidget {
  const VenueDiscoveryScreen({super.key});

  @override
  ConsumerState<VenueDiscoveryScreen> createState() => _VenueDiscoveryScreenState();
}

class _VenueDiscoveryScreenState extends ConsumerState<VenueDiscoveryScreen> {
  final _searchController = TextEditingController();
  String? _selectedSport;
  String _selectedCity = 'All Locations';
  VenueViewMode _viewMode = VenueViewMode.list;
  Timer? _debounce;
  VenueModel? _selectedMapVenue;
  GoogleMapController? _mapController;

  static const _defaultCenter = LatLng(19.0760, 72.8777);
  late final List<String> _sports;

  @override
  void initState() {
    super.initState();
    _sports = ['All', ...SportsRegistry.sports.map((s) => s.name)];
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() {});
    });
  }

  Set<Marker> _buildMarkers(List<VenueModel> venues) {
    final markers = <Marker>{};
    for (int i = 0; i < venues.length; i++) {
      final venue = venues[i];
      // Use coordinates or spread around default center for demonstration if unassigned
      final lat = venue.latitude ?? (_defaultCenter.latitude + ((i % 5) - 2) * 0.02);
      final lng = venue.longitude ?? (_defaultCenter.longitude + ((i ~/ 5) - 2) * 0.02);

      markers.add(
        Marker(
          markerId: MarkerId(venue.venueId),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: venue.name,
            snippet: venue.sports?.firstOrNull ?? 'Sports Venue',
          ),
          onTap: () {
            setState(() => _selectedMapVenue = venue);
          },
        ),
      );
    }
    return markers;
  }

  Widget _buildSearchField(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary,
        borderRadius: AppRadius.brXl2,
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: AppTextStyles.body.copyWith(
          color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search venues, sports, locations...',
          hintStyle: AppTextStyles.body.copyWith(
            color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
          ),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                  ),
                  onPressed: () => _searchController.clear(),
                )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1200;

    final venuesAsync = ref.watch(venuesStreamProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: venuesAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: colors.primary)),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: colors.danger),
              const SizedBox(height: SpacingScale.s16),
              Text(
                'Failed to load venues',
                style: AppTextStyles.body.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: SpacingScale.s12),
              ElevatedButton(
                onPressed: () => ref.invalidate(venuesStreamProvider),
                child: const Text('Retry'),
              ),
            ],
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
            final matchesCity = _selectedCity == 'All Locations' ||
                (v.city?.toLowerCase() == _selectedCity.toLowerCase());
            return matchesSearch && matchesSport && matchesCity;
          }).toList();

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  if (context.isPhone) ...[
                    if (Navigator.of(context).canPop())
                      const PageHero(title: 'Venue Discovery', showPhoneHeader: true),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(SpacingScale.s16, SpacingScale.s12, SpacingScale.s16, 0),
                        child: _buildSearchField(isDark),
                      ),
                    ),
                  ] else
                    SliverAppBar(
                      expandedHeight: 140,
                      pinned: true,
                      leading: Navigator.of(context).canPop()
                          ? IconButton(
                              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                              onPressed: () => Navigator.of(context).pop(),
                            )
                          : null,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [colors.primary, const Color(0xFF0D9488)],
                            ),
                          ),
                          padding: EdgeInsets.fromLTRB(
                            SpacingScale.s20,
                            MediaQuery.of(context).padding.top + SpacingScale.s20,
                            SpacingScale.s20,
                            SpacingScale.s16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                _selectedCity == 'All Locations' ? 'All Sports & Arena Venues' : '$_selectedCity Sports Venues',
                                style: AppTextStyles.title1.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: SpacingScale.s4),
                              Text(
                                'Book courts, turfs, and floodlit grounds across India',
                                style: AppTextStyles.bodySm.copyWith(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Controls Bar: Sports Filters + City Filter + Map/List Toggle
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(SpacingScale.s16, SpacingScale.s12, SpacingScale.s16, SpacingScale.s8),
                      child: Row(
                        children: [
                          Expanded(
                            child: SportFilterBar(
                              padding: EdgeInsets.zero,
                              sports: _sports,
                              selectedSport: _selectedSport,
                              onSelected: (sport) => setState(() => _selectedSport = sport),
                            ),
                          ),
                          const SizedBox(width: SpacingScale.s8),
                          // City Filter Popup
                          PopupMenuButton<String>(
                            tooltip: 'Filter City',
                            initialValue: _selectedCity,
                            onSelected: (c) => setState(() => _selectedCity = c),
                            color: isDark ? AppColors.card : AppColors.lightCard,
                            shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                            child: Container(
                              height: 38,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: colors.surfaceSecondary,
                                borderRadius: AppRadius.brLg,
                                border: Border.all(color: _selectedCity != 'All Locations' ? colors.primary : colors.border),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.location_on_rounded, size: 16, color: _selectedCity != 'All Locations' ? colors.primary : colors.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    _selectedCity == 'All Locations' ? 'City' : _selectedCity,
                                    style: AppTextStyles.caption.copyWith(
                                      color: _selectedCity != 'All Locations' ? colors.primary : colors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Icon(Icons.arrow_drop_down_rounded, size: 18),
                                ],
                              ),
                            ),
                            itemBuilder: (context) => [
                              'All Locations',
                              ...AppConstants.majorCities,
                            ].map((city) => PopupMenuItem(
                              value: city,
                              child: Text(city, style: TextStyle(fontWeight: _selectedCity == city ? FontWeight.bold : FontWeight.normal)),
                            )).toList(),
                          ),
                          const SizedBox(width: SpacingScale.s8),
                          // View Mode Toggle (List / Map)
                          Container(
                            decoration: BoxDecoration(
                              color: colors.surfaceSecondary,
                              borderRadius: AppRadius.brLg,
                              border: Border.all(color: colors.border),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.view_list_rounded,
                                    size: 20,
                                    color: _viewMode == VenueViewMode.list ? colors.primary : colors.textTertiary,
                                  ),
                                  tooltip: 'List View',
                                  onPressed: () => setState(() => _viewMode = VenueViewMode.list),
                                ),
                                Container(width: 1, height: 20, color: colors.border),
                                IconButton(
                                  icon: Icon(
                                    Icons.map_rounded,
                                    size: 20,
                                    color: _viewMode == VenueViewMode.map ? colors.primary : colors.textTertiary,
                                  ),
                                  tooltip: 'Map View',
                                  onPressed: () => setState(() => _viewMode = VenueViewMode.map),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Content Body: List View or Map View
                  if (_viewMode == VenueViewMode.map)
                    SliverFillRemaining(
                      child: Stack(
                        children: [
                          GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: displayVenues.isNotEmpty && displayVenues.first.latitude != null
                                  ? LatLng(displayVenues.first.latitude!, displayVenues.first.longitude!)
                                  : _defaultCenter,
                              zoom: 12.0,
                            ),
                            markers: _buildMarkers(displayVenues),
                            onMapCreated: (ctrl) => _mapController = ctrl,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                            mapToolbarEnabled: false,
                          ),
                          if (_selectedMapVenue != null)
                            Positioned(
                              left: SpacingScale.s16,
                              right: SpacingScale.s16,
                              bottom: SpacingScale.s20,
                              child: _buildVenueCard(_selectedMapVenue!, isDark, compact: false),
                            ),
                        ],
                      ),
                    )
                  else if (displayVenues.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.stadium_rounded,
                              size: 64,
                              color: colors.textTertiary.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: SpacingScale.s16),
                            Text(
                              'No venues found',
                              style: AppTextStyles.title2.copyWith(color: colors.textPrimary),
                            ),
                            const SizedBox(height: SpacingScale.s8),
                            Text(
                              'Try adjusting your search or filters',
                              style: AppTextStyles.bodySm.copyWith(color: colors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (isMobile)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(SpacingScale.s16, SpacingScale.s8, SpacingScale.s16, SpacingScale.s32),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildVenueCard(displayVenues[index], isDark),
                          childCount: displayVenues.length,
                        ),
                      ),
                    )
                  else ...[
                    // Responsive Grid on Tablet / Desktop
                    () {
                      final itemsPerRow = isTablet ? 2 : 3;
                      final rows = (displayVenues.length / itemsPerRow).ceil();
                      return SliverPadding(
                        padding: const EdgeInsets.fromLTRB(SpacingScale.s16, SpacingScale.s4, SpacingScale.s16, SpacingScale.s32),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, rowIndex) {
                              final start = rowIndex * itemsPerRow;
                              final end = (start + itemsPerRow).clamp(0, displayVenues.length);
                              final rowVenues = displayVenues.sublist(start, end);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: SpacingScale.s12),
                                child: Row(
                                  children: rowVenues
                                      .map((v) => Expanded(
                                            child: _buildVenueCard(v, isDark, compact: true),
                                          ))
                                      .toList(),
                                ),
                              );
                            },
                            childCount: rows,
                          ),
                        ),
                      );
                    }(),
                  ],
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVenueCard(VenueModel venue, bool isDark, {bool compact = false}) {
    final primarySport = venue.sports?.firstOrNull?.toLowerCase() ?? 'sports';
    final sportLabel = venue.sports?.join(', ') ?? 'Multi-sport';
    final location = venue.city ?? venue.address ?? 'All Locations';
    final isGoogle = venue.isGoogleSourced;

    String sportCoverImage;
    if (primarySport.contains('badminton')) {
      sportCoverImage = 'assets/images/sports/badminton_smash.jpg';
    } else if (primarySport.contains('football') || primarySport.contains('soccer')) {
      sportCoverImage = 'assets/images/sports/football_action.jpeg';
    } else if (primarySport.contains('tennis')) {
      sportCoverImage = 'assets/images/sports/tennis_racket.jpg';
    } else if (primarySport.contains('basketball')) {
      sportCoverImage = 'assets/images/sports/basketball_hoop.webp';
    } else {
      sportCoverImage = AppAssets.getSportHero(primarySport);
    }

    final cardBg = isDark ? const Color(0xFF131D31) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return Container(
      margin: compact
          ? const EdgeInsets.only(right: SpacingScale.s12)
          : const EdgeInsets.only(bottom: SpacingScale.s16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Full-Bleed Turf / Court Photography Cover
            SizedBox(
              height: 140,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    sportCoverImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(color: AppColors.primary),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.15),
                          Colors.black.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: Color(0xFFCCFF00)),
                          const SizedBox(width: 4),
                          Text(
                            venue.rating > 0 ? venue.rating.toStringAsFixed(1) : '4.8',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (venue.pricePerHour != null)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCCFF00),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '₹${venue.pricePerHour!.toStringAsFixed(0)}/HR',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 12,
                    left: 14,
                    right: 14,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              sportLabel.toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFFCCFF00),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isGoogle ? const Color(0xFF3B82F6) : const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isGoogle ? 'VERIFIED' : 'TURF HUB',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Venue Details Section
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venue.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 14, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Open Today',
                          style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  if (venue.amenities != null && venue.amenities!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: venue.amenities!.take(3).map((a) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            a,
                            style: TextStyle(
                              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () => context.push(AppRoutes.venueDetail.replaceFirst(':id', venue.venueId)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? Colors.white70 : Colors.black87,
                          side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                        child: const Text('Details', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () => context.push(
                          '${AppRoutes.venueBooking}?venueId=${venue.venueId}',
                          extra: venue,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppColors.volt : context.heroCtaBg,
                          foregroundColor: isDark ? AppColors.midnightObsidian : context.heroCtaFg,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                        ),
                        icon: Icon(Icons.flash_on, size: 14, color: isDark ? AppColors.midnightObsidian : context.heroCtaFg),
                        label: Text(
                          'BOOK COURT',
                          style: TextStyle(
                            color: isDark ? AppColors.midnightObsidian : context.heroCtaFg,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
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
