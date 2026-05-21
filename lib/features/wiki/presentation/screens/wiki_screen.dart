import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_tracker_app/features/wiki/presentation/controllers/wiki_controller.dart';
import 'package:fit_tracker_app/features/wiki/presentation/widgets/wiki_filter_strip.dart';
import 'package:fit_tracker_app/features/wiki/presentation/widgets/exercise_card.dart';
import 'package:fit_tracker_app/core/widgets/empty_state_view.dart';

class WikiScreen extends StatelessWidget {
  const WikiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(WikiController());
    return Scaffold(
      appBar: AppBar(title: const Text('WIKI DE EJERCICIOS')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: TextField(
              controller: c.searchCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar ejercicio...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Obx(() => c.search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: c.clearSearch,
                      )
                    : const SizedBox.shrink()),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => WikiFilterStrip(
                muscleGroups: c.muscleGroups,
                selected: c.selectedMuscle.value,
                onSelect: c.setMuscle,
              )),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              if (c.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              final list = c.filtered;
              if (list.isEmpty) {
                return EmptyStateView(
                  icon: Icons.search_off,
                  title: c.exercises.isEmpty
                      ? 'No hay ejercicios registrados'
                      : 'Sin resultados para "${c.search.value}"',
                  subtitle: '',
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                itemCount: list.length,
                itemBuilder: (_, i) => ExerciseCard(exercise: list[i]),
              );
            }),
          ),
        ],
      ),
    );
  }
}
