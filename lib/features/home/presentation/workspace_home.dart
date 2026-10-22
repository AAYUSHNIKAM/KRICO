import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../design_system/layouts/premium_shell.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../models/user_model.dart';
import '../../coach/presentation/dashboard/coach_home_view.dart';
import '../../player/presentation/dashboard/player_home_view.dart';
import 'workspace_destinations.dart';

class WorkspaceHome extends StatelessWidget {
  const WorkspaceHome({super.key, required this.user, required this.destinations});
  final UserModel user;
  final List<WorkspaceDestination> destinations;

  @override
  Widget build(BuildContext context) {
    if (user.role == UserRole.coach) {
      return CoachHomeView(user: user, destinations: destinations);
    }
    if (user.role == UserRole.player) {
      return PlayerHomeView(user: user, destinations: destinations);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (title, subtitle) = switch (user.role) {
      UserRole.parent => ('Parent Sports Command', 'Track your child\'s coaching progress, court sessions, and training calendar.'),
      UserRole.academy => ('Academy Operations Hub', 'Coordinate coaches, manage batches, and drive training excellence across all centers.'),
      UserRole.admin => ('Platform Command Center', 'Manage users, verify venues, and monitor sports operations in real time.'),
      _ => ('Sports Ecosystem Platform', 'Your comprehensive sports training and operations hub.'),
    };
    final primary = destinations.length > 1 ? destinations[1] : destinations[0];
    final secondary = destinations.length > 2 ? destinations[2] : primary;

    final cardBg = isDark ? const Color(0xFF131D31) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Athletic Hero Banner
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFCCFF00).withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            'assets/backgrounds/stadium_floodlights.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(color: const Color(0xFF0F172A)),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.black.withValues(alpha: 0.85),
                                Colors.black.withValues(alpha: 0.65),
                                const Color(0xFF0B0E14).withValues(alpha: 0.95),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 12,
                                runSpacing: 8,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFCCFF00),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          'assets/animations/live_pulse.gif',
                                          width: 14,
                                          height: 14,
                                          errorBuilder: (_, _, _) => const Icon(Icons.circle, size: 8, color: Colors.black),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${user.role.name.toUpperCase()} WORKSPACE',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 10,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${user.city != null && user.city!.isNotEmpty ? user.city! : "National Hub"} • Operational',
                                    style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                title,
                                style: AppTextStyles.heading1.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.8,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                subtitle,
                                style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14, height: 1.5),
                              ),
                              const SizedBox(height: 20),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  FilledButton.icon(
                                    onPressed: () => WorkspaceNavigation.go(context, 1),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xFFCCFF00),
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    icon: Icon(primary.icon, size: 16),
                                    label: Text(primary.label, style: const TextStyle(fontWeight: FontWeight.w900)),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () => WorkspaceNavigation.go(context, 2),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: const BorderSide(color: Colors.white38),
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    icon: Icon(secondary.icon, size: 16),
                                    label: Text(secondary.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                                  ),
                                  if (user.role == UserRole.parent)
                                    ElevatedButton.icon(
                                      onPressed: () => context.push('/add-child'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF3B82F6),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      icon: const Icon(Icons.person_add_rounded, size: 16),
                                      label: const Text('Link Player', style: TextStyle(fontWeight: FontWeight.w800)),
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
                const SizedBox(height: 28),

                // 2. Workspace Operations Grid
                Text(
                  'Operations & Tools',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Quick access to core modules and workflows.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 16),

                for (final section in destinations.skip(1).map((d) => d.section).toSet()) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 14, bottom: 10),
                    child: Text(
                      section.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF3B82F6),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 850 ? 3 : constraints.maxWidth >= 560 ? 2 : 1;
                      final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (var i = 1; i < destinations.length; i++)
                            if (destinations[i].section == section)
                              SizedBox(
                                width: width,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: borderColor),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () => WorkspaceNavigation.go(context, i),
                                      child: Padding(
                                        padding: const EdgeInsets.all(18),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFCCFF00).withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Icon(destinations[i].icon, color: const Color(0xFFCCFF00), size: 22),
                                            ),
                                            const SizedBox(height: 14),
                                            Text(
                                              destinations[i].label,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              destinations[i].description,
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ).animate().fade(duration: 200.ms).slideY(begin: 0.03),
                        ],
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
