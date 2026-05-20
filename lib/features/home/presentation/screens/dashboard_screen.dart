import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/metrics/presentation/controllers/fitness_controller.dart';
import '../../../../features/auth/presentation/controllers/auth_controller.dart';
import '../../../../features/workout/presentation/controllers/workout_controller.dart';
import '../../../../features/water/presentation/controllers/water_controller.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/services/version_service.dart';
import '../../../../features/streak/presentation/controllers/streak_controller.dart';

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
      if (!mounted) return;
      context.read<FitnessController>().loadProfile();
      context.read<FitnessController>().loadWeightLogs();
      context.read<WorkoutController>().loadWeeklyProgress();
      context.read<WaterController>().loadTodayWater();
      context.read<StreakController>().load();
      VersionService.checkAndPrompt(context);
      _offerBiometricIfNeeded();
    });
  }

  void _offerBiometricIfNeeded() {
    final auth = context.read<AuthController>();
    if (!auth.isBiometricAvailable || auth.isBiometricEnabled) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Acceso biométrico'),
        content: const Text(
          '¿Quieres usar huella o Face ID para ingresar más rápido la próxima vez?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Ahora no'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              auth.setBiometricEnabled(true);
            },
            child: const Text('Activar',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  String get _greeting {
    final h = TimeOfDay.now().hour;
    if (h < 12) return 'Buenos días';
    if (h < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    final fitness = context.watch<FitnessController>();
    final workout = context.watch<WorkoutController>();
    final water = context.watch<WaterController>();
    final streak = context.watch<StreakController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.primary),
            onSelected: (value) {
              if (value == 'logout') {
                context.read<AuthController>().logout();
              } else if (value == 'delete') {
                _showDeleteAccountDialog(context);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(children: [
                  Icon(Icons.logout, size: 18),
                  SizedBox(width: 10),
                  Text('Cerrar sesión'),
                ]),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete_forever, size: 18, color: Colors.red),
                  SizedBox(width: 10),
                  Text('Eliminar cuenta',
                      style: TextStyle(color: Colors.red)),
                ]),
              ),
            ],
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
                await streak.load();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroBanner(fitness, streak, isDark),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildQuickStats(fitness, workout),
                          const SizedBox(height: 20),
                          _buildWaterSection(water),
                          const SizedBox(height: 20),
                          _buildWeeklySummary(workout),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // ─── Hero banner ──────────────────────────────────────────────────────────

  Widget _buildHeroBanner(FitnessController fitness, StreakController streak, bool isDark) {
    final name = context.read<AuthController>().userName;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A1F12), const Color(0xFF252C18)]
              : [const Color(0xFF2E3D1A), const Color(0xFF4A6024)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primary.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    fitness.bmi != null
                        ? 'IMC ${fitness.bmi!.toStringAsFixed(1)} · ${fitness.bmiCategory}'
                        : 'Completa tu perfil',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Flexible(child: _streakPill('🔥', streak.workoutStreak, 'entreno')),
                    const SizedBox(width: 8),
                    Flexible(child: _streakPill('💧', streak.waterStreak, 'agua')),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.15),
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4), width: 2),
            ),
            child: const Icon(Icons.fitness_center_rounded,
                size: 34, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _streakPill(String emoji, int days, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              '$days ${days == 1 ? 'día' : 'días'} de $label',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Quick stats ──────────────────────────────────────────────────────────

  Widget _buildQuickStats(FitnessController fitness, WorkoutController workout) {
    final trained = workout.weeklyProgress.values.where((v) => v).length;
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.local_fire_department_rounded,
            iconColor: Colors.orange,
            value: '$trained',
            label: 'Esta semana',
            sub: trained == 1 ? 'entrenamiento' : 'entrenamientos',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            icon: Icons.monitor_weight_outlined,
            iconColor: AppColors.primary,
            value: fitness.weight != null
                ? '${fitness.weight!.toStringAsFixed(1)} kg'
                : '--',
            label: 'Peso actual',
            sub: fitness.height != null
                ? '${fitness.height!.toStringAsFixed(0)} cm'
                : 'sin datos',
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required String sub,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 18),
                ),
                Text(
                  label,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
                Text(
                  sub,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Agua ─────────────────────────────────────────────────────────────────

  Widget _buildWaterSection(WaterController water) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.water_drop_rounded,
                  color: AppColors.secondary, size: 18),
              const SizedBox(width: 8),
              const Text(
                'HIDRATACIÓN HOY',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: AppColors.secondary,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Text(
                '${water.glasses}/${water.goalGlasses}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'vasos',
                style: TextStyle(fontSize: 11, color: AppColors.secondary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: water.progress,
              backgroundColor: AppColors.secondary.withValues(alpha: 0.12),
              color: water.goalReached
                  ? AppColors.primary
                  : AppColors.secondary,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                water.statusText,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              if (water.goalReached)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '✓ META',
                    style: TextStyle(
                        fontSize: 10,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: water.isLoading ? null : water.addGlass,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('VASO',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed:
                    (water.isLoading || water.glasses == 0) ? null : water.removeGlass,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey,
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.35)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(
                      vertical: 11, horizontal: 16),
                ),
                child: const Icon(Icons.remove, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Resumen semanal ──────────────────────────────────────────────────────

  Widget _buildWeeklySummary(WorkoutController workout) {
    const days = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];
    final today = DateTime.now().weekday; // 1=lunes … 7=domingo

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'SEMANA ACTUAL',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),
            const Spacer(),
            Text(
              '${workout.weeklyProgress.values.where((v) => v).length}/7 días',
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (i) {
            final done = workout.weeklyProgress[i + 1] ?? false;
            final isToday = (i + 1) == today;
            return _dayBubble(days[i], done, isToday);
          }),
        ),
      ],
    );
  }

  Widget _dayBubble(String day, bool done, bool isToday) {
    Color bg;
    Color fg;
    if (done) {
      bg = AppColors.primary;
      fg = Colors.black;
    } else if (isToday) {
      bg = AppColors.primary.withValues(alpha: 0.15);
      fg = AppColors.primary;
    } else {
      bg = Theme.of(context).colorScheme.surfaceContainerHighest;
      fg = Colors.grey;
    }

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: isToday && !done
                ? Border.all(color: AppColors.primary, width: 1.5)
                : null,
          ),
          child: Center(
            child: done
                ? Icon(Icons.check_rounded, size: 18, color: fg)
                : Text(
                    day[0],
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13, color: fg),
                  ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          day,
          style: TextStyle(
            fontSize: 8,
            color: isToday ? AppColors.primary : Colors.grey,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // ─── Diálogos ─────────────────────────────────────────────────────────────

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: const Text(
          '¿Estás seguro? Esta acción es irreversible. '
          'Se eliminarán todos tus datos permanentemente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthController>().deleteAccount();
            },
            child:
                const Text('ELIMINAR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showUpdateProfileDialog(
      BuildContext context, FitnessController fitness) {
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
