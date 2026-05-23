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
  final _repsCtrl = TextEditingController(text: '8');
  final _repsMaxCtrl = TextEditingController(text: '12');
  final _warmupSetsCtrl = TextEditingController(text: '0');
  final _warmupRepsCtrl = TextEditingController(text: '10-15');
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
    _repsMaxCtrl.dispose();
    _warmupSetsCtrl.dispose();
    _warmupRepsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.90,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
              width: 40,
              height: 4,
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
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  if (_c.isLoadingExercises.value)
                    const SizedBox(
                      width: 20,
                      height: 20,
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
          const SizedBox(height: 12),
          // ── Series efectivas ──
          _sectionLabel('SERIES EFECTIVAS'),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _setsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Series'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _repsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Reps mín'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _repsMaxCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Reps máx', hintText: 'opc.'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // ── Series de aproximación ──
          _sectionLabel('SERIES DE APROXIMACIÓN (opcional)'),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _warmupSetsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Series'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _warmupRepsCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Reps (rango)',
                    hintText: 'ej. 10-15',
                  ),
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

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 1)),
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
              fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.primary : null,
            ),
          ),
          subtitle: Text(ex.muscleGroup ?? 'General'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_note,
                    size: 20, color: Colors.grey),
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
    final warmupSets = int.tryParse(_warmupSetsCtrl.text) ?? 0;
    final repsMax = int.tryParse(_repsMaxCtrl.text);
    widget.onAdded({
      'exercise_id': _selectedEx!.id,
      'name': _selectedEx!.name,
      'sets': int.tryParse(_setsCtrl.text) ?? 3,
      'reps': int.tryParse(_repsCtrl.text) ?? 8,
      'reps_max': repsMax,
      'warmup_sets': warmupSets,
      'warmup_reps': warmupSets > 0 && _warmupRepsCtrl.text.trim().isNotEmpty
          ? _warmupRepsCtrl.text.trim()
          : null,
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
          title: Text(existingEx == null
              ? 'NUEVO EJERCICIO'
              : 'EDITAR CATÁLOGO'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Nombre del Ejercicio'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedGroup,
                decoration:
                    const InputDecoration(labelText: 'Grupo Muscular'),
                items: _muscleGroups
                    .map((g) =>
                        DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setDialog(() => selectedGroup = v),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: Get.back, child: const Text('CANCELAR')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty) return;
                final Exercise? res = existingEx == null
                    ? await _c.createExercise(
                        nameCtrl.text, selectedGroup ?? 'General')
                    : await _c.updateExercise(existingEx.id,
                        nameCtrl.text, selectedGroup ?? 'General');
                if (res != null) onSaved(res);
                Get.back();
              },
              child: Text(existingEx == null
                  ? 'CREAR Y SELECCIONAR'
                  : 'ACTUALIZAR'),
            ),
          ],
        ),
      ),
    );
  }
}
