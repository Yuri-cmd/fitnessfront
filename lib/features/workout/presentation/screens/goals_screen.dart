import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/goals_controller.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GoalsController>().loadGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GoalsController>();

    return Scaffold(
      appBar: AppBar(title: const Text('MIS METAS')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGoalDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : controller.goals.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: controller.goals.length,
                  itemBuilder: (context, index) {
                    final goal = controller.goals[index];
                    return _buildGoalCard(goal);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_outlined, size: 80, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text('Aún no tienes metas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const Text('Define objetivos para mantenerte motivado'),
        ],
      ),
    );
  }

  Widget _buildGoalCard(dynamic goal) {
    final type = goal['type'] == 'weight' ? 'Peso Objetivo' : 'Entrenamientos Semanales';
    final target = goal['target_value'];
    final current = goal['current_value'] ?? 0;
    
    double progress = 0;
    if (goal['type'] == 'workouts_weekly') {
      progress = (current / target).clamp(0.0, 1.0);
    } else {
      // Para peso, el progreso es más complejo (si es bajar o subir). 
      // Mostraremos la diferencia para simplificar.
      progress = 0.5; // Placeholder
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(type.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.alert, size: 20),
                  onPressed: () => context.read<GoalsController>().deleteGoal(goal['id']),
                )
              ],
            ),
            const SizedBox(height: 8),
            Text(
              goal['type'] == 'weight' ? '$target kg' : '$target Sesiones',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              color: AppColors.primary,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Actual: $current', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                Text('${(progress * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showAddGoalDialog() {
    String selectedType = 'weight';
    final valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('NUEVA META'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedType,
                items: const [
                  DropdownMenuItem(value: 'weight', child: Text('Peso Objetivo (kg)')),
                  DropdownMenuItem(value: 'workouts_weekly', child: Text('Sesiones Semanales')),
                ],
                onChanged: (val) => setDialogState(() => selectedType = val!),
                decoration: const InputDecoration(labelText: 'Tipo de Meta'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: valueController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Valor Objetivo', hintText: 'Ej. 75 o 4'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
            ElevatedButton(
              onPressed: () async {
                final value = double.tryParse(valueController.text);
                if (value != null) {
                  await context.read<GoalsController>().createGoal(selectedType, value);
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('GUARDAR'),
            )
          ],
        ),
      ),
    );
  }
}
