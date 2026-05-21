import 'package:get/get.dart';
import 'package:fit_tracker_app/core/network/dio_client.dart';
import 'package:fit_tracker_app/core/services/health_service.dart';
import 'package:fit_tracker_app/features/workout/data/services/workout_service.dart';
import 'package:fit_tracker_app/features/workout/data/services/goals_service.dart';
import 'package:fit_tracker_app/features/workout/presentation/controllers/workout_controller.dart';
import 'package:fit_tracker_app/features/workout/presentation/controllers/goals_controller.dart';

class WorkoutBinding {
  static void init() {
    final dioClient = Get.find<DioClient>();
    final healthService = Get.find<HealthService>();

    Get.put<WorkoutService>(WorkoutService(dioClient), permanent: true);
    Get.put<GoalsService>(GoalsService(dioClient.dio), permanent: true);

    Get.put<WorkoutController>(
      WorkoutController(Get.find<WorkoutService>(), healthService),
      permanent: true,
    );
    Get.put<GoalsController>(
      GoalsController(Get.find<GoalsService>()),
      permanent: true,
    );
  }
}
