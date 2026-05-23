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

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final WorkoutController _c;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _c = Get.find<WorkoutController>();
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
          unselectedLabelColor: Colors.grey,
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _RoutinesTab(onStart: _startTraining),
          _HistoryTab(controller: _c),
        ],
      ),
    );
  }

  void _startTraining(Routine routine) async {
    final result = await Get.to<dynamic>(
      () => TrainingSessionScreen(routine: routine),
    );

    if (result is List && mounted) {
      final streakData = _c.computeStreakData(routineId: routine.id);
      final userName = Get.find<AuthController>().userName.value;

      Get.to(() => StreakCelebrationScreen(
            streak: streakData.streak,
            trainedDaysThisWeek: streakData.trainedDays,
            userName: userName,
          ));

      unawaited(_c
          .completeRoutine(
            routine.id,
            List<Map<String, dynamic>>.from(result),
          )
          .then((_) => _c.loadWorkoutHistory()));
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
              foregroundColor: Colors.grey,
              side: const BorderSide(color: Colors.grey),
              minimumSize: const Size(double.infinity, 44),
            ),
          ),

          // Archived routines section
          if (c.showArchived.value) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.archive_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                const Text(
                  'ARCHIVADAS',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
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
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'No hay rutinas archivadas',
                    style: TextStyle(color: Colors.grey),
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
              return const Center(
                child: Text(
                  'No entrenaste este día',
                  style: TextStyle(color: Colors.grey),
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
