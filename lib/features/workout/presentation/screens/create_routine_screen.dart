import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';
import 'package:fit_tracker_app/core/theme/app_radii.dart';
import 'package:fit_tracker_app/core/widgets/section_label.dart';
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
  bool _saving = false;

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
          'reps_max': ex.pivot?.repsMax,
          'warmup_sets': ex.pivot?.warmupSets ?? 0,
          'warmup_reps': ex.pivot?.warmupReps,
          'superset_group': ex.pivot?.supersetGroup,
          'rest_seconds': ex.pivot?.restSeconds ?? 90,
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

  // ── Superset helpers ────────────────────────────────────────────────────────

  int _nextSupersetGroup() {
    int max = 0;
    for (final ex in _exercises) {
      final g = ex['superset_group'] as int?;
      if (g != null && g > max) max = g;
    }
    return max + 1;
  }

  /// Display label for a group id — "SUPERSERIE 1", "SUPERSERIE 2", etc.
  /// based on order of first appearance in the exercise list.
  String _supersetLabel(int groupId) {
    final seen = <int>[];
    for (final ex in _exercises) {
      final g = ex['superset_group'] as int?;
      if (g != null && !seen.contains(g)) seen.add(g);
    }
    final ordinal = seen.indexOf(groupId) + 1;
    return 'SUPERSERIE $ordinal';
  }

  /// Returns all distinct superset group ids present in the exercise list.
  List<int> _existingGroups() {
    final seen = <int>[];
    for (final ex in _exercises) {
      final g = ex['superset_group'] as int?;
      if (g != null && !seen.contains(g)) seen.add(g);
    }
    return seen;
  }

  /// Opens a picker so the user can freely assign [index] to any group.
  void _showGroupPicker(int index) {
    final current = _exercises[index]['superset_group'] as int?;
    final groups = _existingGroups();

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _exercises[index]['name'] as String? ?? '',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Asignar a una superserie',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            // Remove from group
            ListTile(
              leading: const Icon(Icons.link_off_rounded, color: Colors.grey),
              title: const Text('Sin superserie'),
              trailing: current == null
                  ? const Icon(Icons.check, color: AppColors.primary, size: 18)
                  : null,
              onTap: () {
                setState(() {
                  _exercises[index]['superset_group'] = null;
                  // Clean up orphaned members in the old group.
                  if (current != null) {
                    final remaining = _exercises
                        .where((e) => e['superset_group'] == current)
                        .toList();
                    if (remaining.length == 1) {
                      remaining.first['superset_group'] = null;
                    }
                  }
                });
                Navigator.pop(ctx);
              },
            ),
            // Existing groups
            for (final g in groups)
              ListTile(
                leading: const Icon(Icons.link_rounded,
                    color: AppColors.primary),
                title: Text(_supersetLabel(g)),
                trailing: current == g
                    ? const Icon(Icons.check,
                        color: AppColors.primary, size: 18)
                    : null,
                onTap: () {
                  setState(() {
                    // Clean up old group first (orphan check).
                    if (current != null && current != g) {
                      final remaining = _exercises
                          .where((e) => e['superset_group'] == current)
                          .toList();
                      if (remaining.length == 1) {
                        remaining.first['superset_group'] = null;
                      }
                    }
                    _exercises[index]['superset_group'] = g;
                  });
                  Navigator.pop(ctx);
                },
              ),
            // Create new group
            ListTile(
              leading: const Icon(Icons.add_link_rounded,
                  color: AppColors.primary),
              title: const Text('Nueva superserie'),
              onTap: () {
                setState(() {
                  if (current != null) {
                    final remaining = _exercises
                        .where((e) => e['superset_group'] == current)
                        .toList();
                    if (remaining.length == 1) {
                      remaining.first['superset_group'] = null;
                    }
                  }
                  _exercises[index]['superset_group'] = _nextSupersetGroup();
                });
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────

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
                  : ReorderableListView.builder(
                      itemCount: _exercises.length,
                      onReorder: (oldIdx, newIdx) {
                        setState(() {
                          if (newIdx > oldIdx) newIdx--;
                          final item = _exercises.removeAt(oldIdx);
                          _exercises.insert(newIdx, item);
                        });
                      },
                      itemBuilder: (_, i) {
                        final groupId =
                            _exercises[i]['superset_group'] as int?;
                        return _ExerciseTile(
                          key: ValueKey('${_exercises[i]['exercise_id']}_$i'),
                          exercise: _exercises[i],
                          onEdit: () => _editExercise(i),
                          onDelete: () =>
                              setState(() => _exercises.removeAt(i)),
                          supersetLabel: groupId != null
                              ? _supersetLabel(groupId)
                              : null,
                          onTapSuperset: () => _showGroupPicker(i),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55)),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(_isEditing ? 'ACTUALIZAR RUTINA' : 'GUARDAR RUTINA'),
            ),
          ],
        ),
      ),
    );
  }

  void _openExercisePicker() {
    Get.bottomSheet(
      ExercisePickerSheet(
        onAdded: (ex) => setState(() => _exercises.add({
              ...ex,
              'superset_group': null,
              'rest_seconds': 90,
            })),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _editExercise(int index) {
    final ex = _exercises[index];
    final setsCtrl = TextEditingController(text: ex['sets'].toString());
    final repsCtrl = TextEditingController(text: ex['reps'].toString());
    final repsMaxCtrl =
        TextEditingController(text: ex['reps_max']?.toString() ?? '');
    final warmupSetsCtrl =
        TextEditingController(text: (ex['warmup_sets'] ?? 0).toString());
    final warmupRepsCtrl =
        TextEditingController(text: ex['warmup_reps'] ?? '');
    final restCtrl =
        TextEditingController(text: (ex['rest_seconds'] ?? 90).toString());

    Get.dialog(AlertDialog(
      title: Text('EDITAR: ${ex['name']}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel('SERIES EFECTIVAS'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: setsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Series'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: repsCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Reps mín'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: repsMaxCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Reps máx', hintText: 'opc.'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const SectionLabel('SERIES DE APROXIMACIÓN'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: warmupSetsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Series'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: warmupRepsCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Reps (rango)',
                      hintText: 'ej. 10-15',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const SectionLabel('DESCANSO ENTRE SERIES'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: restCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Segundos',
                      hintText: '90',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('seg',
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ],
        ),
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
              _exercises[index]['reps_max'] =
                  int.tryParse(repsMaxCtrl.text);
              _exercises[index]['warmup_sets'] =
                  int.tryParse(warmupSetsCtrl.text) ?? 0;
              _exercises[index]['warmup_reps'] =
                  warmupRepsCtrl.text.trim().isEmpty
                      ? null
                      : warmupRepsCtrl.text.trim();
              _exercises[index]['rest_seconds'] =
                  (int.tryParse(restCtrl.text) ?? 90).clamp(5, 600);
            });
            Get.back();
          },
          child: const Text('ACTUALIZAR'),
        ),
      ],
    )).then((_) {
      setsCtrl.dispose();
      repsCtrl.dispose();
      repsMaxCtrl.dispose();
      warmupSetsCtrl.dispose();
      warmupRepsCtrl.dispose();
      restCtrl.dispose();
    });
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
          child:
              const Text('ELIMINAR', style: TextStyle(color: Colors.white)),
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
    setState(() => _saving = true);
    final success = _isEditing
        ? await _c.updateRoutine(
            widget.routine!.id, _nameCtrl.text, _exercises)
        : await _c.createRoutine(_nameCtrl.text, _exercises);
    if (!mounted) return;
    setState(() => _saving = false);
    if (success) {
      Get.back();
      Get.snackbar(
          '¡Listo!', _isEditing ? 'Rutina actualizada' : 'Rutina creada',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12);
    } else {
      Get.snackbar(
          'Error', 'No se pudo guardar la rutina. Intenta de nuevo.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12);
    }
  }
}

