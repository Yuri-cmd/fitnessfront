import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:fit_tracker_app/core/services/live_activity_service.dart';
import 'package:fit_tracker_app/features/workout/data/models/exercise_model.dart';
import 'package:fit_tracker_app/features/workout/data/models/routine_model.dart';

enum TrainingPhase { ready, resting, finished }

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

  final currentExIdx = 0.obs;
  final currentSetIdx = 0.obs;
  final completedSetNum = 0.obs;

  final exerciseOrder = <Exercise>[].obs;

  // sets[exIdx][setIdx] = {'done': bool, 'weight': '', 'type': 'warmup'|'working'}
  final sets = <List<Map<String, dynamic>>>[].obs;

  late List<List<TextEditingController>> controllers;

  // ── Init / dispose ─────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _buildSets();
    _sessionStart = DateTime.now();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsed.value = DateTime.now().difference(_sessionStart!).inSeconds;
    });

    WidgetsBinding.instance.addObserver(this);
    _autoFillCurrentWeight();

    if (Platform.isIOS) {
      AudioPlayer.global.setAudioContext(AudioContext(
        iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
      ));
    }
    _startLiveActivity();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
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
  bool get isLastOfAll => isLastEx && isLastSet;
  bool get canGoBack => currentExIdx.value > 0 || currentSetIdx.value > 0;

  int get exDoneCount =>
      sets.where((s) => s.every((x) => x['done'] == true)).length;
  double get progressPct =>
      exercises.isEmpty ? 0 : exDoneCount / exercises.length;

  String get nextActionLabel {
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
    } else {
      phase.value = TrainingPhase.resting;
      isWarmupRest.value = wasWarmup;
      final restSecs = wasWarmup ? 60 : restTime.value;
      currentRestDuration.value = restSecs;
      restRemaining.value = restSecs;
      _restEndTime = DateTime.now().add(Duration(seconds: restSecs));
      _startRestTimer();
      _updateLiveActivity(isResting: true);
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
    phase.value = TrainingPhase.ready;
    _advanceSet();
    _updateLiveActivity(isResting: false);
  }

  void adjustRest(int delta) {
    final currentRemaining = _restEndTime != null
        ? _restEndTime!.difference(DateTime.now()).inSeconds.clamp(0, 9999)
        : restRemaining.value;

    final newRemaining = (currentRemaining + delta).clamp(5, 300);
    // Don't persist adjustment to working rest while in a warmup rest
    if (!isWarmupRest.value) {
      restTime.value = (restTime.value + delta).clamp(5, 300);
    }
    currentRestDuration.value =
        (currentRestDuration.value + delta).clamp(5, 300);
    _restEndTime = DateTime.now().add(Duration(seconds: newRemaining));
    restRemaining.value = newRemaining;
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

    if (currentSetIdx.value > 0) {
      sets[currentExIdx.value][currentSetIdx.value - 1]['done'] = false;
      currentSetIdx.value--;
    } else {
      currentExIdx.value--;
      currentSetIdx.value = currentEx!.pivot!.totalSets - 1;
      sets[currentExIdx.value][currentSetIdx.value]['done'] = false;
    }
    sets.refresh();
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
  }

  // ── Internal ───────────────────────────────────────────────────────────────
  void _advanceSet() {
    if (!isLastSet) {
      currentSetIdx.value++;
    } else {
      currentExIdx.value++;
      currentSetIdx.value = 0;
    }
    _autoFillCurrentWeight();
  }

  void _startRestTimer() {
    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_restEndTime != null) {
        restRemaining.value =
            _restEndTime!.difference(DateTime.now()).inSeconds.clamp(0, 9999);
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
