import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fit_tracker_app/core/services/live_activity_service.dart';
import 'package:fit_tracker_app/features/workout/data/models/exercise_model.dart';
import 'package:fit_tracker_app/features/workout/data/models/routine_model.dart';
import 'package:fit_tracker_app/features/workout/data/services/workout_service.dart';

enum TrainingPhase { ready, resting, finished }

/// A single step in the flat execution order of the session.
/// [skipRestAfter] = true means go directly to the next step without a rest
/// period (superset transition).
class _Step {
  final int exIdx;
  final int setIdx;
  final bool skipRestAfter;
  const _Step(this.exIdx, this.setIdx, this.skipRestAfter);
}

class TrainingSessionController extends GetxController with WidgetsBindingObserver {
  final Routine routine;

  TrainingSessionController({required this.routine});

  // ── Timers & Audio ─────────────────────────────────────────────────────────
  DateTime? _sessionStart;
  Timer? _timer;
  DateTime? _restEndTime;
  Timer? _restTimer;
  final _player = AudioPlayer();

  // ── Reactive state ─────────────────────────────────────────────────────────
  final phase = TrainingPhase.ready.obs;
  final elapsed = 0.obs;
  final restRemaining = 0.obs;
  final restTime = 180.obs;            // working set rest (user-adjustable, default 3 min)
  final currentRestDuration = 180.obs; // actual duration of the current rest period
  final isWarmupRest = false.obs;
  final isRestWarning = false.obs;     // true when ≤10s remain in rest

  // Last weights per exercise from previous sessions  {exerciseId → kg}
  final _lastWeights = <int, double>{}.obs;

  final currentExIdx = 0.obs;
  final currentSetIdx = 0.obs;
  final completedSetNum = 0.obs;

  final exerciseOrder = <Exercise>[].obs;

  // sets[exIdx][setIdx] = {'done': bool, 'weight': '', 'type': 'warmup'|'working'}
  final sets = <List<Map<String, dynamic>>>[].obs;

  late List<List<TextEditingController>> controllers;

  // ── Flat execution order ───────────────────────────────────────────────────
  List<_Step> _steps = [];
  int _stepIdx = 0;

  static const String _sessionKey = 'active_workout_session';

