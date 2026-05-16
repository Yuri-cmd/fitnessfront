import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../workout/presentation/controllers/workout_controller.dart';

class WikiScreen extends StatefulWidget {
  const WikiScreen({super.key});

  @override
  State<WikiScreen> createState() => _WikiScreenState();
}

class _WikiScreenState extends State<WikiScreen> {
  String _search = '';
  String? _selectedMuscle;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutController>().loadExercises();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workout = context.watch<WorkoutController>();
    final exercises = workout.availableExercises;

    final muscleGroups = exercises
        .map((e) => e['muscle_group']?.toString())
        .whereType<String>()
        .where((m) => m.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final filtered = exercises.where((e) {
      final name = e['name']?.toString().toLowerCase() ?? '';
      final muscle = e['muscle_group']?.toString() ?? '';
      final matchSearch = _search.isEmpty || name.contains(_search.toLowerCase());
      final matchMuscle = _selectedMuscle == null || muscle == _selectedMuscle;
      return matchSearch && matchMuscle;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('WIKI DE EJERCICIOS')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Buscar ejercicio...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _search = '');
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildFilterChip('Todos', null),
                ...muscleGroups.map((m) => _buildFilterChip(m, m)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: workout.isLoadingExercises
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 64, color: Colors.grey.withValues(alpha: 0.3)),
                            const SizedBox(height: 12),
                            Text(
                              exercises.isEmpty
                                  ? 'No hay ejercicios registrados'
                                  : 'Sin resultados para "$_search"',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) =>
                            _buildExerciseCard(filtered[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value) {
    final isSelected = _selectedMuscle == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedMuscle = value),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.black12,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textBody,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseCard(dynamic exercise) {
    final muscle = exercise['muscle_group']?.toString();
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.fitness_center, color: AppColors.primary, size: 20),
        ),
        title: Text(
          exercise['name'] ?? 'Ejercicio',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: muscle != null && muscle.isNotEmpty
            ? Text(
                muscle.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}
