import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_tracker_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:fit_tracker_app/features/workout/data/models/routine_model.dart';
import 'package:fit_tracker_app/features/workout/presentation/controllers/workout_controller.dart';
import 'package:fit_tracker_app/features/workout/presentation/widgets/common/workout_empty_state.dart';
import 'package:fit_tracker_app/features/workout/presentation/widgets/common/routine_card.dart';
import 'package:fit_tracker_app/features/workout/presentation/widgets/common/week_calendar_strip.dart';
import 'package:fit_tracker_app/features/workout/presentation/widgets/common/timeline_entry.dart';
import 'package:fit_tracker_app/features/workout/presentation/screens/create_routine_screen.dart';
import 'package:fit_tracker_app/features/workout/presentation/screens/training_session_screen.dart';
import 'package:fit_tracker_app/features/workout/presentation/screens/streak_celebration_screen.dart';
import 'package:fit_tracker_app/features/workout/presentation/screens/one_rm_screen.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';
import 'package:fit_tracker_app/features/onboarding/presentation/widgets/onboarding_view.dart';
import 'package:fit_tracker_app/features/workout/presentation/controllers/training_session_controller.dart';

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final WorkoutController _c;
  int? _activeSessionRoutineId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _c = Get.find<WorkoutController>();
    _checkForSavedSession();
  }

  Future<void> _checkForSavedSession() async {
    final id = await TrainingSessionController.getSavedRoutineId();
    if (id != null && mounted) setState(() => _activeSessionRoutineId = id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RUTINAS'),
        actions: [
          IconButton(
            tooltip: 'Calculadora 1RM',
            icon: const Icon(Icons.calculate_outlined, color: AppColors.primary),
            onPressed: () => Get.to(() => const OneRmScreen()),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'MIS PLANES', icon: Icon(Icons.fitness_center)),
            Tab(text: 'HISTORIAL', icon: Icon(Icons.history)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_routines',
        onPressed: () => Get.to(() => const CreateRoutineScreen()),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          if (_activeSessionRoutineId != null)
            _ActiveSessionBanner(
              onResume: () {
                final routine = _c.routines.firstWhereOrNull(
                    (r) => r.id == _activeSessionRoutineId);
                if (routine != null) {
                  setState(() => _activeSessionRoutineId = null);
                  _startTraining(routine);
                } else if (_c.isLoading.value) {
                  Get.snackbar(
                    'Cargando...',
                    'Espera un momento y vuelve a intentarlo.',
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(16),
                    borderRadius: 12,
                    duration: const Duration(seconds: 2),
                  );
                }
              },
              onDiscard: () async {
                await TrainingSessionController.clearSavedSession();
                if (mounted) setState(() => _activeSessionRoutineId = null);
              },
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _RoutinesTab(onStart: _startTraining),
                _HistoryTab(controller: _c),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startTraining(Routine routine) async {
    final c = Get.find<WorkoutController>();
    if (!c.isDoneToday(routine) && c.isDoneThisWeek(routine)) {
      final confirmed = await Get.dialog<bool>(AlertDialog(
        title: const Text('¿Repetir entrenamiento?'),
        content: Text(
          'Ya completaste "${routine.name}" esta semana. ¿Quieres volver a hacerlo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('SÍ, REPETIR'),
          ),
        ],
      ));
      if (confirmed != true) return;
    }

    final result = await Get.to<dynamic>(
      () => TrainingSessionScreen(routine: routine),
    );

    if (result is Map && mounted) {
      final sets = List<Map<String, dynamic>>.from(result['sets'] as List);
      final startTime = result['startTime'] as DateTime?;

      final streakData = _c.computeStreakData(routineId: routine.id);
      final userName = Get.find<AuthController>().userName.value;

      Get.to(() => StreakCelebrationScreen(
            streak: streakData.streak,
            trainedDaysThisWeek: streakData.trainedDays,
            userName: userName,
          ));

      unawaited(_c.completeRoutine(routine.id, sets, startTime));
    }
  }
}

class _RoutinesTab extends StatelessWidget {
  final void Function(Routine routine) onStart;

  const _RoutinesTab({required this.onStart});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<WorkoutController>();
    return Obx(() {
      if (c.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (c.routines.isEmpty && !c.showArchived.value) {
        // New user: no routines and no history — show onboarding
        if (c.workoutLogs.isEmpty) {
          return OnboardingView(
            onCreate: () => Get.to(() => const CreateRoutineScreen()),
          );
        }
        return WorkoutEmptyState(
          icon: Icons.fitness_center_outlined,
          title: 'No hay rutinas creadas',
          subtitle: 'Empieza creando tu primer plan de entrenamiento',
          action: TextButton.icon(
            onPressed: c.toggleArchived,
            icon: const Icon(Icons.archive_outlined),
            label: const Text('VER ARCHIVADAS'),
          ),
        );
      }
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: [
          // Active routines
          ...c.routines.map((routine) => RoutineCard(
                routine: routine,
                isDoneToday: c.isDoneToday(routine),
                isDoneThisWeek: c.isDoneThisWeek(routine),
                onStart: () => onStart(routine),
                onEdit: () =>
                    Get.to(() => CreateRoutineScreen(routine: routine)),
                onArchive: () => _confirmArchive(routine, c),
              )),

          // Archive toggle button
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: c.toggleArchived,
            icon: Icon(c.showArchived.value
                ? Icons.expand_less
                : Icons.archive_outlined),
            label: Text(c.showArchived.value
                ? 'OCULTAR ARCHIVADAS'
                : 'VER RUTINAS ARCHIVADAS'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
              side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),

          // Archived routines section
          if (c.showArchived.value) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.archive_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  'ARCHIVADAS',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      letterSpacing: 1),
                ),
                const Spacer(),
                if (c.isLoadingArchived.value)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (!c.isLoadingArchived.value && c.archivedRoutines.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'No hay rutinas archivadas',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ),
              )
            else
              ...c.archivedRoutines.map((routine) => RoutineCard(
                    routine: routine,
                    isDoneToday: false,
                    onStart: () {},
                    onEdit: () =>
                        Get.to(() => CreateRoutineScreen(routine: routine)),
                    onUnarchive: () => c.unarchiveRoutine(routine.id),
                  )),
          ],
        ],
      );
    });
  }

  void _confirmArchive(Routine routine, WorkoutController c) {
    Get.dialog(AlertDialog(
      title: const Text('¿Archivar rutina?'),
      content: Text(
        '"${routine.name}" se moverá a archivadas. Puedes restaurarla cuando quieras.',
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('CANCELAR')),
        ElevatedButton(
          onPressed: () {
            Get.back();
            c.archiveRoutine(routine.id);
          },
          child: const Text('ARCHIVAR'),
        ),
      ],
    ));
  }
}

