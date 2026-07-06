import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';
import 'package:fit_tracker_app/features/metrics/presentation/controllers/fitness_controller.dart';
import 'package:fit_tracker_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:fit_tracker_app/features/workout/presentation/controllers/workout_controller.dart';
import 'package:fit_tracker_app/features/water/presentation/controllers/water_controller.dart';
import 'package:fit_tracker_app/features/water/presentation/widgets/water_section.dart';
import 'package:fit_tracker_app/features/streak/presentation/controllers/streak_controller.dart';
import 'package:fit_tracker_app/features/streak/presentation/widgets/streak_pills.dart';
import 'package:fit_tracker_app/core/theme/theme_controller.dart';
import 'package:fit_tracker_app/core/services/version_service.dart';
import 'package:fit_tracker_app/features/workout/presentation/controllers/training_session_controller.dart';
import 'package:fit_tracker_app/features/workout/presentation/screens/training_session_screen.dart';
import 'package:fit_tracker_app/features/workout/presentation/screens/streak_celebration_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int? _activeSessionRoutineId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Get.find<WorkoutController>().loadWeeklyProgress();
      VersionService.checkAndPrompt(context);
      // Delay biometric offer so it never stacks on top of a version dialog
      Future.delayed(const Duration(milliseconds: 500), () {
        if (Get.isDialogOpen != true) _offerBiometricIfNeeded();
      });
    });
    _checkForSavedSession();
  }

  Future<void> _checkForSavedSession() async {
    final id = await TrainingSessionController.getSavedRoutineId();
    if (id != null && mounted) setState(() => _activeSessionRoutineId = id);
  }

  Future<void> _resumeSession() async {
    final id = _activeSessionRoutineId;
    if (id == null) return;
    final wc = Get.find<WorkoutController>();
    final routine = wc.routines.firstWhereOrNull((r) => r.id == id);
    if (routine == null) {
      await TrainingSessionController.clearSavedSession();
      if (mounted) setState(() => _activeSessionRoutineId = null);
      return;
    }
    if (mounted) setState(() => _activeSessionRoutineId = null);

    final result = await Get.to<dynamic>(
      () => TrainingSessionScreen(routine: routine),
    );

    if (result is Map && mounted) {
      final sets = List<Map<String, dynamic>>.from(result['sets'] as List);
      final startTime = result['startTime'] as DateTime?;
      final streakData = wc.computeStreakData(routineId: routine.id);
      final userName = Get.find<AuthController>().userName.value;
      Get.to(() => StreakCelebrationScreen(
            streak: streakData.streak,
            trainedDaysThisWeek: streakData.trainedDays,
            userName: userName,
          ));
      unawaited(wc.completeRoutine(routine.id, sets, startTime));
    }
  }

  void _offerBiometricIfNeeded() {
    final auth = Get.find<AuthController>();
    if (!auth.isBiometricAvailable.value || auth.isBiometricEnabled.value) return;
    Get.dialog(AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Acceso biométrico'),
      content: const Text(
        '¿Quieres usar huella o Face ID para ingresar más rápido la próxima vez?',
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Ahora no')),
        TextButton(
          onPressed: () {
            Get.back();
            auth.setBiometricEnabled(true);
          },
          child: const Text('Activar',
              style: TextStyle(color: AppColors.primary)),
        ),
      ],
    ));
  }

  String get _greeting {
    final h = TimeOfDay.now().hour;
    if (h < 12) return 'Buenos días';
    if (h < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('POWER STACK'),
        actions: [
          IconButton(
            icon: Obx(() => Icon(
              Get.find<ThemeController>().isDark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: AppColors.primary,
            )),
            onPressed: () => Get.find<ThemeController>().toggle(),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppColors.primary),
            onPressed: () => _showUpdateProfileDialog(context),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.primary),
            onSelected: (value) {
              if (value == 'logout') {
                Get.find<AuthController>().logout();
              } else if (value == 'password') {
                _showChangePasswordDialog(context);
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
                value: 'password',
                child: Row(children: [
                  Icon(Icons.lock_outline, size: 18),
                  SizedBox(width: 10),
                  Text('Cambiar contraseña'),
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
      body: Column(
        children: [
          if (_activeSessionRoutineId != null)
            _ActiveSessionBanner(
              onResume: _resumeSession,
              onDiscard: () async {
                await TrainingSessionController.clearSavedSession();
                if (mounted) setState(() => _activeSessionRoutineId = null);
              },
            ),
          Expanded(
            child: Obx(() {
        final fitness = Get.find<FitnessController>();
        if (fitness.isLoading.value) return const _DashboardSkeleton();
        return RefreshIndicator(
          onRefresh: () async {
            await fitness.loadProfile();
            await fitness.loadWeightLogs();
            await Get.find<WorkoutController>().loadWeeklyProgress();
            await Get.find<WaterController>().loadTodayWater();
            await Get.find<StreakController>().load();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroBanner(isDark),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuickStats(),
                      const SizedBox(height: 20),
                      const WaterSection(),
                      const SizedBox(height: 20),
                      _buildWeeklySummary(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
          ),   // Expanded
        ],
      ),       // Column
    );
  }

  // ─── Hero banner ──────────────────────────────────────────────────────────

  Widget _buildHeroBanner(bool isDark) {
    final fitness = Get.find<FitnessController>();
    final name = Get.find<AuthController>()
        .userName
        .value
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
                    fitness.bmi.value != null
                        ? 'IMC ${fitness.bmi.value!.toStringAsFixed(1)} · ${fitness.bmiCategory}'
                        : 'Completa tu perfil',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const StreakPills(),
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

  // ─── Quick stats ──────────────────────────────────────────────────────────

  Widget _buildQuickStats() {
    final fitness = Get.find<FitnessController>();
    final workout = Get.find<WorkoutController>();
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
            value: fitness.weight.value != null
                ? '${fitness.weight.value!.toStringAsFixed(1)} kg'
                : '--',
            label: 'Peso actual',
            sub: fitness.height.value != null
                ? '${fitness.height.value!.toStringAsFixed(0)} cm'
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

  // ─── Resumen semanal ──────────────────────────────────────────────────────

  Widget _buildWeeklySummary() {
    final workout = Get.find<WorkoutController>();
    const days = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];
    final today = DateTime.now().weekday;

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

  void _showChangePasswordDialog(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final obscureCurrent = ValueNotifier(true);
    final obscureNew = ValueNotifier(true);
    final obscureConfirm = ValueNotifier(true);
    final errorMsg = ValueNotifier<String?>(null);
    final isLoading = ValueNotifier(false);

    Get.dialog(
      StatefulBuilder(
        builder: (_, setState) => AlertDialog(
          title: const Text('Cambiar contraseña'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: obscureCurrent,
                  builder: (_, hide, __) => TextField(
                    controller: currentCtrl,
                    obscureText: hide,
                    decoration: InputDecoration(
                      labelText: 'Contraseña actual',
                      suffixIcon: IconButton(
                        icon: Icon(hide ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => obscureCurrent.value = !hide,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ValueListenableBuilder<bool>(
                  valueListenable: obscureNew,
                  builder: (_, hide, __) => TextField(
                    controller: newCtrl,
                    obscureText: hide,
                    decoration: InputDecoration(
                      labelText: 'Nueva contraseña',
                      helperText: 'Mínimo 8 caracteres',
                      suffixIcon: IconButton(
                        icon: Icon(hide ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => obscureNew.value = !hide,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ValueListenableBuilder<bool>(
                  valueListenable: obscureConfirm,
                  builder: (_, hide, __) => TextField(
                    controller: confirmCtrl,
                    obscureText: hide,
                    decoration: InputDecoration(
                      labelText: 'Confirmar nueva contraseña',
                      suffixIcon: IconButton(
                        icon: Icon(hide ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => obscureConfirm.value = !hide,
                      ),
                    ),
                  ),
                ),
                ValueListenableBuilder<String?>(
                  valueListenable: errorMsg,
                  builder: (_, msg, __) => msg != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(msg,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 12)),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('CANCELAR'),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: isLoading,
              builder: (_, loading, __) => ElevatedButton(
                onPressed: loading
                    ? null
                    : () async {
                        errorMsg.value = null;
                        if (currentCtrl.text.isEmpty ||
                            newCtrl.text.isEmpty ||
                            confirmCtrl.text.isEmpty) {
                          errorMsg.value = 'Completa todos los campos.';
                          return;
                        }
                        if (newCtrl.text.length < 8) {
                          errorMsg.value =
                              'La nueva contraseña debe tener al menos 8 caracteres.';
                          return;
                        }
                        if (newCtrl.text != confirmCtrl.text) {
                          errorMsg.value = 'Las contraseñas no coinciden.';
                          return;
                        }
                        isLoading.value = true;
                        final error =
                            await Get.find<AuthController>().changePassword(
                          currentPassword: currentCtrl.text,
                          newPassword: newCtrl.text,
                        );
                        isLoading.value = false;
                        if (error != null) {
                          errorMsg.value = error;
                        } else {
                          Get.back();
                          Get.snackbar(
                            '¡Listo!',
                            'Contraseña actualizada correctamente.',
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(16),
                            borderRadius: 12,
                          );
                        }
                      },
                child: loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('GUARDAR'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final confirmController = TextEditingController();
    final confirmed = false.obs;

    Get.dialog(
      barrierDismissible: false,
      AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Esta acción es irreversible. Escribe ELIMINAR para confirmar:',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmController,
              decoration: const InputDecoration(
                hintText: 'ELIMINAR',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => confirmed.value = v.trim() == 'ELIMINAR',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              confirmController.dispose();
              Get.back();
            },
            child: const Text('CANCELAR'),
          ),
          Obx(() => ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: confirmed.value
                    ? () async {
                        confirmController.dispose();
                        Get.back();
                        final ok = await Get.find<AuthController>().deleteAccount();
                        if (!ok) {
                          Get.snackbar(
                            'Error',
                            'No se pudo eliminar la cuenta. Intenta de nuevo.',
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(16),
                            borderRadius: 12,
                          );
                        }
                      }
                    : null,
                child: const Text('ELIMINAR',
                    style: TextStyle(color: Colors.white)),
              )),
        ],
      ),
    );
  }

  void _showUpdateProfileDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ProfileSheet(),
    );
  }
}

// ─── Skeleton ─────────────────────────────────────────────────────────────────

// ─── Active session banner ────────────────────────────────────────────────────

class _ActiveSessionBanner extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onDiscard;
  const _ActiveSessionBanner(
      {required this.onResume, required this.onDiscard});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.12),
      child: InkWell(
        onTap: onResume,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.fitness_center_rounded,
                    size: 18, color: Colors.black87),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sesión activa',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: AppColors.primary)),
                    Text('Toca para continuar tu entrenamiento',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.primary)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                color: AppColors.primary.withValues(alpha: 0.55),
                tooltip: 'Descartar sesión',
                onPressed: onDiscard,
              ),
            ],
          ),
        ),
      ),
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
  const _ProfileSheet();

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
    final f = Get.find<FitnessController>();
    _heightCtrl = TextEditingController(text: f.height.value?.toStringAsFixed(0));
    _weightCtrl = TextEditingController(text: f.weight.value?.toStringAsFixed(1));
    _goalCtrl   = TextEditingController(text: f.goalWeight.value?.toStringAsFixed(1));
    _birthDate     = f.birthDate.value;
    _gender        = f.gender.value;
    _activityLevel = f.activityLevel.value;
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
    final ok = await Get.find<FitnessController>().updateFullProfile(
      height:        double.tryParse(_heightCtrl.text),
      weight:        double.tryParse(_weightCtrl.text),
      goalWeight:    double.tryParse(_goalCtrl.text),
      birthDate:     _birthDate,
      gender:        _gender,
      activityLevel: _activityLevel,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(SnackBar(
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
