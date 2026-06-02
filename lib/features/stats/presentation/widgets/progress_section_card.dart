import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';
import 'package:fit_tracker_app/features/stats/data/models/stats_models.dart';
import 'package:fit_tracker_app/features/stats/presentation/controllers/stats_controller.dart';
import 'package:fit_tracker_app/features/stats/presentation/widgets/weight_section_card.dart';
import 'package:fit_tracker_app/features/workout/data/models/exercise_model.dart';
import 'package:fit_tracker_app/features/workout/data/models/routine_model.dart';
import 'package:fit_tracker_app/features/workout/presentation/controllers/workout_controller.dart';

class ProgressSectionCard extends StatelessWidget {
  const ProgressSectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<StatsController>();
    final wc = Get.find<WorkoutController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('PROGRESO POR EJERCICIO / RUTINA'),
        StatsCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TabToggle(controller: c),
              const SizedBox(height: 16),
              Obx(() => c.selectedProgressTab.value == 0
                  ? _ExerciseSelector(statsController: c, workoutController: wc)
                  : _RoutineSelector(statsController: c, workoutController: wc)),
              const SizedBox(height: 16),
              // Obx accede explícitamente a todos los observables para que se re-renderice
              Obx(() {
                final isLoading = c.isLoadingProgress.value;
                final tab = c.selectedProgressTab.value;
                final exerciseData = c.exerciseProgress.toList();
                final routineData = c.routineProgress.toList();
                final hasExSelection = c.selectedExerciseId.value != null;
                final hasRtSelection = c.selectedRoutineId.value != null;

                if (isLoading) {
                  return const SizedBox(
                    height: 160,
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                }
                if (tab == 0) {
                  return _ExerciseProgressChart(
                    data: exerciseData,
                    hasSelection: hasExSelection,
                  );
                } else {
                  return _RoutineProgressChart(
                    data: routineData,
                    hasSelection: hasRtSelection,
                  );
                }
              }),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Tab toggle ─────────────────────────────────────────────────────────────

class _TabToggle extends StatelessWidget {
  final StatsController controller;
  const _TabToggle({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tab = controller.selectedProgressTab.value;
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _TabButton(
              label: 'Por Ejercicio',
              selected: tab == 0,
              onTap: () {
                controller.selectedProgressTab.value = 0;
                controller.exerciseProgress.clear();
              },
            ),
            _TabButton(
              label: 'Por Rutina',
              selected: tab == 1,
              onTap: () {
                controller.selectedProgressTab.value = 1;
                controller.routineProgress.clear();
              },
            ),
          ],
        ),
      );
    });
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: selected ? Colors.white : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Selectors ──────────────────────────────────────────────────────────────

class _ExerciseSelector extends StatelessWidget {
  final StatsController statsController;
  final WorkoutController workoutController;
  const _ExerciseSelector({required this.statsController, required this.workoutController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final exercises = workoutController.availableExercises.toList();
      if (exercises.isEmpty) {
        workoutController.loadExercises();
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      }
      final selectedId = statsController.selectedExerciseId.value;
      final selected = exercises.firstWhereOrNull((e) => e.id == selectedId);
      return _DropdownSelector<Exercise>(
        hint: 'Selecciona un ejercicio',
        items: exercises,
        selected: selected,
        label: (e) => e.name,
        subtitle: (e) => e.muscleGroup ?? '',
        onChanged: (e) => statsController.loadProgressByExercise(e.id),
      );
    });
  }
}

class _RoutineSelector extends StatelessWidget {
  final StatsController statsController;
  final WorkoutController workoutController;
  const _RoutineSelector({required this.statsController, required this.workoutController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final routines = workoutController.routines.toList();
      if (routines.isEmpty) {
        return const EmptyState(Icons.fitness_center, 'No tienes rutinas creadas');
      }
      final selectedId = statsController.selectedRoutineId.value;
      final selected = routines.firstWhereOrNull((r) => r.id == selectedId);
      return _DropdownSelector<Routine>(
        hint: 'Selecciona una rutina',
        items: routines,
        selected: selected,
        label: (r) => r.name,
        subtitle: (r) => '${r.exercises.length} ejercicios',
        onChanged: (r) => statsController.loadProgressByRoutine(r.id),
      );
    });
  }
}

class _DropdownSelector<T> extends StatelessWidget {
  final String hint;
  final List<T> items;
  final T? selected;
  final String Function(T) label;
  final String Function(T) subtitle;
  final void Function(T) onChanged;

