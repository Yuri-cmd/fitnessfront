import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/bindings/core_binding.dart';
import 'core/network/dio_client.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/data/services/auth_service.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/metrics/bindings/metrics_binding.dart';
import 'features/workout/bindings/workout_binding.dart';
import 'features/stats/bindings/stats_binding.dart';
import 'features/water/bindings/water_binding.dart';
import 'features/streak/bindings/streak_binding.dart';
import 'core/theme/app_theme.dart';
import 'core/presentation/screens/splash_screen.dart';
import 'core/services/live_activity_service.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/home/presentation/screens/main_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Platform.isIOS) await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isIOS) {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
    // Terminate any Live Activity left open from a previous session killed by the OS.
    await LiveActivityService.end();
  }

  await initializeDateFormatting('es_ES', null);

  // ── Core dependencies ──
  final themeController = ThemeController();
  await themeController.init();

  final dioClient = DioClient();

  // ── Register all bindings with GetX ──
  CoreBinding.init(themeController, dioClient);

  final authService = AuthService(dioClient);
  Get.put<AuthService>(authService, permanent: true);
  Get.put<AuthController>(AuthController(authService), permanent: true);

  // Feature bindings (all use Get.find<DioClient>() internally)
  MetricsBinding.init();
  WorkoutBinding.init();
  StatsBinding.init();
  WaterBinding.init();
  StreakBinding.init();

  runApp(const FitTrackerApp());
}

class FitTrackerApp extends StatelessWidget {
  const FitTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<ThemeController>();
    final auth = Get.find<AuthController>();

    return Obx(
      () => GetMaterialApp(
        title: 'Power Stack',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: theme.modeObs.value,
        defaultTransition: Transition.rightToLeftWithFade,
        transitionDuration: const Duration(milliseconds: 320),
        home: !auth.isInitialized.value
            ? const SplashScreen()
            : auth.isAuthenticated.value
            ? const MainScreen()
            : const LoginScreen(),
      ),
    );
  }
}
