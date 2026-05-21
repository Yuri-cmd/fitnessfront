import 'package:get/get.dart';
import 'package:fit_tracker_app/features/streak/data/services/streak_service.dart';

class StreakController extends GetxController {
  final StreakService _streakService;

  StreakController(this._streakService);

  final workoutStreak = 0.obs;
  final waterStreak = 0.obs;
  final bestWorkoutStreak = 0.obs;
  final bestWaterStreak = 0.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final response = await _streakService.getStreaks();
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        workoutStreak.value = (data['workout_streak'] as num).toInt();
        waterStreak.value = (data['water_streak'] as num).toInt();
        bestWorkoutStreak.value =
            (data['best_workout_streak'] as num).toInt();
        bestWaterStreak.value = (data['best_water_streak'] as num).toInt();
      }
    } catch (_) {}
    isLoading.value = false;
  }
}
