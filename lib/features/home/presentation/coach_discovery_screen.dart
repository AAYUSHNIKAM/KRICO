import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/sports_registry.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/radius/radius.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../models/coach_model.dart';
import '../../../services/providers.dart';

class CoachDiscoveryScreen extends ConsumerStatefulWidget {
  const CoachDiscoveryScreen({super.key});

  @override
  ConsumerState<CoachDiscoveryScreen> createState() => _CoachDiscoveryScreenState();
}

class _CoachDiscoveryScreenState extends ConsumerState<CoachDiscoveryScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _selectedSport = 'All Sports';
  String _selectedLocation = 'All Locations';
  String _sortBy = 'Recommended';
  double? _minRating;

  final List<String> _sortOptions = ['Recommended', 'Highest Rated', 'Most Experienced', 'Price: Low to High', 'Price: High to Low'];
  final List<String> _ratings = ['Any', '4.8+', '4.5+', '4.0+'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final coachesAsync = ref.watch(coachesStreamProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090B10) : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          // Header / Search Bar
          SliverToBoxAdapter(
            child: _buildHeader(isDark),
          ),

          // 1. Sport Selection First (All 30 Sports Rail)
          SliverToBoxAdapter(
            child: _buildSportSelectorRail(isDark),
          ),

          // Filters Bar (Location, Rating, Sort)
          SliverToBoxAdapter(
            child: _buildFiltersBar(isDark),
          ),

          coachesAsync.when(
            data: (allCoaches) {
              final filtered = _filterCoaches(allCoaches);
              final highlyBooked = _getHighlyBookedCoaches(filtered);
              final topRated = _getTopRatedCoaches(filtered);

              if (filtered.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(isDark),
                );
              }

              return SliverList(
                delegate: SliverChildListDelegate([
                  // Highly Booked Coaches Section (shown if no strict text search query is active)
                  if (_searchQuery.isEmpty && highlyBooked.isNotEmpty) ...[
                    _buildSectionHeader('🔥 Highly Booked Mentors', 'Most active and trusted coaches in ${_selectedSport == 'All Sports' ? 'all sports' : _selectedSport}', isDark),
                    _buildHorizontalCoachCarousel(highlyBooked, isDark),
                    const SizedBox(height: SpacingScale.s20),
                  ],

                  // Top Rated Coaches Section (shown if no strict text search query is active)
                  if (_searchQuery.isEmpty && topRated.isNotEmpty) ...[
                    _buildSectionHeader('⭐ Elite & Top Rated (4.8+)', 'Certified mentors with top performance marks', isDark),
                    _buildHorizontalCoachCarousel(topRated, isDark),
                    const SizedBox(height: SpacingScale.s20),
                  ],

                  // Full Directory Header
                  _buildSectionHeader(
                    'Available Coaches (${filtered.length})',
                    'Choose a coach to view upcoming sessions and book 1-on-1 training',
                    isDark,
                  ),
                  const SizedBox(height: SpacingScale.s8),

                  // Coach Grid / Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s16),
                    child: Column(
                      children: [
                        for (int i = 0; i < filtered.length; i++)
                          _buildCoachCard(filtered[i], isDark, i),
                      ],
                    ),
                  ),
                  const SizedBox(height: SpacingScale.s40),
                ]),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Text('Failed to load coaches: $e', style: AppTextStyles.body.copyWith(color: AppColors.danger)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Filtering & Sorting ---
  List<CoachModel> _filterCoaches(List<CoachModel> coaches) {
    return coaches.where((c) {
      // Sport match
      if (_selectedSport != 'All Sports') {
        final target = _selectedSport.toLowerCase();
        final matchesSportsList = c.sports?.any((s) => s.toLowerCase() == target || target.contains(s.toLowerCase())) ?? false;
        final spec = (c.specialization ?? '').toLowerCase();
        final matchesSpec = spec.contains(target) || target.contains(spec);
        if (!matchesSportsList && !matchesSpec) {
          return false;
        }
      }

      // Location match
      if (_selectedLocation != 'All Locations') {
        final city = (c.city ?? '').toLowerCase();
        final target = _selectedLocation.toLowerCase();
        if (!city.contains(target) && !target.contains(city)) {
          return false;
        }
      }

      // Min rating
      if (_minRating != null && c.rating < _minRating!) {
        return false;
      }

      // Search Query
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchName = c.name.toLowerCase().contains(q);
        final matchSpec = (c.specialization ?? '').toLowerCase().contains(q);
        final matchCity = (c.city ?? '').toLowerCase().contains(q);
        final matchBio = (c.bio ?? '').toLowerCase().contains(q);
        if (!matchName && !matchSpec && !matchCity && !matchBio) {
          return false;
        }
      }

      return true;
    }).toList()
      ..sort((a, b) {
        switch (_sortBy) {
          case 'Highest Rated':
            return b.rating.compareTo(a.rating);
          case 'Most Experienced':
            return b.experience.compareTo(a.experience);
          case 'Price: Low to High':
            return a.hourlyRate.compareTo(b.hourlyRate);
          case 'Price: High to Low':
            return b.hourlyRate.compareTo(a.hourlyRate);
          default: // Recommended
            final scoreA = (a.rating * 10) + a.totalReviews + (a.isVerified ? 15 : 0);
            final scoreB = (b.rating * 10) + b.totalReviews + (b.isVerified ? 15 : 0);
            return scoreB.compareTo(scoreA);
        }
      });
  }

  List<CoachModel> _getHighlyBookedCoaches(List<CoachModel> list) {
    final copy = List<CoachModel>.from(list);
    copy.sort((a, b) => b.totalReviews.compareTo(a.totalReviews));
    return copy.take(5).toList();
  }

  List<CoachModel> _getTopRatedCoaches(List<CoachModel> list) {
    return list.where((c) => c.rating >= 4.8).take(5).toList();
  }

  // --- UI Components ---

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        SpacingScale.s16,
        MediaQuery.of(context).padding.top + SpacingScale.s12,
        SpacingScale.s16,
        SpacingScale.s12,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF10141E) : Colors.white,
        border: Border(bottom: BorderSide(color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.3))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (Navigator.of(context).canPop())
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              if (Navigator.of(context).canPop()) const SizedBox(width: SpacingScale.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Find Your Coach',
                      style: AppTextStyles.title1.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      'Select a sport and connect with certified performance mentors',
                      style: AppTextStyles.caption.copyWith(
                        color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingScale.s12),
          // Search Field
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161C2C) : AppColors.lightSurfaceSecondary,
              borderRadius: AppRadius.brXl2,
              border: Border.all(
                color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5),
              ),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
              style: AppTextStyles.body.copyWith(color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary),
              decoration: InputDecoration(
                hintText: 'Search by coach name, sport, city or drill...',
                hintStyle: AppTextStyles.bodySm.copyWith(color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSportSelectorRail(bool isDark) {
    final allSports = [
      const SportDefinition(
        id: 'all',
        name: 'All Sports',
        icon: Icons.sports_rounded,
        category: 'All',
        description: 'Explore mentors across all disciplines',
        accentColor: AppColors.primary,
      ),
      ...SportsRegistry.sports,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: SpacingScale.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '1. SELECT SPORT FIRST',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  '${allSports.length - 1} Sports Available',
                  style: AppTextStyles.captionXs.copyWith(
                    color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SpacingScale.s8),
          SizedBox(
            height: 82,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s12),
              itemCount: allSports.length,
              itemBuilder: (context, index) {
                final sport = allSports[index];
                final isSelected = _selectedSport == sport.name;

                return GestureDetector(
                  onTap: () => setState(() => _selectedSport = sport.name),
                  child: Container(
                    width: 90,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [sport.accentColor.withValues(alpha: 0.25), sport.accentColor.withValues(alpha: 0.08)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            )
                          : null,
                      color: isSelected
                          ? null
                          : (isDark ? const Color(0xFF141926) : Colors.white),
                      borderRadius: AppRadius.brXl,
                      border: Border.all(
                        color: isSelected
                            ? sport.accentColor
                            : (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.4),
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: sport.accentColor.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          sport.icon,
                          size: 26,
                          color: isSelected
                              ? sport.accentColor
                              : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sport.name,
                          style: AppTextStyles.captionXs.copyWith(
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? (isDark ? Colors.white : Colors.black87)
                                : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersBar(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s16, vertical: SpacingScale.s4),
      child: Row(
        children: [
          // Location filter
          _buildDropdownChip(
            label: _selectedLocation,
            icon: Icons.location_on_rounded,
            options: AppConstants.majorCities,
            onChanged: (v) => setState(() => _selectedLocation = v),
            isDark: isDark,
            isHighlighted: _selectedLocation != 'All Locations',
          ),
          const SizedBox(width: SpacingScale.s8),

          // Rating filter
          _buildDropdownChip(
            label: _minRating == null ? 'Rating: Any' : 'Rating: ${_minRating!}+',
            icon: Icons.star_rounded,
            options: _ratings,
            onChanged: (v) {
              setState(() {
                _minRating = v == 'Any' ? null : double.tryParse(v.replaceAll('+', ''));
              });
            },
            isDark: isDark,
            isHighlighted: _minRating != null,
          ),
          const SizedBox(width: SpacingScale.s8),

          // Sort filter
          _buildDropdownChip(
            label: 'Sort: $_sortBy',
            icon: Icons.swap_vert_rounded,
            options: _sortOptions,
            onChanged: (v) => setState(() => _sortBy = v),
            isDark: isDark,
            isHighlighted: _sortBy != 'Recommended',
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownChip({
    required String label,
    required IconData icon,
    required List<String> options,
    required ValueChanged<String> onChanged,
    required bool isDark,
    bool isHighlighted = false,
  }) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      color: isDark ? const Color(0xFF161C2C) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
      itemBuilder: (ctx) => options
          .map((opt) => PopupMenuItem(
                value: opt,
                child: Text(opt, style: AppTextStyles.bodySm),
              ))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isHighlighted
              ? AppColors.primary.withValues(alpha: 0.15)
              : (isDark ? const Color(0xFF141926) : Colors.white),
          borderRadius: AppRadius.brFull,
          border: Border.all(
            color: isHighlighted
                ? AppColors.primary
                : (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.4),
            width: isHighlighted ? 1.2 : 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isHighlighted ? AppColors.primary : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w500,
                color: isHighlighted ? AppColors.primary : (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(SpacingScale.s16, SpacingScale.s16, SpacingScale.s16, SpacingScale.s8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.title2.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(
              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalCoachCarousel(List<CoachModel> coaches, bool isDark) {
    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s12),
        itemCount: coaches.length,
        itemBuilder: (context, index) {
          final coach = coaches[index];
          return Container(
            width: 260,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(SpacingScale.s12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141926) : Colors.white,
              borderRadius: AppRadius.brXl2,
              border: Border.all(
                color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildAvatar(coach, 46),
                    const SizedBox(width: SpacingScale.s10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  coach.name,
                                  style: AppTextStyles.title3.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (coach.isVerified) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.verified_rounded, size: 14, color: AppColors.primary),
                              ],
                            ],
                          ),
                          Text(
                            coach.specialization ?? 'Certified Coach',
                            style: AppTextStyles.captionXs.copyWith(color: AppColors.primary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFB300)),
                              const SizedBox(width: 2),
                              Text(
                                coach.rating.toStringAsFixed(1),
                                style: AppTextStyles.captionXs.copyWith(fontWeight: FontWeight.w700),
                              ),
                              Text(
                                ' (${coach.totalReviews} reviews)',
                                style: AppTextStyles.captionXs.copyWith(color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rate', style: AppTextStyles.captionXs.copyWith(color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary)),
                        Text(
                          '₹${coach.hourlyRate.toStringAsFixed(0)}/hr',
                          style: AppTextStyles.title3.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.emerald,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => context.push('/coach/${coach.coachId}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: const Color(0xFF0F172A),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                        textStyle: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.w700),
                      ),
                      child: const Text('View Profile'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCoachCard(CoachModel coach, bool isDark, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: SpacingScale.s12),
      padding: const EdgeInsets.all(SpacingScale.s16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131825) : Colors.white,
        borderRadius: AppRadius.brXl2,
        border: Border.all(
          color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(coach, 54),
              const SizedBox(width: SpacingScale.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            coach.name,
                            style: AppTextStyles.title2.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                        if (coach.isVerified) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.verified_rounded, size: 16, color: AppColors.primary),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: AppRadius.brFull,
                          ),
                          child: Text(
                            coach.specialization ?? 'Sports Coach',
                            style: AppTextStyles.captionXs.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (coach.city != null && coach.city!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                              borderRadius: AppRadius.brFull,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_on_rounded, size: 10, color: AppColors.textSecondary),
                                const SizedBox(width: 2),
                                Text(
                                  coach.city!,
                                  style: AppTextStyles.captionXs.copyWith(
                                    color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFB300)),
                        const SizedBox(width: 3),
                        Text(
                          coach.rating.toStringAsFixed(1),
                          style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          ' (${coach.totalReviews} sessions)',
                          style: AppTextStyles.caption.copyWith(color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.workspace_premium_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 3),
                        Text(
                          '${coach.experience} yrs exp',
                          style: AppTextStyles.caption.copyWith(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (coach.bio != null && coach.bio!.isNotEmpty) ...[
            const SizedBox(height: SpacingScale.s10),
            Text(
              coach.bio!,
              style: AppTextStyles.caption.copyWith(
                color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: SpacingScale.s12),
          const Divider(height: 1),
          const SizedBox(height: SpacingScale.s10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SESSION FEE', style: AppTextStyles.captionXs.copyWith(color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary, letterSpacing: 0.8)),
                  Text(
                    '₹${coach.hourlyRate.toStringAsFixed(0)} / hr',
                    style: AppTextStyles.title3.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.emerald,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () => context.push('/coach/${coach.coachId}'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                      side: BorderSide(color: (isDark ? AppColors.border : AppColors.lightBorder)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                    ),
                    child: const Text('Profile'),
                  ),
                  const SizedBox(width: SpacingScale.s8),
                  ElevatedButton(
                    onPressed: () => context.push('/booking', extra: coach),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                      textStyle: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.w700),
                    ),
                    child: const Text('Book Session'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.05, delay: (index * 40).ms);
  }

  Widget _buildAvatar(CoachModel coach, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: AppRadius.brXl,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: ClipRRect(
        borderRadius: AppRadius.brXl,
        child: coach.photoUrl != null && coach.photoUrl!.isNotEmpty
            ? Image.network(
                coach.photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => _avatarFallback(coach.name, size),
              )
            : _avatarFallback(coach.name, size),
      ),
    );
  }

  Widget _avatarFallback(String name, double size) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'C',
        style: TextStyle(
          color: AppColors.primary,
          fontSize: size * 0.42,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpacingScale.s32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_search_rounded, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: SpacingScale.s16),
            Text(
              'No coaches found for ${_selectedSport == 'All Sports' ? 'these filters' : _selectedSport}',
              style: AppTextStyles.title2.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SpacingScale.s6),
            Text(
              'Try switching your selected sport or choosing "All Locations" to discover mentors.',
              style: AppTextStyles.bodySm.copyWith(
                color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SpacingScale.s16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedSport = 'All Sports';
                  _selectedLocation = 'All Locations';
                  _minRating = null;
                  _searchCtrl.clear();
                  _searchQuery = '';
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
              ),
              child: const Text('Reset All Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
