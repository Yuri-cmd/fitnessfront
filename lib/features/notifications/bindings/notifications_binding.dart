import 'package:get/get.dart';
import 'package:fit_tracker_app/core/network/dio_client.dart';
import 'package:fit_tracker_app/features/notifications/data/services/notification_settings_service.dart';
import 'package:fit_tracker_app/features/notifications/presentation/controllers/notification_settings_controller.dart';

class NotificationsBinding {
  static void init() {
    if (!Get.isRegistered<NotificationSettingsService>()) {
      Get.put<NotificationSettingsService>(
        NotificationSettingsService(Get.find<DioClient>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<NotificationSettingsController>()) {
      Get.put<NotificationSettingsController>(
        NotificationSettingsController(
          Get.find<NotificationSettingsService>(),
        ),
        permanent: true,
      );
    }
  }
}
