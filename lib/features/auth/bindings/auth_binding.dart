import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../../core/network/dio_client.dart';
import '../data/services/auth_service.dart';
import '../presentation/controllers/auth_controller.dart';

class AuthBinding {
  static List<SingleChildWidget> providers = [
    ProxyProvider<DioClient, AuthService>(
      update: (context, dioClient, previous) => AuthService(dioClient),
    ),
    ChangeNotifierProxyProvider<AuthService, AuthController>(
      create: (context) => AuthController(context.read<AuthService>()),
      update: (context, authService, previous) => previous ?? AuthController(authService),
    ),
  ];
}