  // ── Init / dispose ─────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _buildSets();
    _sessionStart = DateTime.now();
    WidgetsBinding.instance.addObserver(this);
    if (Platform.isIOS) {
      AudioPlayer.global.setAudioContext(AudioContext(
        iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
      ));
    }
    _asyncInit();
  }

  Future<void> _asyncInit() async {
    await Future.wait([_restoreProgress(), _fetchLastWeights()]);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsed.value = DateTime.now().difference(_sessionStart!).inSeconds;
    });
    elapsed.value = DateTime.now().difference(_sessionStart!).inSeconds;
    _autoFillCurrentWeight();
    _startLiveActivity();
  }

  Future<void> _fetchLastWeights() async {
    try {
      final ids = exerciseOrder.map((e) => e.id).toList();
      if (ids.isEmpty) return;
      final response = await Get.find<WorkoutService>().getLastWeights(ids);
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        _lastWeights.assignAll(
          data.map((k, v) => MapEntry(int.parse(k), (v as num).toDouble())),
        );
      }
    } catch (e) {
      debugPrint('Error fetching last weights: $e');
    }
  }

  double? lastWeightFor(int exerciseId) => _lastWeights[exerciseId];

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _saveProgress();
    } else if (state == AppLifecycleState.detached) {
      LiveActivityService.end();
    } else if (state == AppLifecycleState.resumed) {
      if (phase.value == TrainingPhase.resting && restRemaining.value <= 0) {
        skipRest();
      } else if (phase.value == TrainingPhase.resting && _restEndTime != null) {
        restRemaining.value =
            _restEndTime!.difference(DateTime.now()).inSeconds.clamp(0, 9999);
      }
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _restTimer?.cancel();
    _player.dispose();
    LiveActivityService.end();
    for (final row in controllers) {
      for (final c in row) {
        c.dispose();
      }
    }
    super.onClose();
  }

  // ── Progress persistence ───────────────────────────────────────────────────
  Future<void> _saveProgress() async {
    if (phase.value == TrainingPhase.finished) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final setsData = List.generate(sets.length, (i) =>
        List.generate(sets[i].length, (j) => {
          'done': sets[i][j]['done'],
          'weight': controllers[i][j].text,
          'type': sets[i][j]['type'],
        }),
      );
      await prefs.setString(_sessionKey, jsonEncode({
        'routineId': routine.id,
        'sessionStart': _sessionStart!.toIso8601String(),
        'stepIdx': _stepIdx,
        'restTime': restTime.value,
        'sets': setsData,
      }));
    } catch (e) {
      debugPrint('Error saving workout progress: $e');
    }
  }

  Future<void> _restoreProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_sessionKey);
      if (raw == null) return;

      final data = jsonDecode(raw) as Map<String, dynamic>;
      if (data['routineId'] != routine.id) {
        await prefs.remove(_sessionKey);
        return;
      }

      final savedStart = DateTime.parse(data['sessionStart'] as String);
      if (DateTime.now().difference(savedStart).inHours >= 6) {
        await prefs.remove(_sessionKey);
        return;
      }

      _sessionStart = savedStart;
      _stepIdx = (data['stepIdx'] as num).toInt();
      restTime.value = (data['restTime'] as num).toInt();

      final savedSets = data['sets'] as List<dynamic>;
      for (int i = 0; i < savedSets.length && i < sets.length; i++) {
        final row = savedSets[i] as List<dynamic>;
        for (int j = 0; j < row.length && j < sets[i].length; j++) {
          final s = row[j] as Map<String, dynamic>;
          sets[i][j]['done'] = s['done'] as bool;
          controllers[i][j].text = (s['weight'] as String?) ?? '';
        }
      }
      sets.refresh();

      if (_stepIdx < _steps.length) {
        currentExIdx.value = _steps[_stepIdx].exIdx;
        currentSetIdx.value = _steps[_stepIdx].setIdx;
      }

      Get.snackbar(
        'Sesión restaurada',
        'Retomas donde lo dejaste.',
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('Error restoring session: $e');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
    }
  }

  Future<void> clearProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  // ── Build sets (warmup first, then working) ────────────────────────────────
  void _buildSets() {
    exerciseOrder.value = List<Exercise>.from(routine.exercises);

    sets.value = exerciseOrder.map((ex) {
      final pivot = ex.pivot!;
      final warmup = List.generate(
        pivot.warmupSets,
        (_) => <String, dynamic>{'done': false, 'weight': '', 'type': 'warmup'},
      );
      final working = List.generate(
        pivot.sets,
        (_) => <String, dynamic>{'done': false, 'weight': '', 'type': 'working'},
      );
      return [...warmup, ...working];
    }).toList();

    controllers = exerciseOrder.map((ex) {
      return List.generate(ex.pivot!.totalSets, (_) => TextEditingController());
    }).toList();

    _steps = _buildSteps(exerciseOrder);
    _stepIdx = 0;
    if (_steps.isNotEmpty) {
      currentExIdx.value = _steps[0].exIdx;
      currentSetIdx.value = _steps[0].setIdx;
    }
  }

  /// Builds the flat execution order, handling superset groups.
  ///
  /// For exercises in a superset group (consecutive exercises sharing the same
  /// non-null supersetGroup value):
  /// - Warmup sets are executed per-exercise with rest between them.
  /// - Working sets are executed in rounds: one set from each exercise in the
  ///   group per round, with no rest between exercises in a round, and a normal
  ///   rest only after the last exercise in each round.
  List<_Step> _buildSteps(List<Exercise> exList) {
    final steps = <_Step>[];
    int i = 0;
    while (i < exList.length) {
      final group = exList[i].pivot!.supersetGroup;

      // Find the end of this superset block (consecutive same group).
      int j = i + 1;
      while (group != null &&
          j < exList.length &&
          exList[j].pivot!.supersetGroup == group) {
        j++;
      }

      if (group == null || j == i + 1) {
        // Regular exercise — all sets linearly with rest after each.
        for (int s = 0; s < exList[i].pivot!.totalSets; s++) {
          steps.add(_Step(i, s, false));
        }
        i++;
      } else {
        // Superset block: exList[i..j-1]

        // 1. Warmup sets for each exercise individually (with rest).
        for (int k = i; k < j; k++) {
          for (int s = 0; s < exList[k].pivot!.warmupSets; s++) {
            steps.add(_Step(k, s, false));
          }
        }

        // 2. Working sets in rounds.
        final maxRounds = exList
            .sublist(i, j)
            .map((e) => e.pivot!.sets)
            .reduce((a, b) => a > b ? a : b);

        for (int round = 0; round < maxRounds; round++) {
          // Collect exercises that still have a working set in this round.
          final inRound = <int>[];
          for (int k = i; k < j; k++) {
            final setIdx = exList[k].pivot!.warmupSets + round;
            if (setIdx < exList[k].pivot!.totalSets) {
              inRound.add(k);
            }
          }
          for (int m = 0; m < inRound.length; m++) {
            final k = inRound[m];
            final setIdx = exList[k].pivot!.warmupSets + round;
            final isLastInRound = (m == inRound.length - 1);
            // skipRestAfter = true means transition immediately to next exercise
            steps.add(_Step(k, setIdx, !isLastInRound));
          }
        }

        i = j;
      }
    }
    return steps;
  }

  // ── Computed properties ────────────────────────────────────────────────────
  List<Exercise> get exercises => exerciseOrder;
  Exercise? get currentEx =>
      exercises.isEmpty ? null : exercises[currentExIdx.value];

  bool get isCurrentSetWarmup {
    if (currentEx == null) return false;
    return currentSetIdx.value < currentEx!.pivot!.warmupSets;
  }

  bool get isLastSet {
    if (currentEx == null) return false;
    return currentSetIdx.value >= currentEx!.pivot!.totalSets - 1;
  }

  bool get isLastEx => currentExIdx.value >= exercises.length - 1;
  bool get isLastOfAll => _stepIdx >= _steps.length - 1;
  bool get canGoBack => _stepIdx > 0 || phase.value == TrainingPhase.resting;

  /// True when the current exercise is part of a superset group.
  bool get isInSuperset => currentEx?.pivot?.supersetGroup != null;

  /// True when completing the current set will immediately jump to the next
  /// exercise without a rest (superset transition).
  bool get isNextStepSupersetTransition =>
      !isLastOfAll && _steps[_stepIdx].skipRestAfter;

  /// The next exercise to be done after the current rest, or null if none / same exercise.
  Exercise? get nextExercise {
    if (isLastOfAll || _stepIdx + 1 >= _steps.length) return null;
    final nextExIdx = _steps[_stepIdx + 1].exIdx;
    if (nextExIdx == currentExIdx.value) return null;
    return exercises[nextExIdx];
  }

  /// Whether to show the "next exercise" hint during rest.
  bool get showNextExerciseHint => nextExercise != null;

  int get exDoneCount =>
      sets.where((s) => s.every((x) => x['done'] == true)).length;
  double get progressPct =>
      exercises.isEmpty ? 0 : exDoneCount / exercises.length;

  double get totalVolume {
    double total = 0;
    for (int i = 0; i < exercises.length; i++) {
      final pivot = exercises[i].pivot!;
      for (int j = pivot.warmupSets; j < sets[i].length; j++) {
        final w = double.tryParse(
                controllers[i][j].text.replaceAll(',', '.')) ??
            0;
        total += w * pivot.reps;
      }
    }
    return total;
  }

  String get nextActionLabel {
    if (isLastOfAll) return 'TERMINAR';
    if (_steps[_stepIdx].skipRestAfter) return 'SUPERSERIE →';
    if (isLastSet) return isLastEx ? 'TERMINAR' : 'SIGUIENTE EJERCICIO';
    final nextIdx = currentSetIdx.value + 1;
    final isNextWarmup =
        currentEx != null && nextIdx < currentEx!.pivot!.warmupSets;
    return isNextWarmup ? 'SIGUIENTE APROX.' : 'SIGUIENTE SERIE';
  }

  String get completedSetLabel {
    if (isWarmupRest.value) {
      return 'Aprox. ${completedSetNum.value} completada';
    }
    final warmupCount = currentEx?.pivot?.warmupSets ?? 0;
    final workingNum = completedSetNum.value - warmupCount;
    return 'Serie $workingNum completada';
  }

  double? exMaxWeight(int idx) {
    if (idx >= controllers.length) return null;
    final warmupCount = exercises[idx].pivot!.warmupSets;
    final weights = controllers[idx]
        .skip(warmupCount)
        .map((c) => double.tryParse(c.text.replaceAll(',', '.')) ?? 0.0)
        .where((w) => w > 0)
        .toList();
    if (weights.isEmpty) return null;
    return weights.reduce((a, b) => a > b ? a : b);
  }

  String formatTime(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  /// Only working sets are submitted; warmup sets are excluded from the log.
  List<Map<String, dynamic>> collectSetData() {
    final result = <Map<String, dynamic>>[];
    for (int i = 0; i < exercises.length; i++) {
      final ex = exercises[i];
      final warmupCount = ex.pivot!.warmupSets;
      int workingSetNum = 1;
      for (int j = warmupCount; j < sets[i].length; j++) {
        result.add({
          'exercise_id': ex.id,
          'set_number': workingSetNum++,
          'reps_done': ex.pivot!.reps,
          'weight_kg':
              double.tryParse(controllers[i][j].text.replaceAll(',', '.')) ??
                  0.0,
        });
      }
    }
    return result;
  }

  // ── Session actions ────────────────────────────────────────────────────────
  void completeSet() {
    HapticFeedback.mediumImpact();

    final wasWarmup = isCurrentSetWarmup;
    sets[currentExIdx.value][currentSetIdx.value]['done'] = true;
    sets.refresh();
    completedSetNum.value = currentSetIdx.value + 1;

    if (isLastOfAll) {
      phase.value = TrainingPhase.finished;
      LiveActivityService.end();
      clearProgress();
    } else if (_steps[_stepIdx].skipRestAfter) {
      // Superset transition: advance immediately, no rest.
      _advanceSet();
      phase.value = TrainingPhase.ready;
      _updateLiveActivity(isResting: false);
      _saveProgress();
    } else {
      phase.value = TrainingPhase.resting;
      isWarmupRest.value = wasWarmup;
      final restSecs = wasWarmup ? 60 : (currentEx?.pivot?.restSeconds ?? restTime.value);
      currentRestDuration.value = restSecs;
      restRemaining.value = restSecs;
      _restEndTime = DateTime.now().add(Duration(seconds: restSecs));
      _startRestTimer();
      _updateLiveActivity(isResting: true);
      _saveProgress();
    }
  }

  void skipSet() {
    if (isLastOfAll) {
      phase.value = TrainingPhase.finished;
    } else {
      _advanceSet();
    }
  }

  void skipRest() {
    _restTimer?.cancel();
    _restTimer = null;
    isWarmupRest.value = false;
    isRestWarning.value = false;
    phase.value = TrainingPhase.ready;
    _advanceSet();
    _updateLiveActivity(isResting: false);
  }

  void adjustRest(int delta) {
    final currentRemaining = _restEndTime != null
        ? _restEndTime!.difference(DateTime.now()).inSeconds.clamp(0, 9999)
        : restRemaining.value;

    final newRemaining = (currentRemaining + delta).clamp(5, 300);
    if (!isWarmupRest.value) {
      restTime.value = (restTime.value + delta).clamp(5, 300);
    }
    currentRestDuration.value =
        (currentRestDuration.value + delta).clamp(5, 300);
    _restEndTime = DateTime.now().add(Duration(seconds: newRemaining));
    restRemaining.value = newRemaining;
    if (newRemaining > 10) isRestWarning.value = false;
    _updateLiveActivity(isResting: true);
  }

  void goBack() {
    if (!canGoBack) return;
    if (phase.value == TrainingPhase.resting) {
      _restTimer?.cancel();
      _restTimer = null;
      isWarmupRest.value = false;
      phase.value = TrainingPhase.ready;
      return;
    }

    if (_stepIdx > 0) {
      _stepIdx--;
      currentExIdx.value = _steps[_stepIdx].exIdx;
      currentSetIdx.value = _steps[_stepIdx].setIdx;
      sets[currentExIdx.value][currentSetIdx.value]['done'] = false;
      sets.refresh();
    }
  }

  void reorderExercises(int from, int to) {
    final exItem = exerciseOrder.removeAt(from);
    exerciseOrder.insert(to, exItem);

    final setsItem = sets.removeAt(from);
    sets.insert(to, setsItem);

    final ctrlItem = controllers.removeAt(from);
    controllers.insert(to, ctrlItem);

    exerciseOrder.refresh();
    sets.refresh();

    // Rebuild step list for new order and find first incomplete step.
    _steps = _buildSteps(exerciseOrder);
    _stepIdx = 0;
    for (int i = 0; i < _steps.length; i++) {
      if (sets[_steps[i].exIdx][_steps[i].setIdx]['done'] != true) {
        _stepIdx = i;
        break;
      }
    }
    currentExIdx.value = _steps[_stepIdx].exIdx;
    currentSetIdx.value = _steps[_stepIdx].setIdx;
  }

  // ── Internal ───────────────────────────────────────────────────────────────
  void _advanceSet() {
    if (_stepIdx < _steps.length - 1) {
      _stepIdx++;
      currentExIdx.value = _steps[_stepIdx].exIdx;
      currentSetIdx.value = _steps[_stepIdx].setIdx;
    }
    _autoFillCurrentWeight();
  }

  void _startRestTimer() {
    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_restEndTime != null) {
        final prev = restRemaining.value;
        restRemaining.value =
            _restEndTime!.difference(DateTime.now()).inSeconds.clamp(0, 9999);
        // Trigger haptic warning once when crossing the 10 s threshold
        if (!isRestWarning.value && prev > 10 && restRemaining.value <= 10) {
          isRestWarning.value = true;
          HapticFeedback.mediumImpact();
        }
      }
      if (restRemaining.value <= 0) {
        _restTimer?.cancel();
        _playRestDone();
        skipRest();
      }
    });
  }

  void _autoFillCurrentWeight() {
    if (currentExIdx.value >= controllers.length) return;
    if (currentSetIdx.value >= controllers[currentExIdx.value].length) return;

    final ctrl = controllers[currentExIdx.value][currentSetIdx.value];
    if (ctrl.text.isNotEmpty) return;

    if (currentSetIdx.value > 0) {
      final prev = controllers[currentExIdx.value][currentSetIdx.value - 1];
      if (prev.text.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 50), () {
          ctrl.text = prev.text;
        });
      }
    }
  }

  Future<void> _playRestDone() async {
    try {
      await _player.play(AssetSource('sounds/rest_done.wav'));
    } catch (_) {}
  }

  // ── Live Activity ──────────────────────────────────────────────────────────
  void _startLiveActivity() {
    if (exercises.isEmpty) return;
    final ex = exercises[0];
    LiveActivityService.start(
      routineName: routine.name,
      exerciseName: ex.name,
      currentSet: 1,
      totalSets: ex.pivot!.totalSets,
      sessionStart: _sessionStart!,
    );
  }

  void _updateLiveActivity({bool? isResting}) {
    if (exercises.isEmpty || currentEx == null) return;
    final ex = currentEx!;
    final resting = isResting ?? (phase.value == TrainingPhase.resting);
    LiveActivityService.update(
      exerciseName: ex.name,
      isResting: resting,
      restEndTime: resting ? _restEndTime : null,
      sessionStart: _sessionStart!,
      currentSet: currentSetIdx.value + 1,
      totalSets: ex.pivot!.totalSets,
    );
  }
}
