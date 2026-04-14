import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/fitness_controller.dart';

class WeightMetricsScreen extends StatelessWidget {
  const WeightMetricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fitness = context.watch<FitnessController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('CONTROL DE PESO'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note, color: AppColors.primary),
            onPressed: () => _showUpdateProfileDialog(context, fitness),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddWeightDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBmiSummary(fitness),
            const SizedBox(height: 32),
            const Text(
              'PROGRESO HISTÓRICO',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildDetailedGraph(fitness),
            const SizedBox(height: 32),
            const Text(
              'TODOS LOS REGISTROS',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            _buildHistoryList(fitness),
          ],
        ),
      ),
    );
  }

  Widget _buildBmiSummary(FitnessController fitness) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetricItem('PESO ACTUAL', '${fitness.weight ?? "?"} kg'),
          _buildMetricItem('IMC', fitness.bmi?.toStringAsFixed(1) ?? '--'),
          _buildMetricItem('META', fitness.weightToLose > 0 ? '-${fitness.weightToLose.toStringAsFixed(1)} kg' : 'OK'),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
      ],
    );
  }

  Widget _buildDetailedGraph(FitnessController fitness) {
    if (fitness.weightLogs.isEmpty) return const Center(child: Text('No hay datos suficientes'));

    return Container(
      height: 250,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: fitness.weightLogs.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), double.tryParse(e.value['weight'].toString()) ?? 0);
              }).toList().reversed.toList(),
              isCurved: true,
              color: AppColors.primary,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(FitnessController fitness) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: fitness.weightLogs.length,
      itemBuilder: (context, index) {
        final log = fitness.weightLogs[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.scale_outlined, color: AppColors.primary),
            title: Text('${log['weight']} kg', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(log['created_at'].toString().split('T')[0]),
          ),
        );
      },
    );
  }

  void _showAddWeightDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('NUEVO REGISTRO'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Peso en kg'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () {
              final w = double.tryParse(controller.text);
              if (w != null) context.read<FitnessController>().addWeight(w);
              Navigator.pop(context);
            },
            child: const Text('GUARDAR'),
          ),
        ],
      ),
    );
  }

  void _showUpdateProfileDialog(BuildContext context, FitnessController fitness) {
    final heightController = TextEditingController(text: fitness.height?.toString());
    final weightController = TextEditingController(text: fitness.weight?.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ACTUALIZAR DATOS'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Talla (cm)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Peso Inicial (kg)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () {
              final h = double.tryParse(heightController.text);
              final w = double.tryParse(weightController.text);
              if (h != null && w != null) {
                context.read<FitnessController>().updateProfileMetrics(h, w);
              }
              Navigator.pop(context);
            },
            child: const Text('GUARDAR'),
          ),
        ],
      ),
    );
  }
}
