import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class TrainingSessionScreen extends StatefulWidget {
  final dynamic routine;
  const TrainingSessionScreen({super.key, required this.routine});

  @override
  State<TrainingSessionScreen> createState() => _TrainingSessionScreenState();
}

class _TrainingSessionScreenState extends State<TrainingSessionScreen> {
  int _seconds = 0;
  Timer? _timer;
  bool _isPaused = false;
  int _currentExerciseIndex = 0;

  final Map<int, TextEditingController> _weightControllers = {};
  final Map<int, double> _weights = {};

  @override
  void initState() {
    super.initState();
    _startTimer();
    final exercises = widget.routine['exercises'] as List<dynamic>? ?? [];
    for (int i = 0; i < exercises.length; i++) {
      _weightControllers[i] = TextEditingController();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPaused) setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _weightControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _saveCurrentWeight() {
    final text = _weightControllers[_currentExerciseIndex]?.text ?? '';
    final parsed = double.tryParse(text.replaceAll(',', '.'));
    if (parsed != null && parsed > 0) {
      _weights[_currentExerciseIndex] = parsed;
    }
  }

  List<Map<String, dynamic>> _collectSetData() {
    final exercises = widget.routine['exercises'] as List<dynamic>? ?? [];
    final sets = <Map<String, dynamic>>[];
    for (int i = 0; i < exercises.length; i++) {
      final ex = exercises[i];
      final numSets = (ex['pivot']['sets'] as num).toInt();
      final reps = (ex['pivot']['reps'] as num).toInt();
      final weight = _weights[i] ?? 0.0;
      final exerciseId = ex['id'];
      for (int s = 1; s <= numSets; s++) {
        sets.add({
          'exercise_id': exerciseId,
          'set_number': s,
          'reps_done': reps,
          'weight_kg': weight,
        });
      }
    }
    return sets;
  }

  @override
  Widget build(BuildContext context) {
    final exercises = widget.routine['exercises'] as List<dynamic>? ?? [];
    final currentEx = exercises.isNotEmpty ? exercises[_currentExerciseIndex] : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routine['name'].toString().toUpperCase()),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                _formatTime(_seconds),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: exercises.isNotEmpty
                ? (_currentExerciseIndex + 1) / exercises.length
                : 0,
            backgroundColor: Colors.black12,
            color: AppColors.primary,
          ),
          Expanded(
            child: currentEx == null
                ? const Center(child: Text('No hay ejercicios'))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EJERCICIO ${_currentExerciseIndex + 1} DE ${exercises.length}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentEx['name'],
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildInfoChip(
                              Icons.repeat,
                              '${currentEx['pivot']['sets']} Series',
                            ),
                            const SizedBox(width: 12),
                            _buildInfoChip(
                              Icons.fitness_center,
                              '${currentEx['pivot']['reps']} Reps',
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        _buildWeightInput(),
                        const SizedBox(height: 28),
                        if (currentEx['instructions'] != null) ...[
                          const Text(
                            'INSTRUCCIONES',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          _buildInstructions(currentEx['instructions']),
                        ],
                        if (currentEx['description'] != null) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'DESCRIPCIÓN',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currentEx['description'],
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
          _buildBottomControls(exercises.length),
        ],
      ),
    );
  }

  Widget _buildWeightInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PESO UTILIZADO',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _weightControllers[_currentExerciseIndex],
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    hintText: '0.0',
                    suffixText: 'kg',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _saveCurrentWeight(),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  _buildQuickWeightBtn('+2.5'),
                  const SizedBox(height: 4),
                  _buildQuickWeightBtn('+5'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickWeightBtn(String label) {
    return SizedBox(
      height: 32,
      child: OutlinedButton(
        onPressed: () {
          final add = double.parse(label.replaceAll('+', ''));
          final current = double.tryParse(
                _weightControllers[_currentExerciseIndex]
                        ?.text
                        .replaceAll(',', '.') ??
                    '0',
              ) ??
              0;
          final newVal = current + add;
          _weightControllers[_currentExerciseIndex]?.text =
              newVal.toStringAsFixed(1);
          _weights[_currentExerciseIndex] = newVal;
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          side: const BorderSide(color: AppColors.primary),
        ),
        child: Text(
          label,
          style: const TextStyle(color: AppColors.primary, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions(dynamic instructions) {
    List<dynamic> steps = [];
    if (instructions is String) {
      steps = [instructions];
    } else if (instructions is List) {
      steps = instructions;
    }
    return Column(
      children: steps
          .map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Expanded(child: Text(step.toString())),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildBottomControls(int total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => setState(() => _isPaused = !_isPaused),
            icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
            iconSize: 32,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _nextExercise,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
              ),
              child: Text(
                _currentExerciseIndex < total - 1
                    ? 'SIGUIENTE EJERCICIO'
                    : 'FINALIZAR ENTRENAMIENTO',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextExercise() {
    _saveCurrentWeight();
    final exercises = widget.routine['exercises'] as List<dynamic>? ?? [];
    if (_currentExerciseIndex < exercises.length - 1) {
      setState(() => _currentExerciseIndex++);
    } else {
      Navigator.pop(context, _collectSetData());
    }
  }
}
