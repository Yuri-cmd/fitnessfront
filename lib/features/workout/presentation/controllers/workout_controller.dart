import 'package:flutter/material.dart';
import '../../data/services/workout_service.dart';

class WorkoutController with ChangeNotifier {
  final WorkoutService _workoutService;

  WorkoutController(this._workoutService);

  List<dynamic> _routines = [];
  List<dynamic> _availableExercises = [];
  List<dynamic> _workoutLogs = [];
  Map<int, bool> _weeklyProgress = {}; 
  bool _isLoading = false;
  bool _isLoadingExercises = false;

  List<dynamic> get routines => _routines;
  List<dynamic> get availableExercises => _availableExercises;
  List<dynamic> get workoutLogs => _workoutLogs;
  bool get isLoading => _isLoading;
  bool get isLoadingExercises => _isLoadingExercises;
  Map<int, bool> get weeklyProgress => _weeklyProgress;

  Future<void> loadWeeklyProgress() async {
    try {
      final response = await _workoutService.getWeeklyProgress();
      if (response.statusCode == 200) {
        _weeklyProgress = (response.data as Map).map((key, value) => MapEntry(int.parse(key.toString()), value as bool));
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> loadWorkoutHistory() async {
    try {
      final response = await _workoutService.getWorkoutHistory();
      if (response.statusCode == 200) {
        _workoutLogs = response.data;
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> loadRoutines() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _workoutService.getRoutines();
      if (response.statusCode == 200) {
        _routines = response.data;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadExercises() async {
    _isLoadingExercises = true;
    notifyListeners();
    try {
      final response = await _workoutService.getExercises();
      if (response.statusCode == 200) {
        _availableExercises = response.data;
      }
    } catch (e) {
      debugPrint("Error loading exercises: $e");
    }
    _isLoadingExercises = false;
    notifyListeners();
  }

  Future<dynamic> createExercise(String name, String muscleGroup) async {
    try {
      final response = await _workoutService.createExercise({'name': name, 'muscle_group': muscleGroup});
      await loadExercises();
      return response.data;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<dynamic> updateExercise(int id, String name, String muscleGroup) async {
    try {
      final response = await _workoutService.updateExercise(id, {'name': name, 'muscle_group': muscleGroup});
      await loadExercises();
      return response.data;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<bool> createRoutine(String name, List<Map<String, dynamic>> selectedExercises) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _workoutService.createRoutine(name, selectedExercises);
      if (response.statusCode == 201 || response.statusCode == 200) {
        await loadRoutines();
        return true;
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> updateRoutine(int id, String name, List<Map<String, dynamic>> selectedExercises) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _workoutService.updateRoutine(id, name, selectedExercises);
      if (response.statusCode == 200) {
        await loadRoutines();
        return true;
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<void> deleteRoutine(int id) async {
    try {
      await _workoutService.deleteRoutine(id);
      await loadRoutines();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> completeRoutine(int id) async {
    try {
      await _workoutService.completeRoutine(id);
      await loadRoutines();
      await loadWeeklyProgress();
      await loadWorkoutHistory();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
