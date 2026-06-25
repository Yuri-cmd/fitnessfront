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
      final warning = controller.isRestWarning.value;
      final accentColor = warning ? Colors.orange.shade500 : AppColors.primary;

      final nextEx = controller.showNextExerciseHint ? controller.nextExercise : null;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 6))
          ],
        ),
        child: Column(
          children: [
            // ── Badge serie completada ────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 15, color: AppColors.primary),
                  const SizedBox(width: 7),
                  Text(
                    controller.completedSetLabel,
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Circular countdown timer ──────────────────────────────────────
            Stack(
              alignment: Alignment.center,
              children: [
                // Track background
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 10,
                    valueColor: AlwaysStoppedAnimation(
                      colorScheme.onSurface.withValues(alpha: 0.07),
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                // Draining arc
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: (1 - restPct).clamp(0.0, 1.0),
                    strokeWidth: 10,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation(accentColor),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                // Inner content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.isWarmupRest.value
                          ? 'APROX.'
                          : 'DESCANSO',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        color: warning
                            ? Colors.orange.shade600
                            : colorScheme.onSurface,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        height: 1,
                      ),
                      child: Text(
                        controller.formatTime(controller.restRemaining.value),
                      ),
                    ),
                    if (warning) ...[
                      const SizedBox(height: 4),
                      Text(
                        '¡PREPÁRATE!',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade600,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Próximo ejercicio ─────────────────────────────────────────────
            if (nextEx != null) ...[
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: colorScheme.onSurface.withValues(alpha: 0.07)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.arrow_forward_rounded,
                          size: 15, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
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
                                fontSize: 14,
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
              const SizedBox(height: 20),
            ],

            // ── Ajustar descanso ──────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _AdjustBtn(
                    label: '−15s',
                    onTap: () => controller.adjustRest(-15),
                    context: context),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    'ajustar descanso',
                    style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.35),
                        fontSize: 12),
                  ),
                ),
                _AdjustBtn(
                    label: '+15s',
                    onTap: () => controller.adjustRest(15),
                    context: context),
              ],
            ),

            const SizedBox(height: 20),

            // ── Botón skip ────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.skipRest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
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
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _AdjustBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final BuildContext context;
  const _AdjustBtn(
      {required this.label, required this.onTap, required this.context});

  @override
  Widget build(BuildContext ctx) {
    final colorScheme = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        side:
            BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.22)),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.65))),
    );
  }
}
