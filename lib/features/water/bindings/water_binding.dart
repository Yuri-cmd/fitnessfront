import 'package:get/get.dart';
import 'package:fit_tracker_app/core/network/dio_client.dart';
import 'package:fit_tracker_app/features/water/data/services/water_service.dart';
import 'package:fit_tracker_app/features/water/presentation/controllers/water_controller.dart';

class WaterBinding {
  static void init() {
    if (!Get.isRegistered<WaterService>()) {
      Get.put<WaterService>(
        WaterService(Get.find<DioClient>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<WaterController>()) {
      Get.put<WaterController>(
        WaterController(Get.find<WaterService>()),
        permanent: true,
      );
    }
  }
}
