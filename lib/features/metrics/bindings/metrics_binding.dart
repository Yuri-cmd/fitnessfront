import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../../core/network/dio_client.dart';
import '../data/services/metrics_service.dart';
import '../presentation/controllers/fitness_controller.dart';
import '../../auth/data/services/auth_service.dart';

class MetricsBinding {
  static List<SingleChildWidget> providers = [
    ProxyProvider<DioClient, MetricsService>(
      update: (context, dioClient, previous) => MetricsService(dioClient),
    ),
    ChangeNotifierProxyProvider2<MetricsService, AuthService, FitnessController>(
      create: (context) => FitnessController(
        context.read<MetricsService>(),
        context.read<AuthService>(),
      ),
      update: (context, metricsService, authService, previous) =>
          previous ?? FitnessController(metricsService, authService),
    ),
  ];
}
