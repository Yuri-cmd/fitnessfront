import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:fit_tracker_app/features/workout/data/models/goal_model.dart';
import 'package:fit_tracker_app/features/workout/data/services/goals_service.dart';

class GoalsController extends GetxController {
  final GoalsService _goalsService;
  GoalsController(this._goalsService);

  final goals = <Goal>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadGoals();
  }

  Future<void> loadGoals() async {
    isLoading.value = true;
    try {
      final response = await _goalsService.getGoals();
      if (response.statusCode == 200) {
        goals.value = (response.data as List<dynamic>)
            .map((e) => Goal.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading goals: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createGoal(
    String type,
    double targetValue, {
    DateTime? deadline,
  }) async {
    try {
      final response = await _goalsService.createGoal({
        'type': type,
        'target_value': targetValue,
        'deadline': deadline?.toIso8601String(),
      });
      if (response.statusCode == 201) {
        await loadGoals();
        return true;
      }
    } catch (e) {
      debugPrint('Error creating goal: $e');
    }
    return false;
  }

  Future<void> deleteGoal(int id) async {
    try {
      await _goalsService.deleteGoal(id);
      goals.removeWhere((g) => g.id == id);
    } catch (e) {
      debugPrint('Error deleting goal: $e');
    }
  }
}
