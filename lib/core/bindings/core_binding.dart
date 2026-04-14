import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../network/dio_client.dart';

class CoreBinding {
  static List<SingleChildWidget> providers = [
    Provider<DioClient>(
      create: (context) => DioClient(),
    ),
  ];
}
