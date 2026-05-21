import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';
import 'package:fit_tracker_app/features/workout/presentation/controllers/training_session_controller.dart';

class ReadyPhaseView extends GetView<TrainingSessionController> {
  const ReadyPhaseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ex = controller.currentEx;
      if (ex == null) return const SizedBox();

      final numSets = ex.pivot!.sets;
      final reps = ex.pivot!.reps;
      final currentExIdx = controller.currentExIdx.value;
      final currentSetIdx = controller.currentSetIdx.value;

      return Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EJERCICIO ${currentExIdx + 1} DE ${controller.exercises.length}',
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ex.name,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w900),
                      ),
                      if (ex.muscleGroup != null)
                        Text(ex.muscleGroup!,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFF5F5F5)),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(numSets, (i) {
                          final isCurSet = i == currentSetIdx;
                          final isDoneSet =
                              controller.sets[currentExIdx][i]['done'] == true;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            height: 10,
                            width: isCurSet ? 28 : 10,
                            decoration: BoxDecoration(
                              color: isDoneSet || isCurSet
                                  ? AppColors.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'SERIE ${currentSetIdx + 1} DE $numSets',
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$reps',
                            style: const TextStyle(
                                fontSize: 64, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(width: 8),
                          const Text('reps',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          TextField(
                            controller: controller
                                .controllers[currentExIdx][currentSetIdx],
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 36, fontWeight: FontWeight.w900),
                            decoration: InputDecoration(
                              hintText: '0',
                              hintStyle: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.3)),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 48),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                                    width: 2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                    color: AppColors.primary, width: 2),
                              ),
                              filled: true,
                              fillColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerLowest,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: Text('kg',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text('peso utilizado (opcional)',
                          style: TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.completeSet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            elevation: 0,
                            shadowColor:
                                AppColors.primary.withValues(alpha: 0.4),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check, size: 20),
                              SizedBox(width: 8),
                              Text('COMPLETAR SERIE',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed:
                                controller.canGoBack ? controller.goBack : null,
                            icon: const Icon(Icons.undo, size: 14),
                            label: const Text('Anterior'),
                            style: TextButton.styleFrom(
                              foregroundColor: controller.canGoBack
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.2),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: controller.skipSet,
                            icon: const Icon(Icons.skip_next, size: 14),
                            label: const Text('Saltar'),
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (controller.exDoneCount > 0) ...[
            const SizedBox(height: 16),
            _buildDoneList(context),
          ],
        ],
      );
    });
  }

  Widget _buildDoneList(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('YA COMPLETADOS',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          const SizedBox(height: 10),
          ...List.generate(controller.exercises.length, (i) {
            if (!controller.sets[i].every((s) => s['done'] == true)) {
              return const SizedBox();
            }
            final maxW = controller.exMaxWeight(i);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Icon(Icons.check,
                        size: 10, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(controller.exercises[i].name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                  if (maxW != null)
                    Text(
                      '${maxW.toStringAsFixed(1)} kg máx',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
