import 'package:get/get.dart';
import 'package:fit_tracker_app/core/network/dio_client.dart';
import 'package:fit_tracker_app/core/services/health_service.dart';
import 'package:fit_tracker_app/features/metrics/data/services/metrics_service.dart';
import 'package:fit_tracker_app/features/metrics/data/services/measurement_service.dart';
import 'package:fit_tracker_app/features/metrics/presentation/controllers/fitness_controller.dart';
import 'package:fit_tracker_app/features/metrics/presentation/controllers/measurement_controller.dart';
import 'package:fit_tracker_app/features/auth/data/services/auth_service.dart';

class MetricsBinding {
  static void init() {
    final dioClient = Get.find<DioClient>();

    Get.put<MetricsService>(MetricsService(dioClient), permanent: true);
    Get.put<MeasurementService>(MeasurementService(dioClient), permanent: true);

    Get.put<FitnessController>(
      FitnessController(
        Get.find<MetricsService>(),
        Get.find<AuthService>(),
        Get.find<HealthService>(),
      ),
      permanent: true,
    );
    Get.put<MeasurementController>(
      MeasurementController(Get.find<MeasurementService>()),
      permanent: true,
    );
  }
}
