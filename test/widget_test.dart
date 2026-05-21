import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:fit_tracker_app/main.dart';
import 'package:fit_tracker_app/core/network/dio_client.dart';
import 'package:fit_tracker_app/core/services/health_service.dart';
import 'package:fit_tracker_app/core/theme/theme_controller.dart';
import 'package:fit_tracker_app/features/auth/data/services/auth_service.dart';
import 'package:fit_tracker_app/features/auth/presentation/controllers/auth_controller.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Setup GetX bindings for test
    final dioClient = DioClient();
    final themeController = ThemeController();
    Get.put<ThemeController>(themeController, permanent: true);
    Get.put<DioClient>(dioClient, permanent: true);
    Get.put<HealthService>(HealthService(), permanent: true);
    final authService = AuthService(dioClient);
    Get.put<AuthService>(authService, permanent: true);
    Get.put<AuthController>(AuthController(authService), permanent: true);

    await tester.pumpWidget(const FitTrackerApp());
    await tester.pump();
    expect(find.byType(FitTrackerApp), findsOneWidget);
  });
}
