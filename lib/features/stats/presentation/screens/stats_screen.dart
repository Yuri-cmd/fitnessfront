import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/stats_controller.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatsController>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsController>();

    return Scaffold(
      appBar: AppBar(title: const Text('ESTADÍSTICAS')),
      body: stats.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => context.read<StatsController>().loadAll(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWeightSection(stats.weightHistory),
                    const SizedBox(height: 32),
                    _buildActivitySection(stats.activityHeatmap),
                    const SizedBox(height: 32),
                    _buildVolumeSection(stats.volumeByMuscle),
                    const SizedBox(height: 32),
                    _buildRecordsSection(stats.personalRecords),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      );

  Widget _card(Widget child) => Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(padding: const EdgeInsets.all(20), child: child),
      );

  Widget _emptyState(IconData icon, String msg) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.grey.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text(msg, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );

  // ─── Historial de Peso ────────────────────────────────────────────────────

  Widget _buildWeightSection(List<dynamic> history) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('HISTORIAL DE PESO'),
        _card(
          history.isEmpty
              ? _emptyState(Icons.scale, 'Sin registros de peso aún')
              : Column(
                  children: [
                    SizedBox(height: 200, child: _buildWeightChart(history)),
                    if (history.length >= 2) ...[
                      const SizedBox(height: 16),
                      _buildWeightTrend(history),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildWeightChart(List<dynamic> history) {
    final spots = history.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), (e.value['weight'] as num).toDouble());
    }).toList();

    final weights = spots.map((s) => s.y);
    final minY = weights.reduce((a, b) => a < b ? a : b) - 2;
    final maxY = weights.reduce((a, b) => a > b ? a : b) + 2;

    return LineChart(
      LineChartData(
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
              show: true,
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
          ),
        ],
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (v, _) => Text(
                '${v.toStringAsFixed(0)}kg',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (v, _) {
                final idx = v.toInt();
                if (idx < 0 || idx >= history.length) return const SizedBox();
                if (idx != 0 && idx != history.length ~/ 2 && idx != history.length - 1) {
                  return const SizedBox();
                }
                final date = DateTime.parse(history[idx]['created_at']);
                return Text(
                  DateFormat('dd/MM').format(date),
                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeightTrend(List<dynamic> history) {
    final last = (history.last['weight'] as num).toDouble();
    final prev = (history[history.length - 2]['weight'] as num).toDouble();
    final diff = last - prev;
    final isDown = diff < 0;
    final color = isDown ? AppColors.primary : AppColors.alert;

    return Row(
      children: [
        Icon(isDown ? Icons.trending_down : Icons.trending_up, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          '${isDown ? '-' : '+'}${diff.abs().toStringAsFixed(1)} kg desde el registro anterior',
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }

  // ─── Actividad (Heatmap) ──────────────────────────────────────────────────

  Widget _buildActivitySection(List<dynamic> activity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('ACTIVIDAD ESTE AÑO'),
        _card(_buildHeatmap(activity)),
      ],
    );
  }

  Widget _buildHeatmap(List<dynamic> activity) {
    final dateMap = <String, int>{};
    for (final item in activity) {
      dateMap[item['date'] as String] = (item['count'] as num).toInt();
    }
    final total = activity.fold(0, (s, i) => s + (i['count'] as num).toInt());

    const weeks = 16;
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: weeks * 7));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$total entrenamientos este año',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
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
              final isFuture = date.isAfter(now);
              if (isFuture) return const SizedBox();
              final dateStr = DateFormat('yyyy-MM-dd').format(date);
              final count = dateMap[dateStr] ?? 0;
              return Container(
                decoration: BoxDecoration(
                  color: count > 0
                    ? AppColors.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
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
            const Text('Menos ', style: TextStyle(fontSize: 10, color: Colors.grey)),
            Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 4),
            Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
            const Text(' Más', style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  // ─── Volumen por Músculo ──────────────────────────────────────────────────

  Widget _buildVolumeSection(List<dynamic> volume) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('VOLUMEN POR MÚSCULO (30 DÍAS)'),
        _card(
          volume.isEmpty
              ? _emptyState(
                  Icons.bar_chart,
                  'Registra entrenamientos con pesos\npara ver tu volumen por músculo',
                )
              : SizedBox(height: 200, child: _buildVolumeChart(volume)),
        ),
      ],
    );
  }

  Widget _buildVolumeChart(List<dynamic> volume) {
    final maxV = volume.fold(0.0, (m, v) {
      final vol = (v['total_volume'] as num).toDouble();
      return vol > m ? vol : m;
    });

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceEvenly,
        maxY: maxV * 1.25,
        barGroups: volume.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: (e.value['total_volume'] as num).toDouble(),
                color: AppColors.primary,
                width: 18,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          );
        }).toList(),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (v, _) {
                final idx = v.toInt();
                if (idx < 0 || idx >= volume.length) return const SizedBox();
                final muscle = volume[idx]['muscle_group']?.toString() ?? 'N/A';
                final label = muscle.length > 7 ? muscle.substring(0, 7) : muscle;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    label.toUpperCase(),
                    style: const TextStyle(fontSize: 8, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ─── Récords Personales ───────────────────────────────────────────────────

  Widget _buildRecordsSection(List<dynamic> records) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('RÉCORDS PERSONALES (TOP 10)'),
        _card(
          records.isEmpty
              ? _emptyState(
                  Icons.emoji_events,
                  'Registra entrenamientos con pesos\npara ver tus récords personales',
                )
              : Column(
                  children: records.asMap().entries.map((e) {
                    return _buildPrRow(e.key + 1, e.value);
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildPrRow(int rank, dynamic record) {
    final medalColors = [Colors.amber, Colors.grey.shade400, Colors.brown.shade300];
    final color = rank <= 3 ? medalColors[rank - 1] : AppColors.primary.withValues(alpha: 0.2);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record['name'] ?? 'Ejercicio', style: const TextStyle(fontWeight: FontWeight.w600)),
                if (record['muscle_group'] != null)
                  Text(
                    record['muscle_group'].toString().toUpperCase(),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
              ],
            ),
          ),
          Text(
            '${(record['max_weight'] as num).toStringAsFixed(1)} kg',
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
