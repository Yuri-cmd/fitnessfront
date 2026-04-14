import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../data/services/workout_service.dart';
import '../presentation/controllers/workout_controller.dart';
import '../../../core/network/dio_client.dart';

class WorkoutBinding {
  static List<SingleChildWidget> providers = [
    ProxyProvider<DioClient, WorkoutService>(
      update: (_, dioClient, __) => WorkoutService(dioClient),
    ),
    ChangeNotifierProxyProvider<WorkoutService, WorkoutController>(
      create: (context) => WorkoutController(context.read<WorkoutService>()),
      update: (_, service, previous) => previous ?? WorkoutController(service),
    ),
  ];
}
