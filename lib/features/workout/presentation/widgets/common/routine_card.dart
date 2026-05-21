import 'package:flutter/material.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';
import 'package:fit_tracker_app/features/workout/data/models/routine_model.dart';

class RoutineCard extends StatelessWidget {
  final Routine routine;
  final bool isDoneToday;
  final VoidCallback onStart;
  final VoidCallback onEdit;

  const RoutineCard({
    super.key,
    required this.routine,
    required this.isDoneToday,
    required this.onStart,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor:
              isDoneToday ? AppColors.primary : Colors.grey.shade200,
          child: Icon(
            isDoneToday ? Icons.check : Icons.flash_on,
            color: isDoneToday ? Colors.white : Colors.grey,
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                routine.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            if (isDoneToday)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '¡HECHA!',
                  style: TextStyle(
                    color: AppColors.textTitle,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.edit_note_outlined,
                  color: AppColors.primary),
              onPressed: onEdit,
            ),
          ],
        ),
        subtitle: Text('${routine.exercises.length} EJERCICIOS'),
        children: [
          ...routine.exercises.map<Widget>(
            (ex) => ListTile(
              title: Text(ex.name),
              subtitle: Text(
                '${ex.pivot!.sets} series x ${ex.pivot!.reps} reps',
              ),
              trailing: const Icon(Icons.check_circle_outline),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: isDoneToday ? null : onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDoneToday ? Colors.grey.shade100 : AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(
                isDoneToday ? 'YA ENTRENADO HOY' : '¡A ENTRENAR!',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
