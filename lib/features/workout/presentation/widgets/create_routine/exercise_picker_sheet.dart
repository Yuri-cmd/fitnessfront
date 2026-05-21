import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';
import 'package:fit_tracker_app/features/workout/data/models/exercise_model.dart';
import 'package:fit_tracker_app/features/workout/presentation/controllers/workout_controller.dart';

class ExercisePickerSheet extends StatefulWidget {
  final void Function(Map<String, dynamic>) onAdded;

  const ExercisePickerSheet({super.key, required this.onAdded});

  @override
  State<ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<ExercisePickerSheet> {
  final _c = Get.find<WorkoutController>();
  final _setsCtrl = TextEditingController(text: '3');
  final _repsCtrl = TextEditingController(text: '12');
  Exercise? _selectedEx;
  String _search = '';

  static const _muscleGroups = [
    'Pecho', 'Espalda', 'Piernas', 'Hombros',
    'Brazos', 'Core', 'Cardio', 'Full Body',
  ];

  @override
  void dispose() {
    _setsCtrl.dispose();
    _repsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('AÑADIR EJERCICIO',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  if (_c.isLoadingExercises.value)
                    const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              )),
          const SizedBox(height: 16),
          TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Buscar ejercicio...',
              suffixIcon: _search.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _search = ''),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => _showExerciseFormDialog(
              onSaved: (ex) => setState(() => _selectedEx = ex),
            ),
            icon: const Icon(Icons.add),
            label: const Text('¿NO ESTÁ EN LA LISTA? CRÉALO AQUÍ'),
          ),
          const Divider(),
          Expanded(child: Obx(() => _buildExerciseList())),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _setsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Series'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _repsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Repeticiones'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _addToRoutine,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 55),
            ),
            child: const Text('AÑADIR A LA RUTINA'),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList() {
    if (_c.isLoadingExercises.value) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_c.availableExercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No hay ejercicios disponibles'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _c.loadExercises,
              child: const Text('CARGAR EJERCICIOS'),
            ),
          ],
        ),
      );
    }
    final sorted = List<Exercise>.from(_c.availableExercises)
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final filtered = sorted
        .where((e) => e.name.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('No hay resultados para tu búsqueda'));
    }
    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (_, i) {
        final ex = filtered[i];
        final isSelected = _selectedEx?.id == ex.id;
        return ListTile(
          title: Text(
            ex.name,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.primary : Colors.black87,
            ),
          ),
          subtitle: Text(ex.muscleGroup ?? 'General'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_note, size: 20, color: Colors.grey),
                onPressed: () => _showExerciseFormDialog(
                  existingEx: ex,
                  onSaved: (updated) {
                    if (isSelected) setState(() => _selectedEx = updated);
                  },
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: AppColors.primary),
            ],
          ),
          onTap: () => setState(() => _selectedEx = ex),
        );
      },
    );
  }

  void _addToRoutine() {
    if (_selectedEx == null) return;
    widget.onAdded({
      'exercise_id': _selectedEx!.id,
      'name': _selectedEx!.name,
      'sets': int.tryParse(_setsCtrl.text) ?? 3,
      'reps': int.tryParse(_repsCtrl.text) ?? 12,
    });
    Get.back();
  }

  void _showExerciseFormDialog({
    Exercise? existingEx,
    required void Function(Exercise?) onSaved,
  }) {
    final nameCtrl = TextEditingController(text: existingEx?.name);
    String? selectedGroup = _muscleGroups.contains(existingEx?.muscleGroup)
        ? existingEx!.muscleGroup
        : _muscleGroups[0];

    Get.dialog(
      StatefulBuilder(
        builder: (_, setDialog) => AlertDialog(
          title: Text(existingEx == null ? 'NUEVO EJERCICIO' : 'EDITAR CATÁLOGO'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre del Ejercicio'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedGroup,
                decoration: const InputDecoration(labelText: 'Grupo Muscular'),
                items: _muscleGroups
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setDialog(() => selectedGroup = v),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: Get.back, child: const Text('CANCELAR')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty) return;
                final Exercise? res = existingEx == null
                    ? await _c.createExercise(
                        nameCtrl.text, selectedGroup ?? 'General')
                    : await _c.updateExercise(
                        existingEx.id, nameCtrl.text, selectedGroup ?? 'General');
                if (res != null) onSaved(res);
                Get.back();
              },
              child: Text(existingEx == null ? 'CREAR Y SELECCIONAR' : 'ACTUALIZAR'),
            ),
          ],
        ),
      ),
    );
  }
}