class _HistoryTab extends StatelessWidget {
  final WorkoutController controller;

  const _HistoryTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() => WeekCalendarStrip(
              selectedDate: controller.selectedDate.value,
              onDateSelected: (d) => controller.selectedDate.value = d,
            )),
        const Divider(height: 1),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.workoutLogs.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.workoutLogs.isEmpty) {
              return WorkoutEmptyState(
                icon: Icons.calendar_month_outlined,
                title: 'Historial vacío',
                subtitle: 'Tus entrenamientos completados aparecerán aquí',
                action: TextButton(
                  onPressed: controller.loadWorkoutHistory,
                  child: const Text('REINTENTAR CARGAR'),
                ),
              );
            }

            final selected = controller.selectedDate.value;
            final filtered = controller.workoutLogs.where((log) {
              final d = log.completedAt;
              return d.day == selected.day &&
                  d.month == selected.month &&
                  d.year == selected.year;
            }).toList();

            if (filtered.isEmpty) {
              return Center(
                child: Text(
                  'No entrenaste este día',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: filtered.length,
              itemBuilder: (_, i) => TimelineEntry(
                log: filtered[i],
                isLast: i == filtered.length - 1,
              ),
            );
          }),
        ),
      ],
    );
  }
}

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
                            fontSize: 11,
                            color: AppColors.primary)),
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
