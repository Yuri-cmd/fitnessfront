import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../../core/network/dio_client.dart';
import '../data/services/stats_service.dart';
import '../presentation/controllers/stats_controller.dart';
import '../../water/data/services/water_service.dart';
import '../../water/presentation/controllers/water_controller.dart';
import '../../streak/data/services/streak_service.dart';
import '../../streak/presentation/controllers/streak_controller.dart';
import '../../notifications/data/services/notification_settings_service.dart';
import '../../notifications/presentation/controllers/notification_settings_controller.dart';

class StatsBinding {
  static List<SingleChildWidget> providers = [
    ProxyProvider<DioClient, StatsService>(
      update: (_, dioClient, __) => StatsService(dioClient),
    ),
    ChangeNotifierProxyProvider<StatsService, StatsController>(
      create: (context) => StatsController(context.read<StatsService>()),
      update: (_, service, controller) => controller ?? StatsController(service),
    ),
    ProxyProvider<DioClient, WaterService>(
      update: (_, dioClient, __) => WaterService(dioClient),
    ),
    ChangeNotifierProxyProvider<WaterService, WaterController>(
      create: (context) => WaterController(context.read<WaterService>()),
      update: (_, service, controller) => controller ?? WaterController(service),
    ),
    ProxyProvider<DioClient, StreakService>(
      update: (_, dioClient, __) => StreakService(dioClient),
    ),
    ChangeNotifierProxyProvider<StreakService, StreakController>(
      create: (context) => StreakController(context.read<StreakService>()),
      update: (_, service, controller) => controller ?? StreakController(service),
    ),
    ProxyProvider<DioClient, NotificationSettingsService>(
      update: (_, dioClient, __) => NotificationSettingsService(dioClient),
    ),
    ChangeNotifierProxyProvider<NotificationSettingsService, NotificationSettingsController>(
      create: (context) => NotificationSettingsController(context.read<NotificationSettingsService>()),
      update: (_, service, controller) => controller ?? NotificationSettingsController(service),
    ),
  ];
}
