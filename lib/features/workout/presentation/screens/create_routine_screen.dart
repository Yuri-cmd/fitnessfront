import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/workout_controller.dart';

class CreateRoutineScreen extends StatefulWidget {
  final dynamic routine;

  const CreateRoutineScreen({super.key, this.routine});

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  final _nameController = TextEditingController();
  final List<Map<String, dynamic>> _selectedExercises = [];
  String _searchQuery = "";

  static const List<String> muscleGroups = [
    'Pecho', 'Espalda', 'Piernas', 'Hombros', 'Brazos', 'Core', 'Cardio', 'Full Body'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.routine != null) {
      _nameController.text = widget.routine['name'] ?? "";
      final exercises = widget.routine['exercises'] as List? ?? [];
      for (var ex in exercises) {
        _selectedExercises.add({
          'exercise_id': ex['id'],
          'name': ex['name'],
          'sets': ex['pivot']?['sets'] ?? 3,
          'reps': ex['pivot']?['reps'] ?? 12,
        });
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutController>().loadExercises();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routine == null ? 'NUEVA RUTINA' : 'EDITAR RUTINA'),
        actions: [
          if (widget.routine != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.alert),
              onPressed: _confirmDelete,
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la Rutina',
                hintText: 'Ej. Piernas y Glúteos',
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('EJERCICIOS', style: TextStyle(fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () => _showAddExerciseBottomSheet(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Añadir'),
                )
              ],
            ),
            Expanded(
              child: _selectedExercises.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.fitness_center, size: 48, color: Colors.grey.withValues(alpha: 0.3)),
                          const SizedBox(height: 16),
                          const Text('Aún no has añadido ejercicios', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _selectedExercises.length,
                      itemBuilder: (context, index) {
                        final ex = _selectedExercises[index];
                        return Card(
                          child: ListTile(
                            onTap: () => _showEditListExerciseDialog(index),
                            title: Text(ex['name'] ?? 'S/N', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${ex['sets']} series x ${ex['reps']} reps'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                                  onPressed: () => _showEditListExerciseDialog(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.alert),
                                  onPressed: () => setState(() => _selectedExercises.removeAt(index)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveRoutine,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 55)),
              child: Text(widget.routine == null ? 'GUARDAR RUTINA' : 'ACTUALIZAR RUTINA'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditListExerciseDialog(int index) {
    final ex = _selectedExercises[index];
    final setsController = TextEditingController(text: ex['sets'].toString());
    final repsController = TextEditingController(text: ex['reps'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('EDITAR: ${ex['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: setsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Series')),
            const SizedBox(height: 16),
            TextField(controller: repsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Repeticiones')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedExercises[index]['sets'] = int.tryParse(setsController.text) ?? ex['sets'];
                _selectedExercises[index]['reps'] = int.tryParse(repsController.text) ?? ex['reps'];
              });
              Navigator.pop(context);
            },
            child: const Text('ACTUALIZAR'),
          )
        ],
      ),
    );
  }

  void _showAddExerciseBottomSheet(BuildContext parentContext) {
    dynamic selectedEx;
    final setsController = TextEditingController(text: '3');
    final repsController = TextEditingController(text: '12');
    _searchQuery = "";

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Consumer<WorkoutController>(
            builder: (context, workout, child) {
              final exercises = List.from(workout.availableExercises);
              exercises.sort((a, b) => (a['name'] ?? '').toString().toLowerCase().compareTo((b['name'] ?? '').toString().toLowerCase()));

              final filteredExercises = exercises.where((e) {
                final name = e['name']?.toString().toLowerCase() ?? "";
                return name.contains(_searchQuery.toLowerCase());
              }).toList();

              return Container(
                height: MediaQuery.of(context).size.height * 0.85,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                padding: EdgeInsets.only(
                  left: 24, right: 24, top: 12, bottom: MediaQuery.of(context).viewInsets.bottom + 24
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('AÑADIR EJERCICIO', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        if (workout.isLoadingExercises)
                          const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (val) => setSheetState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Buscar ejercicio...',
                        suffixIcon: _searchQuery.isNotEmpty 
                          ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setSheetState(() => _searchQuery = "")) 
                          : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () => _showCreateExerciseDialog(context, workout, (newEx) {
                        setSheetState(() => selectedEx = newEx);
                      }),
                      icon: const Icon(Icons.add),
                      label: const Text('¿NO ESTÁ EN LA LISTA? CRÉALO AQUÍ'),
                    ),
                    const Divider(),
                    Expanded(
                      child: workout.isLoadingExercises
                          ? const Center(child: CircularProgressIndicator())
                          : (workout.availableExercises.isEmpty)
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('No hay ejercicios disponibles'),
                                      const SizedBox(height: 16),
                                      ElevatedButton(onPressed: () => workout.loadExercises(), child: const Text('CARGAR EJERCICIOS'))
                                    ],
                                  ),
                                )
                              : (filteredExercises.isEmpty)
                                  ? const Center(child: Text('No hay resultados para tu búsqueda'))
                                  : ListView.builder(
                                      itemCount: filteredExercises.length,
                                      itemBuilder: (context, index) {
                                        final ex = filteredExercises[index];
                                        final isSelected = selectedEx?['id'] == ex['id'];
                                        return ListTile(
                                          title: Text(ex['name'] ?? 'S/N', 
                                            style: TextStyle(
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                              color: isSelected ? AppColors.primary : Colors.black87
                                            )
                                          ),
                                          subtitle: Text(ex['muscle_group'] ?? 'General'),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit_note, size: 20, color: Colors.grey),
                                                onPressed: () => _showCreateExerciseDialog(context, workout, (updatedEx) {
                                                  // Si el ejercicio editado era el seleccionado, actualizamos la seleccion
                                                  if (isSelected) setSheetState(() => selectedEx = updatedEx);
                                                }, existingEx: ex),
                                              ),
                                              if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary)
                                            ],
                                          ),
                                          onTap: () => setSheetState(() => selectedEx = ex),
                                        );
                                      },
                                    ),
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: setsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Series'))),
                        const SizedBox(width: 16),
                        Expanded(child: TextField(controller: repsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Repeticiones'))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (selectedEx != null) {
                          setState(() {
                            // Actualizamos el nombre por si se editó en el catálogo
                            _selectedExercises.add({
                              'exercise_id': selectedEx['id'],
                              'name': selectedEx['name'],
                              'sets': int.tryParse(setsController.text) ?? 3,
                              'reps': int.tryParse(repsController.text) ?? 12,
                            });
                          });
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 55)),
                      child: const Text('AÑADIR A LA RUTINA'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showCreateExerciseDialog(BuildContext context, WorkoutController workout, Function(dynamic) onSaved, {dynamic existingEx}) {
    final nameController = TextEditingController(text: existingEx?['name']);
    String? selectedGroup = muscleGroups.contains(existingEx?['muscle_group']) ? existingEx['muscle_group'] : muscleGroups[0];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existingEx == null ? 'NUEVO EJERCICIO' : 'EDITAR CATÁLOGO'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nombre del Ejercicio')),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedGroup,
                decoration: const InputDecoration(labelText: 'Grupo Muscular'),
                items: muscleGroups.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (val) => setDialogState(() => selectedGroup = val),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  dynamic res;
                  if (existingEx == null) {
                    res = await workout.createExercise(nameController.text, selectedGroup ?? 'General');
                  } else {
                    res = await workout.updateExercise(existingEx['id'], nameController.text, selectedGroup ?? 'General');
                  }
                  
                  if (res != null) {
                    onSaved(res);
                  }
                  if (mounted) Navigator.pop(context);
                }
              },
              child: Text(existingEx == null ? 'CREAR Y SELECCIONAR' : 'ACTUALIZAR'),
            )
          ],
        ),
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar Rutina?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () async {
              await context.read<WorkoutController>().deleteRoutine(widget.routine['id']);
              if (mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.alert),
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  void _saveRoutine() async {
    if (_nameController.text.isEmpty || _selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rellena todos los campos')));
      return;
    }

    bool success;
    if (widget.routine == null) {
      success = await context.read<WorkoutController>().createRoutine(_nameController.text, _selectedExercises);
    } else {
      success = await context.read<WorkoutController>().updateRoutine(widget.routine['id'], _nameController.text, _selectedExercises);
    }

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.routine == null ? 'Rutina creada' : 'Rutina actualizada')));
    }
  }
}
