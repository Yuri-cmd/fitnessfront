import 'package:get/get.dart';
import 'package:fit_tracker_app/core/network/dio_client.dart';
import 'package:fit_tracker_app/features/streak/data/services/streak_service.dart';
import 'package:fit_tracker_app/features/streak/presentation/controllers/streak_controller.dart';

class StreakBinding {
  static void init() {
    if (!Get.isRegistered<StreakService>()) {
      Get.put<StreakService>(
        StreakService(Get.find<DioClient>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<StreakController>()) {
      Get.put<StreakController>(
        StreakController(Get.find<StreakService>()),
        permanent: true,
      );
    }
  }
}
