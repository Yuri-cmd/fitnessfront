import 'package:get/get.dart';
import 'package:fit_tracker_app/features/water/data/services/water_service.dart';

class WaterController extends GetxController {
  final WaterService _waterService;

  WaterController(this._waterService);

  final glasses = 0.obs;
  final goalGlasses = 8.obs;
  final isLoading = false.obs;

  bool get goalReached => glasses.value >= goalGlasses.value;
  double get progress => (glasses.value / goalGlasses.value).clamp(0.0, 1.0);
  String get statusText => goalReached
      ? '¡Meta alcanzada! 🎉'
      : '${goalGlasses.value - glasses.value} vasos más para tu meta';

  @override
  void onInit() {
    super.onInit();
    loadTodayWater();
  }

  Future<void> loadTodayWater() async {
    try {
      final response = await _waterService.getTodayWater();
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        glasses.value = (data['glasses'] as num).toInt();
        goalGlasses.value = (data['goal_glasses'] as num).toInt();
      }
    } catch (_) {}
  }

  Future<void> addGlass() async {
    isLoading.value = true;
    try {
      final response = await _waterService.logGlasses(1);
      if (response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        glasses.value = (data['glasses'] as num).toInt();
        goalGlasses.value = (data['goal_glasses'] as num).toInt();
      }
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> removeGlass() async {
    if (glasses.value <= 0) return;
    isLoading.value = true;
    try {
      final response = await _waterService.removeLastGlass();
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        glasses.value = (data['glasses'] as num).toInt();
        goalGlasses.value = (data['goal_glasses'] as num).toInt();
      }
    } catch (_) {}
    isLoading.value = false;
  }
}
