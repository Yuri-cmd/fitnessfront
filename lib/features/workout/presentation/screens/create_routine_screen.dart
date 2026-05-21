import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';
import 'package:fit_tracker_app/features/workout/data/models/routine_model.dart';
import 'package:fit_tracker_app/features/workout/presentation/controllers/workout_controller.dart';
import 'package:fit_tracker_app/features/workout/presentation/widgets/create_routine/exercise_picker_sheet.dart';

class CreateRoutineScreen extends StatefulWidget {
  final Routine? routine;
  const CreateRoutineScreen({super.key, this.routine});

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  final _nameCtrl = TextEditingController();
  final _exercises = <Map<String, dynamic>>[];

  WorkoutController get _c => Get.find<WorkoutController>();
  bool get _isEditing => widget.routine != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameCtrl.text = widget.routine!.name;
      for (final ex in widget.routine!.exercises) {
        _exercises.add({
          'exercise_id': ex.id,
          'name': ex.name,
          'sets': ex.pivot?.sets ?? 3,
          'reps': ex.pivot?.reps ?? 12,
        });
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _c.loadExercises());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'EDITAR RUTINA' : 'NUEVA RUTINA'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.alert),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre de la Rutina',
                hintText: 'Ej. Piernas y Glúteos',
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('EJERCICIOS',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: _openExercisePicker,
                  icon: const Icon(Icons.add),
                  label: const Text('Añadir'),
                ),
              ],
            ),
            Expanded(
              child: _exercises.isEmpty
                  ? const _EmptyExercises()
                  : ListView.builder(
                      itemCount: _exercises.length,
                      itemBuilder: (_, i) => _ExerciseTile(
                        exercise: _exercises[i],
                        onEdit: () => _editExercise(i),
                        onDelete: () =>
                            setState(() => _exercises.removeAt(i)),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55)),
              child: Text(_isEditing ? 'ACTUALIZAR RUTINA' : 'GUARDAR RUTINA'),
            ),
          ],
        ),
      ),
    );
  }

  void _openExercisePicker() {
    Get.bottomSheet(
      ExercisePickerSheet(
        onAdded: (ex) => setState(() => _exercises.add(ex)),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _editExercise(int index) {
    final ex = _exercises[index];
    final setsCtrl = TextEditingController(text: ex['sets'].toString());
    final repsCtrl = TextEditingController(text: ex['reps'].toString());
    Get.dialog(AlertDialog(
      title: Text('EDITAR: ${ex['name']}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: setsCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Series'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: repsCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Repeticiones'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('CANCELAR')),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _exercises[index]['sets'] =
                  int.tryParse(setsCtrl.text) ?? ex['sets'];
              _exercises[index]['reps'] =
                  int.tryParse(repsCtrl.text) ?? ex['reps'];
            });
            Get.back();
          },
          child: const Text('ACTUALIZAR'),
        ),
      ],
    ));
  }

  void _confirmDelete() {
    Get.dialog(AlertDialog(
      title: const Text('¿Eliminar Rutina?'),
      content: const Text('Esta acción no se puede deshacer.'),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('CANCELAR')),
        ElevatedButton(
          onPressed: () async {
            await _c.deleteRoutine(widget.routine!.id);
            Get.back();
            Get.back();
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.alert),
          child: const Text('ELIMINAR',
              style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }

  void _save() async {
    if (_nameCtrl.text.isEmpty || _exercises.isEmpty) {
      Get.snackbar('Atención', 'Rellena todos los campos',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12);
      return;
    }
    final success = _isEditing
        ? await _c.updateRoutine(widget.routine!.id, _nameCtrl.text, _exercises)
        : await _c.createRoutine(_nameCtrl.text, _exercises);
    if (success) {
      Get.back();
      Get.snackbar(
          '¡Listo!', _isEditing ? 'Rutina actualizada' : 'Rutina creada',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12);
    }
  }
}

// ── Widgets privados ──────────────────────────────────────────────────────────

class _EmptyExercises extends StatelessWidget {
  const _EmptyExercises();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center,
              size: 48, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text('Aún no has añadido ejercicios',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  final Map<String, dynamic> exercise;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExerciseTile({
    required this.exercise,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onEdit,
        title: Text(exercise['name'] ?? 'S/N',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle:
            Text('${exercise['sets']} series x ${exercise['reps']} reps'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.alert),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
