import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';
import 'package:fit_tracker_app/features/workout/data/models/routine_model.dart';
import 'package:fit_tracker_app/features/workout/presentation/controllers/training_session_controller.dart';
import 'package:fit_tracker_app/features/workout/presentation/widgets/training_session/ready_phase_view.dart';
import 'package:fit_tracker_app/features/workout/presentation/widgets/training_session/resting_phase_view.dart';
import 'package:fit_tracker_app/features/workout/presentation/widgets/training_session/finished_phase_view.dart';
import 'package:fit_tracker_app/features/workout/presentation/widgets/training_session/reorder_sheet.dart';

class TrainingSessionScreen extends StatelessWidget {
  final Routine routine;
  const TrainingSessionScreen({super.key, required this.routine});

  Future<void> _doExit() async {
    final leave = await _confirmExit();
    if (leave == true) {
      await Get.find<TrainingSessionController>().clearProgress();
      Get.delete<TrainingSessionController>();
      Get.back(result: null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TrainingSessionController(routine: routine));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _doExit();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFEEEEEE),
        body: SafeArea(
          child: Obx(() => AnimatedSwitcher(
            duration: const Duration(milliseconds: 480),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: CurvedAnimation(
                  parent: animation, curve: Curves.easeInOutCubic),
              child: child,
            ),
            child: controller.phase.value == TrainingPhase.finished
                ? const FinishedPhaseView(key: ValueKey('finished'))
                : Column(
                    key: const ValueKey('active'),
                    children: [
                      _buildHeader(controller, context),
                      _buildProgressBar(context, controller),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                            opacity: CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeInOutCubic),
                            child: child,
                          ),
                          child: SingleChildScrollView(
                            key: ValueKey(controller.phase.value),
                            padding:
                                const EdgeInsets.fromLTRB(20, 12, 20, 20),
                            child:
                                controller.phase.value == TrainingPhase.resting
                                    ? const RestingPhaseView()
                                    : const ReadyPhaseView(),
                          ),
                        ),
                      ),
                    ],
                  ),
          )),
        ),
      ),
    );
  }

  Future<bool?> _confirmExit() => Get.dialog<bool>(
        AlertDialog(
          title: const Text('¿Salir del entrenamiento?'),
          content: const Text('Perderás el progreso de esta sesión.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('CONTINUAR'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.alert),
              child: const Text('SALIR', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

  Widget _buildHeader(TrainingSessionController c, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routine.name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Obx(() => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer_outlined,
                              size: 13, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            c.formatTime(c.elapsed.value),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Get.bottomSheet(
              const ReorderSheet(),
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
            ),
            icon: const Icon(Icons.reorder),
          ),
          IconButton(
            onPressed: _doExit,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(
      BuildContext context, TrainingSessionController c) {
    return Obx(() => Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: c.progressPct,
                  minHeight: 6,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${c.exDoneCount} / ${c.exercises.length} ejercicios',
                style:
                    const TextStyle(fontSize: 11, color: AppColors.primary),
              ),
            ],
          ),
        ));
  }
}
