import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';
import 'package:fit_tracker_app/features/water/presentation/controllers/water_controller.dart';

class WaterSection extends StatelessWidget {
  const WaterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<WaterController>();
    return Obx(() => Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.water_drop_rounded,
                      color: AppColors.secondary, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'HIDRATACIÓN HOY',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: AppColors.secondary,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${c.glasses.value}/${c.goalGlasses.value}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('vasos',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.secondary)),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: c.progress,
                  backgroundColor:
                      AppColors.secondary.withValues(alpha: 0.12),
                  color: c.goalReached
                      ? AppColors.primary
                      : AppColors.secondary,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(c.statusText,
                      style:
                          const TextStyle(fontSize: 11, color: Colors.grey)),
                  if (c.goalReached)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '✓ META',
                        style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed:
                          c.isLoading.value ? null : c.addGlass,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('VASO',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 11),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: (c.isLoading.value || c.glasses.value == 0)
                        ? null
                        : c.removeGlass,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      side: BorderSide(
                          color: Colors.grey.withValues(alpha: 0.35)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 11, horizontal: 16),
                    ),
                    child: const Icon(Icons.remove, size: 16),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
