import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';
import 'package:fit_tracker_app/features/workout/presentation/controllers/training_session_controller.dart';

class RestingPhaseView extends GetView<TrainingSessionController> {
  const RestingPhaseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final restPct = (controller.restTime.value - controller.restRemaining.value) /
          controller.restTime.value.clamp(1, controller.restTime.value);

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    'Serie ${controller.completedSetNum.value} completada',
                    style: const TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('DESCANSANDO',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 2)),
            const SizedBox(height: 8),
            Text(
              controller.formatTime(controller.restRemaining.value),
              style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.w900,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: restPct.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            // Ajustar descanso
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildRestAdjustBtn('-15s', () => controller.adjustRest(-15)),
                const SizedBox(width: 12),
                const Text('ajustar descanso',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(width: 12),
                _buildRestAdjustBtn('+15s', () => controller.adjustRest(15)),
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

  Widget _buildRestAdjustBtn(String label, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: const BorderSide(color: Colors.grey),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }
}
