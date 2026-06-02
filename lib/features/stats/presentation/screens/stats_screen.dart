import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_tracker_app/features/stats/presentation/controllers/stats_controller.dart';
import 'package:fit_tracker_app/features/stats/presentation/widgets/weight_section_card.dart';
import 'package:fit_tracker_app/features/stats/presentation/widgets/activity_heatmap_card.dart';
import 'package:fit_tracker_app/features/stats/presentation/widgets/volume_section_card.dart';
import 'package:fit_tracker_app/features/stats/presentation/widgets/personal_records_card.dart';
import 'package:fit_tracker_app/features/stats/presentation/widgets/progress_section_card.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<StatsController>();
    return Scaffold(
      appBar: AppBar(title: const Text('ESTADÍSTICAS')),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: c.loadAll,
          child: const SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WeightSectionCard(),
                SizedBox(height: 32),
                ActivityHeatmapCard(),
                SizedBox(height: 32),
                VolumeSectionCard(),
                SizedBox(height: 32),
                PersonalRecordsCard(),
                SizedBox(height: 32),
                ProgressSectionCard(),
                SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }
}
