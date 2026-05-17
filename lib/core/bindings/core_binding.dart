import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../network/dio_client.dart';
import '../theme/theme_controller.dart';
import '../services/health_service.dart';

class CoreBinding {
  static List<SingleChildWidget> providers(ThemeController themeController) => [
    ChangeNotifierProvider<ThemeController>.value(value: themeController),
    Provider<DioClient>(
      create: (_) => DioClient(),
    ),
    Provider<HealthService>(
      create: (_) => HealthService(),
    ),
  ];
}
