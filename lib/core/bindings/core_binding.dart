import 'package:get/get.dart';
import 'package:fit_tracker_app/core/network/dio_client.dart';
import 'package:fit_tracker_app/core/services/health_service.dart';
import 'package:fit_tracker_app/core/theme/theme_controller.dart';

class CoreBinding {
  static void init(ThemeController themeController, DioClient dioClient) {
    Get.put<ThemeController>(themeController, permanent: true);
    Get.put<DioClient>(dioClient, permanent: true);
    Get.put<HealthService>(HealthService(), permanent: true);
  }
}
