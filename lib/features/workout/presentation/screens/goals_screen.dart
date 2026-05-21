import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';
import 'package:fit_tracker_app/features/workout/presentation/controllers/goals_controller.dart';
import 'package:fit_tracker_app/features/workout/presentation/widgets/common/workout_empty_state.dart';
import 'package:fit_tracker_app/features/workout/presentation/widgets/common/goal_card.dart';

class GoalsScreen extends GetView<GoalsController> {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MIS METAS')),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_goals',
        onPressed: () => _showAddGoalDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.goals.isEmpty) {
          return const WorkoutEmptyState(
            icon: Icons.emoji_events_outlined,
            title: 'Aún no tienes metas',
            subtitle: 'Define objetivos para mantenerte motivado',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: controller.goals.length,
          itemBuilder: (_, i) => GoalCard(
            goal: controller.goals[i],
            onDelete: controller.deleteGoal,
          ),
        );
      }),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    String selectedType = 'weight';
    final valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('NUEVA META'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                items: const [
                  DropdownMenuItem(
                    value: 'weight',
                    child: Text('Peso Objetivo (kg)'),
                  ),
                  DropdownMenuItem(
                    value: 'workouts_weekly',
                    child: Text('Sesiones Semanales'),
                  ),
                ],
                onChanged: (val) =>
                    setDialogState(() => selectedType = val!),
                decoration: const InputDecoration(labelText: 'Tipo de Meta'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: valueController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Valor Objetivo',
                  hintText: 'Ej. 75 o 4',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              onPressed: () async {
                final value = double.tryParse(valueController.text);
                if (value != null) {
                  Get.back();
                  await controller.createGoal(selectedType, value);
                }
              },
              child: const Text('GUARDAR'),
            ),
          ],
        ),
      ),
    );
  }
}
