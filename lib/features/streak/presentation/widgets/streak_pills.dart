import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_tracker_app/features/streak/presentation/controllers/streak_controller.dart';

class StreakPills extends StatelessWidget {
  const StreakPills({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<StreakController>();
    return Obx(() => Row(
          children: [
            Flexible(child: _Pill('🔥', c.workoutStreak.value, 'entreno')),
            const SizedBox(width: 8),
            Flexible(child: _Pill('💧', c.waterStreak.value, 'agua')),
          ],
        ));
  }
}

class _Pill extends StatelessWidget {
  final String emoji;
  final int days;
  final String label;

  const _Pill(this.emoji, this.days, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              '$days ${days == 1 ? 'día' : 'días'} de $label',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
