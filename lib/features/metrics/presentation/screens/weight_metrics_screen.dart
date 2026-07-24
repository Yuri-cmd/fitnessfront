import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';
import 'package:fit_tracker_app/core/theme/app_radii.dart';
import 'package:fit_tracker_app/core/widgets/app_card.dart';
import 'package:fit_tracker_app/features/metrics/presentation/controllers/fitness_controller.dart';
import 'package:fit_tracker_app/features/metrics/presentation/widgets/bmi_summary_card.dart';

class WeightMetricsScreen extends StatelessWidget {
  const WeightMetricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CONTROL DE PESO'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note, color: AppColors.primary),
            onPressed: () => _showUpdateDialog(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_weight',
        onPressed: () => _showAddWeightDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            BmiSummaryCard(),
            SizedBox(height: 32),
            Text('PROGRESO HISTÓRICO',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 16),
            _WeightGraph(),
            SizedBox(height: 32),
            Text('TODOS LOS REGISTROS',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 8),
            _WeightHistoryList(),
          ],
        ),
      ),
    );
  }

  void _showAddWeightDialog(BuildContext context) {
    final ctrl = TextEditingController();
    Get.dialog(AlertDialog(
      title: const Text('NUEVO REGISTRO'),
      content: TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(hintText: 'Peso en kg'),
        autofocus: true,
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('CANCELAR')),
        ElevatedButton(
          onPressed: () {
            final w = double.tryParse(ctrl.text);
            if (w != null) Get.find<FitnessController>().addWeight(w);
            Get.back();
          },
          child: const Text('GUARDAR'),
        ),
      ],
    ));
  }

  void _showUpdateDialog(BuildContext context) {
    final c = Get.find<FitnessController>();
    final heightCtrl =
        TextEditingController(text: c.height.value?.toString());
    final weightCtrl =
        TextEditingController(text: c.weight.value?.toString());
    Get.dialog(AlertDialog(
      title: const Text('ACTUALIZAR DATOS'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: heightCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Talla (cm)'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: weightCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Peso Inicial (kg)'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('CANCELAR')),
        ElevatedButton(
          onPressed: () {
            final h = double.tryParse(heightCtrl.text);
            final w = double.tryParse(weightCtrl.text);
            if (h != null && w != null) {
              c.updateProfileMetrics(h, w);
            }
            Get.back();
          },
          child: const Text('GUARDAR'),
        ),
      ],
    ));
  }
}

class _WeightGraph extends StatelessWidget {
  const _WeightGraph();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<FitnessController>();
    return Obx(() {
      if (c.weightLogs.isEmpty) {
        return const Center(child: Text('No hay datos suficientes'));
      }
      return AppCard(
        radius: AppRadii.lg,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: SizedBox(
          height: 250 - 48,
          child: LineChart(LineChartData(
          gridData: const FlGridData(
              show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
                sideTitles:
                    SideTitles(showTitles: true, reservedSize: 40)),
            bottomTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: c.weightLogs.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.weight);
              }).toList().reversed.toList(),
              isCurved: true,
              color: AppColors.primary,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.primary.withValues(alpha: 0.2)),
            ),
          ],
        )),
        ),
      );
    });
  }
}

class _WeightHistoryList extends StatelessWidget {
  const _WeightHistoryList();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<FitnessController>();
    return Obx(() => ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: c.weightLogs.length,
          itemBuilder: (_, i) {
            final log = c.weightLogs[i];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.scale_outlined,
                    color: AppColors.primary),
                title: Text('${log.weight} kg',
                    style:
                        const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                    log.createdAt.toIso8601String().split('T')[0]),
              ),
            );
          },
        ));
  }
}
