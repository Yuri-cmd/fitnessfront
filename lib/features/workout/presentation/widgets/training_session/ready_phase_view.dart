import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';
import 'package:fit_tracker_app/core/theme/app_radii.dart';
import 'package:fit_tracker_app/core/theme/app_shadows.dart';
import 'package:fit_tracker_app/core/widgets/app_card.dart';
import 'package:fit_tracker_app/core/widgets/app_pill.dart';
import 'package:fit_tracker_app/features/workout/presentation/controllers/training_session_controller.dart';

class ReadyPhaseView extends GetView<TrainingSessionController> {
  const ReadyPhaseView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Obx(() {
      final ex = controller.currentEx;
      if (ex == null) return const SizedBox();

      final pivot = ex.pivot;
      if (pivot == null) return const SizedBox();
      final numWarmup = pivot.warmupSets;
      final numWorking = pivot.sets;
      final totalSets = pivot.totalSets;
      final currentExIdx = controller.currentExIdx.value;
      final currentSetIdx = controller.currentSetIdx.value;
      final isWarmup = controller.isCurrentSetWarmup;
      final isLastWorkingSet = !isWarmup && controller.isLastSet;

      final warmupNum = isWarmup ? currentSetIdx + 1 : 0;
      final workingNum = isWarmup ? 0 : currentSetIdx - numWarmup + 1;

      return Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              boxShadow: AppShadows.card(dark: isDark),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'EJERCICIO ${currentExIdx + 1} DE ${controller.exercises.length}',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary),
                          ),
                          if (numWarmup > 0)
                            AppPill(
                              label: isWarmup
                                  ? 'APROX. $warmupNum/$numWarmup'
                                  : 'EFECTIVA $workingNum/$numWorking',
                              color: isWarmup
                                  ? AppColors.warning
                                  : AppColors.primary,
                              fontSize: 11,
                            ),
                          if (controller.isInSuperset)
                            AppPill(
                              label: 'SUPERSERIE',
                              color: AppColors.supersetAccent,
                              icon: Icons.link_rounded,
                              fontSize: 11,
                            ),
                          if (isLastWorkingSet)
                            AppPill(
                              label: '¡ÚLTIMA!',
                              color: AppColors.warning,
                              icon: Icons.local_fire_department,
                              fontSize: 11,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ex.name,
                        style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.w900, height: 1.1),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (ex.muscleGroup != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(ex.muscleGroup!,
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 12)),
                        ),
                    ],
                  ),
                ),
                Divider(height: 1, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06)),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: CurvedAnimation(
                        parent: animation, curve: Curves.easeInOutCubic),
                    child: child,
                  ),
                  child: Padding(
                  key: ValueKey('ex${currentExIdx}s$currentSetIdx'),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 20),
                  child: Column(
                    children: [
                      // Set progress dots — warmup dots are smaller/orange
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(totalSets, (i) {
                          final isWarmupDot = i < numWarmup;
                          final isCurSet = i == currentSetIdx;
                          final isDoneSet =
                              controller.sets[currentExIdx][i]['done'] == true;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            height: isWarmupDot ? 7 : 10,
                            width: isCurSet ? 28 : (isWarmupDot ? 7 : 10),
                            decoration: BoxDecoration(
                              color: isDoneSet || isCurSet
                                  ? (isWarmupDot
                                      ? AppColors.warning.withValues(alpha: 0.65)
                                      : AppColors.primary)
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
                        isWarmup
                            ? 'APROX. $warmupNum DE $numWarmup'
                            : isLastWorkingSet
                                ? '¡ÚLTIMA SERIE!'
                                : 'SERIE $workingNum DE $numWorking',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isWarmup
                                ? AppColors.warning
                                : isLastWorkingSet
                                    ? AppColors.warning
                                    : Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      // Reps display
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            isWarmup
                                ? (pivot.warmupReps ?? '10-15')
                                : pivot.repsDisplay,
                            style: const TextStyle(
                                fontSize: 64, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(width: 8),
                          const Text('reps',
                              style: TextStyle(
                                  fontSize: 20, color: Colors.grey)),
                        ],
                      ),
                      if (isWarmup)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'PESO LIVIANO – SIN LLEGAR AL FALLO',
                            style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.warning,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          TextField(
                            controller: controller
                                .controllers[currentExIdx][currentSetIdx],
                            keyboardType:
                                const TextInputType.numberWithOptions(
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
                                borderSide: BorderSide(
                                    color: isWarmup
                                        ? AppColors.warning
                                        : AppColors.primary,
                                    width: 2),
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
                      const SizedBox(height: 8),
                      Builder(builder: (ctx) {
                        final lastW = controller.lastWeightFor(ex.id);
                        if (lastW != null) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.history_rounded,
                                    size: 12,
                                    color: AppColors.secondary
                                        .withValues(alpha: 0.7)),
                                const SizedBox(width: 5),
                                Text(
                                  'última sesión: ${lastW.toStringAsFixed(1)} kg',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.secondary
                                          .withValues(alpha: 0.8)),
                                ),
                              ],
                            ),
                          );
                        }
                        return Text(
                          'peso utilizado (opcional)',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.withValues(alpha: 0.6)),
                        );
                      }),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.completeSet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isWarmup
                                ? AppColors.warning
                                : AppColors.primary,
                            foregroundColor: isWarmup
                                ? Colors.white
                                : AppColors.onPrimary,
                            padding:
                                const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                controller.isNextStepSupersetTransition
                                    ? Icons.link_rounded
                                    : Icons.check,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isWarmup
                                    ? 'COMPLETAR APROX.'
                                    : controller.isNextStepSupersetTransition
                                        ? 'COMPLETAR → SUPERSERIE'
                                        : isLastWorkingSet
                                            ? 'COMPLETAR ÚLTIMA SERIE'
                                            : 'COMPLETAR SERIE',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: controller.canGoBack
                                ? controller.goBack
                                : null,
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
    return AppCard(
      padding: const EdgeInsets.all(16),
      bordered: true,
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
