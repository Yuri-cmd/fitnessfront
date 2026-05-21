import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';
import 'package:fit_tracker_app/features/stats/data/models/stats_models.dart';
import 'package:fit_tracker_app/features/stats/presentation/controllers/stats_controller.dart';
import 'package:fit_tracker_app/features/stats/presentation/widgets/weight_section_card.dart' show SectionHeader, StatsCard, EmptyState;

class PersonalRecordsCard extends StatelessWidget {
  const PersonalRecordsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<StatsController>();
    return Obx(() {
      final records = c.personalRecords.toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader('RÉCORDS PERSONALES (TOP 10)'),
          StatsCard(
            records.isEmpty
                ? EmptyState(Icons.emoji_events,
                    'Registra entrenamientos con pesos\npara ver tus récords personales')
                : Column(
                    children: records
                        .asMap()
                        .entries
                        .map((e) => _PrRow(rank: e.key + 1, record: e.value))
                        .toList(),
                  ),
          ),
        ],
      );
    });
  }
}

class _PrRow extends StatelessWidget {
  final int rank;
  final PersonalRecord record;

  const _PrRow({required this.rank, required this.record});

  @override
  Widget build(BuildContext context) {
    final medalColors = [
      Colors.amber,
      Colors.grey.shade400,
      Colors.brown.shade300
    ];
    final color = rank <= 3
        ? medalColors[rank - 1]
        : AppColors.primary.withValues(alpha: 0.2);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Center(
              child: Text('$rank',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                if (record.muscleGroup != null)
                  Text(record.muscleGroup!.toUpperCase(),
                      style:
                          const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
          Text(
            '${record.maxWeight.toStringAsFixed(1)} kg',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                fontSize: 15),
          ),
        ],
      ),
    );
  }
}
