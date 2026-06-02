import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:fit_tracker_app/features/workout/data/models/exercise_model.dart';
import 'package:fit_tracker_app/features/workout/data/models/routine_model.dart';
import 'package:fit_tracker_app/features/workout/data/models/workout_log_model.dart';
import 'package:fit_tracker_app/features/workout/data/services/workout_service.dart';
import 'package:fit_tracker_app/features/workout/domain/streak_calculator.dart';
import 'package:fit_tracker_app/core/services/health_service.dart';
import 'package:fit_tracker_app/core/services/app_flags.dart';

class WorkoutController extends GetxController {
  final WorkoutService _workoutService;
  final HealthService _healthService;

  WorkoutController(this._workoutService, this._healthService);

  final routines = <Routine>[].obs;
  final archivedRoutines = <Routine>[].obs;
  final availableExercises = <Exercise>[].obs;
  final workoutLogs = <WorkoutLog>[].obs;
  final weeklyProgress = <int, bool>{}.obs;
  final isLoading = false.obs;
  final isLoadingExercises = false.obs;
  final isLoadingArchived = false.obs;
  final showArchived = false.obs;
  final selectedDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    loadRoutines();
    loadWorkoutHistory();
  }

  Future<void> loadWeeklyProgress() async {
    try {
      final response = await _workoutService.getWeeklyProgress();
      if (response.statusCode == 200) {
        weeklyProgress.value = (response.data as Map).map(
          (key, value) => MapEntry(int.parse(key.toString()), value as bool),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> loadWorkoutHistory() async {
    try {
      final response = await _workoutService.getWorkoutHistory();
      if (response.statusCode == 200) {
        workoutLogs.value = (response.data as List<dynamic>)
            .map((e) => WorkoutLog.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
    }
  }

  Future<void> loadRoutines() async {
    isLoading.value = true;
    try {
      final response = await _workoutService.getRoutines();
      if (response.statusCode == 200) {
        routines.value = (response.data as List<dynamic>)
            .map((e) => Routine.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadExercises() async {
    isLoadingExercises.value = true;
    try {
      final response = await _workoutService.getExercises();
      if (response.statusCode == 200) {
        availableExercises.value = (response.data as List<dynamic>)
            .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading exercises: $e');
    } finally {
      isLoadingExercises.value = false;
    }
  }

  Future<Exercise?> createExercise(String name, String muscleGroup) async {
    try {
      final response = await _workoutService.createExercise(
        {'name': name, 'muscle_group': muscleGroup},
      );
      await loadExercises();
      return Exercise.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<Exercise?> updateExercise(int id, String name, String muscleGroup) async {
    try {
      final response = await _workoutService.updateExercise(
        id,
        {'name': name, 'muscle_group': muscleGroup},
      );
      await loadExercises();
      return Exercise.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<bool> createRoutine(
    String name,
    List<Map<String, dynamic>> selectedExercises,
  ) async {
    isLoading.value = true;
    try {
      final response = await _workoutService.createRoutine(name, selectedExercises);
      if (response.statusCode == 201 || response.statusCode == 200) {
        await loadRoutines();
        return true;
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  Future<bool> updateRoutine(
    int id,
    String name,
    List<Map<String, dynamic>> selectedExercises,
  ) async {
    isLoading.value = true;
    try {
      final response = await _workoutService.updateRoutine(id, name, selectedExercises);
      if (response.statusCode == 200) {
        await loadRoutines();
        return true;
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading.value = false;
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

  Future<void> archiveRoutine(int id) async {
    try {
      await _workoutService.archiveRoutine(id);
      await loadRoutines();
      if (showArchived.value) await loadArchivedRoutines();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> unarchiveRoutine(int id) async {
    try {
      await _workoutService.unarchiveRoutine(id);
      await loadRoutines();
      await loadArchivedRoutines();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> loadArchivedRoutines() async {
    isLoadingArchived.value = true;
    try {
      final response = await _workoutService.getArchivedRoutines();
      if (response.statusCode == 200) {
        archivedRoutines.value = (response.data as List<dynamic>)
            .map((e) => Routine.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoadingArchived.value = false;
    }
  }

  void toggleArchived() {
    showArchived.value = !showArchived.value;
    if (showArchived.value && archivedRoutines.isEmpty) {
      loadArchivedRoutines();
    }
  }

  Future<void> completeRoutine(
    int id, [
    List<Map<String, dynamic>>? sets,
    DateTime? startTime,
  ]) async {
    final start = startTime ?? DateTime.now();

    // Optimistic update: marca la rutina como hecha de inmediato en la UI
    workoutLogs.insert(0, WorkoutLog(routineId: id, completedAt: DateTime.now()));

    try {
      await _workoutService.completeRoutine(id, sets);
      _healthService.saveWorkout(start: start, end: DateTime.now());
    } catch (e) {
      debugPrint('completeRoutine save failed: $e');
      return;
    }
    // Suppress 401→logout for background reloads: a transient server error
    // after a successful save shouldn't kick the user out mid-session.
    AppFlags.suppressLogout(const Duration(seconds: 30));
    try {
      await loadRoutines();
      await loadWeeklyProgress();
      await loadWorkoutHistory();
    } catch (e) {
      debugPrint('completeRoutine reload failed: $e');
    }
  }

  ({int streak, List<bool> trainedDays}) computeStreakData(
      {required int routineId}) {
    return calculateStreak(
      logs: List<WorkoutLog>.from(workoutLogs),
      routineCount: routines.length,
      now: DateTime.now(),
      insertRoutineId: routineId,
    );
  }

  bool isDoneToday(Routine routine) {
    return workoutLogs.any((log) {
      if (log.routineId != routine.id) return false;
      final d = log.completedAt;
      final now = DateTime.now();
      return d.year == now.year && d.month == now.month && d.day == now.day;
    });
  }

  bool isDoneThisWeek(Routine routine) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(monday.year, monday.month, monday.day);
    return workoutLogs.any((log) {
      if (log.routineId != routine.id) return false;
      return !log.completedAt.isBefore(weekStart);
    });
  }
}
