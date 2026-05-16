import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/bindings/core_binding.dart';
import 'features/auth/bindings/auth_binding.dart';
import 'features/metrics/bindings/metrics_binding.dart';
import 'features/workout/bindings/workout_binding.dart';
import 'features/stats/bindings/stats_binding.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/home/presentation/screens/dashboard_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  runApp(
    MultiProvider(
      providers: [
        ...CoreBinding.providers,
        ...AuthBinding.providers,
        ...MetricsBinding.providers,
        ...WorkoutBinding.providers,
        ...StatsBinding.providers,
      ],
      child: const FitTrackerApp(),
    ),
  );
}

class FitTrackerApp extends StatelessWidget {
  const FitTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Power Stack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Consumer<AuthController>(
        builder: (context, auth, _) {
          return auth.isAuthenticated ? const DashboardScreen() : const LoginScreen();
        },
      ),
    );
  }
}
