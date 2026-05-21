import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';
import 'package:fit_tracker_app/features/stats/data/models/stats_models.dart';
import 'package:fit_tracker_app/features/stats/presentation/controllers/stats_controller.dart';
import 'package:fit_tracker_app/features/stats/presentation/widgets/weight_section_card.dart' show SectionHeader, StatsCard;

class ActivityHeatmapCard extends StatelessWidget {
  const ActivityHeatmapCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<StatsController>();
    return Obx(() {
      final activity = c.activityHeatmap.toList();
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader('ACTIVIDAD ESTE AÑO'),
            StatsCard(_HeatmapContent(activity: activity)),
          ],
        );
    });
  }
}

class _HeatmapContent extends StatelessWidget {
  final List<ActivityDay> activity;
  const _HeatmapContent({required this.activity});

  @override
  Widget build(BuildContext context) {
    final dateMap = <String, int>{
      for (final item in activity) item.date: item.count,
    };
    final total = activity.fold(0, (s, i) => s + i.count);

    const weeks = 16;
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: weeks * 7));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$total entrenamientos este año',
            style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(
          height: 84,
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 3,
              mainAxisSpacing: 3,
            ),
            itemCount: weeks * 7,
            itemBuilder: (context, index) {
              final date = startDate.add(Duration(days: index));
              if (date.isAfter(now)) return const SizedBox();
              final count =
                  dateMap[DateFormat('yyyy-MM-dd').format(date)] ?? 0;
              return Container(
                decoration: BoxDecoration(
                  color: count > 0
                      ? AppColors.primary
                      : Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text('Menos ',
                style: TextStyle(fontSize: 10, color: Colors.grey)),
            Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 4),
            Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2))),
            const Text(' Más',
                style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ],
    );
  }
}
