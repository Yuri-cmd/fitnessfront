import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/stats_controller.dart';
import '../../../../core/theme/app_colors.dart';

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
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<StatsController>().loadAchievements();
      if (mounted) _animCtrl.forward();
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  String _resolveIcon(String? raw) {
    if (raw == null || raw.isEmpty) return '🏆';
    if (!raw.startsWith('fa-')) return raw;
    const map = {
      'fa-trophy': '🏆', 'fa-medal': '🥇', 'fa-star': '⭐',
      'fa-fire': '🔥', 'fa-bolt': '⚡', 'fa-dumbbell': '🏋️',
      'fa-heart': '❤️', 'fa-crown': '👑', 'fa-check': '✅',
      'fa-flag': '🚩', 'fa-running': '🏃', 'fa-bicycle': '🚴',
      'fa-swimmer': '🏊', 'fa-walking': '🚶', 'fa-weight': '⚖️',
      'fa-apple-alt': '🍎', 'fa-bed': '🛏️', 'fa-brain': '🧠',
      'fa-chart-line': '📈', 'fa-calendar-check': '📅',
    };
    for (final entry in map.entries) {
      if (raw.contains(entry.key)) return entry.value;
    }
    return '🏆';
  }

  String _formatDate(String raw) {
    try {
      final d = DateTime.parse(raw);
      const months = [
        '', 'ene', 'feb', 'mar', 'abr', 'may', 'jun',
        'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
      ];
      return '${d.day} ${months[d.month]} ${d.year}';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsController>();
    final count = stats.achievements.length;

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
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ]
            : null,
      ),
      body: CustomScrollView(
        slivers: [
          if (stats.achievements.isEmpty)
            SliverFillRemaining(child: _buildEmpty())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _buildAnimatedCard(stats.achievements[i], i, count),
                  childCount: count,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCard(dynamic ach, int index, int total) {
    final start = (index / total) * 0.6;
    final end = start + 0.4;
    final fade = CurvedAnimation(
      parent: _animCtrl,
      curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOut),
    );
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(fade);

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildCard(ach),
        ),
      ),
    );
  }

  Widget _buildCard(dynamic ach) {
    final earnedAt = ach['pivot']?['earned_at'];

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
              border: Border.all(color: Colors.amber.withValues(alpha: 0.35), width: 1.5),
            ),
            child: Center(
              child: Text(
                _resolveIcon(ach['icon']?.toString()),
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
                  (ach['name'] ?? '').toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                if (ach['description'] != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    ach['description'].toString(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
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
                        _formatDate(earnedAt.toString()),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.amber,
                          fontWeight: FontWeight.w600,
                        ),
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

  Widget _buildEmpty() {
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
                child: Text('🏆', style: TextStyle(fontSize: 56)),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Aún no tienes logros',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Text(
              'Completa rutinas, cumple tus metas\nde hidratación y supera tus récords\npara desbloquear medallas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                  Text(
                    'Ve a entrenar y empieza',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
