import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/app_router.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../design_system/radius/radius.dart';
import '../../../design_system/widgets/page_headers/page_hero.dart';
import '../../../design_system/responsive/responsive_helpers.dart';
import '../../../design_system/tokens/duration_tokens.dart';
import '../../../core/constants/app_assets.dart';
import '../../../design_system/utils/extensions.dart';
import '../../../models/venue_model.dart';
import '../../../services/providers.dart';
import 'package:url_launcher/url_launcher.dart';

class VenueDetailScreen extends ConsumerWidget {
  const VenueDetailScreen({super.key, required this.venueId});
  final String venueId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final venueAsync = ref.watch(venueProvider(venueId));

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
      body: venueAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: AppColors.danger),
              const SizedBox(height: SpacingScale.s16),
              Text('Failed to load venue', style: AppTextStyles.bodyLg.copyWith(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
              const SizedBox(height: SpacingScale.s12),
              GestureDetector(
                onTap: () => ref.invalidate(venueProvider(venueId)),
                child: Text(
                  'Retry',
                  style: AppTextStyles.button.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        data: (venue) => _VenueDetailContent(venue: venue),
      ),
    );
  }
}

class _VenueDetailContent extends ConsumerWidget {
  const _VenueDetailContent({required this.venue});
  final VenueModel venue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final location = [venue.city, venue.address].where((s) => s != null && s.isNotEmpty).join(', ');
    final sportLabel = venue.sports?.join(', ') ?? 'Multi-sport';
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final secColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final now = DateTime.now();
    final todayKey = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final bookedToday = ref.watch(venueBookedSlotsProvider((venueId: venue.venueId, dateKey: todayKey)));

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          if (context.isPhone)
            PageHero(title: venue.name, showPhoneHeader: true)
          else
            SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            stretch: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded, color: Colors.white),
                tooltip: 'Share venue on WhatsApp',
                onPressed: () => _shareOnWhatsApp(venue),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surface : AppColors.lightSurface,
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(
                      child: Opacity(
                        opacity: isDark ? 0.35 : 0.18,
                        child: Image.asset(
                          _getVenueSportAsset(venue.sports),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              (isDark ? AppColors.surface : AppColors.lightSurface).withValues(alpha: 0.3),
                              (isDark ? AppColors.surface : AppColors.lightSurface).withValues(alpha: 0.95),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: SpacingScale.s20,
                      left: SpacingScale.s20,
                      right: SpacingScale.s20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(venue.name, style: AppTextStyles.heading3.copyWith(color: isDark ? Colors.white : AppColors.lightTextPrimary, fontWeight: FontWeight.w700)),
                          const SizedBox(height: SpacingScale.s6),
                          Row(
                            children: [
                              Icon(Icons.location_on_rounded, size: 16, color: isDark ? Colors.white.withValues(alpha: 0.8) : AppColors.lightTextSecondary),
                              const SizedBox(width: SpacingScale.s4),
                              Expanded(
                                child: Text(
                                  location.isNotEmpty ? location : 'Location unavailable',
                                  style: AppTextStyles.body.copyWith(color: isDark ? Colors.white.withValues(alpha: 0.8) : AppColors.lightTextSecondary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: SpacingScale.s4),
                          Row(
                            children: [
                              Icon(Icons.sports_rounded, size: 14, color: isDark ? Colors.white.withValues(alpha: 0.7) : AppColors.lightTextTertiary),
                              const SizedBox(width: SpacingScale.s4),
                              Flexible(
                                child: Text(sportLabel, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.caption.copyWith(color: isDark ? Colors.white.withValues(alpha: 0.7) : AppColors.lightTextTertiary)),
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
                padding: const EdgeInsets.all(SpacingScale.s8),
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
            padding: const EdgeInsets.all(SpacingScale.s16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildInfoChipsRow(context, isDark),
                const SizedBox(height: SpacingScale.s24),
                _SectionHeader(title: 'About', icon: Icons.info_outline_rounded, color: AppColors.primary, textColor: textColor),
                const SizedBox(height: SpacingScale.s8),
                Text(
                  venue.description ?? 'No description available for this venue.',
                  style: AppTextStyles.body.copyWith(color: secColor, height: 1.6),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: SpacingScale.s24),
                _SectionHeader(title: 'Amenities', icon: Icons.check_circle_outline_rounded, color: AppColors.success, textColor: textColor),
                const SizedBox(height: SpacingScale.s12),
                _buildAmenitiesGrid(context, isDark),
                const SizedBox(height: SpacingScale.s24),
                _SectionHeader(title: 'Available Time Slots', icon: Icons.access_time_rounded, color: AppColors.primary, textColor: textColor),
                const SizedBox(height: SpacingScale.s12),
                ...List.generate(VenueTimeSlot.slots.length, (i) => _buildSlotCard(context, i, isDark, bookedToday)),
                const SizedBox(height: SpacingScale.s24),
                _buildBookButton(context, isDark),
                const SizedBox(height: SpacingScale.s32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChipsRow(BuildContext context, bool isDark) {
    final chips = <Widget>[
      _InfoChip(icon: Icons.star_rounded, label: venue.rating.toStringAsFixed(1), color: AppColors.gold),
      const SizedBox(width: SpacingScale.s8),
      _InfoChip(icon: Icons.location_on_rounded, label: venue.city ?? 'N/A', color: AppColors.primary),
      const SizedBox(width: SpacingScale.s8),
      _InfoChip(
        icon: Icons.people_rounded,
        label: venue.capacity != null ? '${venue.capacity} cap' : 'N/A',
        color: AppColors.purple,
      ),
    ];
    if (venue.pricePerHour != null) {
      chips.add(const SizedBox(width: SpacingScale.s8));
      chips.add(_InfoChip(
        icon: Icons.currency_rupee_rounded,
        label: '₹${venue.pricePerHour!.toStringAsFixed(0)}/hr',
        color: AppColors.success,
      ));
    }
    return Row(children: chips).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildAmenitiesGrid(BuildContext context, bool isDark) {
    final amenities = venue.amenities ?? [];
    if (amenities.isEmpty) {
      return Text('No amenities listed', style: AppTextStyles.body.copyWith(color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary));
    }
    return Wrap(
      spacing: SpacingScale.s8,
      runSpacing: SpacingScale.s8,
      children: amenities.map((a) => Container(
        padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s12, vertical: SpacingScale.s8),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.06),
          borderRadius: AppRadius.brMd,
          border: Border.all(color: AppColors.success.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, size: 14, color: AppColors.success),
            const SizedBox(width: SpacingScale.s6),
            Text(a, style: AppTextStyles.labelSm.copyWith(color: AppColors.success, fontWeight: FontWeight.w500)),
          ],
        ),
      )).toList(),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildSlotCard(BuildContext context, int index, bool isDark, Set<String> bookedToday) {
    final slot = VenueTimeSlot.slots[index];
    final now = DateTime.now();
    final isPastToday = _isSlotPast(slot.startTime, now);
    final isBooked = bookedToday.contains(slot.startTime);
    final available = !isBooked && !isPastToday;
    final statusColor = available ? AppColors.success : (isBooked ? AppColors.danger : AppColors.textTertiary);
    final statusLabel = available ? 'Available' : (isBooked ? 'Booked' : 'Ended');
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final terColor = isDark ? AppColors.textTertiary : AppColors.lightTextTertiary;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    return Container(
      margin: const EdgeInsets.only(bottom: SpacingScale.s8),
      padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s12, vertical: SpacingScale.s12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl2,
        border: Border.all(
          color: available
              ? AppColors.success.withValues(alpha: 0.25)
              : borderColor.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (available ? AppColors.success : terColor).withValues(alpha: 0.1),
              borderRadius: AppRadius.brMd,
            ),
            child: Icon(
              available ? Icons.access_time_rounded : Icons.block_rounded,
              size: 18,
              color: available ? AppColors.success : terColor,
            ),
          ),
          const SizedBox(width: SpacingScale.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(slot.label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500, color: textColor)),
                const SizedBox(height: SpacingScale.s2),
                Text('₹${slot.price}/hr', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s10, vertical: SpacingScale.s4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: AppRadius.brSm,
            ),
            child: Text(
              statusLabel,
              style: AppTextStyles.labelSm.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 400 + index * 80)).slideY(begin: 0.1, end: 0);
  }

  bool _isSlotPast(String startTime, DateTime now) {
    final parts = startTime.split(':');
    if (parts.length != 2) return false;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    if (now.hour != hour) return now.hour > hour;
    return now.minute >= minute;
  }

  Future<void> _shareOnWhatsApp(VenueModel venue) async {
    final city = venue.city?.isNotEmpty == true ? venue.city! : 'Pune';
    final price = venue.pricePerHour != null ? '₹${venue.pricePerHour!.toInt()}/hr' : 'Great rates';
    final text = 'Hey! Let\'s book a court at ${venue.name} in $city ($price) on KRICO Sports! Check it out: https://krico.app/venue/${venue.venueId}';
    final whatsappUri = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(text)}');
    final webUri = Uri.parse('https://api.whatsapp.com/send?text=${Uri.encodeComponent(text)}');
    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  Widget _buildBookButton(BuildContext context, bool isDark) {
    final price = venue.pricePerHour != null ? '₹${venue.pricePerHour!.toStringAsFixed(0)}/hr' : 'Book Now';
    return Row(
      children: [
        IconButton.filledTonal(
          icon: const Icon(Icons.share_rounded, color: Color(0xFF25D366)),
          tooltip: 'Invite teammates on WhatsApp',
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFF25D366).withValues(alpha: 0.15),
            padding: const EdgeInsets.all(14),
          ),
          onPressed: () => _shareOnWhatsApp(venue),
        ),
        const SizedBox(width: SpacingScale.s12),
        Expanded(
          child: _PremiumButton(
            label: 'Book Now${venue.pricePerHour != null ? ' - $price' : ''}',
            icon: Icons.calendar_today_rounded,
            onTap: () => context.push(AppRoutes.venueBooking.replaceFirst(':id', venue.venueId)),
          ),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s10, vertical: SpacingScale.s6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.brMd,
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: SpacingScale.s4),
          Text(label, style: AppTextStyles.labelSm.copyWith(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon, required this.color, required this.textColor});
  final String title;
  final IconData icon;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: AppRadius.brLg,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: SpacingScale.s10),
        Text(title, style: AppTextStyles.title2.copyWith(color: textColor, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _PremiumButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PremiumButton({required this.label, required this.icon, required this.onTap});

  @override
  State<_PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<_PremiumButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? (_hovered ? AppColors.voltHover : AppColors.volt)
        : (_hovered ? AppColors.pitchSlate : context.heroCtaBg);
    final fg = isDark ? AppColors.midnightObsidian : context.heroCtaFg;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: DurationTokens.fast,
          height: 56,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: AppRadius.brXl2,
            boxShadow: [
              BoxShadow(
                color: (isDark ? AppColors.volt : Colors.black).withValues(alpha: _hovered ? 0.35 : 0.18),
                blurRadius: _hovered ? 20 : 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, color: fg, size: 18),
                const SizedBox(width: SpacingScale.s8),
                Text(
                  widget.label,
                  style: AppTextStyles.buttonLg.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _getVenueSportAsset(List<String>? sports) {
  if (sports == null || sports.isEmpty) return AppAssets.heroCricket;
  return AppAssets.getSportHero(sports.first);
}

