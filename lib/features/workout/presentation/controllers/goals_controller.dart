import 'package:flutter/material.dart';
import 'package:fit_tracker_app/features/workout/data/services/goals_service.dart';

class GoalsController with ChangeNotifier {
  final GoalsService _goalsService;
  GoalsController(this._goalsService);

  List<dynamic> _goals = [];
  bool _isLoading = false;

  List<dynamic> get goals => _goals;
  bool get isLoading => _isLoading;

  Future<void> loadGoals() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _goalsService.getGoals();
      if (response.statusCode == 200) {
        _goals = response.data;
      }
    } catch (e) {
      debugPrint("Error loading goals: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createGoal(String type, double targetValue, {DateTime? deadline}) async {
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
      debugPrint("Error creating goal: $e");
    }
    return false;
  }

  Future<void> deleteGoal(int id) async {
    try {
      await _goalsService.deleteGoal(id);
      _goals.removeWhere((g) => g['id'] == id);
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting goal: $e");
    }
  }
}
