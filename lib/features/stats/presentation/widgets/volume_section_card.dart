import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';
import 'package:fit_tracker_app/features/stats/data/models/stats_models.dart';
import 'package:fit_tracker_app/features/stats/presentation/controllers/stats_controller.dart';
import 'package:fit_tracker_app/features/stats/presentation/widgets/weight_section_card.dart' show SectionHeader, StatsCard, EmptyState;

class VolumeSectionCard extends StatelessWidget {
  const VolumeSectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<StatsController>();
    return Obx(() {
      final volume = c.volumeByMuscle.toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader('VOLUMEN POR MÚSCULO (30 DÍAS)'),
          StatsCard(
            volume.isEmpty
                ? EmptyState(Icons.bar_chart,
                    'Registra entrenamientos con pesos\npara ver tu volumen por músculo')
                : SizedBox(height: 200, child: _VolumeChart(volume: volume)),
          ),
        ],
      );
    });
  }
}

class _VolumeChart extends StatelessWidget {
  final List<VolumeByMuscle> volume;
  const _VolumeChart({required this.volume});

  @override
  Widget build(BuildContext context) {
    final maxV = volume.fold(0.0, (m, v) => v.totalVolume > m ? v.totalVolume : m);

    return BarChart(BarChartData(
      alignment: BarChartAlignment.spaceEvenly,
      maxY: maxV * 1.25,
      barGroups: volume.asMap().entries.map((e) {
        return BarChartGroupData(x: e.key, barRods: [
          BarChartRodData(
            toY: e.value.totalVolume,
            color: AppColors.primary,
            width: 18,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ]);
      }).toList(),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 36,
            getTitlesWidget: (v, _) {
              final idx = v.toInt();
              if (idx < 0 || idx >= volume.length) return const SizedBox();
              final muscle = volume[idx].muscleGroup;
              final label =
                  muscle.length > 7 ? muscle.substring(0, 7) : muscle;
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(label.toUpperCase(),
                    style:
                        const TextStyle(fontSize: 8, color: Colors.grey),
                    textAlign: TextAlign.center),
              );
            },
          ),
        ),
      ),
    ));
  }
}
