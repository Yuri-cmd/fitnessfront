import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_tracker_app/features/workout/data/models/exercise_model.dart';
import 'package:fit_tracker_app/features/workout/presentation/controllers/workout_controller.dart';

class WikiController extends GetxController {
  WorkoutController get _w => Get.find<WorkoutController>();

  final search = ''.obs;
  final selectedMuscle = Rx<String?>(null);
  final searchCtrl = TextEditingController();

  bool get isLoading => _w.isLoadingExercises.value;
  List<Exercise> get exercises => _w.availableExercises;

  List<String> get muscleGroups => exercises
      .map((e) => e.muscleGroup)
      .whereType<String>()
      .where((m) => m.isNotEmpty)
      .toSet()
      .toList()
        ..sort();

  List<Exercise> get filtered => exercises.where((e) {
        final name = e.name.toLowerCase();
        final muscle = e.muscleGroup ?? '';
        return (search.value.isEmpty ||
                name.contains(search.value.toLowerCase())) &&
            (selectedMuscle.value == null || muscle == selectedMuscle.value);
      }).toList();

  @override
  void onInit() {
    super.onInit();
    searchCtrl.addListener(() => search.value = searchCtrl.text);
    _w.loadExercises();
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    super.onClose();
  }

  void clearSearch() {
    searchCtrl.clear();
    search.value = '';
  }

  void setMuscle(String? m) => selectedMuscle.value = m;
}
