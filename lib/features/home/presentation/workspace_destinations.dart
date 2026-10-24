import 'package:flutter/material.dart';
import '../../../models/user_model.dart';

class WorkspaceDestination {
  const WorkspaceDestination(this.id, this.label, this.icon, this.description,
      {this.section = 'Coaching workspace'});
  final String id;
  final String label;
  final IconData icon;
  final String description;
  final String section;
}

/// The first five destinations are the mobile navigation, in task order.
List<WorkspaceDestination> workspaceDestinations(UserRole role) {
  const home = WorkspaceDestination('home', 'Home', Icons.home_outlined, 'Your next steps, in one place');
  const find = WorkspaceDestination('discover', 'Find a coach', Icons.person_search_outlined, 'Compare coaches, review their profiles and request a session');
  const bookings = WorkspaceDestination('bookings', 'Bookings', Icons.event_note_outlined, 'Track requests, upcoming sessions and your booking history');
  const messages = WorkspaceDestination('messages', 'Messages', Icons.chat_bubble_outline, 'Coordinate training and discuss session details');
  const community = WorkspaceDestination('community', 'Community', Icons.groups_outlined, 'Share updates and connect with other athletes', section: 'Community & opportunities');
  const profile = WorkspaceDestination('profile', 'My profile', Icons.person_outline, 'Manage your identity and public profile', section: 'Account');
  const contracts = WorkspaceDestination('contracts', 'Agreements', Icons.description_outlined, 'Review coaching terms and signatures', section: 'Account');
  const venues = WorkspaceDestination('venues', 'Venues', Icons.stadium_outlined, 'Find a place to train and book a venue', section: 'Training tools');

  return switch (role) {
    UserRole.player => [
      home, find, bookings, messages,
      const WorkspaceDestination('growth', 'Growth', Icons.trending_up, 'Review your training journey, goals and achievements', section: 'Player development'),
      const WorkspaceDestination('performance', 'Performance', Icons.show_chart, 'Track and compare your training metrics', section: 'Player development'),
      const WorkspaceDestination('video', 'Video review', Icons.videocam_outlined, 'Upload training footage and review feedback', section: 'Player development'),
      const WorkspaceDestination('squad', 'Squad goals', Icons.flag_outlined, 'Work towards shared team goals', section: 'Player development'),
      const WorkspaceDestination('challenges', 'Challenges', Icons.bolt_outlined, 'Keep practice engaging with training challenges', section: 'Player development'),
      venues, community, contracts, profile,
    ],
    UserRole.parent => [
      home, find, bookings, messages,
      const WorkspaceDestination('children', 'My players', Icons.family_restroom, 'Manage linked players and log their training', section: 'Player development'),
      const WorkspaceDestination('progress', 'Player progress', Icons.trending_up, 'Follow the progress of each linked player', section: 'Player development'),
      venues, community, contracts, profile,
    ],
    UserRole.coach => [
      home,
      const WorkspaceDestination('requests', 'Requests', Icons.inbox_outlined, 'Accept or decline incoming booking requests'),
      const WorkspaceDestination('schedule', 'Schedule', Icons.calendar_month_outlined, 'Manage sessions, attendance and completion'),
      const WorkspaceDestination('students', 'Players', Icons.people_outline, 'Review your players and record their progress'),
      messages,
      const WorkspaceDestination('availability', 'Availability', Icons.edit_calendar_outlined, 'Publish the dates and times players can book'),
      const WorkspaceDestination('earnings', 'Earnings', Icons.account_balance_wallet_outlined, 'Review your session earnings', section: 'Business management'),
      const WorkspaceDestination('overview', 'Business overview', Icons.insights_outlined, 'Review statistics, milestones and your plan', section: 'Business management'),
      const WorkspaceDestination('jobs', 'Academy jobs', Icons.work_outline, 'Find and apply for academy opportunities', section: 'Community & opportunities'),
      const WorkspaceDestination('offers', 'Academy offers', Icons.mail_outline, 'Review invitations and offers from academies', section: 'Community & opportunities'),
      community, contracts, profile,
    ],
    UserRole.academy => [
      home,
      const WorkspaceDestination('batches', 'Batches', Icons.groups_outlined, 'Organize training groups and batch details'),
      const WorkspaceDestination('coaches', 'Coaches', Icons.sports_outlined, 'Manage your coaching team and invitations'),
      messages,
      const WorkspaceDestination('jobs', 'Recruitment', Icons.work_outline, 'Post coaching jobs and review recruitment'),
      const WorkspaceDestination('overview', 'Academy overview', Icons.insights_outlined, 'Review academy statistics and operations', section: 'Business management'),
      const WorkspaceDestination('advertising', 'Advertising', Icons.campaign_outlined, 'Manage your academy campaigns', section: 'Business management'),
      community, contracts, profile,
    ],
    UserRole.admin => [
      home,
      const WorkspaceDestination('users', 'Users', Icons.people_outline, 'Review platform users and account access', section: 'Platform operations'),
      const WorkspaceDestination('venues', 'Venues', Icons.stadium_outlined, 'Review and manage training venues', section: 'Platform operations'),
      const WorkspaceDestination('overview', 'Operations', Icons.insights_outlined, 'Review platform statistics and administrative tasks', section: 'Platform operations'),
      const WorkspaceDestination('coupons', 'Coupons', Icons.local_offer_outlined, 'Manage promotional coupons', section: 'Platform operations'),
      messages, contracts, profile,
    ],
  };
}