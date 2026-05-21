import 'package:flutter/material.dart';
import 'package:fit_tracker_app/features/stats/data/models/stats_models.dart';
import 'package:fit_tracker_app/features/stats/presentation/controllers/stats_controller.dart';

class AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const AchievementCard({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    final earnedAt = achievement.pivot?.earnedAt;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.amber.withValues(alpha: 0.35), width: 1.5),
            ),
            child: Center(
              child: Text(
                StatsController.resolveIcon(achievement.icon),
                style: const TextStyle(fontSize: 30),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                if (achievement.description != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    achievement.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12,
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
                if (earnedAt != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          size: 11, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        StatsController.formatDate(earnedAt.toIso8601String()),
                        style: const TextStyle(
                            fontSize: 11,
                            color: Colors.amber,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.verified_rounded, color: Colors.amber, size: 22),
        ],
      ),
    );
  }
}
