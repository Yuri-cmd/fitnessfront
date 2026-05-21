import 'package:get/get.dart';
import 'package:fit_tracker_app/core/network/dio_client.dart';
import 'package:fit_tracker_app/features/stats/data/services/stats_service.dart';
import 'package:fit_tracker_app/features/stats/presentation/controllers/stats_controller.dart';
import 'package:fit_tracker_app/features/water/data/services/water_service.dart';
import 'package:fit_tracker_app/features/streak/data/services/streak_service.dart';
import 'package:fit_tracker_app/features/notifications/data/services/notification_settings_service.dart';
import 'package:fit_tracker_app/features/notifications/bindings/notifications_binding.dart';

class StatsBinding {
  static void init() {
    final dioClient = Get.find<DioClient>();

    if (!Get.isRegistered<StatsService>()) {
      Get.put<StatsService>(StatsService(dioClient), permanent: true);
    }
    if (!Get.isRegistered<WaterService>()) {
      Get.put<WaterService>(WaterService(dioClient), permanent: true);
    }
    if (!Get.isRegistered<StreakService>()) {
      Get.put<StreakService>(StreakService(dioClient), permanent: true);
    }
    if (!Get.isRegistered<NotificationSettingsService>()) {
      Get.put<NotificationSettingsService>(
        NotificationSettingsService(dioClient),
        permanent: true,
      );
    }

    if (!Get.isRegistered<StatsController>()) {
      Get.put<StatsController>(
        StatsController(Get.find<StatsService>()),
        permanent: true,
      );
    }

    NotificationsBinding.init();
  }
}
