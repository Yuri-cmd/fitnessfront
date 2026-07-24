import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';
import 'package:fit_tracker_app/core/theme/app_radii.dart';
import 'package:fit_tracker_app/features/metrics/presentation/controllers/fitness_controller.dart';

class BmiSummaryCard extends StatelessWidget {
  const BmiSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<FitnessController>();
    return Obx(() => Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MetricItem('PESO ACTUAL',
                  c.weight.value != null ? '${c.weight.value} kg' : '?'),
              _MetricItem(
                  'IMC', c.bmi.value?.toStringAsFixed(1) ?? '--'),
              _MetricItem(
                  'META',
                  c.weightToLose > 0
                      ? '-${c.weightToLose.toStringAsFixed(1)} kg'
                      : 'OK'),
            ],
          ),
        ));
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  const _MetricItem(this.label, this.value);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary)),
        ],
      );
}
