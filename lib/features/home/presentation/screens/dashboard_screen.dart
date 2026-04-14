import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/metrics/presentation/controllers/fitness_controller.dart';
import '../../../../features/auth/presentation/controllers/auth_controller.dart';
import '../../../../features/workout/presentation/screens/routines_screen.dart';
import '../../../../features/metrics/presentation/screens/weight_metrics_screen.dart';
import '../../../../features/workout/presentation/controllers/workout_controller.dart';
import '../../../../features/workout/presentation/screens/goals_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FitnessController>().loadProfile();
      context.read<FitnessController>().loadWeightLogs();
      context.read<WorkoutController>().loadWeeklyProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    final fitness = context.watch<FitnessController>();
    final workout = context.watch<WorkoutController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('POWER STACK'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppColors.primary),
            onPressed: () => _showUpdateProfileDialog(context, fitness),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.primary),
            onPressed: () => context.read<AuthController>().logout(),
          )
        ],
      ),
      body: fitness.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await fitness.loadProfile();
                await fitness.loadWeightLogs();
                await workout.loadWeeklyProgress();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(fitness),
                    const SizedBox(height: 32),
                    _buildBmiSummary(fitness),
                    const SizedBox(height: 32),
                    const Text(
                      'MÓDULOS PRINCIPALES',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    _buildModuleGrid(context),
                    const SizedBox(height: 32),
                    const Text(
                      'RESUMEN SEMANAL',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    _buildWeeklySummary(workout),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader(FitnessController fitness) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HOLA, ATLETA',
          style: TextStyle(fontSize: 14, color: AppColors.primary.withValues(alpha: 0.7), fontWeight: FontWeight.bold),
        ),
        const Text(
          'Bienvenido de nuevo',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textTitle),
        ),
      ],
    );
  }

  Widget _buildBmiSummary(FitnessController fitness) {
    return Card(
      elevation: 0,
      color: AppColors.primary.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Text(
                    'TU ESTADO FÍSICO',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    fitness.bmiCategory.toUpperCase(),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'IMC: ${fitness.bmi?.toStringAsFixed(1) ?? '--'}',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.speed, size: 48, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildModuleCard(
          context,
          'PESO',
          Icons.scale,
          AppColors.primary,
          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WeightMetricsScreen())),
        ),
        _buildModuleCard(
          context,
          'RUTINAS',
          Icons.fitness_center,
          AppColors.secondary,
          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RoutinesScreen())),
        ),
        _buildModuleCard(
          context,
          'METAS',
          Icons.emoji_events,
          Colors.orange,
          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GoalsScreen())),
        ),
      ],
    );
  }

  Widget _buildModuleCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklySummary(WorkoutController workout) {
    const days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final isCompleted = workout.weeklyProgress[index + 1] ?? false;
          return _buildDayStat(days[index], isCompleted);
        }),
      ),
    );
  }

  Widget _buildDayStat(String day, bool completed) {
    return Column(
      children: [
        Text(day, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 8),
        Icon(
          completed ? Icons.check_circle : Icons.radio_button_unchecked,
          color: completed ? AppColors.primary : Colors.grey.withValues(alpha: 0.3),
          size: 20,
        ),
      ],
    );
  }

  void _showUpdateProfileDialog(BuildContext context, FitnessController fitness) {
    final heightController = TextEditingController(text: fitness.height?.toString());
    final weightController = TextEditingController(text: fitness.weight?.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('DATOS BÁSICOS'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Talla (cm)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Peso Inicial (kg)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () {
              final h = double.tryParse(heightController.text);
              final w = double.tryParse(weightController.text);
              if (h != null && w != null) context.read<FitnessController>().updateProfileMetrics(h, w);
              Navigator.pop(context);
            },
            child: const Text('GUARDAR'),
          ),
        ],
      ),
    );
  }
}