// ── Private widgets ───────────────────────────────────────────────────────────

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
  final String? supersetLabel;
  final VoidCallback onTapSuperset;

  const _ExerciseTile({
    super.key,
    required this.exercise,
    required this.onEdit,
    required this.onDelete,
    required this.supersetLabel,
    required this.onTapSuperset,
  });

  @override
  Widget build(BuildContext context) {
    final warmupSets = (exercise['warmup_sets'] as num?)?.toInt() ?? 0;
    final reps = (exercise['reps'] as num).toInt();
    final repsMax = (exercise['reps_max'] as num?)?.toInt();
    final repsDisplay = repsMax != null ? '$reps-$repsMax' : '$reps';
    final warmupLabel = warmupSets > 0 ? '$warmupSets aprox. + ' : '';
    final restSecs = (exercise['rest_seconds'] as num?)?.toInt() ?? 90;
    final restLabel = restSecs < 60
        ? '${restSecs}s'
        : restSecs % 60 == 0
            ? '${restSecs ~/ 60}min'
            : '${restSecs ~/ 60}min ${restSecs % 60}s';
    final subtitle =
        '$warmupLabel${exercise['sets']} series × $repsDisplay reps  ·  $restLabel descanso';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 4, 4, 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Drag handle
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.drag_handle, color: Colors.grey),
            ),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise['name'] ?? 'S/N',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  // Superset chip
                  GestureDetector(
                    onTap: onTapSuperset,
                    child: supersetLabel != null
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppRadii.lg),
                              border: Border.all(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.25)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.link_rounded,
                                    size: 11, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  supersetLabel!,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.expand_more_rounded,
                                    size: 11, color: AppColors.primary),
                              ],
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_link_rounded,
                                  size: 11, color: Colors.grey.shade400),
                              const SizedBox(width: 4),
                              Text(
                                'Añadir a superserie',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade400),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
            // Actions
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
              onPressed: onEdit,
              iconSize: 20,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.alert),
              onPressed: onDelete,
              iconSize: 20,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
            ),
          ],
        ),
      ),
    );
  }
}
