import 'package:flutter/material.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';
import 'package:fit_tracker_app/features/workout/data/models/routine_model.dart';

class RoutineCard extends StatelessWidget {
  final Routine routine;
  final bool isDoneToday;
  final bool isDoneThisWeek;
  final VoidCallback onStart;
  final VoidCallback onEdit;
  final VoidCallback? onArchive;
  final VoidCallback? onUnarchive;

  const RoutineCard({
    super.key,
    required this.routine,
    required this.isDoneToday,
    this.isDoneThisWeek = false,
    required this.onStart,
    required this.onEdit,
    this.onArchive,
    this.onUnarchive,
  });

  @override
  Widget build(BuildContext context) {
    final archived = routine.isArchived;
    final doneWeek = !archived && isDoneThisWeek;
    final doneToday = !archived && isDoneToday;

    Color avatarBg;
    Color avatarIconColor;
    IconData avatarIcon;
    if (archived) {
      avatarBg = Colors.grey.shade200;
      avatarIconColor = Colors.grey;
      avatarIcon = Icons.archive_outlined;
    } else if (doneToday) {
      avatarBg = AppColors.primary.withValues(alpha: 0.15);
      avatarIconColor = AppColors.primary;
      avatarIcon = Icons.check_rounded;
    } else if (doneWeek) {
      avatarBg = Colors.grey.shade200;
      avatarIconColor = Colors.grey.shade500;
      avatarIcon = Icons.check_rounded;
    } else {
      avatarBg = Colors.grey.shade100;
      avatarIconColor = Colors.grey.shade600;
      avatarIcon = Icons.flash_on_rounded;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        childrenPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: avatarBg,
          child: Icon(avatarIcon, size: 20, color: avatarIconColor),
        ),
        title: Text(
          routine.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: archived
                ? Colors.grey
                : doneWeek && !doneToday
                    ? Colors.grey.shade500
                    : null,
            height: 1.2,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Row(
            children: [
              Text(
                '${routine.exercises.length} ejercicios',
                style: TextStyle(
                  fontSize: 11,
                  color: archived ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              if (doneToday) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '¡HECHA HOY!',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                ),
              ] else if (doneWeek) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'HECHA ESTA SEMANA',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (archived)
              _SmallIconButton(
                icon: Icons.unarchive_outlined,
                color: AppColors.primary,
                tooltip: 'Restaurar',
                onPressed: onUnarchive,
              )
            else ...[
              _SmallIconButton(
                icon: Icons.archive_outlined,
                color: Colors.grey,
                tooltip: 'Archivar',
                onPressed: onArchive,
              ),
              _SmallIconButton(
                icon: Icons.edit_outlined,
                color: AppColors.primary,
                tooltip: 'Editar',
                onPressed: onEdit,
              ),
            ],
            const Icon(Icons.expand_more, size: 20, color: Colors.grey),
          ],
        ),
        children: [
          const Divider(height: 1),
          ..._buildExerciseList(),
          if (!archived)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
              child: ElevatedButton(
                onPressed: isDoneToday ? null : onStart,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDoneToday ? Colors.grey.shade100 : AppColors.primary,
                  minimumSize: const Size(double.infinity, 46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  isDoneToday ? 'YA ENTRENADO HOY' : '¡A ENTRENAR!',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildExerciseList() {
    return routine.exercises.map<Widget>((ex) {
      final pivot = ex.pivot!;
      final warmupLabel =
          pivot.warmupSets > 0 ? '${pivot.warmupSets} aprox. + ' : '';
      final detail =
          '$warmupLabel${pivot.sets} series × ${pivot.repsDisplay} reps';
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              width: 6,
              height: 6,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ex.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    detail,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

class _SmallIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback? onPressed;

  const _SmallIconButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}
