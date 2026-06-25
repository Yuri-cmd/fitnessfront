import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';
import 'package:fit_tracker_app/features/workout/presentation/controllers/training_session_controller.dart';

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primary),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary)),
        ],
      ),
    );
  }
}

class FinishedPhaseView extends GetView<TrainingSessionController> {
  const FinishedPhaseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.flag, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text('¡ENTRENAMIENTO COMPLETADO!',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 1)),
            const SizedBox(height: 8),
            Text(
              controller.routine.name,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StatChip(
                  icon: Icons.fitness_center,
                  label: '${controller.exercises.length} ejerc.',
                ),
                const SizedBox(width: 10),
                _StatChip(
                  icon: Icons.timer_outlined,
                  label: controller.formatTime(controller.elapsed.value),
                ),
                if (controller.totalVolume > 0) ...[
                  const SizedBox(width: 10),
                  _StatChip(
                    icon: Icons.local_fire_department_outlined,
                    label: '${controller.totalVolume.toStringAsFixed(0)} kg',
                  ),
                ],
              ],
            ),
            const SizedBox(height: 28),
            // Resumen
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('RESUMEN',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey)),
                  const SizedBox(height: 12),
                  ...List.generate(controller.exercises.length, (i) {
                    final ex = controller.exercises[i];
                    final maxW = controller.exMaxWeight(i);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.check,
                                size: 12, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(ex.name,
                                style:
                                    const TextStyle(fontWeight: FontWeight.w600)),
                          ),
                          if (maxW != null)
                            Text(
                              '${maxW.toStringAsFixed(1)} kg',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondary),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(result: controller.collectSetData()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
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
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Descartar y salir',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          ],
        ),
      );
    });
  }
}
