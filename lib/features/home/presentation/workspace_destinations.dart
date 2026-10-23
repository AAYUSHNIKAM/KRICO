import 'package:flutter/material.dart';
import '../../../models/user_model.dart';

class WorkspaceDestination {
  final String id;
  final String label;
  final IconData icon;
  final String description;
  final String section;

  const WorkspaceDestination({
    required this.id,
    required this.label,
    required this.icon,
    this.description = '',
    this.section = 'Core',
  });
}

List<WorkspaceDestination> workspaceDestinations(UserRole role) {
  switch (role) {
    case UserRole.player:
      return const [
        WorkspaceDestination(
          id: 'dashboard',
          label: 'Dashboard',
          icon: Icons.speed_rounded,
          description: 'Athlete HUD, progress streaks, and training missions',
          section: 'Overview',
        ),
        WorkspaceDestination(
          id: 'performance',
          label: 'Performance',
          icon: Icons.show_chart_rounded,
          description: 'Telemetry metrics, skill radars, and session logs',
          section: 'Training',
        ),
        WorkspaceDestination(
          id: 'video_analysis',
          label: 'AI Coach',
          icon: Icons.videocam_rounded,
          description: 'Frame-by-frame biomechanics and video feedback',
          section: 'Training',
        ),
        WorkspaceDestination(
          id: 'coaches',
          label: 'Coaches',
          icon: Icons.person_search_rounded,
          description: 'Discover certified coaches and reserve slots',
          section: 'Coaching',
        ),
        WorkspaceDestination(
          id: 'squad_goals',
          label: 'Squad Goals',
          icon: Icons.emoji_events_rounded,
          description: 'Team challenges, milestones, and shared targets',
          section: 'Network',
        ),
        WorkspaceDestination(
          id: 'challenges',
          label: 'Challenges',
          icon: Icons.bolt_rounded,
          description: 'Compete in community fitness and skill trials',
          section: 'Network',
        ),
        WorkspaceDestination(
          id: 'community',
          label: 'Community',
          icon: Icons.people_rounded,
          description: 'Connect with peers, mentors, and sports clubs',
          section: 'Network',
        ),
        WorkspaceDestination(
          id: 'chat',
          label: 'Chat',
          icon: Icons.chat_rounded,
          description: 'Direct messaging with coaches and squadmates',
          section: 'Network',
        ),
        WorkspaceDestination(
          id: 'profile',
          label: 'Profile',
          icon: Icons.person_rounded,
          description: 'Manage athlete accreditation and personal details',
          section: 'Account',
        ),
      ];
    case UserRole.coach:
      return const [
        WorkspaceDestination(
          id: 'dashboard',
          label: 'Dashboard',
          icon: Icons.dashboard_rounded,
          description: 'Coaching command center and key indicators',
          section: 'Overview',
        ),
        WorkspaceDestination(
          id: 'schedule',
          label: 'Schedule',
          icon: Icons.calendar_month_rounded,
          description: 'Session slots, bookings, and availability grid',
          section: 'Management',
        ),
        WorkspaceDestination(
          id: 'students',
          label: 'Students',
          icon: Icons.people_rounded,
          description: 'Active trainees, roster records, and progress',
          section: 'Management',
        ),
        WorkspaceDestination(
          id: 'earnings',
          label: 'Earnings',
          icon: Icons.account_balance_wallet_rounded,
          description: 'Escrow vault releases, payout logs, and income',
          section: 'Finance',
        ),
        WorkspaceDestination(
          id: 'jobs',
          label: 'Jobs',
          icon: Icons.work_rounded,
          description: 'Academy postings and coaching recruitment',
          section: 'Career',
        ),
        WorkspaceDestination(
          id: 'offers',
          label: 'Offers',
          icon: Icons.email_rounded,
          description: 'Direct contracts and private coaching requests',
          section: 'Career',
        ),
        WorkspaceDestination(
          id: 'community',
          label: 'Community',
          icon: Icons.groups_rounded,
          description: 'Coach collective, discussions, and updates',
          section: 'Network',
        ),
        WorkspaceDestination(
          id: 'chat',
          label: 'Chat',
          icon: Icons.chat_rounded,
          description: 'Client communication and session coordination',
          section: 'Network',
        ),
        WorkspaceDestination(
          id: 'profile',
          label: 'Profile',
          icon: Icons.person_rounded,
          description: 'Accreditation badges and public portfolio',
          section: 'Account',
        ),
      ];
    case UserRole.parent:
      return const [
        WorkspaceDestination(
          id: 'dashboard',
          label: 'Dashboard',
          icon: Icons.dashboard_rounded,
          description: 'Parent Sports Command',
          section: 'Overview',
        ),
        WorkspaceDestination(
          id: 'coaches',
          label: 'Coaches',
          icon: Icons.person_search_rounded,
          description: 'Discover and evaluate verified mentors',
          section: 'Coaching',
        ),
        WorkspaceDestination(
          id: 'progress',
          label: 'Progress',
          icon: Icons.show_chart_rounded,
          description: 'Track child performance metrics and attendance',
          section: 'Monitoring',
        ),
        WorkspaceDestination(
          id: 'community',
          label: 'Community',
          icon: Icons.people_rounded,
          description: 'Sports community forums and announcements',
          section: 'Network',
        ),
        WorkspaceDestination(
          id: 'chat',
          label: 'Chat',
          icon: Icons.chat_rounded,
          description: 'Direct messaging with assigned coaches',
          section: 'Network',
        ),
        WorkspaceDestination(
          id: 'profile',
          label: 'Profile',
          icon: Icons.person_rounded,
          description: 'Family account settings and payment preferences',
          section: 'Account',
        ),
      ];
    case UserRole.academy:
      return const [
        WorkspaceDestination(
          id: 'dashboard',
          label: 'Dashboard',
          icon: Icons.dashboard_rounded,
          description: 'Academy Operations Hub',
          section: 'Overview',
        ),
        WorkspaceDestination(
          id: 'batches',
          label: 'Batches',
          icon: Icons.group_rounded,
          description: 'Batch formations, time tables, and capacity',
          section: 'Operations',
        ),
        WorkspaceDestination(
          id: 'coaches',
          label: 'Coaches',
          icon: Icons.sports_rounded,
          description: 'Staff coaches, performance audits, and assignments',
          section: 'Staff',
        ),
        WorkspaceDestination(
          id: 'community',
          label: 'Community',
          icon: Icons.people_rounded,
          description: 'Academy announcements and athlete parent portal',
          section: 'Network',
        ),
        WorkspaceDestination(
          id: 'advertising',
          label: 'Advertising',
          icon: Icons.campaign_rounded,
          description: 'Promotion campaigns and admission pipelines',
          section: 'Growth',
        ),
        WorkspaceDestination(
          id: 'jobs',
          label: 'Jobs',
          icon: Icons.work_rounded,
          description: 'Post hiring requisitions for qualified mentors',
          section: 'Staff',
        ),
        WorkspaceDestination(
          id: 'chat',
          label: 'Chat',
          icon: Icons.chat_rounded,
          description: 'Staff and student communication desk',
          section: 'Network',
        ),
        WorkspaceDestination(
          id: 'profile',
          label: 'Profile',
          icon: Icons.person_rounded,
          description: 'Academy accreditation and legal credentials',
          section: 'Account',
        ),
      ];
    case UserRole.admin:
      return const [
        WorkspaceDestination(
          id: 'dashboard',
          label: 'Dashboard',
          icon: Icons.dashboard_rounded,
          description: 'Platform Command Center',
          section: 'Overview',
        ),
        WorkspaceDestination(
          id: 'venues',
          label: 'Venues',
          icon: Icons.stadium_rounded,
          description: 'Facility approval, court specs, and turf audits',
          section: 'Management',
        ),
        WorkspaceDestination(
          id: 'users',
          label: 'Users',
          icon: Icons.people_rounded,
          description: 'Account security, role governance, and verification',
          section: 'Governance',
        ),
        WorkspaceDestination(
          id: 'coupons',
          label: 'Coupons',
          icon: Icons.local_offer_rounded,
          description: 'Discount campaigns and promotional pricing rules',
          section: 'Finance',
        ),
        WorkspaceDestination(
          id: 'profile',
          label: 'Profile',
          icon: Icons.person_rounded,
          description: 'Platform executive credentials',
          section: 'Account',
        ),
      ];
  }
}
