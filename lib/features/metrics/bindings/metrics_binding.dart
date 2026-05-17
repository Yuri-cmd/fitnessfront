import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/services/health_service.dart';
import '../data/services/metrics_service.dart';
import '../data/services/measurement_service.dart';
import '../presentation/controllers/fitness_controller.dart';
import '../presentation/controllers/measurement_controller.dart';
import '../../auth/data/services/auth_service.dart';

class MetricsBinding {
  static List<SingleChildWidget> providers = [
    ProxyProvider<DioClient, MetricsService>(
      update: (context, dioClient, previous) => MetricsService(dioClient),
    ),
    ChangeNotifierProxyProvider3<MetricsService, AuthService, HealthService, FitnessController>(
      create: (context) => FitnessController(
        context.read<MetricsService>(),
        context.read<AuthService>(),
        context.read<HealthService>(),
      ),
      update: (context, metricsService, authService, healthService, previous) =>
          previous ?? FitnessController(metricsService, authService, healthService),
    ),
    ProxyProvider<DioClient, MeasurementService>(
      update: (_, dioClient, __) => MeasurementService(dioClient),
    ),
    ChangeNotifierProxyProvider<MeasurementService, MeasurementController>(
      create: (context) => MeasurementController(context.read<MeasurementService>()),
      update: (_, service, controller) => controller ?? MeasurementController(service),
    ),
  ];
}
