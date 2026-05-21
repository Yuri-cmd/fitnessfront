import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_tracker_app/core/widgets/app_nav_bar.dart';
import 'dashboard_screen.dart';
import 'package:fit_tracker_app/features/workout/presentation/screens/routines_screen.dart';
import 'package:fit_tracker_app/features/metrics/presentation/screens/weight_metrics_screen.dart';
import 'package:fit_tracker_app/features/stats/presentation/screens/stats_screen.dart';
import 'more_screen.dart';

class _NavController extends GetxController {
  final currentIndex = 0.obs;
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = Get.put(_NavController());

    const screens = [
      DashboardScreen(),
      RoutinesScreen(),
      WeightMetricsScreen(),
      StatsScreen(),
      MoreScreen(),
    ];

    return Obx(() => Scaffold(
          body: IndexedStack(
            index: nav.currentIndex.value,
            children: screens,
          ),
          bottomNavigationBar: SafeArea(
            child: AppNavBar(
              currentIndex: nav.currentIndex.value,
              onTap: (i) => nav.currentIndex.value = i,
            ),
          ),
        ));
  }
}
