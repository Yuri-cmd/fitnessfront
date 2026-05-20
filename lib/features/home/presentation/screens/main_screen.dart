import 'package:flutter/material.dart';
import '../../../../../core/widgets/app_nav_bar.dart';
import 'dashboard_screen.dart';
import '../../../workout/presentation/screens/routines_screen.dart';
import '../../../metrics/presentation/screens/weight_metrics_screen.dart';
import '../../../stats/presentation/screens/stats_screen.dart';
import 'more_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    RoutinesScreen(),
    WeightMetricsScreen(),
    StatsScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        child: AppNavBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
        ),
      ),
    );
  }
}
