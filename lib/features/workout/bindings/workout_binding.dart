import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../data/services/workout_service.dart';
import '../data/services/goals_service.dart';
import '../presentation/controllers/workout_controller.dart';
import '../presentation/controllers/goals_controller.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/services/health_service.dart';

class WorkoutBinding {
  static List<SingleChildWidget> providers = [
    ProxyProvider<DioClient, WorkoutService>(
      update: (_, dioClient, __) => WorkoutService(dioClient),
    ),
    ProxyProvider<DioClient, GoalsService>(
      update: (_, dio, __) => GoalsService(dio.dio),
    ),
    ChangeNotifierProxyProvider2<WorkoutService, HealthService, WorkoutController>(
      create: (context) => WorkoutController(
        context.read<WorkoutService>(),
        context.read<HealthService>(),
      ),
      update: (_, service, healthService, controller) =>
          controller ?? WorkoutController(service, healthService),
    ),
    ChangeNotifierProxyProvider<GoalsService, GoalsController>(
      create: (context) => GoalsController(context.read<GoalsService>()),
      update: (_, service, controller) => controller ?? GoalsController(service),
    ),
  ];
}
