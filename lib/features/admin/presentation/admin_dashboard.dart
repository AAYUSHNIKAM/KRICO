import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import 'dashboard/widgets/admin_dashboard_header.dart';
import 'dashboard/widgets/admin_stats_section.dart';
import 'dashboard/widgets/admin_tasks_section.dart';
import 'dashboard/widgets/admin_venue_form.dart';
import 'dashboard/widgets/admin_coupon_section.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const AdminDashboardHeader(),
          SliverPadding(
            padding: EdgeInsets.all(SpacingScale.s16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const AdminStatsSection(),
                SizedBox(height: SpacingScale.s24),
                const AdminTasksSection(),
                SizedBox(height: SpacingScale.s24),
                const AdminVenueForm(),
                SizedBox(height: SpacingScale.s24),
                const AdminCouponSection(),
                SizedBox(height: SpacingScale.s32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
