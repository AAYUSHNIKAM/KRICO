import 'package:flutter/material.dart';
import '../../player/presentation/dashboard/dashboard_page.dart';
import '../../../models/user_model.dart';

class PlayerDashboard extends StatelessWidget {
  final UserModel userModel;

  const PlayerDashboard({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    return DashboardPage(userModel: userModel);
  }
}
