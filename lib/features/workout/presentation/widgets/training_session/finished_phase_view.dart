import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';
import 'package:fit_tracker_app/core/theme/app_radii.dart';
import 'package:fit_tracker_app/core/widgets/app_card.dart';
import 'package:fit_tracker_app/features/workout/presentation/controllers/training_session_controller.dart';

class FinishedPhaseView extends GetView<TrainingSessionController> {
  const FinishedPhaseView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      final duration = controller.formatTime(controller.elapsed.value);
      final volume = controller.totalVolume;

      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          children: [
            // ── Hero celebratorio ─────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.14),
                    AppColors.primary.withValues(alpha: 0.04),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppRadii.xl),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.18)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.emoji_events_rounded,
                        size: 42, color: AppColors.primary),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    '¡ENTRENAMIENTO COMPLETADO!',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    controller.routine.name,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onSurface),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Stats ─────────────────────────────────────────────────────────
            AppCard(
              padding: EdgeInsets.zero,
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        value: '${controller.exercises.length}',
                        label: 'ejercicios',
                        icon: Icons.fitness_center_rounded,
                      ),
                    ),
                    VerticalDivider(
                        width: 1,
                        color: colorScheme.onSurface.withValues(alpha: 0.08)),
                    Expanded(
                      child: _StatTile(
                        value: duration,
                        label: 'duración',
                        icon: Icons.timer_outlined,
                      ),
                    ),
                    if (volume > 0) ...[
                      VerticalDivider(
                          width: 1,
                          color:
                              colorScheme.onSurface.withValues(alpha: 0.08)),
                      Expanded(
                        child: _StatTile(
                          value: _formatVolume(volume),
                          label: 'volumen',
                          icon: Icons.local_fire_department_outlined,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Lista ejercicios ──────────────────────────────────────────────
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RESUMEN',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: colorScheme.onSurface.withValues(alpha: 0.4)),
                  ),
                  const SizedBox(height: 14),
                  ...List.generate(controller.exercises.length, (i) {
                    final ex = controller.exercises[i];
                    final maxW = controller.exMaxWeight(i);
                    final doneSets = controller.sets[i]
                        .where((s) => s['done'] == true)
                        .length;
                    final totalSets = controller.sets[i].length;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.check_rounded,
                                size: 14, color: AppColors.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ex.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14)),
                                Text(
                                  '$doneSets/$totalSets series',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: colorScheme.onSurface
                                          .withValues(alpha: 0.45)),
                                ),
                              ],
                            ),
                          ),
                          if (maxW != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.secondary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${maxW.toStringAsFixed(1)} kg',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: AppColors.secondary),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Botón guardar ─────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(result: {
                  'sets': controller.collectSetData(),
                  'startTime': controller.sessionStart,
                }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('GUARDAR ENTRENAMIENTO',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () async {
                final confirm = await Get.dialog<bool>(AlertDialog(
                  title: const Text('¿Descartar entrenamiento?'),
                  content: const Text(
                    'Se perderá todo el progreso de esta sesión. Esta acción no se puede deshacer.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text('CANCELAR'),
                    ),
                    TextButton(
                      onPressed: () => Get.back(result: true),
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.error),
                      child: const Text('DESCARTAR'),
                    ),
                  ],
                ));
                if (confirm == true) Get.back();
              },
              child: Text('Descartar y salir',
                  style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.35),
                      fontSize: 12)),
            ),
          ],
        ),
      );
    });
  }

  String _formatVolume(double kg) {
    if (kg >= 1000) return '${(kg / 1000).toStringAsFixed(1)}t';
    return '${kg.toStringAsFixed(0)} kg';
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  const _StatTile(
      {required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  height: 1)),
          const SizedBox(height: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.4))),
        ],
      ),
    );
  }
}
