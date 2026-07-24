import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';
import 'package:fit_tracker_app/core/theme/app_radii.dart';
import 'package:fit_tracker_app/features/stats/data/models/stats_models.dart';
import 'package:fit_tracker_app/features/stats/presentation/controllers/stats_controller.dart';

class WeightSectionCard extends StatelessWidget {
  const WeightSectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<StatsController>();
    return Obx(() {
      final history = c.weightHistory.toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader('HISTORIAL DE PESO'),
          StatsCard(
            history.isEmpty
                ? EmptyState(Icons.scale, 'Sin registros de peso aún')
                : Column(
                    children: [
                      SizedBox(
                          height: 200, child: _WeightChart(history: history)),
                      if (history.length >= 2) ...[
                        const SizedBox(height: 16),
                        _WeightTrend(history: history),
                      ],
                    ],
                  ),
          ),
        ],
      );
    });
  }
}

class _WeightChart extends StatelessWidget {
  final List<WeightHistory> history;
  const _WeightChart({required this.history});

  @override
  Widget build(BuildContext context) {
    final spots = history.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.weight);
    }).toList();
    final weights = spots.map((s) => s.y);
    final minY = weights.reduce((a, b) => a < b ? a : b) - 2;
    final maxY = weights.reduce((a, b) => a > b ? a : b) + 2;

    return LineChart(LineChartData(
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppColors.primary,
          barWidth: 3,
          dotData: FlDotData(
            show: true,
            getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
              radius: 4,
              color: AppColors.primary,
              strokeWidth: 2,
              strokeColor: Colors.white,
            ),
          ),
          belowBarData: BarAreaData(
              show: true, color: AppColors.primary.withValues(alpha: 0.08)),
        ),
      ],
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 44,
            getTitlesWidget: (v, _) => Text('${v.toStringAsFixed(0)}kg',
                style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            getTitlesWidget: (v, _) {
              final idx = v.toInt();
              if (idx < 0 || idx >= history.length) return const SizedBox();
              if (idx != 0 &&
                  idx != history.length ~/ 2 &&
                  idx != history.length - 1) {
                return const SizedBox();
              }
              return Text(
                  DateFormat('dd/MM').format(history[idx].createdAt),
                  style: const TextStyle(fontSize: 9, color: Colors.grey));
            },
          ),
        ),
      ),
    ));
  }
}

class _WeightTrend extends StatelessWidget {
  final List<WeightHistory> history;
  const _WeightTrend({required this.history});

  @override
  Widget build(BuildContext context) {
    final last = history.last.weight;
    final prev = history[history.length - 2].weight;
    final diff = last - prev;
    final isDown = diff < 0;
    final color = isDown ? AppColors.primary : AppColors.alert;

    return Row(
      children: [
        Icon(isDown ? Icons.trending_down : Icons.trending_up,
            color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          '${isDown ? '-' : '+'}${diff.abs().toStringAsFixed(1)} kg desde el registro anterior',
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }
}

// ── Shared helpers ─────────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 12)),
      );
}

class StatsCard extends StatelessWidget {
  final Widget child;
  const StatsCard(this.child, {super.key});

  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg)),
        child: Padding(padding: const EdgeInsets.all(20), child: child),
      );
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String msg;
  const EmptyState(this.icon, this.msg, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.grey.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text(msg,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
}
