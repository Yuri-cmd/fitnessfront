import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/metrics/presentation/controllers/fitness_controller.dart';
import '../../../../features/auth/presentation/controllers/auth_controller.dart';
import '../../../../features/workout/presentation/screens/routines_screen.dart';
import '../../../../features/metrics/presentation/screens/weight_metrics_screen.dart';
import '../../../../features/workout/presentation/controllers/workout_controller.dart';
import '../../../../features/workout/presentation/screens/goals_screen.dart';
import '../../../../features/stats/presentation/screens/stats_screen.dart';
import '../../../../features/stats/presentation/controllers/stats_controller.dart';
import '../../../../features/wiki/presentation/screens/wiki_screen.dart';
import '../../../../features/metrics/presentation/screens/body_measurements_screen.dart';
import '../../../../features/water/presentation/controllers/water_controller.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/services/version_service.dart';

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
      context.read<WaterController>().loadTodayWater();
      context.read<StatsController>().loadAchievements();
      VersionService.checkAndPrompt(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final fitness = context.watch<FitnessController>();
    final workout = context.watch<WorkoutController>();
    final water = context.watch<WaterController>();
    final stats = context.watch<StatsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('POWER STACK'),
        actions: [
          IconButton(
            icon: Icon(
              context.watch<ThemeController>().isDark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: AppColors.primary,
            ),
            onPressed: () => context.read<ThemeController>().toggle(),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppColors.primary),
            onPressed: () => _showUpdateProfileDialog(context, fitness),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.primary),
            onPressed: () => context.read<AuthController>().logout(),
          ),
        ],
      ),
      body: fitness.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await fitness.loadProfile();
                await fitness.loadWeightLogs();
                await workout.loadWeeklyProgress();
                await water.loadTodayWater();
                await stats.loadAchievements();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildBmiSummary(fitness),
                    const SizedBox(height: 24),
                    _buildWaterSection(water),
                    const SizedBox(height: 24),
                    if (stats.achievements.isNotEmpty) ...[
                      _buildAchievementsSection(stats.achievements),
                      const SizedBox(height: 24),
                    ],
                    const Text(
                      'MÓDULOS PRINCIPALES',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildModuleGrid(context),
                    const SizedBox(height: 24),
                    const Text(
                      'RESUMEN SEMANAL',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildWeeklySummary(workout),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HOLA, ATLETA',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.primary.withValues(alpha: 0.7),
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          'Bienvenido de nuevo',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textTitle,
          ),
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
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TU ESTADO FÍSICO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
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

  // ─── Sección de Agua ───────────────────────────────────────────────────────

  Widget _buildWaterSection(WaterController water) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.water_drop, color: AppColors.secondary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'HIDRATACIÓN HOY',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.secondary,
                ),
              ),
              const Spacer(),
              Text(
                '${water.todayMl} / 2000 ml',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: water.progress,
              backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
              color: AppColors.secondary,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            water.statusText,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildWaterBtn(water, 200),
              const SizedBox(width: 8),
              _buildWaterBtn(water, 350),
              const SizedBox(width: 8),
              _buildWaterBtn(water, 500),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaterBtn(WaterController water, int ml) {
    return Expanded(
      child: OutlinedButton(
        onPressed: water.isLoading ? null : () => water.logWater(ml),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.secondary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        child: Text(
          '+${ml}ml',
          style: const TextStyle(color: AppColors.secondary, fontSize: 12),
        ),
      ),
    );
  }

  // ─── Sección de Logros ────────────────────────────────────────────────────

  Widget _buildAchievementsSection(List<dynamic> achievements) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'LOGROS OBTENIDOS',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 72,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final ach = achievements[index];
              return Tooltip(
                message: ach['description'] ?? ach['name'] ?? '',
                child: Container(
                  width: 64,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        ach['icon'] ?? '🏆',
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        (ach['name'] ?? '').toString().split(' ').first,
                        style:
                            const TextStyle(fontSize: 8, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Grid de Módulos ──────────────────────────────────────────────────────

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
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WeightMetricsScreen()),
          ),
        ),
        _buildModuleCard(
          context,
          'RUTINAS',
          Icons.fitness_center,
          AppColors.secondary,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RoutinesScreen()),
          ),
        ),
        _buildModuleCard(
          context,
          'METAS',
          Icons.emoji_events,
          Colors.orange,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GoalsScreen()),
          ),
        ),
        _buildModuleCard(
          context,
          'ESTADÍSTICAS',
          Icons.bar_chart,
          Colors.purple,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StatsScreen()),
          ),
        ),
        _buildModuleCard(
          context,
          'WIKI',
          Icons.menu_book,
          Colors.teal,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WikiScreen()),
          ),
        ),
        _buildModuleCard(
          context,
          'MEDIDAS',
          Icons.straighten,
          Colors.deepOrange,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BodyMeasurementsScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildModuleCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Resumen Semanal ──────────────────────────────────────────────────────

  Widget _buildWeeklySummary(WorkoutController workout) {
    const days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor),
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
          color:
              completed ? AppColors.primary : Colors.grey.withValues(alpha: 0.3),
          size: 20,
        ),
      ],
    );
  }

  // ─── Diálogo de Perfil ────────────────────────────────────────────────────

  void _showUpdateProfileDialog(BuildContext context, FitnessController fitness) {
    final heightController =
        TextEditingController(text: fitness.height?.toString());
    final weightController =
        TextEditingController(text: fitness.weight?.toString());

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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              final h = double.tryParse(heightController.text);
              final w = double.tryParse(weightController.text);
              if (h != null && w != null) {
                context.read<FitnessController>().updateProfileMetrics(h, w);
              }
              Navigator.pop(context);
            },
            child: const Text('GUARDAR'),
          ),
        ],
      ),
    );
  }
}
