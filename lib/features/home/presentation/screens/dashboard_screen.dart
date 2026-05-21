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
          ? const _DashboardSkeleton()
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProfileSheet(fitness: fitness),
    );
  }
}

// ─── Skeleton ─────────────────────────────────────────────────────────────────

class _DashboardSkeleton extends StatefulWidget {
  const _DashboardSkeleton();

  @override
  State<_DashboardSkeleton> createState() => _DashboardSkeletonState();
}

class _DashboardSkeletonState extends State<_DashboardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 0.9)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? Colors.white : Colors.black;

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final block = base.withValues(alpha: _anim.value * 0.12);
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero banner placeholder
              Container(
                width: double.infinity,
                height: 160,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                color: isDark
                    ? const Color(0xFF1A1F12)
                    : const Color(0xFF2E3D1A),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(100, 12, Colors.white.withValues(alpha: _anim.value * 0.15)),
                    const SizedBox(height: 8),
                    _box(160, 22, Colors.white.withValues(alpha: _anim.value * 0.2)),
                    const SizedBox(height: 14),
                    _box(130, 26, Colors.white.withValues(alpha: _anim.value * 0.12), radius: 20),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  children: [
                    // Quick stats row
                    Row(
                      children: [
                        Expanded(child: _card(block, 80)),
                        const SizedBox(width: 12),
                        Expanded(child: _card(block, 80)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Water section
                    _card(block, 140),
                    const SizedBox(height: 20),
                    // Weekly summary header
                    Row(
                      children: [
                        _box(110, 11, block),
                        const Spacer(),
                        _box(60, 11, block),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Day bubbles
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        7,
                        (_) => Column(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                  color: block, shape: BoxShape.circle),
                            ),
                            const SizedBox(height: 5),
                            _box(16, 8, block),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _box(double w, double h, Color color, {double radius = 6}) =>
      Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(radius)),
      );

  Widget _card(Color block, double height) => Container(
        width: double.infinity,
        height: height,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: block,
          borderRadius: BorderRadius.circular(20),
        ),
      );
}

// ─── Bottom sheet de perfil ────────────────────────────────────────────────────

class _ProfileSheet extends StatefulWidget {
  final FitnessController fitness;
  const _ProfileSheet({required this.fitness});

  @override
  State<_ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<_ProfileSheet> {
  late final TextEditingController _heightCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _goalCtrl;
  DateTime? _birthDate;
  String? _gender;
  String? _activityLevel;
  bool _saving = false;

  static const _activities = [
    ('sedentary',           'Sedentario',       'Poco o ningún ejercicio'),
    ('lightly_active',      'Ligeramente activo','Ejercicio ligero 1–3 días/sem'),
    ('moderately_active',   'Moderadamente activo','Ejercicio moderado 3–5 días/sem'),
    ('very_active',         'Muy activo',       'Ejercicio intenso 6–7 días/sem'),
    ('extra_active',        'Extra activo',     'Trabajo físico + entreno diario'),
  ];

  @override
  void initState() {
    super.initState();
    final f = widget.fitness;
    _heightCtrl = TextEditingController(text: f.height?.toStringAsFixed(0));
    _weightCtrl = TextEditingController(text: f.weight?.toStringAsFixed(1));
    _goalCtrl   = TextEditingController(text: f.goalWeight?.toStringAsFixed(1));
    _birthDate     = f.birthDate;
    _gender        = f.gender;
    _activityLevel = f.activityLevel;
  }

  @override
  void dispose() {
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _goalCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 25),
      firstDate: DateTime(1920),
      lastDate: DateTime(now.year - 5),
      helpText: 'Fecha de nacimiento',
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final ok = await widget.fitness.updateFullProfile(
      height:        double.tryParse(_heightCtrl.text),
      weight:        double.tryParse(_weightCtrl.text),
      goalWeight:    double.tryParse(_goalCtrl.text),
      birthDate:     _birthDate,
      gender:        _gender,
      activityLevel: _activityLevel,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Perfil actualizado' : 'Error al guardar'),
      backgroundColor: ok ? AppColors.primary : Colors.red.shade400,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scroll) => Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const Text('MI PERFIL',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                  const Spacer(),
                  if (_saving)
                    const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                  else
                    FilledButton(
                      onPressed: _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('GUARDAR',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
            Expanded(
              child: ListView(
                controller: scroll,
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                children: [
                  _sectionLabel('MEDIDAS CORPORALES'),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _numField(_heightCtrl,  'Talla (cm)',  Icons.height_rounded)),
                    const SizedBox(width: 12),
                    Expanded(child: _numField(_weightCtrl,  'Peso actual (kg)', Icons.monitor_weight_outlined)),
                  ]),
                  const SizedBox(height: 12),
                  _numField(_goalCtrl, 'Peso objetivo (kg)', Icons.flag_outlined),
                  const SizedBox(height: 24),

                  _sectionLabel('FECHA DE NACIMIENTO'),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: scheme.outline.withValues(alpha: 0.4)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.cake_outlined,
                              size: 20, color: scheme.onSurfaceVariant),
                          const SizedBox(width: 12),
                          Text(
                            _birthDate != null
                                ? '${_birthDate!.day.toString().padLeft(2,'0')}/${_birthDate!.month.toString().padLeft(2,'0')}/${_birthDate!.year}'
                                : 'Seleccionar fecha',
                            style: TextStyle(
                              fontSize: 15,
                              color: _birthDate != null
                                  ? scheme.onSurface
                                  : scheme.onSurfaceVariant,
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.chevron_right_rounded,
                              color: scheme.onSurfaceVariant),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _sectionLabel('GÉNERO'),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _genderChip('male',   'Masculino', Icons.male_rounded)),
                    const SizedBox(width: 12),
                    Expanded(child: _genderChip('female', 'Femenino',  Icons.female_rounded)),
                  ]),
                  const SizedBox(height: 24),

                  _sectionLabel('NIVEL DE ACTIVIDAD'),
                  const SizedBox(height: 12),
                  ..._activities.map((a) => _activityTile(a.$1, a.$2, a.$3)),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      letterSpacing: 1.4,
    ),
  );

  Widget _numField(TextEditingController ctrl, String label, IconData icon) =>
      TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

  Widget _genderChip(String value, String label, IconData icon) {
    final selected = _gender == value;
    final color = AppColors.primary;
    return GestureDetector(
      onTap: () => setState(() => _gender = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: selected ? color : Colors.grey),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected ? color : null,
                )),
          ],
        ),
      ),
    );
  }

  Widget _activityTile(String value, String label, String sub) {
    final selected = _activityLevel == value;
    final color = AppColors.primary;
    return GestureDetector(
      onTap: () => setState(() => _activityLevel = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: selected ? color : null,
                      )),
                  Text(sub,
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      )),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}
