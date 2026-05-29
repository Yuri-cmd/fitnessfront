import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';
import 'package:fit_tracker_app/features/workout/presentation/controllers/training_session_controller.dart';

class RestingPhaseView extends GetView<TrainingSessionController> {
  const RestingPhaseView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      final restPct =
          (controller.currentRestDuration.value - controller.restRemaining.value) /
              controller.currentRestDuration.value.clamp(
                  1, controller.currentRestDuration.value);

      final nextEx = controller.showNextExerciseHint ? controller.nextExercise : null;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            // Badge completado
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check, size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    controller.completedSetLabel,
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              controller.isWarmupRest.value
                  ? 'DESCANSO APROX.'
                  : 'DESCANSANDO',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface.withValues(alpha: 0.45),
                  letterSpacing: 2),
            ),
            const SizedBox(height: 8),

            // Timer — usa color explícito para ser visible en modo oscuro
            Text(
              controller.formatTime(controller.restRemaining.value),
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.w900,
                color: colorScheme.onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 16),

            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: restPct.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor:
                    colorScheme.onSurface.withValues(alpha: 0.08),
                color: AppColors.primary,
              ),
            ),

            // Próximo ejercicio
            if (nextEx != null) ...[
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: colorScheme.onSurface.withValues(alpha: 0.08)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.arrow_forward_rounded,
                        size: 15,
                        color:
                            colorScheme.onSurface.withValues(alpha: 0.4)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PRÓXIMO EJERCICIO',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.4)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            nextEx.name,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (nextEx.pivot != null)
                            Text(
                              '${nextEx.pivot!.totalSets} series × ${nextEx.pivot!.repsDisplay} reps',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.5)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),
            // Ajustar descanso
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildRestAdjustBtn(
                    context, '-15s', () => controller.adjustRest(-15)),
                const SizedBox(width: 12),
                Text('ajustar descanso',
                    style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                        fontSize: 12)),
                const SizedBox(width: 12),
                _buildRestAdjustBtn(
                    context, '+15s', () => controller.adjustRest(15)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.skipRest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(controller.nextActionLabel,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w900)),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildRestAdjustBtn(
      BuildContext context, String label, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: BorderSide(
            color: colorScheme.onSurface.withValues(alpha: 0.25)),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface.withValues(alpha: 0.6))),
    );
  }
}
