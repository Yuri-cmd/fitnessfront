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

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() => _seconds++);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$mins:$secs";
  }

  @override
  Widget build(BuildContext context) {
    final exercises = widget.routine['exercises'] as List<dynamic>? ?? [];
    final currentEx = exercises.isNotEmpty ? exercises[_currentExerciseIndex] : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routine['name'].toUpperCase()),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                _formatTime(_seconds),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: exercises.isNotEmpty ? (_currentExerciseIndex + 1) / exercises.length : 0,
            backgroundColor: Colors.black12,
            color: AppColors.primary,
          ),
          Expanded(
            child: currentEx == null
                ? const Center(child: Text("No hay ejercicios"))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EJERCICIO ${_currentExerciseIndex + 1} DE ${exercises.length}',
                          style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentEx['name'],
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildInfoChip(Icons.repeat, '${currentEx['pivot']['sets']} Series'),
                            const SizedBox(width: 12),
                            _buildInfoChip(Icons.fitness_center, '${currentEx['pivot']['reps']} Reps'),
                          ],
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'INSTRUCCIONES',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        _buildInstructions(currentEx['instructions']),
                        const SizedBox(height: 32),
                        if (currentEx['description'] != null) ...[
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
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _buildInstructions(dynamic instructions) {
    List<dynamic> steps = [];
    if (instructions is String) {
      // Intentar parsear si es un string de JSON
      steps = [instructions]; 
    } else if (instructions is List) {
      steps = instructions;
    }

    return Column(
      children: steps.map((step) => Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
            Expanded(child: Text(step.toString())),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildBottomControls(int total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))],
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
                _currentExerciseIndex < total - 1 ? 'SIGUIENTE EJERCICIO' : 'FINALIZAR ENTRENAMIENTO',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextExercise() {
    final exercises = widget.routine['exercises'] as List<dynamic>? ?? [];
    if (_currentExerciseIndex < exercises.length - 1) {
      setState(() => _currentExerciseIndex++);
    } else {
      _finishWorkout();
    }
  }

  void _finishWorkout() {
    Navigator.pop(context, true); // Retornar true para indicar que se completó
  }
}
