import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';
import 'package:fit_tracker_app/features/workout/data/models/exercise_model.dart';
import 'package:fit_tracker_app/features/workout/presentation/controllers/training_session_controller.dart';

class ReorderSheet extends GetView<TrainingSessionController> {
  const ReorderSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final exercises = controller.exerciseOrder;
      final lockedUntil = controller.currentExIdx.value;

      // Map supersetGroup → ordinal label (SS 1, SS 2…)
      final seenGroups = <int>[];
      for (final ex in exercises) {
        final g = ex.pivot?.supersetGroup;
        if (g != null && !seenGroups.contains(g)) seenGroups.add(g);
      }
      final ssMap = {for (var i = 0; i < seenGroups.length; i++) seenGroups[i]: i + 1};

      return Container(
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Reordenar ejercicios',
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('LISTO',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 340,
                  child: ReorderableListView.builder(
                    itemCount: exercises.length,
                    onReorder: (oldIdx, newIdx) {
                      if (oldIdx < lockedUntil ||
                          newIdx <= lockedUntil - 1) {
                        return;
                      }
                      final adjustedNew =
                          newIdx > oldIdx ? newIdx - 1 : newIdx;
                      controller.reorderExercises(oldIdx, adjustedNew);
                    },
                    itemBuilder: (ctx, i) {
                      final Exercise ex = exercises[i];
                      final locked = i < lockedUntil;
                      final group = ex.pivot?.supersetGroup;
                      final ssOrdinal = group != null ? ssMap[group] : null;

                      final isFirstInGroup = group != null &&
                          (i == 0 ||
                              exercises[i - 1].pivot?.supersetGroup != group);
                      final isLastInGroup = group != null &&
                          (i == exercises.length - 1 ||
                              exercises[i + 1].pivot?.supersetGroup != group);

                      return Column(
                        key: ValueKey(ex.id),
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SS group header — only on first exercise of the group
                          if (isFirstInGroup)
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(4, 8, 0, 2),
                              child: Row(
                                children: [
                                  const Icon(Icons.link_rounded,
                                      size: 11,
                                      color: AppColors.supersetAccent),
                                  const SizedBox(width: 4),
                                  Text(
                                    'SS $ssOrdinal',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.supersetAccent,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Left accent bar for superset exercises
                                if (group != null)
                                  Container(
                                    width: 3,
                                    margin: EdgeInsets.only(
                                      left: 4,
                                      bottom: isLastInGroup ? 4 : 0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.supersetAccent
                                          .withValues(alpha: 0.35),
                                      borderRadius: isLastInGroup
                                          ? const BorderRadius.vertical(
                                              bottom: Radius.circular(3))
                                          : BorderRadius.zero,
                                    ),
                                  )
                                else
                                  const SizedBox(width: 7),
                                Expanded(
                                  child: ListTile(
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 10),
                                    leading: CircleAvatar(
                                      radius: 14,
                                      backgroundColor: locked
                                          ? AppColors.primary
                                          : AppColors.primary
                                              .withValues(alpha: 0.12),
                                      child: locked
                                          ? const Icon(Icons.check,
                                              size: 14,
                                              color: Colors.white)
                                          : Text('${i + 1}',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primary)),
                                    ),
                                    title: Text(ex.name,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color:
                                                locked ? Colors.grey : null)),
                                    subtitle: Text(
                                      '${ex.pivot!.sets} series × ${ex.pivot!.reps} reps',
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    trailing: locked
                                        ? null
                                        : const Icon(Icons.drag_handle,
                                            color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