  const _DropdownSelector({
    required this.hint,
    required this.items,
    required this.selected,
    required this.label,
    required this.subtitle,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<T>(
        isExpanded: true,
        underline: const SizedBox(),
        hint: Text(hint, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        value: selected,
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label(item),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
                if (subtitle(item).isNotEmpty)
                  Text(subtitle(item),
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          );
        }).toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

// ── Charts ─────────────────────────────────────────────────────────────────

class _ExerciseProgressChart extends StatelessWidget {
  final List<ExerciseProgressPoint> data;
  final bool hasSelection;
  const _ExerciseProgressChart({required this.data, required this.hasSelection});

  @override
  Widget build(BuildContext context) {
    if (!hasSelection) return const SizedBox.shrink();
    if (data.isEmpty) {
      return const EmptyState(Icons.bar_chart, 'Sin sesiones registradas para este ejercicio');
    }

    final weights = data.map((d) => d.maxWeight).toList();
    final best = weights.reduce((a, b) => a > b ? a : b);
    final minW = weights.reduce((a, b) => a < b ? a : b);
    final first = data.first.maxWeight;
    final improvement = best - first;
    final spread = (best - minW).abs();
    final minY = (minW - spread * 0.2 - 2).clamp(0.0, double.infinity);
    final maxY = best + spread * 0.2 + 2;

    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.maxWeight);
    }).toList();

    return Column(
      children: [
        SizedBox(height: 180, child: _buildChart(spots, minY, maxY, data, AppColors.primary)),
        const SizedBox(height: 12),
        _SummaryRow(items: [
          _SummaryItem('Mejor peso', '${best.toStringAsFixed(1)} kg', Icons.emoji_events),
          _SummaryItem('Sesiones', '${data.length}', Icons.calendar_today),
          _SummaryItem(
            'Mejora',
            '${improvement >= 0 ? '+' : ''}${improvement.toStringAsFixed(1)} kg',
            improvement >= 0 ? Icons.trending_up : Icons.trending_down,
            color: improvement >= 0 ? AppColors.primary : AppColors.alert,
          ),
        ]),
      ],
    );
  }
}

class _RoutineProgressChart extends StatelessWidget {
  final List<RoutineProgressPoint> data;
  final bool hasSelection;
  const _RoutineProgressChart({required this.data, required this.hasSelection});

  @override
  Widget build(BuildContext context) {
    if (!hasSelection) return const SizedBox.shrink();
    if (data.isEmpty) {
      return const EmptyState(Icons.bar_chart, 'Sin sesiones registradas para esta rutina');
    }

    final volumes = data.map((d) => d.totalVolume).toList();
    final best = volumes.reduce((a, b) => a > b ? a : b);
    final minV = volumes.reduce((a, b) => a < b ? a : b);
    final first = data.first.totalVolume;
    final spread = (best - minV).abs();
    final minY = (minV - spread * 0.2).clamp(0.0, double.infinity);
    final maxY = best > 0 ? best + spread * 0.2 + best * 0.05 : 10.0;
    final pct = first > 0 ? (best - first) / first * 100 : 0.0;

    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.totalVolume);
    }).toList();

    return Column(
      children: [
        SizedBox(height: 180, child: _buildChart(spots, minY, maxY, data, Colors.deepPurple)),
        const SizedBox(height: 12),
        _SummaryRow(items: [
          _SummaryItem(
            'Mejor vol.',
            best >= 1000 ? '${(best / 1000).toStringAsFixed(1)}k kg' : '${best.toStringAsFixed(0)} kg',
            Icons.emoji_events,
          ),
          _SummaryItem('Sesiones', '${data.length}', Icons.calendar_today),
          _SummaryItem(
            'Mejora',
            '${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(0)}%',
            pct >= 0 ? Icons.trending_up : Icons.trending_down,
            color: pct >= 0 ? AppColors.primary : AppColors.alert,
          ),
        ]),
      ],
    );
  }
}

Widget _buildChart(
  List<FlSpot> spots,
  double minY,
  double maxY,
  List<dynamic> dataItems,
  Color color,
) {
  // Garantizar que minY < maxY para evitar crash de fl_chart
  if (maxY <= minY) maxY = minY + 1;

  return LineChart(LineChartData(
    minY: minY,
    maxY: maxY,
    lineBarsData: [
      LineChartBarData(
        spots: spots,
        isCurved: spots.length > 2,
        color: color,
        barWidth: 3,
        dotData: FlDotData(
          show: true,
          getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
            radius: 4,
            color: color,
            strokeWidth: 2,
            strokeColor: Colors.white,
          ),
        ),
        belowBarData:
            BarAreaData(show: true, color: color.withValues(alpha: 0.08)),
      ),
    ],
    gridData: const FlGridData(show: false),
    borderData: FlBorderData(show: false),
    titlesData: FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 52,
          getTitlesWidget: (v, _) {
            final label = v >= 1000
                ? '${(v / 1000).toStringAsFixed(1)}k'
                : v.toStringAsFixed(0);
            return Text(label,
                style: const TextStyle(fontSize: 10, color: Colors.grey));
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          getTitlesWidget: (v, _) {
            final idx = v.toInt();
            if (idx < 0 || idx >= dataItems.length) return const SizedBox();
            if (idx != 0 &&
                idx != dataItems.length ~/ 2 &&
                idx != dataItems.length - 1) {
              return const SizedBox();
            }
            try {
              final raw = (dataItems[idx] as dynamic).date as String;
              final d = DateTime.parse(raw);
              return Text(DateFormat('dd/MM').format(d),
                  style: const TextStyle(fontSize: 9, color: Colors.grey));
            } catch (_) {
              return const SizedBox();
            }
          },
        ),
      ),
    ),
  ));
}

// ── Summary ────────────────────────────────────────────────────────────────

class _SummaryItem {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  const _SummaryItem(this.label, this.value, this.icon, {this.color});
}

class _SummaryRow extends StatelessWidget {
  final List<_SummaryItem> items;
  const _SummaryRow({required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items.map((item) {
        final color = item.color ?? AppColors.primary;
        return Expanded(
          child: Column(
            children: [
              Icon(item.icon, size: 18, color: color),
              const SizedBox(height: 4),
              Text(item.value,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: color)),
              Text(item.label,
                  style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
