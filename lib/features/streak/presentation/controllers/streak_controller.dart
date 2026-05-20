import 'package:flutter/material.dart';
import '../../data/services/streak_service.dart';

class StreakController with ChangeNotifier {
  final StreakService _streakService;

  StreakController(this._streakService);

  int _workoutStreak = 0;
  int _waterStreak = 0;
  int _bestWorkoutStreak = 0;
  int _bestWaterStreak = 0;
  bool _isLoading = false;

  int get workoutStreak => _workoutStreak;
  int get waterStreak => _waterStreak;
  int get bestWorkoutStreak => _bestWorkoutStreak;
  int get bestWaterStreak => _bestWaterStreak;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _streakService.getStreaks();
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        _workoutStreak = (data['workout_streak'] as num).toInt();
        _waterStreak = (data['water_streak'] as num).toInt();
        _bestWorkoutStreak = (data['best_workout_streak'] as num).toInt();
        _bestWaterStreak = (data['best_water_streak'] as num).toInt();
      }
    } catch (e) {
      debugPrint('Error loading streaks: $e');
    }
    _isLoading = false;
    notifyListeners();
  }
}
