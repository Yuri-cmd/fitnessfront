import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_tracker_app/core/widgets/app_nav_bar.dart';
import 'dashboard_screen.dart';
import 'package:fit_tracker_app/features/workout/presentation/screens/routines_screen.dart';
import 'package:fit_tracker_app/features/metrics/presentation/screens/weight_metrics_screen.dart';
import 'package:fit_tracker_app/features/stats/presentation/screens/stats_screen.dart';
import 'more_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentIndex = 0.obs;

    final screens = const [
      DashboardScreen(),
      RoutinesScreen(),
      WeightMetricsScreen(),
      StatsScreen(),
      MoreScreen(),
    ];

    return Obx(() => Scaffold(
          body: IndexedStack(
            index: currentIndex.value,
            children: screens,
          ),
          bottomNavigationBar: SafeArea(
            child: AppNavBar(
              currentIndex: currentIndex.value,
              onTap: (i) => currentIndex.value = i,
            ),
          ),
        ));
  }
}
