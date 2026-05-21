import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';
import 'package:fit_tracker_app/features/stats/data/models/stats_models.dart';
import 'package:fit_tracker_app/features/stats/presentation/controllers/stats_controller.dart';
import 'package:fit_tracker_app/features/stats/presentation/widgets/achievement_card.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    Get.find<StatsController>().loadAchievements().then((_) {
      if (mounted) _animCtrl.forward();
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<StatsController>();
    return Obx(() {
      final count = c.achievements.length;
      return Scaffold(
        appBar: AppBar(
          title: const Text('MIS LOGROS'),
          actions: count > 0
              ? [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Center(
                      child: Text(
                        '$count ${count == 1 ? 'logro' : 'logros'}',
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                    ),
                  ),
                ]
              : null,
        ),
        body: CustomScrollView(
          slivers: [
            if (count == 0)
              SliverFillRemaining(child: _AchievementsEmpty())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _AnimatedCard(
                      achievement: c.achievements[i],
                      index: i,
                      total: count,
                      ctrl: _animCtrl,
                    ),
                    childCount: count,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _AnimatedCard extends StatelessWidget {
  final Achievement achievement;
  final int index;
  final int total;
  final AnimationController ctrl;

  const _AnimatedCard({
    required this.achievement,
    required this.index,
    required this.total,
    required this.ctrl,
  });

  @override
  Widget build(BuildContext context) {
    final start = (index / total) * 0.6;
    final end = (start + 0.4).clamp(0.0, 1.0);
    final fade = CurvedAnimation(
        parent: ctrl, curve: Interval(start, end, curve: Curves.easeOut));
    final slide = Tween<Offset>(
        begin: const Offset(0, 0.3), end: Offset.zero).animate(fade);

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AchievementCard(achievement: achievement),
        ),
      ),
    );
  }
}

class _AchievementsEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.amber.withValues(alpha: 0.08),
                border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.25), width: 2),
              ),
              child: const Center(
                  child: Text('🏆', style: TextStyle(fontSize: 56))),
            ),
            const SizedBox(height: 28),
            const Text('Aún no tienes logros',
                style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Text(
              'Completa rutinas, cumple tus metas\nde hidratación y supera tus récords\npara desbloquear medallas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fitness_center_rounded,
                      size: 16, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Ve a entrenar y empieza',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
