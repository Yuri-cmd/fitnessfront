import 'package:flutter/material.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';
import 'package:fit_tracker_app/features/workout/data/models/goal_model.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final ValueChanged<int> onDelete;

  const GoalCard({
    super.key,
    required this.goal,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isWeekly = goal.type == 'workouts_weekly';
    final typeLabel = isWeekly ? 'Entrenamientos Semanales' : 'Peso Objetivo';
    final target = goal.targetValue;
    final current = goal.currentValue;
    final progress = isWeekly
        ? (current / target).clamp(0.0, 1.0)
        : 0.5;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  typeLabel.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.alert, size: 20),
                  onPressed: () => onDelete(goal.id),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isWeekly ? '$target Sesiones' : '$target kg',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              color: AppColors.primary,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Actual: $current',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
